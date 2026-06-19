// Edge Function: trend-decay
// PROJECT_RULES §2 — TypeScript manages global trend decay and seasonal meta shifts
// GDD §8.1 — Triggered via Supabase Cron (daily)
// Decays brand heat scores, updates seasonal trend scores, pushes Realtime events.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// GDD §8.9.7 — Heat decays 1–3 points/day without active play
const HEAT_DECAY_MIN = 1;
const HEAT_DECAY_MAX = 3;

serve(async (_req: Request): Promise<Response> => {
  // ── SEC-01: Cron-secret authorization gate ────────────────────────────
  // Fail-closed: missing env var = 500, wrong/missing header = 401.
  const expectedSecret = Deno.env.get("CRON_SECRET");
  if (!expectedSecret) {
    console.error("trend-decay: CRON_SECRET not configured — rejecting.");
    return new Response(
      JSON.stringify({ error: "Server misconfigured" }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
  const cronSecret = _req.headers.get("x-cron-secret");
  if (cronSecret !== expectedSecret) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const now = new Date();
    const oneDayAgo = new Date(now.getTime() - 86_400_000);

    // Fetch all brand states where player was not active today
    const { data: inactiveBrands, error } = await supabase
      .from("brand_state")
      .select("player_id, heat, last_active_at")
      .lt("last_active_at", oneDayAgo.toISOString());

    if (error) {
      throw new Error(error.message);
    }

    let decayCount = 0;

    if (inactiveBrands && inactiveBrands.length > 0) {
      for (const brand of inactiveBrands) {
        const decayAmount = Math.floor(
          Math.random() * (HEAT_DECAY_MAX - HEAT_DECAY_MIN + 1) + HEAT_DECAY_MIN,
        );
        const newHeat = Math.max(0, (brand.heat as number) - decayAmount);

        await supabase
          .from("brand_state")
          .update({ heat: newHeat })
          .eq("player_id", brand.player_id);

        decayCount++;
      }
    }

    // AI_UNCERTAINTY: TS-214 tracks the remaining seasonal-meta decay rollout:
    // 1. Update seasonal trend meta (colour palettes, silhouettes, fabrics)
    // 2. Push Realtime event to all connected clients with new trend scores
    // 3. Apply "outdated design" penalties for misaligned drops
    // 4. Trigger Celebrity Micro-Trend weekly event roll (GDD §8.1.1)

    console.log(`trend-decay: applied heat decay to ${decayCount} inactive brands`);

    return new Response(
      JSON.stringify({ status: "decay_complete", brands_processed: decayCount }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
