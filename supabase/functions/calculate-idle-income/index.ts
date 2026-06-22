// Edge Function: calculate-idle-income
// GDD §3.3–3.4 — Server-authoritative idle income calculation
// PROJECT_RULES §2 — TypeScript Edge Functions manage economy events.
//
// Auth strategy (Phase 3 directive):
//   Step 1: Verify caller identity via supabase.auth.getUser(token) — this
//           performs a cryptographic server-side JWT validation, not a raw
//           base64 decode. player_id is extracted from verified user.id only.
//   Step 2: Admin client (SERVICE_ROLE_KEY) executes all DB writes. brand_state
//           has no client UPDATE policy (GDD §8 — server-authoritative economy).
//
// CLOCK SPOOFING PREVENTION: server new Date() used, client clock IGNORED.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface BrandStateRow {
  idle_revenue_per_hour: number;
  total_revenue: number;
  momentum_buff_active: boolean;
  momentum_buff_until: string | null;
  last_active_at: string | null;
}

interface IdleIncomeResponse {
  earned_amount: number;
  new_total_revenue: number;
  multiplier: number;
  decay_factor: number;
  momentum_buff_active: boolean;
}

// GDD §3.4 — Decay constants
const FULL_RATE_HOURS = 24;
const DECAY_FLOOR = 0.40;
const MOMENTUM_BUFF_HOURS = 12;
// Guard: skip if less than 60 seconds elapsed (prevents rapid-foreground spam)
const MIN_ELAPSED_SECONDS = 60;

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  const correlationId = crypto.randomUUID();
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

    // Verify JWT cryptographically via Supabase Auth — rejects spoofed tokens.
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
    const { data: allowed, error: rateError } = await admin.rpc(
      "edge_consume_rate_limit",
      {
        p_actor_id: playerId,
        p_action: "idle_income",
        p_window_seconds: 300,
        p_max_requests: 10,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) {
      return new Response(
        JSON.stringify({ error: "RATE_LIMITED" }),
        { status: 429, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // Fetch brand state
    const { data: brandState, error: brandError } = await admin
      .from("brand_state")
      .select("idle_revenue_per_hour, total_revenue, momentum_buff_active, momentum_buff_until, last_active_at")
      .eq("player_id", playerId)
      .single<BrandStateRow>();

    if (brandError || !brandState) {
      return new Response(
        JSON.stringify({ error: "Brand state not found" }),
        { status: 404, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Step 3: Time delta (server NTP clock only) ─────────────────────────
    const now = new Date();
    const lastActive = brandState.last_active_at
      ? new Date(brandState.last_active_at)
      : now;

    const elapsedSeconds = (now.getTime() - lastActive.getTime()) / 1_000;

    // Guard: too soon — return 0 without writing (prevents log spam)
    if (elapsedSeconds < MIN_ELAPSED_SECONDS) {
      return new Response(
        JSON.stringify({
          earned_amount: 0,
          new_total_revenue: Number(brandState.total_revenue),
          multiplier: 1.0,
          decay_factor: 1.0,
          momentum_buff_active: brandState.momentum_buff_active,
        } satisfies IdleIncomeResponse),
        { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const elapsedHours = elapsedSeconds / 3_600;
    const baseRate = Number(brandState.idle_revenue_per_hour);

    // ── Step 4: Decay + momentum buff (GDD §3.4) ──────────────────────────
    let decayFactor = 1.0;
    if (elapsedHours > FULL_RATE_HOURS) {
      const decayProgress = Math.min(
        (elapsedHours - FULL_RATE_HOURS) / FULL_RATE_HOURS,
        1.0,
      );
      decayFactor = 1.0 - (1.0 - DECAY_FLOOR) * decayProgress;
    }

    const momentumActive = brandState.momentum_buff_until
      ? new Date(brandState.momentum_buff_until) > now
      : false;
    const multiplier = momentumActive ? 1.5 : decayFactor;

    const earnedAmount = baseRate * elapsedHours * multiplier;
    const newTotalRevenue = Number(brandState.total_revenue) + earnedAmount;

    // ── Step 5: Atomic writes (sequential — Supabase JS v2 no multi-tx) ───
    const momentumUntil = new Date(now.getTime() + MOMENTUM_BUFF_HOURS * 3_600_000);

    const { error: updateError } = await admin
      .from("brand_state")
      .update({
        last_active_at: now.toISOString(),
        total_revenue: newTotalRevenue,
        momentum_buff_active: true,
        momentum_buff_until: momentumUntil.toISOString(),
        updated_at: now.toISOString(),
      })
      .eq("player_id", playerId);

    if (updateError) {
      throw new Error(`brand_state update failed: ${updateError.message}`);
    }

    await admin.from("idle_income_log").insert({
      player_id: playerId,
      computed_at: now.toISOString(),
      amount: earnedAmount,
      multiplier,
      decay_factor: decayFactor,
    });

    // ── Step 6: Return delta to client ─────────────────────────────────────
    return new Response(
      JSON.stringify({
        earned_amount: earnedAmount,
        new_total_revenue: newTotalRevenue,
        multiplier,
        decay_factor: decayFactor,
        momentum_buff_active: true,
      } satisfies IdleIncomeResponse),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("calculate-idle-income", correlationId, err);
    return new Response(
      JSON.stringify({
        error: "IDLE_INCOME_FAILED",
        correlation_id: correlationId,
      }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});

