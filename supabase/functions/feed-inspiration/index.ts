// Edge Function: feed-inspiration
// Permissioned design inspiration and feed collab requests behind JWT checks.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type FeedInspirationAction =
  | "request_inspiration"
  | "respond_inspiration"
  | "request_collab"
  | "respond_collab";

interface FeedInspirationRequest {
  action?: unknown;
  post_id?: unknown;
  request_id?: unknown;
  approve?: unknown;
  message?: unknown;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function errorStatus(message: string): number {
  if (
    message.includes("UNAUTHORIZED") ||
    message.includes("SERVICE_ROLE_REQUIRED")
  ) {
    return 401;
  }
  if (message.includes("NOT_FOUND") || message.includes("MISSING")) {
    return 404;
  }
  if (
    message.includes("NOT_ARTISAN") ||
    message.includes("CANNOT_REQUEST_OWN") ||
    message.includes("NOT_DESIGN_DROP")
  ) {
    return 403;
  }
  if (
    message.includes("INVALID") ||
    message.includes("duplicate key") ||
    message.includes("invalid input syntax")
  ) {
    return 400;
  }
  return 500;
}

function actionFrom(value: unknown): FeedInspirationAction | null {
  if (typeof value !== "string") return null;
  const action = value.trim().toLowerCase();
  if (
    action === "request_inspiration" ||
    action === "respond_inspiration" ||
    action === "request_collab" ||
    action === "respond_collab"
  ) {
    return action;
  }
  return null;
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

    const body = (await req.json()) as FeedInspirationRequest;
    const action = actionFrom(body.action);
    if (action === null) {
      return json({ error: "INVALID_ACTION" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data: allowed, error: rateError } = await admin.rpc(
      "edge_consume_rate_limit",
      {
        p_actor_id: playerId,
        p_action: "feed_inspiration",
        p_window_seconds: 300,
        p_max_requests: 10,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: "RATE_LIMITED" }, 429);

    let rpcName = "";
    let params: Record<string, unknown> = {};

    switch (action) {
      case "request_inspiration": {
        const postId = typeof body.post_id === "string" ? body.post_id : "";
        if (!postId) return json({ error: "MISSING_POST_ID" }, 400);
        rpcName = "edge_request_design_inspiration";
        params = {
          p_requester_id: playerId,
          p_post_id: postId,
          p_message: typeof body.message === "string" ? body.message : null,
        };
        break;
      }
      case "respond_inspiration": {
        const requestId = typeof body.request_id === "string" ? body.request_id : "";
        if (!requestId) return json({ error: "MISSING_REQUEST_ID" }, 400);
        rpcName = "edge_respond_design_inspiration";
        params = {
          p_recipient_id: playerId,
          p_request_id: requestId,
          p_approve: body.approve === true,
        };
        break;
      }
      case "request_collab": {
        const postId = typeof body.post_id === "string" ? body.post_id : "";
        if (!postId) return json({ error: "MISSING_POST_ID" }, 400);
        rpcName = "edge_request_feed_collab";
        params = {
          p_requester_id: playerId,
          p_post_id: postId,
          p_message: typeof body.message === "string" ? body.message : null,
        };
        break;
      }
      case "respond_collab": {
        const requestId = typeof body.request_id === "string" ? body.request_id : "";
        if (!requestId) return json({ error: "MISSING_REQUEST_ID" }, 400);
        rpcName = "edge_respond_feed_collab";
        params = {
          p_recipient_id: playerId,
          p_request_id: requestId,
          p_approve: body.approve === true,
        };
        break;
      }
    }

    const { data, error } = await admin.rpc(rpcName, params);
    if (error) {
      const status = errorStatus(error.message);
      console.error("feed-inspiration RPC error:", error.message);
      return json(
        { error: status === 403 ? "INSPIRATION_FORBIDDEN" : "INSPIRATION_FAILED" },
        status,
      );
    }
    if (!data) {
      return json({ error: "EMPTY_RESPONSE" }, 500);
    }

    return json(data as Record<string, unknown>);
  } catch (err) {
    const message = (err as Error).message;
    console.error("feed-inspiration error:", message);
    return json({ error: "INSPIRATION_FAILED" }, errorStatus(message));
  }
});
