import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export type JsonRecord = Record<string, unknown>;
export const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};
const MAX_PAYLOAD_BYTES = 32_768;

export function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function hasExactKeys(
  value: JsonRecord,
  keys: readonly string[],
): boolean {
  const expected = new Set(keys);
  return Object.keys(value).length === expected.size &&
    Object.keys(value).every((key) => expected.has(key));
}

function reply(body: JsonRecord, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

type Contract = {
  rpc: string;
  ruleVersion: string;
  failureCode: string;
  validate: (body: JsonRecord) => JsonRecord | null;
  includeAnonymousClaim?: boolean;
};

export async function handleKingstonRequest(
  request: Request,
  contract: Contract,
): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (request.method !== "POST") {
    return reply({ error: "METHOD_NOT_ALLOWED" }, 405);
  }
  if (
    !request.headers.get("content-type")?.toLowerCase().startsWith(
      "application/json",
    )
  ) {
    return reply({ error: "CONTENT_TYPE_REQUIRED" }, 415);
  }
  const contentLength = Number(request.headers.get("content-length") ?? "0");
  if (Number.isFinite(contentLength) && contentLength > MAX_PAYLOAD_BYTES) {
    return reply({ error: "PAYLOAD_TOO_LARGE" }, 413);
  }
  const authorization = request.headers.get("authorization") ?? "";
  if (!authorization.startsWith("Bearer ")) {
    return reply({ error: "MISSING_AUTH" }, 401);
  }

  const correlationId = crypto.randomUUID();
  try {
    const rawBody = await request.text();
    if (new TextEncoder().encode(rawBody).byteLength > MAX_PAYLOAD_BYTES) {
      return reply({ error: "PAYLOAD_TOO_LARGE" }, 413);
    }
    let parsed: unknown;
    try {
      parsed = JSON.parse(rawBody);
    } catch (_) {
      return reply({ error: "INVALID_JSON" }, 400);
    }
    if (!isRecord(parsed)) return reply({ error: "INVALID_PAYLOAD" }, 400);
    const idempotencyKey = parsed.idempotency_key;
    if (
      typeof idempotencyKey !== "string" || !UUID_PATTERN.test(idempotencyKey)
    ) {
      return reply({ error: "INVALID_IDEMPOTENCY_KEY" }, 400);
    }
    const payload = contract.validate(parsed);
    if (payload === null) return reply({ error: "INVALID_PAYLOAD" }, 400);

    const url = Deno.env.get("SUPABASE_URL") ?? "";
    const caller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY") ?? "", {
      global: { headers: { Authorization: authorization } },
    });
    const token = authorization.slice("Bearer ".length);
    const { data: { user }, error: authError } = await caller.auth.getUser(
      token,
    );
    if (authError || !user || !UUID_PATTERN.test(user.id)) {
      return reply({ error: "UNAUTHORIZED" }, 401);
    }

    const service = createClient(
      url,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );
    const parameters: JsonRecord = {
      p_auth_user_id: user.id,
      p_idempotency_key: idempotencyKey,
      p_request_payload: payload,
      p_rule_version: contract.ruleVersion,
    };
    if (contract.includeAnonymousClaim) {
      parameters.p_actor_is_anonymous =
        (user as unknown as { is_anonymous?: boolean }).is_anonymous === true;
    }
    const { data, error } = await service.schema("api").rpc(
      contract.rpc,
      parameters,
    );
    if (error) {
      console.error(
        "kingston-rpc-rejected",
        contract.rpc,
        correlationId,
        error.code ?? "unknown",
      );
      const conflict = error.message.includes("IDEMPOTENCY_KEY_CONFLICT") ||
        error.message.includes("ALREADY_") ||
        error.message.includes("RATE_LIMIT");
      return reply({
        error: contract.failureCode,
        correlation_id: correlationId,
      }, conflict ? 409 : 400);
    }
    return reply(isRecord(data) ? data : { result: data });
  } catch (error) {
    console.error(
      "kingston-edge-failed",
      contract.rpc,
      correlationId,
      error instanceof SyntaxError ? "invalid-json" : "internal",
    );
    return reply(
      { error: contract.failureCode, correlation_id: correlationId },
      500,
    );
  }
}
