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

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);

  const correlationId = crypto.randomUUID();
  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "MISSING_AUTH" }, 401);

    const verifier = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );
    const { data: { user }, error: authError } = await verifier.auth.getUser(
      authHeader.slice("Bearer ".length),
    );
    if (authError || !user) return json({ error: "UNAUTHORIZED" }, 401);

    const body = await req.json() as Record<string, unknown>;
    const city = typeof body.city === "string" ? body.city : "";
    const storeType = typeof body.store_type === "string" ? body.store_type : "";
    const priceTier = typeof body.price_tier === "string" ? body.price_tier : "";
    const inventoryCapacity = typeof body.inventory_capacity === "number"
      ? Math.trunc(body.inventory_capacity)
      : 0;
    const idempotencyKey = typeof body.idempotency_key === "string"
      ? body.idempotency_key
      : "";
    if (!city || !storeType || !priceTier || !idempotencyKey || inventoryCapacity <= 0) {
      return json({ error: "INVALID_PAYLOAD" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const { data: allowed, error: rateError } = await admin.rpc(
      "edge_consume_rate_limit",
      {
        p_actor_id: user.id,
        p_action: "open_first_store",
        p_window_seconds: 300,
        p_max_requests: 5,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: "RATE_LIMITED" }, 429);

    const { data, error } = await admin.rpc("edge_open_first_store_atomic", {
      p_player_id: user.id,
      p_city: city,
      p_store_type: storeType,
      p_price_tier: priceTier,
      p_inventory_capacity: inventoryCapacity,
      p_idempotency_key: idempotencyKey,
    });
    if (error) throw error;
    return json(data as Record<string, unknown>);
  } catch (error) {
    console.error("open-first-store", correlationId, error);
    const message = error instanceof Error ? error.message : "";
    if (message.includes("INSUFFICIENT_CAPITAL")) {
      return json({ error: "INSUFFICIENT_CAPITAL" }, 409);
    }
    if (message.includes("MOGUL_ONLY")) return json({ error: "MOGUL_ONLY" }, 403);
    if (message.includes("FIRST_STORE_ALREADY_OPEN")) {
      return json({ error: "FIRST_STORE_ALREADY_OPEN" }, 409);
    }
    if (message.includes("INVALID_")) return json({ error: message }, 400);
    return json({ error: "STORE_OPEN_FAILED", correlation_id: correlationId }, 500);
  }
});
