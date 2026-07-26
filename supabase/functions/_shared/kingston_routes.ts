import {
  hasExactKeys,
  isRecord,
  type JsonRecord,
  UUID_PATTERN,
} from "./kingston_contract.ts";

export type KingstonRoute = {
  rpc: string;
  ruleVersion: string;
  failureCode: string;
  validate: (body: JsonRecord) => JsonRecord | null;
  includeAnonymousClaim?: boolean;
};

export function validateFounderTrial(body: JsonRecord): JsonRecord | null {
  if (body.action === "initialize") {
    if (
      !hasExactKeys(body, [
        "action",
        "brand_name",
        "career_path",
        "idempotency_key",
      ]) || typeof body.brand_name !== "string" ||
      !["designer", "mogul"].includes(String(body.career_path))
    ) return null;
    return {
      action: body.action,
      brand_name: body.brand_name,
      career_path: body.career_path,
    };
  }
  if (body.action === "advance") {
    const keys = body.specialization === undefined
      ? ["action", "next_stage", "idempotency_key"]
      : ["action", "next_stage", "specialization", "idempotency_key"];
    if (
      !hasExactKeys(body, keys) || typeof body.next_stage !== "string" ||
      (body.specialization !== undefined &&
        !["artisan", "architect"].includes(String(body.specialization)))
    ) return null;
    return body.specialization === undefined
      ? { action: body.action, next_stage: body.next_stage }
      : {
        action: body.action,
        next_stage: body.next_stage,
        specialization: body.specialization,
      };
  }
  return null;
}

export function validateDesignIntent(body: JsonRecord): JsonRecord | null {
  if (body.action === "start") {
    if (
      !hasExactKeys(body, [
        "action",
        "fabric_color_hex",
        "style_tags",
        "idempotency_key",
      ]) ||
      typeof body.fabric_color_hex !== "string" ||
      !/^[0-9A-F]{6}$/.test(body.fabric_color_hex) ||
      !Array.isArray(body.style_tags) || body.style_tags.length < 1 ||
      body.style_tags.length > 3 ||
      !body.style_tags.every((tag) =>
        typeof tag === "string" && tag.length <= 40
      )
    ) return null;
    return {
      action: body.action,
      fabric_color_hex: body.fabric_color_hex,
      style_tags: body.style_tags,
    };
  }
  if (body.action === "mint") {
    if (
      !hasExactKeys(body, ["action", "session_id", "idempotency_key"]) ||
      typeof body.session_id !== "string" || !UUID_PATTERN.test(body.session_id)
    ) return null;
    return { action: body.action, session_id: body.session_id };
  }
  if (body.action === "release") {
    if (
      !hasExactKeys(body, [
        "action",
        "design_id",
        "release_intent",
        "blueprint",
        "vex_opt_in",
        "idempotency_key",
      ]) ||
      typeof body.design_id !== "string" ||
      !UUID_PATTERN.test(body.design_id) ||
      body.release_intent !== "publish_first_drop" ||
      !isRecord(body.blueprint) ||
      typeof body.vex_opt_in !== "boolean"
    ) return null;
    return {
      action: body.action,
      design_id: body.design_id,
      release_intent: body.release_intent,
      blueprint: body.blueprint,
      vex_opt_in: body.vex_opt_in,
    };
  }
  return null;
}

export function validateFirstStore(body: JsonRecord): JsonRecord | null {
  if (
    !hasExactKeys(body, [
      "store_type",
      "price_tier",
      "inventory_capacity",
      "idempotency_key",
    ]) ||
    !["flagship", "ecommerce"].includes(String(body.store_type)) ||
    !["accessible", "signature", "luxury"].includes(String(body.price_tier)) ||
    !Number.isInteger(body.inventory_capacity) ||
    Number(body.inventory_capacity) < 12 ||
    Number(body.inventory_capacity) > 60
  ) return null;
  return {
    store_type: body.store_type,
    price_tier: body.price_tier,
    inventory_capacity: body.inventory_capacity,
  };
}

export function validateIdleSettlement(body: JsonRecord): JsonRecord | null {
  return hasExactKeys(body, ["idempotency_key"]) ? {} : null;
}

export function validateProgressionEvent(body: JsonRecord): JsonRecord | null {
  const keys = body.entity_id === undefined
    ? ["event_key", "idempotency_key"]
    : ["event_key", "entity_id", "idempotency_key"];
  if (
    !hasExactKeys(body, keys) ||
    !["first_drop_result_viewed", "store_result_viewed"].includes(
      String(body.event_key),
    ) ||
    (body.entity_id !== undefined &&
      (typeof body.entity_id !== "string" ||
        !UUID_PATTERN.test(body.entity_id)))
  ) return null;
  return body.entity_id === undefined
    ? { event_key: body.event_key }
    : { event_key: body.event_key, entity_id: body.entity_id };
}

const REPORT_CATEGORIES = [
  "harassment",
  "hate",
  "spam",
  "cheating",
  "inappropriate_content",
  "other",
];
export function validatePlayerReport(body: JsonRecord): JsonRecord | null {
  if (
    !hasExactKeys(body, [
      "reported_player_id",
      "category",
      "description",
      "idempotency_key",
    ]) ||
    typeof body.reported_player_id !== "string" ||
    !UUID_PATTERN.test(body.reported_player_id) ||
    !REPORT_CATEGORIES.includes(String(body.category)) ||
    typeof body.description !== "string" ||
    body.description.length > 1000
  ) return null;
  return {
    reported_player_id: body.reported_player_id,
    category: body.category,
    description: body.description.trim(),
  };
}

export const KINGSTON_ROUTES: Record<string, KingstonRoute> = {
  "founder-trial": {
    rpc: "server_founder_trial_intent_v1",
    ruleVersion: "kingston-founder-trial.v1",
    failureCode: "FOUNDER_TRIAL_REJECTED",
    validate: validateFounderTrial,
    includeAnonymousClaim: true,
  },
  "drop-design": {
    rpc: "server_design_intent_v1",
    ruleVersion: "kingston-design-intent.v1",
    failureCode: "DESIGN_INTENT_REJECTED",
    validate: validateDesignIntent,
  },
  "open-first-store": {
    rpc: "server_open_first_store_v1",
    ruleVersion: "kingston-first-store.v1",
    failureCode: "FIRST_STORE_REJECTED",
    validate: validateFirstStore,
  },
  "calculate-idle-income": {
    rpc: "server_settle_idle_income_v1",
    ruleVersion: "kingston-idle-settlement.v1",
    failureCode: "IDLE_SETTLEMENT_REJECTED",
    validate: validateIdleSettlement,
  },
  "progression-event": {
    rpc: "server_progression_event_v1",
    ruleVersion: "kingston-progression-event.v1",
    failureCode: "PROGRESSION_EVENT_REJECTED",
    validate: validateProgressionEvent,
  },
  "submit-player-report": {
    rpc: "server_submit_player_report_v1",
    ruleVersion: "kingston-player-report.v1",
    failureCode: "PLAYER_REPORT_REJECTED",
    validate: validatePlayerReport,
  },
};
