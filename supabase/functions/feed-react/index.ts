// Edge Function: feed-react
// Deduplicated HYPE/LIKE/SAVE feed reactions behind a verified user boundary.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface FeedReactRequest {
  post_id?: unknown;
  reaction_type?: unknown;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function errorStatus(message: string): number {
  if (message.includes("UNAUTHORIZED")) return 401;
  if (message.includes("POST_NOT_FOUND")) return 404;
  if (
    message.includes("INVALID_REACTION_TYPE") ||
    message.includes("invalid input syntax")
  ) {
    return 400;
  }
  return 500;
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

    const body = (await req.json()) as FeedReactRequest;
    const postId = typeof body.post_id === "string" ? body.post_id : "";
    const reactionType = typeof body.reaction_type === "string"
      ? body.reaction_type.trim().toLowerCase()
      : "";

    if (!postId) {
      return json({ error: "MISSING_POST_ID" }, 400);
    }
    if (!["hype", "like", "save"].includes(reactionType)) {
      return json({ error: "INVALID_REACTION_TYPE" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data, error } = await admin.rpc("edge_react_to_feed_post", {
      p_player_id: playerId,
      p_post_id: postId,
      p_reaction_type: reactionType,
    });

    if (error) {
      return json({ error: error.message }, errorStatus(error.message));
    }

    const row = Array.isArray(data) ? data[0] : data;
    if (!row) {
      return json({ error: "EMPTY_REACTION_RESPONSE" }, 500);
    }

    return json(row as Record<string, unknown>);
  } catch (err) {
    const message = (err as Error).message;
    console.error("feed-react error:", message);
    return json({ error: message }, errorStatus(message));
  }
});
