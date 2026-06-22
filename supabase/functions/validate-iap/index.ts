import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const LUXE_PRODUCTS: Record<string, number> = {
  "initiates_cache": 100,
  "artisans_reserve": 550,
  "architects_vault": 1200,
  "sovereign_syndicate": 6500,
};

interface VerifiedPurchase {
  productId: string;
  transactionId: string;
  accountToken: string;
  environment: string;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const hash = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function newestAppleItem(body: Record<string, unknown>): Record<string, unknown> | null {
  const candidates = [
    ...((body.latest_receipt_info as Record<string, unknown>[] | undefined) ?? []),
    ...((((body.receipt as Record<string, unknown> | undefined)?.in_app) as
      Record<string, unknown>[] | undefined) ?? []),
  ];
  candidates.sort((a, b) =>
    Number(b.purchase_date_ms ?? 0) - Number(a.purchase_date_ms ?? 0)
  );
  return candidates[0] ?? null;
}

async function verifyAppleReceipt(receiptData: string): Promise<VerifiedPurchase> {
  const sharedSecret = Deno.env.get("APPLE_SHARED_SECRET") ?? "";
  const bundleId = Deno.env.get("APPLE_BUNDLE_ID") ?? "";
  if (!sharedSecret || !bundleId) throw new Error("IAP_NOT_CONFIGURED");

  let responseBody: Record<string, unknown> | null = null;
  for (const url of [
    "https://buy.itunes.apple.com/verifyReceipt",
    "https://sandbox.itunes.apple.com/verifyReceipt",
  ]) {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ "receipt-data": receiptData, password: sharedSecret }),
    });
    if (!response.ok) throw new Error("STORE_UNAVAILABLE");
    const body = await response.json() as Record<string, unknown>;
    if (body.status === 21007) continue;
    if (body.status !== 0) throw new Error("RECEIPT_INVALID");
    responseBody = body;
    break;
  }
  if (!responseBody) throw new Error("RECEIPT_INVALID");

  const receipt = responseBody.receipt as Record<string, unknown> | undefined;
  if (String(receipt?.bundle_id ?? "") !== bundleId) throw new Error("BUNDLE_MISMATCH");
  const item = newestAppleItem(responseBody);
  if (!item || item.cancellation_date_ms || item.revocation_date) {
    throw new Error("RECEIPT_INVALID");
  }
  const productId = String(item.product_id ?? "");
  const transactionId = String(item.transaction_id ?? "");
  const accountToken = String(
    item.app_account_token ?? item.application_username ?? "",
  ).toLowerCase();
  if (!productId || !transactionId || !accountToken) throw new Error("ACCOUNT_BINDING_REQUIRED");
  return {
    productId,
    transactionId,
    accountToken,
    environment: String(responseBody.environment ?? "unknown"),
  };
}

async function googleAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(
    Deno.env.get("GOOGLE_SERVICE_ACCOUNT_KEY") ?? "{}",
  ) as { client_email?: string; private_key?: string };
  if (!serviceAccount.client_email || !serviceAccount.private_key) {
    throw new Error("IAP_NOT_CONFIGURED");
  }
  const now = Math.floor(Date.now() / 1000);
  const encode = (value: unknown) =>
    btoa(JSON.stringify(value)).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
  const signingInput = `${encode({ alg: "RS256", typ: "JWT" })}.${encode({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  })}`;
  const pem = serviceAccount.private_key.replace(/\\n/g, "\n")
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput),
  );
  const assertion = `${signingInput}.${
    btoa(String.fromCharCode(...new Uint8Array(signature)))
      .replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "")
  }`;
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${assertion}`,
  });
  const body = await response.json() as { access_token?: string };
  if (!body.access_token) throw new Error("STORE_UNAVAILABLE");
  return body.access_token;
}

async function verifyGooglePurchase(
  requestedProductId: string,
  purchaseToken: string,
): Promise<VerifiedPurchase> {
  const packageName = Deno.env.get("GOOGLE_PACKAGE_NAME") ?? "";
  if (!packageName) throw new Error("IAP_NOT_CONFIGURED");
  const accessToken = await googleAccessToken();
  const response = await fetch(
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${
      encodeURIComponent(packageName)
    }/purchases/products/${encodeURIComponent(requestedProductId)}/tokens/${
      encodeURIComponent(purchaseToken)
    }`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  if (!response.ok) throw new Error(response.status >= 500 ? "STORE_UNAVAILABLE" : "RECEIPT_INVALID");
  const body = await response.json() as Record<string, unknown>;
  if (body.purchaseState !== 0 || body.consumptionState === 1) throw new Error("RECEIPT_INVALID");
  const accountToken = String(body.obfuscatedExternalAccountId ?? "").toLowerCase();
  const transactionId = String(body.orderId ?? "");
  if (!accountToken || !transactionId) throw new Error("ACCOUNT_BINDING_REQUIRED");
  return {
    productId: requestedProductId,
    transactionId,
    accountToken,
    environment: "google_play",
  };
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "METHOD_NOT_ALLOWED" }, 405);
  const correlationId = crypto.randomUUID();

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "MISSING_AUTH" }, 401);
    const token = authHeader.slice("Bearer ".length);
    const verifier = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    );
    const { data: { user }, error: authError } = await verifier.auth.getUser(token);
    if (authError || !user) return json({ error: "UNAUTHORIZED" }, 401);

    const body = await req.json() as Record<string, unknown>;
    const platform = String(body.platform ?? "");
    const requestedProductId = String(body.productId ?? "");
    const receiptData = String(body.receiptData ?? "");
    if (!["ios", "android"].includes(platform) || !receiptData) {
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
        p_action: "validate_iap",
        p_window_seconds: 600,
        p_max_requests: 10,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: "RATE_LIMITED" }, 429);

    const verified = platform === "ios"
      ? await verifyAppleReceipt(receiptData)
      : await verifyGooglePurchase(requestedProductId, receiptData);
    const grant = LUXE_PRODUCTS[verified.productId];
    if (!grant) return json({ error: "UNKNOWN_PRODUCT" }, 400);
    if (verified.accountToken !== user.id.toLowerCase()) {
      return json({ error: "ACCOUNT_MISMATCH" }, 403);
    }

    const { data, error } = await admin.rpc("edge_redeem_iap_atomic", {
      p_player_id: user.id,
      p_platform: platform,
      p_transaction_id: verified.transactionId,
      p_receipt_hash: await sha256Hex(receiptData),
      p_product_id: verified.productId,
      p_luxe_grant: grant,
      p_account_token: verified.accountToken,
      p_environment: verified.environment,
    });
    if (error) throw error;
    return json(data as Record<string, unknown>);
  } catch (error) {
    console.error("validate-iap", correlationId, error);
    const message = error instanceof Error ? error.message : "";
    if (message.includes("STORE_UNAVAILABLE")) return json({ error: "STORE_UNAVAILABLE_RETRY" }, 503);
    if (message.includes("ACCOUNT")) return json({ error: "ACCOUNT_MISMATCH" }, 403);
    if (message.includes("INVALID") || message.includes("MISMATCH")) {
      return json({ error: "RECEIPT_INVALID" }, 400);
    }
    if (message.includes("CONFIGURED")) return json({ error: "STORE_NOT_CONFIGURED" }, 503);
    return json({ error: "PURCHASE_VALIDATION_FAILED", correlation_id: correlationId }, 500);
  }
});
