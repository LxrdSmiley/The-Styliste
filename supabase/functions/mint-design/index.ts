import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function safeError(error: unknown): Response {
  const correlationId = crypto.randomUUID();
  console.error("mint-design", correlationId, error);
  const message = error instanceof Error ? error.message : "";
  if (message.includes("INTERACTION_REQUIRED")) {
    return json({ error: "ATELIER_INTERACTION_REQUIRED" }, 409);
  }
  if (message.includes("EXPIRED")) return json({ error: "ATELIER_SESSION_EXPIRED" }, 409);
  if (message.includes("NOT_FOUND")) return json({ error: "ATELIER_SESSION_NOT_FOUND" }, 404);
  return json({ error: "MINT_FAILED", correlation_id: correlationId }, 500);
}

function normalizeTags(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return [...new Set(value.map((tag) => String(tag).trim().toLowerCase()).filter(Boolean))]
    .slice(0, 3)
    .map((tag) => tag.slice(0, 48));
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "MISSING_AUTH" }, 401);
    const token = authHeader.slice("Bearer ".length);
    const verifyClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: authError } = await verifyClient.auth.getUser(token);
    if (authError || !user) return json({ error: "UNAUTHORIZED" }, 401);

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data: allowed, error: rateError } = await admin.rpc(
      "edge_consume_rate_limit",
      {
        p_actor_id: user.id,
        p_action: "atelier_mint",
        p_window_seconds: 600,
        p_max_requests: 20,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: "RATE_LIMITED" }, 429);
    const body = await req.json() as Record<string, unknown>;

    if (body.action === "start") {
      const rawColor = String(body.fabric_color_hex ?? "FAF7F0")
        .replace(/[^0-9a-f]/gi, "")
        .toUpperCase()
        .slice(0, 6);
      const { data, error } = await admin.rpc("edge_start_atelier_session", {
        p_player_id: user.id,
        p_fabric_color_hex: rawColor,
        p_style_tags: normalizeTags(body.style_tags),
      });
      if (error) throw error;
      return json(data as Record<string, unknown>, 201);
    }

    if (body.action === "mint") {
      const sessionId = typeof body.session_id === "string" ? body.session_id : "";
      if (!sessionId) return json({ error: "MISSING_SESSION_ID" }, 400);
      const { data: updated, error: updateError } = await admin.rpc(
        "edge_update_atelier_session",
        {
          p_player_id: user.id,
          p_session_id: sessionId,
          p_fabric_color_hex: String(body.fabric_color_hex ?? "FAF7F0"),
          p_style_tags: normalizeTags(body.style_tags),
        },
      );
      if (updateError) throw updateError;
      if (!updated) return json({ error: "ATELIER_SESSION_NOT_FOUND" }, 404);
      const { data, error } = await admin.rpc("edge_mint_atelier_session", {
        p_player_id: user.id,
        p_session_id: sessionId,
      });
      if (error) throw error;
      return json(data as Record<string, unknown>);
    }

    return json({ error: "INVALID_ACTION" }, 400);
  } catch (error) {
    return safeError(error);
  }
});
