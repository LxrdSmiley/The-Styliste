// Edge Function: process-transaction
// PROJECT_RULES §2 — Server-authoritative economy mutations (Phase 5).
// ALL capital allocation events route through here. Never trust client amounts.
//
// Auth: hybrid JWT/service-role pattern (same as calculate-idle-income).
//   Step 1: verifyClient.auth.getUser(token) — cryptographic identity check.
//   Step 2: admin client (SERVICE_ROLE_KEY) executes all privileged DB writes.
//
// Float precision: all computed numeric values are wrapped in
//   parseFloat((...).toFixed(4)) before Postgres writes to prevent JS
//   floating-point trailing decimals causing NUMERIC scale rejection.
//
// Supported actions (Phase 5): upgrade_store
// Reserved (Phase 6+): open_store, launch_campaign, draw_loan, repay_loan,
//   buy_equity, sell_equity, pay_talent_salary

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// --- Constants ---
const UPGRADE_BASE_COST = 500.0;
const UPGRADE_COST_EXPONENT = 1.5;
const UPGRADE_REVENUE_MULTIPLIER = 1.4;

interface TransactionRequest {
  action: string;
  store_id?: string;
}

interface StoreRow {
  id: string;
  player_id: string;
  tier: number;
  revenue_per_hour: number;
}

interface BrandStateRow {
  total_revenue: number;
  idle_revenue_per_hour: number;
}

// Safely coerce a value to a 4-decimal float — prevents JS trailing decimals
// from causing Postgres NUMERIC scale rejection errors.
function safeFloat(value: number, decimals = 4): number {
  return parseFloat(value.toFixed(decimals));
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // ── Step 1: Cryptographic JWT verification ─────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Missing or malformed Authorization header" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }
    const token = authHeader.replace("Bearer ", "");

    const verifyClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: authError } = await verifyClient.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const playerId: string = user.id;

    // ── Step 2: Admin client for privileged DB ops ─────────────────────────
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // ── Step 3: Parse and dispatch action ─────────────────────────────────
    const body: TransactionRequest = await req.json();
    const { action } = body;

    if (action === "upgrade_store") {
      return await handleUpgradeStore(admin, playerId, body.store_id ?? "");
    }

    return new Response(
      JSON.stringify({ error: `Unknown action: ${action}` }),
      { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});

// ---------------------------------------------------------------------------
// Action: upgrade_store
// ---------------------------------------------------------------------------
async function handleUpgradeStore(
  admin: ReturnType<typeof createClient>,
  playerId: string,
  storeId: string,
): Promise<Response> {
  if (!storeId) {
    return new Response(
      JSON.stringify({ error: "store_id is required for upgrade_store" }),
      { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }

  // Fetch store and brand_state in parallel.
  const [storeResult, brandResult] = await Promise.all([
    admin.from("stores").select("id, player_id, tier, revenue_per_hour").eq("id", storeId).single<StoreRow>(),
    admin.from("brand_state").select("total_revenue, idle_revenue_per_hour").eq("player_id", playerId).single<BrandStateRow>(),
  ]);

  if (storeResult.error || !storeResult.data) {
    return new Response(
      JSON.stringify({ error: "Store not found" }),
      { status: 404, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
  if (brandResult.error || !brandResult.data) {
    return new Response(
      JSON.stringify({ error: "Brand state not found" }),
      { status: 404, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }

  const store = storeResult.data;
  const brandState = brandResult.data;

  // Ownership check — prevent cross-player exploits.
  if (store.player_id !== playerId) {
    return new Response(
      JSON.stringify({ error: "Forbidden" }),
      { status: 403, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }

  // Server-computed cost — never trusted from client.
  const cost = safeFloat(UPGRADE_BASE_COST * Math.pow(UPGRADE_COST_EXPONENT, store.tier));
  const currentBalance = Number(brandState.total_revenue);

  // Funds check — explicit 400 so client can surface "INSUFFICIENT CAPITAL".
  if (currentBalance < cost) {
    return new Response(
      JSON.stringify({
        error: "INSUFFICIENT_CAPITAL",
        cost,
        balance: safeFloat(currentBalance),
      }),
      { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }

  // Computed values — all wrapped in safeFloat() to prevent JS precision drift.
  const newTier = store.tier + 1;
  const newRevenuePerHour = safeFloat(Number(store.revenue_per_hour) * UPGRADE_REVENUE_MULTIPLIER);
  const newTotalRevenue = safeFloat(currentBalance - cost);

  // ── Atomic writes (sequential — Supabase JS v2 no multi-tx) ────────────
  const { error: storeUpdateError } = await admin
    .from("stores")
    .update({ tier: newTier, revenue_per_hour: newRevenuePerHour })
    .eq("id", storeId);

  if (storeUpdateError) {
    throw new Error(`stores update failed: ${storeUpdateError.message}`);
  }

  // Recalculate idle_revenue_per_hour = sum of all store revenue_per_hour for player.
  const { data: allStores } = await admin
    .from("stores")
    .select("revenue_per_hour")
    .eq("player_id", playerId);

  const newRevenueIdle = safeFloat(
    (allStores ?? []).reduce((sum: number, s: { revenue_per_hour: number }) => sum + Number(s.revenue_per_hour), 0),
  );

  const { error: brandUpdateError } = await admin
    .from("brand_state")
    .update({
      total_revenue: newTotalRevenue,
      idle_revenue_per_hour: newRevenueIdle,
      updated_at: new Date().toISOString(),
    })
    .eq("player_id", playerId);

  if (brandUpdateError) {
    throw new Error(`brand_state update failed: ${brandUpdateError.message}`);
  }

  return new Response(
    JSON.stringify({
      success: true,
      new_tier: newTier,
      new_revenue_per_hour: newRevenuePerHour,
      new_total_revenue: newTotalRevenue,
      new_idle_revenue_per_hour: newRevenueIdle,
    }),
    { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
  );
}

