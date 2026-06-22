// Edge Function: drop-design
// Publishes a completed Alpha design to feed through a service-only RPC.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface DropDesignRequest {
  design_id?: unknown;
  style_tags?: unknown;
  vex_review?: unknown;
  vex_quote?: unknown;
  vex_caption?: unknown;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function errorStatus(message: string): number {
  if (message.includes("UNAUTHORIZED")) return 401;
  if (message.includes("NOT_OWNED")) return 403;
  if (message.includes("NOT_FOUND")) return 404;
  if (
    message.includes("NOT_READY") ||
    message.includes("ALREADY_DROPPED") ||
    message.includes("invalid input syntax")
  ) {
    return 400;
  }
  return 500;
}

function normalizeTags(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  const seen = new Set<string>();
  const tags: string[] = [];
  for (const raw of value) {
    const tag = String(raw).trim().toLowerCase();
    if (!tag || seen.has(tag)) continue;
    seen.add(tag);
    tags.push(tag.slice(0, 48));
    if (tags.length >= 8) break;
  }
  return tags;
}

async function verifyUser(req: Request): Promise<string | Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return json({ error: "MISSING_AUTH" }, 401);
  }

  const token = authHeader.replace("Bearer ", "");
  const verifyClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user }, error } = await verifyClient.auth.getUser(token);

  if (error || !user) {
    return json({ error: "UNAUTHORIZED" }, 401);
  }

  return user.id;
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return json({ error: "METHOD_NOT_ALLOWED" }, 405);
  }

  try {
    const verified = await verifyUser(req);
    if (verified instanceof Response) return verified;
    const playerId = verified;

    const body = (await req.json()) as DropDesignRequest;
    const designId = typeof body.design_id === "string" ? body.design_id : "";
    if (!designId) {
      return json({ error: "MISSING_DESIGN_ID" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data: allowed, error: rateError } = await admin.rpc(
      "edge_consume_rate_limit",
      {
        p_actor_id: playerId,
        p_action: "drop_design",
        p_window_seconds: 600,
        p_max_requests: 10,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: "RATE_LIMITED" }, 429);

    const { data, error } = await admin.rpc("edge_drop_design", {
      p_player_id: playerId,
      p_design_id: designId,
      p_style_tags: normalizeTags(body.style_tags),
      p_vex_review: body.vex_review ?? null,
      p_vex_quote: typeof body.vex_quote === "string" ? body.vex_quote : null,
      p_vex_caption: typeof body.vex_caption === "string" ? body.vex_caption : null,
    });

    if (error) {
      const status = errorStatus(error.message);
      const safeCode = status === 403
        ? "DESIGN_NOT_OWNED"
        : status === 404
        ? "DESIGN_NOT_FOUND"
        : status === 400
        ? "DROP_NOT_READY"
        : "DROP_FAILED";
      console.error("drop-design RPC error:", error.message);
      return json({ error: safeCode }, status);
    }

    const row = Array.isArray(data) ? data[0] : data;
    if (!row) {
      return json({ error: "EMPTY_DROP_RESPONSE" }, 500);
    }

    return json(row as Record<string, unknown>);
  } catch (err) {
    const message = (err as Error).message;
    console.error("drop-design error:", message);
    return json({ error: "DROP_FAILED" }, errorStatus(message));
  }
});
