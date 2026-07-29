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
        "idempotency_key",
      ]) || typeof body.brand_name !== "string" ||
      body.brand_name.trim().length < 2 || body.brand_name.trim().length > 40
    ) return null;
    return {
      action: body.action,
      brand_name: body.brand_name.trim(),
    };
  }
  if (body.action === "advance") {
    switch (body.next_stage) {
      case "complete_artisan_sample":
        if (!hasExactKeys(body, [
          "action", "next_stage", "artisan_choice", "idempotency_key",
        ]) || !["draped_bodice", "structured_bodice"].includes(
          String(body.artisan_choice),
        )) return null;
        return {
          action: body.action,
          next_stage: body.next_stage,
          artisan_choice: body.artisan_choice,
        };
      case "complete_architect_sample":
        if (!hasExactKeys(body, [
          "action", "next_stage", "architect_choice", "idempotency_key",
        ]) || !["limited_run", "neighborhood_run"].includes(
          String(body.architect_choice),
        )) return null;
        return {
          action: body.action,
          next_stage: body.next_stage,
          architect_choice: body.architect_choice,
        };
      case "reveal_shared_result":
        return hasExactKeys(body, ["action", "next_stage", "idempotency_key"])
          ? { action: body.action, next_stage: body.next_stage }
          : null;
      case "choose_revision_or_business_response":
        if (!hasExactKeys(body, [
          "action", "next_stage", "response_choice", "idempotency_key",
        ]) || !["refine_silhouette", "adjust_run_plan"].includes(
          String(body.response_choice),
        )) return null;
        return {
          action: body.action,
          next_stage: body.next_stage,
          response_choice: body.response_choice,
        };
      case "select_founder_path":
        if (!hasExactKeys(body, [
          "action", "next_stage", "specialization", "idempotency_key",
        ]) || !["artisan", "architect"].includes(
          String(body.specialization),
        )) return null;
        return {
          action: body.action,
          next_stage: body.next_stage,
          specialization: body.specialization,
        };
      default:
        return null;
    }
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

const CAPSULE_BRIEF_KEYS = [
  "title",
  "narrative",
  "target_audience",
  "house_code",
  "palette_direction",
  "material_direction",
];
const CAPSULE_GRAMMAR_KEYS = [
  "silhouette",
  "material",
  "palette",
  "construction",
];

export function validateCapsuleFoundation(body: JsonRecord): JsonRecord | null {
  if (body.action === "initialize" || body.action === "evaluate_readiness") {
    return hasExactKeys(body, ["action", "idempotency_key"])
      ? { action: body.action }
      : null;
  }
  if (body.action === "save_brief") {
    if (
      !hasExactKeys(body, ["action", "brief", "idempotency_key"]) ||
      !isRecord(body.brief) || !hasExactKeys(body.brief, CAPSULE_BRIEF_KEYS) ||
      typeof body.brief.title !== "string" ||
      body.brief.title.trim().length < 2 || body.brief.title.trim().length > 48 ||
      typeof body.brief.narrative !== "string" ||
      body.brief.narrative.trim().length < 12 ||
      body.brief.narrative.trim().length > 240 ||
      !["kingston_creatives", "city_evenings"].includes(
        String(body.brief.target_audience),
      ) ||
      !["tailored_radiance", "soft_structure"].includes(
        String(body.brief.house_code),
      ) ||
      !["ivory_obsidian", "kingston_blue_ivory"].includes(
        String(body.brief.palette_direction),
      ) ||
      !["cotton_twill", "linen_blend"].includes(
        String(body.brief.material_direction),
      )
    ) return null;
    return {
      action: body.action,
      brief: {
        title: body.brief.title.trim(),
        narrative: body.brief.narrative.trim(),
        target_audience: body.brief.target_audience,
        house_code: body.brief.house_code,
        palette_direction: body.brief.palette_direction,
        material_direction: body.brief.material_direction,
      },
    };
  }
  if (body.action === "save_look") {
    if (
      !hasExactKeys(body, ["action", "role", "grammar", "idempotency_key"]) ||
      !["hero_piece", "commercial_anchor", "experimental_piece"].includes(
        String(body.role),
      ) ||
      !isRecord(body.grammar) ||
      !hasExactKeys(body.grammar, CAPSULE_GRAMMAR_KEYS) ||
      !["column", "draped", "structured"].includes(
        String(body.grammar.silhouette),
      ) ||
      !["cotton_twill", "linen_blend"].includes(
        String(body.grammar.material),
      ) ||
      !["ivory_obsidian", "kingston_blue_ivory"].includes(
        String(body.grammar.palette),
      ) ||
      !["straight_seam", "soft_drape", "sharp_panel"].includes(
        String(body.grammar.construction),
      )
    ) return null;
    return {
      action: body.action,
      role: body.role,
      grammar: {
        silhouette: body.grammar.silhouette,
        material: body.grammar.material,
        palette: body.grammar.palette,
        construction: body.grammar.construction,
      },
    };
  }
  return null;
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
  "capsule-foundation": {
    rpc: "server_capsule_foundation_intent_v1",
    ruleVersion: "kingston-capsule-foundation.v1",
    failureCode: "CAPSULE_FOUNDATION_REJECTED",
    validate: validateCapsuleFoundation,
  },
};
