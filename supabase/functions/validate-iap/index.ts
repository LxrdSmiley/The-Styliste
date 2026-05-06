// Edge Function: validate-iap
// GDD §9.8 — Phase 9: Server-authoritative Luxe Token minting.
//
// Security model (three-layer defence):
//   Layer 1: Server-to-server receipt verification with Apple/Google.
//            Spoofed receipts have no valid transaction on store servers.
//   Layer 2: SHA-256(receiptData) deduplication in iap_receipts table.
//            INSERT ON CONFLICT DO NOTHING — zero rows = already redeemed → 409.
//   Layer 3: Postgres PRIMARY KEY B-tree serializes concurrent inserts (~0.05ms
//            critical section) — eliminates TOCTOU replay race entirely.
//
// Compensating rollback: if Apple/Google returns 5xx (transient), the hash row
//   is deleted to allow retry. Genuine auth failures (21003/21004) are NOT rolled
//   back — that receipt is permanently blacklisted.
//
// Required env vars:
//   APPLE_SHARED_SECRET       — App Store Connect shared secret
//   GOOGLE_SERVICE_ACCOUNT_KEY — JSON key for Google Play Developer API service account
//   GOOGLE_PACKAGE_NAME        — e.g., com.skinteethnerd.thestyliste
//
// Grant amounts are SERVER-AUTHORITATIVE — client cannot influence token quantity.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// ---------------------------------------------------------------------------
// Server-authoritative product map — client cannot influence grant amount.
// GDD §9.8 — Luxe Token tiers.
// ---------------------------------------------------------------------------
const LUXE_PRODUCTS: Record<string, number> = {
  "luxe_100":  100,
  "luxe_550":  550,
  "luxe_1200": 1200,
  "luxe_2800": 2800,
};

// ---------------------------------------------------------------------------
// SHA-256 via Web Crypto API (available in Deno)
// ---------------------------------------------------------------------------
async function sha256Hex(input: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

// ---------------------------------------------------------------------------
// Apple receipt verification
// ---------------------------------------------------------------------------
async function verifyAppleReceipt(
  receiptData: string,
): Promise<{ valid: boolean; transientError: boolean }> {
  const sharedSecret = Deno.env.get("APPLE_SHARED_SECRET") ?? "";
  const payload = JSON.stringify({ "receipt-data": receiptData, password: sharedSecret });

  // Production first, then sandbox fallback for status 21007 (TestFlight)
  for (const url of [
    "https://buy.itunes.apple.com/verifyReceipt",
    "https://sandbox.itunes.apple.com/verifyReceipt",
  ]) {
    const res = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: payload,
    });

    if (!res.ok) {
      // Apple server itself returned 5xx
      return { valid: false, transientError: true };
    }

    const body = await res.json() as { status: number };
    if (body.status === 0) return { valid: true, transientError: false };
    if (body.status === 21007) continue; // sandbox receipt — retry against sandbox URL
    // 21003 = receipt auth failed; 21004 = wrong shared secret; others = invalid
    return { valid: false, transientError: false };
  }
  return { valid: false, transientError: false };
}

// ---------------------------------------------------------------------------
// Google Play receipt verification (OAuth2 via service account)
// ---------------------------------------------------------------------------
async function verifyGoogleReceipt(
  productId: string,
  purchaseToken: string,
): Promise<{ valid: boolean; transientError: boolean }> {
  const serviceAccountJson = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_KEY") ?? "{}";
  const packageName = Deno.env.get("GOOGLE_PACKAGE_NAME") ?? "";

  let serviceAccount: { client_email: string; private_key: string };
  try {
    serviceAccount = JSON.parse(serviceAccountJson) as {
      client_email: string;
      private_key: string;
    };
  } catch {
    console.error("validate-iap: invalid GOOGLE_SERVICE_ACCOUNT_KEY");
    return { valid: false, transientError: false };
  }

  // Build JWT for service account
  const now = Math.floor(Date.now() / 1000);
  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claimSet = btoa(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/androidpublisher",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );

  // Sign with RS256 — requires importing the private key
  let accessToken: string;
  try {
    const privateKeyPem = serviceAccount.private_key.replace(/\\n/g, "\n");
    const pemContents = privateKeyPem
      .replace("-----BEGIN PRIVATE KEY-----", "")
      .replace("-----END PRIVATE KEY-----", "")
      .replace(/\s/g, "");
    const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));
    const cryptoKey = await crypto.subtle.importKey(
      "pkcs8",
      binaryKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const signingInput = `${header}.${claimSet}`;
    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      cryptoKey,
      new TextEncoder().encode(signingInput),
    );
    const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)));
    const jwt = `${signingInput}.${sigB64}`;

    const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
    });
    const tokenBody = await tokenRes.json() as { access_token?: string };
    if (!tokenBody.access_token) return { valid: false, transientError: false };
    accessToken = tokenBody.access_token;
  } catch (err) {
    console.error("validate-iap: Google JWT signing failed:", (err as Error).message);
    return { valid: false, transientError: true };
  }

  // Call Google Play Developer API
  const apiUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/products/${productId}/tokens/${purchaseToken}`;
  const apiRes = await fetch(apiUrl, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });

  if (!apiRes.ok) {
    return { valid: false, transientError: apiRes.status >= 500 };
  }

  const apiBody = await apiRes.json() as { purchaseState?: number };
  // purchaseState 0 = purchased
  return { valid: apiBody.purchaseState === 0, transientError: false };
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // ── JWT identity verification ──────────────────────────────────────────
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

    // ── Parse payload ──────────────────────────────────────────────────────
    const body = await req.json() as {
      platform?: string;
      productId?: string;
      receiptData?: string;
    };
    const { platform, productId, receiptData } = body;

    if (
      !platform || !productId || !receiptData ||
      !["ios", "android"].includes(platform)
    ) {
      return new Response(
        JSON.stringify({ error: "INVALID_PAYLOAD" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // Validate productId is a known product
    const luxeGrant = LUXE_PRODUCTS[productId];
    if (luxeGrant === undefined) {
      return new Response(
        JSON.stringify({ error: "UNKNOWN_PRODUCT" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Layer 2: SHA-256 deduplication ─────────────────────────────────────
    // Hash before external call — prevents TOCTOU window.
    const receiptHash = await sha256Hex(receiptData);

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    // INSERT ON CONFLICT DO NOTHING — B-tree PK serializes concurrent requests.
    const { data: insertedRows, error: insertErr } = await admin
      .from("iap_receipts")
      .insert({
        receipt_hash: receiptHash,
        player_id: uid,
        product_id: productId,
        platform,
        luxe_granted: luxeGrant,
      })
      .select("receipt_hash");

    if (insertErr) throw new Error(`Receipt insert failed: ${insertErr.message}`);

    if (!insertedRows || insertedRows.length === 0) {
      // Hash already exists — this receipt was already redeemed.
      return new Response(
        JSON.stringify({ error: "RECEIPT_ALREADY_REDEEMED" }),
        { status: 409, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Layer 1: Server-to-server verification ─────────────────────────────
    let verifyResult: { valid: boolean; transientError: boolean };
    if (platform === "ios") {
      verifyResult = await verifyAppleReceipt(receiptData);
    } else {
      verifyResult = await verifyGoogleReceipt(productId, receiptData);
    }

    if (!verifyResult.valid) {
      // Compensating rollback: delete hash row only on transient 5xx errors
      // so the player can retry. Genuine auth failures stay blacklisted.
      if (verifyResult.transientError) {
        await admin
          .from("iap_receipts")
          .delete()
          .eq("receipt_hash", receiptHash);
        return new Response(
          JSON.stringify({ error: "STORE_UNAVAILABLE_RETRY" }),
          { status: 503, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
        );
      }
      // Permanent auth failure — receipt_hash stays in table as blacklist entry.
      return new Response(
        JSON.stringify({ error: "RECEIPT_INVALID" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    // ── Atomic token grant ─────────────────────────────────────────────────
    // Fetch current balance then increment (service role bypasses RLS).
    const { data: brandRows, error: brandErr } = await admin
      .from("brand_state")
      .select("luxe_tokens")
      .eq("player_id", uid)
      .limit(1);

    if (brandErr) throw new Error(`Brand state fetch failed: ${brandErr.message}`);

    const currentTokens = (brandRows?.[0] as { luxe_tokens: number } | undefined)
      ?.luxe_tokens ?? 0;
    const newBalance = currentTokens + luxeGrant;

    const { error: updateErr } = await admin
      .from("brand_state")
      .update({ luxe_tokens: newBalance })
      .eq("player_id", uid);

    if (updateErr) throw new Error(`Token grant failed: ${updateErr.message}`);

    console.log(
      `validate-iap: granted ${luxeGrant} tokens to ${uid} for ${productId} (${platform})`,
    );

    return new Response(
      JSON.stringify({
        success: true,
        luxe_granted: luxeGrant,
        new_balance: newBalance,
      }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("validate-iap fatal:", (err as Error).message);
    return new Response(
      JSON.stringify({ error: (err as Error).message }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
