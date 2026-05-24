// Edge Function: mint-design
// GDD §4.1 — Server-authoritative Alpha design minting.
// PROJECT_RULES §2 — Client cannot dictate hype_score; server calculates it.
//
// Auth: same hybrid pattern as calculate-idle-income (Phase 3):
//   Step 1: verifyClient.auth.getUser(token) → cryptographic JWT check → player_id
//   Step 2: admin client (SERVICE_ROLE_KEY) executes all DB writes.
//
// hype_score is returned as a float literal (e.g. 73.45) so the Dart
// _SafeDouble JsonConverter handles it cleanly regardless of whole-number
// serialisation by Postgres.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient, type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface MintDesignRequest {
  fabric_color_hex?: unknown; // e.g. "C9A84C" - no leading #
  material_quality?: unknown;
  aesthetic_alignment?: unknown;
  style_tags?: unknown;
}

interface TrendRow {
  tag_name: string;
  multiplier: number | string;
}

interface TalentPoolRow {
  tier: string;
  base_hype_multiplier: number | string | null;
}

interface RosterTalentRow {
  talent_pool: TalentPoolRow | TalentPoolRow[] | null;
}

function clampNumber(value: unknown, min: number, max: number): number {
  const n = Number(value);
  if (!Number.isFinite(n)) return min;
  return Math.min(Math.max(n, min), max);
}

function normalizeStyleTags(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  return value
    .map((tag: unknown): string => String(tag).trim())
    .filter((tag: string): boolean => tag.length > 0)
    .slice(0, 8);
}

function normalizeTalentPool(row: RosterTalentRow): TalentPoolRow | null {
  if (Array.isArray(row.talent_pool)) {
    return row.talent_pool[0] ?? null;
  }
  return row.talent_pool;
}

async function resolveTrendMultiplier(
  admin: SupabaseClient,
  styleTags: string[],
): Promise<number> {
  if (styleTags.length === 0) return 1.0;

  const normalizedTags = new Set(
    styleTags.map((tag: string): string => tag.toLowerCase()),
  );
  const { data, error } = await admin
    .from("trend_tsunamis")
    .select("tag_name, multiplier")
    .gt("expires_at", new Date().toISOString());

  if (error) {
    console.error("trend_tsunamis lookup failed:", error.message);
    return 1.0;
  }

  const rows = (data ?? []) as TrendRow[];
  const hasMatch = rows.some((row: TrendRow): boolean =>
    normalizedTags.has(row.tag_name.toLowerCase())
  );

  return hasMatch ? 1.5 : 1.0;
}

async function resolveSovereignTalentBonus(
  admin: SupabaseClient,
  playerId: string,
): Promise<number> {
  const { data, error } = await admin
    .from("player_roster")
    .select("talent_pool(tier, base_hype_multiplier)")
    .eq("player_id", playerId)
    .limit(3);

  if (error) {
    console.error("player_roster talent lookup failed:", error.message);
    return 0.0;
  }

  const rows = (data ?? []) as RosterTalentRow[];
  const bonus = rows.reduce((total: number, row: RosterTalentRow): number => {
    const talent = normalizeTalentPool(row);
    if (!talent || talent.tier !== "sovereign") return total;

    const multiplier = clampNumber(talent.base_hype_multiplier, 1.0, 2.0);
    return total + (multiplier - 1.0) * 10.0;
  }, 0.0);

  return Math.min(bonus, 25.0);
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
    const body = (await req.json()) as MintDesignRequest;
    const fabricColorHex: string = String(body.fabric_color_hex ?? "FAF7F0")
      .replace(/^#/, "")
      .toUpperCase()
      .slice(0, 6);
    const materialQuality = clampNumber(body.material_quality ?? 50, 0, 100);
    const aestheticAlignment = clampNumber(body.aesthetic_alignment ?? 50, 0, 100);
    const styleTags = normalizeStyleTags(body.style_tags);

    // ── Step 3: Admin client for privileged DB ops ─────────────────────────
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // ── Step 4: Server-authoritative deterministic hype_score ──────────────
    const trendMultiplier = await resolveTrendMultiplier(admin, styleTags);
    const sovereignTalentBonus = await resolveSovereignTalentBonus(admin, playerId);

    const adjustedAesthetic = Math.min(aestheticAlignment * trendMultiplier, 100);
    const rawHype = adjustedAesthetic * (materialQuality / 100) + sovereignTalentBonus;
    const hypoScore: number = parseFloat(Math.min(rawHype, 100).toFixed(2));

    // ── Step 5: Generate design name deterministically ─────────────────────
    const suffix: string = Date.now().toString(36).toUpperCase().slice(-4);
    const designName: string = `ALPHA ${suffix}`;

    // ── Step 6: Insert into designs table ─────────────────────────────────
    const { data: design, error: insertError } = await admin
      .from("designs")
      .insert({
        player_id: playerId,
        owner_id: playerId,
        name: designName,
        session_type: "quick_sketch",
        status: "complete",
        hype_score: hypoScore,
        is_alpha: true,
        fabric_data: {
          color_hex: fabricColorHex,
          material_quality: materialQuality,
          aesthetic_alignment: aestheticAlignment,
          style_tags: styleTags,
        },
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
