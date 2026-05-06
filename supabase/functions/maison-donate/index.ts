// Edge Function: maison-donate
// GDD §7.2 — Phase 8: Maison Treasury Engine
// Hybrid JWT/Service Role pattern (identical to process-transaction).
//
// Auth flow:
//   Step 1: verifyClient.auth.getUser(token) — cryptographic identity.
//   Step 2: adminClient (SERVICE_ROLE_KEY) executes all privileged DB writes.
//
// Write path (append-only ledger, no treasury row-lock contention):
//   1. Deduct amount from brand_state.total_revenue (player's own row — no shared contention).
//   2. INSERT into maison_treasury_ledger — zero contention, any concurrency level.
//   3. Postgres AFTER INSERT trigger fn_on_donation_insert() materializes treasury.
//
// Float precision: all NUMERIC writes wrapped in parseFloat((...).toFixed(4)).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const safeFloat = (n: number): number => parseFloat(n.toFixed(4));

interface DonateRequest {
  amount: number;
}

interface BrandStateRow {
  player_id: string;
  total_revenue: number;
}

interface MaisonMemberRow {
  maison_id: string;
  player_id: string;
  role: string;
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // ── Step 1: JWT identity verification ──────────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "MISSING_AUTH" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }
    const token = authHeader.replace("Bearer ", "");

    const verifyClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );
    const { data: { user }, error: authError } = await verifyClient.auth.getUser(token);
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "INVALID_TOKEN" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }
    const uid = user.id;

    // ── Step 2: Parse + validate payload ───────────────────────────────────
    const body: DonateRequest = await req.json();
    const rawAmount = body?.amount;
    if (typeof rawAmount !== "number" || rawAmount <= 0 || !isFinite(rawAmount)) {
      return new Response(
        JSON.stringify({ error: "INVALID_AMOUNT" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }
    // Slider is rounded to whole number on client; enforce integer floor server-side too.
    const amount = safeFloat(Math.floor(rawAmount));
    if (amount <= 0) {
      return new Response(
        JSON.stringify({ error: "INVALID_AMOUNT" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Step 3: Service role admin client ───────────────────────────────────
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // ── Step 4: Membership check ────────────────────────────────────────────
    const { data: memberRows, error: memberErr } = await admin
      .from("maison_members")
      .select("maison_id, player_id, role")
      .eq("player_id", uid)
      .limit(1);

    if (memberErr) throw new Error(`Membership query failed: ${memberErr.message}`);
    if (!memberRows || memberRows.length === 0) {
      return new Response(
        JSON.stringify({ error: "NOT_A_MEMBER" }),
        { status: 403, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }
    const maisonId = (memberRows[0] as MaisonMemberRow).maison_id;

    // ── Step 5: Funds check ─────────────────────────────────────────────────
    const { data: brandRows, error: brandErr } = await admin
      .from("brand_state")
      .select("player_id, total_revenue")
      .eq("player_id", uid)
      .limit(1);

    if (brandErr) throw new Error(`Brand state query failed: ${brandErr.message}`);
    const brandState = brandRows?.[0] as BrandStateRow | undefined;
    const currentBalance = brandState?.total_revenue ?? 0;

    if (currentBalance < amount) {
      return new Response(
        JSON.stringify({
          error: "INSUFFICIENT_CAPITAL",
          balance: currentBalance,
          required: amount,
        }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Step 6: ACID writes — deduct player balance, insert ledger row ──────
    // Sequential (not concurrent): deduct first, then ledger INSERT.
    // Trigger fn_on_donation_insert materializes maisons.treasury in same txn.

    const newBalance = safeFloat(currentBalance - amount);
    const { error: deductErr } = await admin
      .from("brand_state")
      .update({ total_revenue: newBalance })
      .eq("player_id", uid);

    if (deductErr) throw new Error(`Deduct failed: ${deductErr.message}`);

    const { error: ledgerErr } = await admin
      .from("maison_treasury_ledger")
      .insert({
        maison_id: maisonId,
        player_id: uid,
        amount: amount,
      });

    if (ledgerErr) {
      // Compensating transaction: refund the deduction on ledger failure.
      await admin
        .from("brand_state")
        .update({ total_revenue: safeFloat(currentBalance) })
        .eq("player_id", uid);
      throw new Error(`Ledger insert failed: ${ledgerErr.message}`);
    }

    return new Response(
      JSON.stringify({
        success: true,
        new_balance: newBalance,
        maison_id: maisonId,
        donated: amount,
      }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("maison-donate error:", (err as Error).message);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
