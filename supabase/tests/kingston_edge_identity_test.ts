import {
  assert,
  assertEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import {
  handleKingstonRequest,
  type JsonRecord,
} from "../functions/_shared/kingston_contract.ts";
import { KINGSTON_ROUTES } from "../functions/_shared/kingston_routes.ts";

const OWNER_ID = "00000000-0000-4000-8000-000000000901";
const RESOURCE_ID = "00000000-0000-4000-8000-00000000d902";
const IDEMPOTENCY_KEY = "00000000-0000-4000-8000-00000000a903";

function request(body: JsonRecord, token = "valid-owner"): Request {
  return new Request("http://local/functions/v1/test", {
    method: "POST",
    headers: {
      "authorization": `Bearer ${token}`,
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  });
}

function installFetchMock(
  captured: JsonRecord[],
  rejectToken = false,
  rpcErrorMessage?: string,
): () => void {
  const original = globalThis.fetch;
  globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = String(input);
    if (url.includes("/auth/v1/user")) {
      if (rejectToken) {
        return new Response(JSON.stringify({ message: "rejected" }), {
          status: 401,
          headers: { "content-type": "application/json" },
        });
      }
      return new Response(
        JSON.stringify({
          id: OWNER_ID,
          aud: "authenticated",
          role: "authenticated",
          is_anonymous: false,
        }),
        { status: 200, headers: { "content-type": "application/json" } },
      );
    }
    if (url.includes("/rest/v1/rpc/")) {
      captured.push(JSON.parse(String(init?.body ?? "{}")) as JsonRecord);
      if (rpcErrorMessage !== undefined) {
        return new Response(
          JSON.stringify({
            code: "P0001",
            message: rpcErrorMessage,
          }),
          {
            status: 400,
            headers: { "content-type": "application/json" },
          },
        );
      }
      return new Response(
        JSON.stringify({
          receipt_version: "test.v1",
          idempotency_key: IDEMPOTENCY_KEY,
        }),
        { status: 200, headers: { "content-type": "application/json" } },
      );
    }
    throw new Error("unexpected mocked request");
  }) as typeof fetch;
  return () => {
    globalThis.fetch = original;
  };
}

Deno.env.set("SUPABASE_URL", "http://supabase.local");
Deno.env.set("SUPABASE_ANON_KEY", "local-anon-test-key");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "local-service-test-key");

Deno.test("all seven routes reject malformed payloads and client actor fields", () => {
  assertEquals(Object.keys(KINGSTON_ROUTES).length, 7);
  const malformed: Record<string, JsonRecord> = {
    "founder-trial": {
      action: "initialize",
      brand_name: "Kingston House",
      player_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "drop-design": {
      action: "release",
      owner_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "open-first-store": {
      player_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "calculate-idle-income": {
      p_user_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "progression-event": {
      event_key: "invented",
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "submit-player-report": {
      reporter_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
    "capsule-foundation": {
      action: "initialize",
      player_id: OWNER_ID,
      idempotency_key: IDEMPOTENCY_KEY,
    },
  };
  for (const [endpoint, route] of Object.entries(KINGSTON_ROUTES)) {
    assertEquals(route.validate(malformed[endpoint]), null, endpoint);
  }
});

Deno.test("Founder Trial accepts only bounded interaction choices", () => {
  const route = KINGSTON_ROUTES["founder-trial"];
  assertEquals(route.validate({
    action: "initialize",
    brand_name: "Kingston House",
    idempotency_key: IDEMPOTENCY_KEY,
  }), {
    action: "initialize",
    brand_name: "Kingston House",
  });
  assertEquals(route.validate({
    action: "advance",
    next_stage: "complete_artisan_sample",
    artisan_choice: "draped_bodice",
    idempotency_key: IDEMPOTENCY_KEY,
  }), {
    action: "advance",
    next_stage: "complete_artisan_sample",
    artisan_choice: "draped_bodice",
  });
  assertEquals(route.validate({
    action: "advance",
    next_stage: "select_founder_path",
    specialization: "artisan",
    player_id: OWNER_ID,
    idempotency_key: IDEMPOTENCY_KEY,
  }), null);
});

Deno.test("shared boundary rejects a missing token before any database call", async () => {
  const response = await handleKingstonRequest(
    new Request("http://local", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ idempotency_key: IDEMPOTENCY_KEY }),
    }),
    KINGSTON_ROUTES["calculate-idle-income"],
  );
  assertEquals(response.status, 401);
});

Deno.test("shared boundary rejects a malformed UUID idempotency key", async () => {
  const response = await handleKingstonRequest(
    request({ idempotency_key: "not-a-uuid" }),
    KINGSTON_ROUTES["calculate-idle-income"],
  );
  assertEquals(response.status, 400);
  assertEquals(await response.json(), { error: "INVALID_IDEMPOTENCY_KEY" });
});

Deno.test("shared boundary rejects malformed JSON as a client error", async () => {
  const response = await handleKingstonRequest(
    new Request("http://local", {
      method: "POST",
      headers: {
        authorization: "Bearer valid-owner",
        "content-type": "application/json",
      },
      body: "{not-json",
    }),
    KINGSTON_ROUTES["calculate-idle-income"],
  );
  assertEquals(response.status, 400);
  assertEquals(await response.json(), { error: "INVALID_JSON" });
});

Deno.test("shared boundary rejects unknown payload keys", async () => {
  const response = await handleKingstonRequest(
    request({
      idempotency_key: IDEMPOTENCY_KEY,
      unknown: true,
    }),
    KINGSTON_ROUTES["calculate-idle-income"],
  );
  assertEquals(response.status, 400);
  assertEquals(await response.json(), { error: "INVALID_PAYLOAD" });
});

Deno.test("shared boundary measures and rejects an oversized body", async () => {
  const response = await handleKingstonRequest(
    request({
      idempotency_key: IDEMPOTENCY_KEY,
      padding: "x".repeat(33_000),
    }),
    KINGSTON_ROUTES["calculate-idle-income"],
  );
  assertEquals(response.status, 413);
  assertEquals(await response.json(), { error: "PAYLOAD_TOO_LARGE" });
});

for (const tokenCase of ["malformed-token", "expired-token"]) {
  Deno.test(`shared boundary rejects ${tokenCase}`, async () => {
    const captured: JsonRecord[] = [];
    const restore = installFetchMock(captured, true);
    try {
      const response = await handleKingstonRequest(
        request({ idempotency_key: IDEMPOTENCY_KEY }, tokenCase),
        KINGSTON_ROUTES["calculate-idle-income"],
      );
      assertEquals(response.status, 401);
      assertEquals(captured.length, 0);
    } finally {
      restore();
    }
  });
}

Deno.test("valid owner is derived from token and body has no actor authority", async () => {
  const captured: JsonRecord[] = [];
  const restore = installFetchMock(captured);
  try {
    const response = await handleKingstonRequest(
      request({ idempotency_key: IDEMPOTENCY_KEY }),
      KINGSTON_ROUTES["calculate-idle-income"],
    );
    assertEquals(response.status, 200);
    assertEquals(captured.length, 1);
    assertEquals(captured[0].p_auth_user_id, OWNER_ID);
    assertEquals(captured[0].p_request_payload, {});
  } finally {
    restore();
  }
});

Deno.test("foreign resource stays data while verified token remains actor", async () => {
  const captured: JsonRecord[] = [];
  const restore = installFetchMock(captured);
  try {
    const blueprint = {
      version: 1,
      garment_category: "starter_garment",
      editable_zones: ["bodice"],
      materials: ["minimalist"],
      palette: ["FAF7F0"],
      construction_choices: ["straight_seam"],
      revision_lineage: [],
    };
    const response = await handleKingstonRequest(
      request({
        action: "release",
        design_id: RESOURCE_ID,
        release_intent: "publish_first_drop",
        blueprint,
        vex_opt_in: true,
        idempotency_key: IDEMPOTENCY_KEY,
      }),
      KINGSTON_ROUTES["drop-design"],
    );
    assertEquals(response.status, 200);
    assertEquals(captured[0].p_auth_user_id, OWNER_ID);
    assertEquals(
      (captured[0].p_request_payload as JsonRecord).design_id,
      RESOURCE_ID,
    );
    assert(!(captured[0].p_request_payload as JsonRecord).player_id);
  } finally {
    restore();
  }
});

Deno.test("repeated idempotency key is transported unchanged", async () => {
  const captured: JsonRecord[] = [];
  const restore = installFetchMock(captured);
  try {
    const first = await handleKingstonRequest(
      request({ idempotency_key: IDEMPOTENCY_KEY }),
      KINGSTON_ROUTES["calculate-idle-income"],
    );
    const replay = await handleKingstonRequest(
      request({ idempotency_key: IDEMPOTENCY_KEY }),
      KINGSTON_ROUTES["calculate-idle-income"],
    );
    assertEquals(first.status, 200);
    assertEquals(replay.status, 200);
    assertEquals(captured[0].p_idempotency_key, IDEMPOTENCY_KEY);
    assertEquals(captured[1].p_idempotency_key, IDEMPOTENCY_KEY);
  } finally {
    restore();
  }
});

Deno.test("database replay conflict maps to a deterministic 409", async () => {
  const captured: JsonRecord[] = [];
  const restore = installFetchMock(
    captured,
    false,
    "IDEMPOTENCY_KEY_CONFLICT",
  );
  try {
    const response = await handleKingstonRequest(
      request({ idempotency_key: IDEMPOTENCY_KEY }),
      KINGSTON_ROUTES["calculate-idle-income"],
    );
    assertEquals(response.status, 409);
    const body = await response.json();
    assertEquals(body.error, "IDLE_SETTLEMENT_REJECTED");
    assert(typeof body.correlation_id === "string");
  } finally {
    restore();
  }
});

Deno.test("capsule foundation accepts only bounded client intent", async () => {
  const captured: JsonRecord[] = [];
  const restore = installFetchMock(captured);
  try {
    const response = await handleKingstonRequest(
      request({
        action: "save_look",
        role: "hero_piece",
        grammar: {
          silhouette: "draped",
          material: "linen_blend",
          palette: "kingston_blue_ivory",
          construction: "soft_drape",
        },
        idempotency_key: IDEMPOTENCY_KEY,
      }),
      KINGSTON_ROUTES["capsule-foundation"],
    );
    assertEquals(response.status, 200);
    assertEquals(captured[0].p_auth_user_id, OWNER_ID);
    assertEquals(
      captured[0].p_rule_version,
      "kingston-capsule-foundation.v1",
    );
    assert(!(captured[0].p_request_payload as JsonRecord).player_id);
  } finally {
    restore();
  }
});

Deno.test("capsule foundation rejects score, ownership, and unknown look fields", async () => {
  const response = await handleKingstonRequest(
    request({
      action: "save_look",
      role: "hero_piece",
      grammar: {
        silhouette: "draped",
        material: "linen_blend",
        palette: "kingston_blue_ivory",
        construction: "soft_drape",
        score: 999999,
      },
      idempotency_key: IDEMPOTENCY_KEY,
    }),
    KINGSTON_ROUTES["capsule-foundation"],
  );
  assertEquals(response.status, 400);
});

Deno.test("disabled endpoint source is not part of the seven-route dispatcher", () => {
  for (
    const disabled of [
      "feed-react",
      "feed-comment",
      "feed-inspiration",
      "mint-design",
      "claim-mini-game-reward",
      "process-transaction",
      "maison-donate",
      "validate-iap",
      "trend-decay",
      "eclipse-event-tick",
    ]
  ) {
    assert(!(disabled in KINGSTON_ROUTES), disabled);
  }
});
