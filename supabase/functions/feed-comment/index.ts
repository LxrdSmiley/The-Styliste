// Edge Function: feed-comment
// Appends a feed comment through a service-only RPC after JWT verification.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface FeedCommentRequest {
  post_id?: unknown;
  body?: unknown;
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
    message.includes("INVALID_COMMENT_BODY") ||
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

    const body = (await req.json()) as FeedCommentRequest;
    const postId = typeof body.post_id === "string" ? body.post_id : "";
    const commentBody = typeof body.body === "string" ? body.body.trim() : "";

    if (!postId) {
      return json({ error: "MISSING_POST_ID" }, 400);
    }
    if (commentBody.length < 1 || commentBody.length > 280) {
      return json({ error: "INVALID_COMMENT_BODY" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data, error } = await admin.rpc("edge_add_feed_comment", {
      p_player_id: playerId,
      p_post_id: postId,
      p_body: commentBody,
    });

    if (error) {
      return json({ error: error.message }, errorStatus(error.message));
    }

    const row = Array.isArray(data) ? data[0] : data;
    if (!row) {
      return json({ error: "EMPTY_COMMENT_RESPONSE" }, 500);
    }

    return json(row as Record<string, unknown>);
  } catch (err) {
    const message = (err as Error).message;
    console.error("feed-comment error:", message);
    return json({ error: message }, errorStatus(message));
  }
});
