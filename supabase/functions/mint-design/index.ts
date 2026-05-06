// Edge Function: mint-design
// GDD §4.1 — Server-authoritative Alpha design minting.
// PROJECT_RULES §2 — Client cannot dictate hype_score; server generates it.
//
// Auth: same hybrid pattern as calculate-idle-income (Phase 3):
//   Step 1: verifyClient.auth.getUser(token) → cryptographic JWT check → player_id
//   Step 2: admin client (SERVICE_ROLE_KEY) executes all DB writes.
//
// hype_score is returned as a float literal (e.g. 73.45) so the Dart
// _SafeDouble JsonConverter handles it cleanly regardless of whole-number
// serialisation by Postgres.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface MintDesignRequest {
  fabric_color_hex: string; // e.g. "C9A84C" — no leading #
}

interface PlayerRow {
  brand_rank: number;
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

    // ── Step 2: Parse client body ──────────────────────────────────────────
    const body: MintDesignRequest = await req.json();
    const fabricColorHex: string = (body.fabric_color_hex ?? "FAF7F0")
      .replace(/^#/, "")
      .toUpperCase()
      .slice(0, 6);

    // ── Step 3: Admin client for privileged DB ops ─────────────────────────
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // Read brand_rank from players to weight hype_score.
    const { data: player } = await admin
      .from("players")
      .select("brand_rank")
      .eq("id", playerId)
      .single<PlayerRow>();

    const brandRank: number = player?.brand_rank ?? 1;

    // ── Step 4: Server-generated weighted hype_score ───────────────────────
    // Range: 10–100. Brand rank adds up to +25 bonus (rank 1–50 scale).
    // Always a float — multiply by 1.0 to guarantee non-integer serialisation.
    const baseHype: number = Math.random() * 70.0 + 30.0;
    const rankBonus: number = Math.min(brandRank * 0.5, 25.0);
    const rawHype: number = baseHype + rankBonus;
    const hypoScore: number = parseFloat(Math.min(rawHype, 100.0).toFixed(2));

    // ── Step 5: Generate design name deterministically ─────────────────────
    const suffix: string = Date.now().toString(36).toUpperCase().slice(-4);
    const designName: string = `ALPHA ${suffix}`;

    // ── Step 6: Insert into designs table ─────────────────────────────────
    const { data: design, error: insertError } = await admin
      .from("designs")
      .insert({
        player_id: playerId,
        name: designName,
        session_type: "quick_sketch",
        status: "complete",
        hype_score: hypoScore,
        is_alpha: true,
        fabric_data: { color_hex: fabricColorHex },
      })
      .select()
      .single();

    if (insertError || !design) {
      throw new Error(`designs insert failed: ${insertError?.message}`);
    }

    return new Response(JSON.stringify(design), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
