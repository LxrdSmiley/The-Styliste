import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "content-type, x-cron-secret",
};

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

async function sameSecret(left: string, right: string): Promise<boolean> {
  if (!left || !right || left.length !== right.length) return false;
  const encoder = new TextEncoder();
  const [a, b] = await Promise.all([
    crypto.subtle.digest("SHA-256", encoder.encode(left)),
    crypto.subtle.digest("SHA-256", encoder.encode(right)),
  ]);
  const av = new Uint8Array(a);
  const bv = new Uint8Array(b);
  let diff = 0;
  for (let i = 0; i < av.length; i++) diff |= av[i] ^ bv[i];
  return diff === 0;
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);

  const expected = Deno.env.get("CRON_INVOKE_SECRET") ?? "";
  if (expected.length < 32) {
    console.error("trend-decay: CRON_INVOKE_SECRET is missing or too short");
    return json({ error: "SERVICE_NOT_CONFIGURED" }, 503);
  }
  if (!await sameSecret(req.headers.get("x-cron-secret") ?? "", expected)) {
    return json({ error: "UNAUTHORIZED" }, 401);
  }

  const correlationId = crypto.randomUUID();
  try {
    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const periodKey = new Date().toISOString().slice(0, 10);
    const { data: claimed, error: claimError } = await admin.rpc("edge_claim_job_run", {
      p_job_key: "trend_decay",
      p_period_key: periodKey,
    });
    if (claimError) throw claimError;
    if (!claimed) return json({ status: "already_complete", period: periodKey });

    const oneDayAgo = new Date(Date.now() - 86_400_000).toISOString();
    const { data: inactiveBrands, error } = await admin
      .from("brand_state")
      .select("player_id, heat")
      .lt("last_active_at", oneDayAgo);
    if (error) throw error;

    let processed = 0;
    for (const brand of inactiveBrands ?? []) {
      const currentHeat = Number(brand.heat ?? 0);
      const decay = 1 + Math.floor(Math.random() * 3);
      const { error: updateError } = await admin
        .from("brand_state")
        .update({ heat: Math.max(0, currentHeat - decay) })
        .eq("player_id", brand.player_id);
      if (updateError) throw updateError;
      processed++;
    }
    return json({ status: "decay_complete", brands_processed: processed });
  } catch (error) {
    console.error("trend-decay", correlationId, error);
    return json({ error: "TREND_DECAY_FAILED", correlation_id: correlationId }, 500);
  }
});
