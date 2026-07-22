-- GDD v7 §§5, 11, 19, 21.3, 22 / Directive 1X
-- Forward-only correction of the unapproved Kingston authority draft.
-- Published migrations remain byte-for-byte outside this change.

BEGIN;

-- ---------------------------------------------------------------------------
-- Economy vocabulary and source separation.
-- `total_revenue` remains a legacy field for deferred code, but no active
-- Kingston authority below reads or writes it as spendable money.
-- ---------------------------------------------------------------------------

ALTER TABLE public.brand_state
  ADD COLUMN IF NOT EXISTS house_funds NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS lifetime_gross_revenue NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS lifetime_costs NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS lifetime_net_result NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS idle_base_revenue_per_hour NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS idle_store_revenue_per_hour NUMERIC(14, 2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS idle_automation_revenue_per_hour NUMERIC(14, 2) NOT NULL DEFAULT 0;

UPDATE public.brand_state
SET house_funds = GREATEST(0, total_revenue),
    idle_base_revenue_per_hour = GREATEST(0, idle_revenue_per_hour),
    lifetime_gross_revenue = 0,
    lifetime_costs = 0,
    lifetime_net_result = 0
WHERE house_funds = 0
  AND lifetime_gross_revenue = 0
  AND lifetime_costs = 0
  AND lifetime_net_result = 0;

ALTER TABLE public.brand_state
  ADD CONSTRAINT brand_state_house_funds_nonnegative
    CHECK (house_funds >= 0),
  ADD CONSTRAINT brand_state_lifetime_gross_nonnegative
    CHECK (lifetime_gross_revenue >= 0),
  ADD CONSTRAINT brand_state_lifetime_costs_nonnegative
    CHECK (lifetime_costs >= 0),
  ADD CONSTRAINT brand_state_idle_base_nonnegative
    CHECK (idle_base_revenue_per_hour >= 0),
  ADD CONSTRAINT brand_state_idle_store_nonnegative
    CHECK (idle_store_revenue_per_hour >= 0),
  ADD CONSTRAINT brand_state_idle_automation_nonnegative
    CHECK (idle_automation_revenue_per_hour >= 0);

-- ---------------------------------------------------------------------------
-- Frozen Kingston starter catalog. Every listed option is granted to every
-- Founder Trial participant; no purchase, entitlement, count, or client score
-- changes the rule. The average option signal prevents adding array entries
-- from being a monotonic score exploit.
-- ---------------------------------------------------------------------------

CREATE TABLE private.kingston_starter_design_catalog (
  option_kind TEXT NOT NULL CHECK (option_kind IN ('material', 'zone', 'construction')),
  option_id TEXT NOT NULL,
  score_signal NUMERIC(6, 2) NOT NULL CHECK (score_signal BETWEEN -10 AND 10),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  rule_version TEXT NOT NULL DEFAULT 'kingston-design-result.v2',
  PRIMARY KEY (option_kind, option_id, rule_version)
);
ALTER TABLE private.kingston_starter_design_catalog ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON private.kingston_starter_design_catalog
  FROM PUBLIC, anon, authenticated;
GRANT SELECT ON private.kingston_starter_design_catalog TO service_role;

INSERT INTO private.kingston_starter_design_catalog(
  option_kind, option_id, score_signal
) VALUES
  ('zone', 'bodice', 0),
  ('construction', 'straight_seam', 0),
  ('material', 'minimalist', 4),
  ('material', 'streetwear', 1),
  ('material', 'couture', 5),
  ('material', 'avant-garde', 2),
  ('material', 'sustainable', 3),
  ('material', 'ivory', 0),
  ('material', 'monochrome', 1),
  ('material', 'oversized', -2),
  ('material', 'tailored', 4),
  ('material', 'deconstructed', -1)
ON CONFLICT (option_kind, option_id, rule_version) DO UPDATE
SET score_signal = EXCLUDED.score_signal,
    active = TRUE;

-- ---------------------------------------------------------------------------
-- Server-timed idle settlement. House Funds and lifetime metrics are updated
-- independently, and the receipt names every authoritative value explicitly.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.settle_idle_income(
  p_actor_id UUID,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_brand public.brand_state%ROWTYPE;
  v_existing JSONB;
  v_now TIMESTAMPTZ := clock_timestamp();
  v_elapsed_seconds BIGINT;
  v_amount NUMERIC(14, 2);
  v_house_funds NUMERIC(14, 2);
  v_lifetime_gross NUMERIC(14, 2);
  v_lifetime_costs NUMERIC(14, 2);
  v_lifetime_net NUMERIC(14, 2);
  v_response JSONB;
BEGIN
  IF p_actor_id IS NULL OR (SELECT auth.role()) <> 'service_role' THEN
    RAISE EXCEPTION 'UNAUTHORIZED_IDLE_SETTLEMENT';
  END IF;
  IF p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED';
  END IF;

  SELECT receipt.response INTO v_existing
  FROM ledger.idle_income_receipts AS receipt
  WHERE receipt.player_id = p_actor_id
    AND receipt.idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_existing; END IF;

  SELECT * INTO v_brand
  FROM public.brand_state AS brand
  WHERE brand.player_id = p_actor_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;

  SELECT receipt.response INTO v_existing
  FROM ledger.idle_income_receipts AS receipt
  WHERE receipt.player_id = p_actor_id
    AND receipt.idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_existing; END IF;

  v_elapsed_seconds := GREATEST(0, LEAST(
    86400,
    EXTRACT(EPOCH FROM (
      v_now - COALESCE(v_brand.last_active_at, v_now)
    ))::BIGINT
  ));
  v_amount := ROUND(
    GREATEST(0, v_brand.idle_revenue_per_hour)
      * v_elapsed_seconds / 3600.0,
    2
  );
  v_house_funds := ROUND(v_brand.house_funds + v_amount, 2);
  v_lifetime_gross := ROUND(v_brand.lifetime_gross_revenue + v_amount, 2);
  v_lifetime_costs := v_brand.lifetime_costs;
  v_lifetime_net := ROUND(v_lifetime_gross - v_lifetime_costs, 2);

  UPDATE public.brand_state
  SET house_funds = v_house_funds,
      lifetime_gross_revenue = v_lifetime_gross,
      lifetime_net_result = v_lifetime_net,
      last_active_at = v_now,
      updated_at = v_now
  WHERE player_id = p_actor_id;

  INSERT INTO public.idle_income_log(
    player_id, computed_at, amount, multiplier, decay_factor
  ) VALUES (p_actor_id, v_now, v_amount, 1, 1);

  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key,
    amount, balance_after, cause
  ) VALUES (
    p_actor_id, 'idle_income_settlement', 'kingston-idle-settlement.v2',
    p_idempotency_key, v_amount, v_house_funds,
    jsonb_build_object(
      'elapsed_seconds', v_elapsed_seconds,
      'server_time', v_now,
      'base_rate_per_hour', v_brand.idle_base_revenue_per_hour,
      'store_rate_per_hour', v_brand.idle_store_revenue_per_hour,
      'automation_rate_per_hour', v_brand.idle_automation_revenue_per_hour
    )
  );

  v_response := jsonb_build_object(
    'receipt_id', p_idempotency_key,
    'earned_amount', v_amount,
    'house_funds', v_house_funds,
    'lifetime_gross_revenue', v_lifetime_gross,
    'lifetime_costs', v_lifetime_costs,
    'lifetime_net_result', v_lifetime_net,
    'elapsed_seconds', v_elapsed_seconds,
    'base_rate_per_hour', v_brand.idle_base_revenue_per_hour,
    'store_rate_per_hour', v_brand.idle_store_revenue_per_hour,
    'automation_rate_per_hour', v_brand.idle_automation_revenue_per_hour,
    'rule_version', 'kingston-idle-settlement.v2',
    'settled_at', v_now
  );
  INSERT INTO ledger.idle_income_receipts(
    player_id, idempotency_key, response
  ) VALUES (p_actor_id, p_idempotency_key, v_response);
  RETURN v_response;
END;
$$;
REVOKE ALL ON FUNCTION private.settle_idle_income(UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.settle_idle_income(UUID, UUID)
  TO service_role;

-- ---------------------------------------------------------------------------
-- Frozen design settlement. It verifies actor/session/design ownership,
-- starter catalog membership, exact supported shape, uniqueness, and a fixed
-- rule version. Vex text is included only when the player opted in.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.release_design_v2(
  p_actor_id UUID,
  p_design_id UUID,
  p_release_intent TEXT,
  p_blueprint JSONB,
  p_vex_opt_in BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_design public.designs%ROWTYPE;
  v_brand public.brand_state%ROWTYPE;
  v_player public.players%ROWTYPE;
  v_post public.feed_posts%ROWTYPE;
  v_drop public.garment_drops%ROWTYPE;
  v_material_count INTEGER;
  v_catalog_count INTEGER;
  v_material_signal NUMERIC(10, 2);
  v_score NUMERIC(10, 2);
  v_followers_delta INTEGER;
  v_heat_delta INTEGER;
  v_xp_delta INTEGER;
  v_verdict TEXT;
  v_headline TEXT;
  v_quote TEXT;
  v_result JSONB;
  v_content JSONB;
  v_tags TEXT[];
  v_settled_at TIMESTAMPTZ := clock_timestamp();
BEGIN
  IF p_actor_id IS NULL OR (SELECT auth.role()) <> 'service_role' THEN
    RAISE EXCEPTION 'UNAUTHORIZED_RELEASE';
  END IF;
  IF p_release_intent <> 'publish_first_drop' THEN
    RAISE EXCEPTION 'INVALID_RELEASE_INTENT';
  END IF;
  IF p_vex_opt_in IS NULL THEN RAISE EXCEPTION 'VEX_OPT_IN_REQUIRED'; END IF;
  IF jsonb_typeof(p_blueprint) <> 'object'
     OR EXISTS (
       SELECT 1 FROM jsonb_object_keys(p_blueprint) AS key_name(key)
       WHERE key_name.key <> ALL (ARRAY[
         'version', 'garment_category', 'editable_zones', 'materials',
         'palette', 'construction_choices', 'revision_lineage'
       ])
     )
     OR p_blueprint->>'version' <> '1'
     OR p_blueprint->>'garment_category' <> 'starter_garment'
     OR p_blueprint->'editable_zones' <> '["bodice"]'::JSONB
     OR p_blueprint->'construction_choices' <> '["straight_seam"]'::JSONB
     OR p_blueprint->'revision_lineage' <> '[]'::JSONB
     OR jsonb_typeof(p_blueprint->'materials') <> 'array'
     OR jsonb_typeof(p_blueprint->'palette') <> 'array'
     OR jsonb_array_length(p_blueprint->'materials') NOT BETWEEN 1 AND 3
     OR jsonb_array_length(p_blueprint->'palette') <> 1
     OR (p_blueprint->'palette'->>0) !~ '^[0-9A-F]{6}$' THEN
    RAISE EXCEPTION 'INVALID_DESIGN_BLUEPRINT';
  END IF;

  SELECT COUNT(*), COUNT(DISTINCT material.value),
         ARRAY_AGG(DISTINCT material.value ORDER BY material.value)
  INTO v_material_count, v_catalog_count, v_tags
  FROM jsonb_array_elements_text(p_blueprint->'materials') AS material(value);
  IF v_material_count <> v_catalog_count THEN
    RAISE EXCEPTION 'DUPLICATE_DESIGN_OPTION';
  END IF;

  SELECT COUNT(*), ROUND(AVG(catalog.score_signal), 2)
  INTO v_catalog_count, v_material_signal
  FROM private.kingston_starter_design_catalog AS catalog
  WHERE catalog.option_kind = 'material'
    AND catalog.rule_version = 'kingston-design-result.v2'
    AND catalog.active
    AND catalog.option_id = ANY(v_tags);
  IF v_catalog_count <> v_material_count THEN
    RAISE EXCEPTION 'UNKNOWN_DESIGN_OPTION';
  END IF;

  SELECT * INTO v_design
  FROM public.designs AS design
  WHERE design.id = p_design_id
    AND design.player_id = p_actor_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'DESIGN_NOT_FOUND_OR_NOT_OWNED'; END IF;
  IF v_design.status = 'dropped' THEN RAISE EXCEPTION 'DESIGN_ALREADY_DROPPED'; END IF;
  IF v_design.status <> 'complete' THEN RAISE EXCEPTION 'DESIGN_NOT_READY'; END IF;
  IF NOT EXISTS (
    SELECT 1
    FROM public.atelier_sessions AS session
    WHERE session.player_id = p_actor_id
      AND session.design_id = p_design_id
      AND session.minted_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'ATELIER_SESSION_NOT_OWNED';
  END IF;

  SELECT * INTO v_player
  FROM public.players AS player
  WHERE player.id = p_actor_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'PLAYER_NOT_FOUND'; END IF;
  SELECT * INTO v_brand
  FROM public.brand_state AS brand
  WHERE brand.player_id = p_actor_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;

  v_score := ROUND(GREATEST(0, LEAST(100, 65 + v_material_signal)), 2);
  v_followers_delta := FLOOR(v_score / 2)::INTEGER;
  v_heat_delta := CEIL(v_score / 20)::INTEGER;
  v_xp_delta := ROUND(v_score)::INTEGER;
  v_verdict := CASE
    WHEN v_score >= 85 THEN 'Alpha'
    WHEN v_score >= 65 THEN 'Noticed'
    ELSE 'Developing'
  END;
  v_headline := CASE
    WHEN v_score >= 85 THEN 'A clear signature enters the room.'
    WHEN v_score >= 65 THEN 'The silhouette has a point of view.'
    ELSE 'The first cut is promising, not finished.'
  END;
  v_quote := CASE
    WHEN v_score >= 85 THEN 'The choices hold together under scrutiny.'
    WHEN v_score >= 65 THEN 'Commit to the strongest material decision next.'
    ELSE 'Revision will reveal the garment''s intent.'
  END;

  v_result := jsonb_build_object(
    'result_version', 'kingston-design-result.v2',
    'hype_score', v_score,
    'causes', jsonb_build_array(
      jsonb_build_object(
        'factor', 'starter_material_signal',
        'value', v_material_signal,
        'rule_version', 'kingston-design-result.v2'
      ),
      jsonb_build_object('factor', 'starter_zone', 'value', 'bodice'),
      jsonb_build_object(
        'factor', 'starter_construction', 'value', 'straight_seam'
      )
    ),
    'followers_delta', v_followers_delta,
    'brand_heat_delta', v_heat_delta,
    'xp_delta', v_xp_delta,
    'next_objective', 'Review the customer result and choose a targeted response.',
    'vex_opted_in', p_vex_opt_in,
    'settled_at', v_settled_at
  );
  IF p_vex_opt_in THEN
    v_result := v_result || jsonb_build_object(
      'vex_verdict', v_verdict,
      'vex_headline', v_headline,
      'vex_quote', v_quote
    );
  END IF;

  v_content := jsonb_build_object(
    'event', 'alpha_dropped',
    'design_id', p_design_id,
    'design_name', v_design.name,
    'style_tags', to_jsonb(v_tags),
    'authoritative_result', v_result,
    'brand_name', v_player.brand_name,
    'audience', 'kingston_starter_customers'
  );
  IF p_vex_opt_in THEN
    v_content := v_content || jsonb_build_object(
      'vex_verdict', v_verdict,
      'vex_headline', v_headline,
      'vex_quote', v_quote
    );
  END IF;

  INSERT INTO public.feed_posts(
    player_id, type, content, hype, likes, comments_count
  ) VALUES (
    p_actor_id, 'design_flex', v_content, v_score, 0, 0
  ) RETURNING * INTO v_post;
  INSERT INTO public.garment_drops(
    player_id, design_id, style_tags, hype_score, feed_post_id
  ) VALUES (
    p_actor_id, p_design_id, v_tags, v_score, v_post.id
  ) RETURNING * INTO v_drop;

  UPDATE public.designs
  SET status = 'dropped',
      dropped_at = v_settled_at,
      hype_score = v_score,
      design_blueprint = p_blueprint,
      authoritative_result = v_result,
      result_version = 'kingston-design-result.v2'
  WHERE id = p_design_id;
  UPDATE public.brand_state
  SET followers = followers + v_followers_delta,
      heat = LEAST(100, heat + v_heat_delta),
      hype_score = GREATEST(hype_score, v_score),
      updated_at = v_settled_at
  WHERE player_id = p_actor_id;
  UPDATE public.players
  SET total_xp = total_xp + v_xp_delta,
      last_active_at = v_settled_at
  WHERE id = p_actor_id;

  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key,
    amount, balance_after, cause
  ) VALUES (
    p_actor_id, 'design_release', 'kingston-design-result.v2', p_design_id,
    0, v_brand.house_funds,
    jsonb_build_object(
      'design_id', p_design_id,
      'feed_post_id', v_post.id,
      'result', v_result
    )
  );

  RETURN v_result || jsonb_build_object(
    'success', TRUE,
    'feed_post_id', v_post.id,
    'garment_drop_id', v_drop.id,
    'design_id', p_design_id
  );
END;
$$;
REVOKE ALL ON FUNCTION private.release_design_v2(
  UUID, UUID, TEXT, JSONB, BOOLEAN
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.release_design_v2(
  UUID, UUID, TEXT, JSONB, BOOLEAN
) TO service_role;
REVOKE ALL ON FUNCTION private.release_design(UUID, UUID, TEXT, JSONB)
  FROM PUBLIC, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Founder initialization no longer accepts tier/avatar authority, grants no
-- tier-based Hype ceiling, and does not mark onboarding complete. Advancement
-- fails closed until each causal step can be derived from server-owned state.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.authority_founder_trial_v1(
  p_auth_user_id UUID,
  p_actor_is_anonymous BOOLEAN,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_action TEXT := COALESCE(p_request_payload->>'action', '');
  v_player_id UUID;
  v_existing JSONB;
  v_result JSONB;
  v_brand_name TEXT;
  v_path TEXT;
  v_starting_house_funds CONSTANT NUMERIC(14, 2) := 100000;
BEGIN
  IF p_rule_version <> 'kingston-founder-trial.v1' THEN
    RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION';
  END IF;
  IF p_idempotency_key IS NULL THEN RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED'; END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;

  PERFORM pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('kingston:' || p_auth_user_id::TEXT, 0)
  );
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'founder_trial', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;

  IF v_action = 'initialize' THEN
    IF (p_request_payload - ARRAY[
      'action', 'brand_name', 'career_path'
    ]) <> '{}'::JSONB THEN
      RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
    END IF;
    IF EXISTS (
      SELECT 1 FROM private.auth_player_identities AS identity
      WHERE identity.auth_user_id = p_auth_user_id
    ) THEN
      RAISE EXCEPTION 'FOUNDER_ALREADY_INITIALIZED';
    END IF;
    IF EXISTS (
      SELECT 1 FROM public.players AS player
      WHERE player.id = p_auth_user_id
    ) THEN
      RAISE EXCEPTION 'PLAYER_IDENTITY_CONFLICT';
    END IF;

    v_brand_name := btrim(COALESCE(p_request_payload->>'brand_name', ''));
    v_path := COALESCE(p_request_payload->>'career_path', '');
    IF char_length(v_brand_name) NOT BETWEEN 2 AND 40 THEN
      RAISE EXCEPTION 'INVALID_BRAND_NAME';
    END IF;
    IF v_path NOT IN ('designer', 'mogul') THEN
      RAISE EXCEPTION 'INVALID_CAREER_PATH';
    END IF;

    INSERT INTO public.players(
      id, brand_name, path, hq_city, onboarding_complete, is_anonymous
    ) VALUES (
      p_auth_user_id, v_brand_name, v_path, 'kingston', FALSE,
      COALESCE(p_actor_is_anonymous, FALSE)
    );
    INSERT INTO private.auth_player_identities(auth_user_id, player_id)
    VALUES (p_auth_user_id, p_auth_user_id);
    INSERT INTO public.brand_state(
      player_id, total_revenue, house_funds,
      lifetime_gross_revenue, lifetime_costs, lifetime_net_result,
      hype_score, idle_revenue_per_hour,
      idle_base_revenue_per_hour, idle_store_revenue_per_hour,
      idle_automation_revenue_per_hour, luxe_tokens
    ) VALUES (
      p_auth_user_id, 0, v_starting_house_funds,
      0, 0, 0, 0, 0, 0, 0, 0, 0
    );
    INSERT INTO ledger.economy_ledger(
      player_id, entry_type, rule_version, idempotency_key,
      amount, balance_after, cause
    ) VALUES (
      p_auth_user_id, 'founder_house_funds', p_rule_version,
      p_idempotency_key, v_starting_house_funds, v_starting_house_funds,
      jsonb_build_object('source', 'founder_trial', 'city', 'kingston')
    );
    INSERT INTO public.founder_trials(player_id) VALUES (p_auth_user_id);

    v_player_id := p_auth_user_id;
    v_result := jsonb_build_object(
      'receipt_version', p_rule_version,
      'operation', 'founder_trial',
      'status', 'initialized',
      'idempotency_key', p_idempotency_key,
      'player_id', v_player_id,
      'stage', 'shared_starter_garment',
      'starting_house_funds', v_starting_house_funds,
      'hq_city', 'kingston',
      'onboarding_complete', FALSE
    );
  ELSIF v_action = 'advance' THEN
    -- Ordered client acknowledgements are not proof that the player completed
    -- the Artisan sample, Architect sample, consequence, or recovery step.
    RAISE EXCEPTION 'FOUNDER_TRIAL_ADVANCE_NOT_AVAILABLE';
  ELSE
    RAISE EXCEPTION 'INVALID_FOUNDER_TRIAL_ACTION';
  END IF;

  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'founder_trial', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Design intent delegates releases only to the frozen v2 settlement.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.authority_design_intent_v1(
  p_auth_user_id UUID,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID;
  v_action TEXT := COALESCE(p_request_payload->>'action', '');
  v_existing JSONB;
  v_session public.atelier_sessions%ROWTYPE;
  v_design public.designs%ROWTYPE;
  v_style_tags TEXT[];
  v_result JSONB;
BEGIN
  IF p_rule_version <> 'kingston-design-intent.v1' THEN
    RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION';
  END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;
  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'design_intent', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;

  IF v_action = 'start' THEN
    IF (p_request_payload - ARRAY[
      'action', 'fabric_color_hex', 'style_tags'
    ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
    IF COALESCE(p_request_payload->>'fabric_color_hex', '') !~ '^[0-9A-F]{6}$' THEN
      RAISE EXCEPTION 'INVALID_FABRIC_COLOR';
    END IF;
    IF jsonb_typeof(COALESCE(
      p_request_payload->'style_tags', 'null'::JSONB
    )) <> 'array' THEN
      RAISE EXCEPTION 'INVALID_STYLE_TAGS';
    END IF;
    SELECT ARRAY(
      SELECT jsonb_array_elements_text(p_request_payload->'style_tags')
    ) INTO v_style_tags;
    IF cardinality(v_style_tags) NOT BETWEEN 1 AND 3 THEN
      RAISE EXCEPTION 'INVALID_STYLE_TAGS';
    END IF;
    IF (
      SELECT COUNT(DISTINCT tag)
      FROM unnest(v_style_tags) AS selected(tag)
    ) <> cardinality(v_style_tags) OR EXISTS (
      SELECT 1
      FROM unnest(v_style_tags) AS selected(tag)
      WHERE NOT EXISTS (
        SELECT 1
        FROM private.kingston_starter_design_catalog AS catalog
        WHERE catalog.option_kind = 'material'
          AND catalog.option_id = selected.tag
          AND catalog.rule_version = 'kingston-design-result.v2'
          AND catalog.active
      )
    ) THEN
      RAISE EXCEPTION 'INVALID_STYLE_TAGS';
    END IF;

    SELECT * INTO v_session
    FROM public.atelier_sessions AS session
    WHERE session.player_id = v_player_id
      AND session.design_id IS NULL
      AND session.expires_at > clock_timestamp()
      AND session.fabric_color_hex = p_request_payload->>'fabric_color_hex'
      AND session.style_tags = v_style_tags
    ORDER BY session.started_at DESC
    LIMIT 1
    FOR UPDATE;
    IF NOT FOUND THEN
      INSERT INTO public.atelier_sessions(
        player_id, fabric_color_hex, style_tags
      ) VALUES (
        v_player_id, p_request_payload->>'fabric_color_hex', v_style_tags
      ) RETURNING * INTO v_session;
    END IF;
    v_result := jsonb_build_object(
      'status', 'started',
      'session_id', v_session.id,
      'expires_at', v_session.expires_at
    );
  ELSIF v_action = 'mint' THEN
    IF (p_request_payload - ARRAY['action', 'session_id']) <> '{}'::JSONB THEN
      RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
    END IF;
    SELECT * INTO v_session
    FROM public.atelier_sessions AS session
    WHERE session.id = (p_request_payload->>'session_id')::UUID
      AND session.player_id = v_player_id
    FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ATELIER_SESSION_NOT_FOUND'; END IF;
    IF v_session.expires_at <= clock_timestamp() THEN
      RAISE EXCEPTION 'ATELIER_SESSION_EXPIRED';
    END IF;
    IF v_session.design_id IS NOT NULL THEN
      RAISE EXCEPTION 'ATELIER_SESSION_ALREADY_MINTED';
    END IF;
    INSERT INTO public.designs(
      player_id, name, session_type, status, fabric_data, design_blueprint
    ) VALUES (
      v_player_id,
      'Kingston Alpha ' || left(v_session.id::TEXT, 8),
      'quick_sketch',
      'complete',
      jsonb_build_object(
        'fabric_color_hex', v_session.fabric_color_hex,
        'style_tags', to_jsonb(v_session.style_tags)
      ),
      jsonb_build_object(
        'version', 1,
        'garment_category', 'starter_garment',
        'editable_zones', jsonb_build_array('bodice'),
        'materials', to_jsonb(v_session.style_tags),
        'palette', jsonb_build_array(v_session.fabric_color_hex),
        'construction_choices', jsonb_build_array('straight_seam'),
        'revision_lineage', '[]'::JSONB
      )
    ) RETURNING * INTO v_design;
    UPDATE public.atelier_sessions
    SET minted_at = clock_timestamp(), design_id = v_design.id
    WHERE id = v_session.id;
    v_result := to_jsonb(v_design) || jsonb_build_object(
      'intent_status', 'minted', 'session_id', v_session.id
    );
  ELSIF v_action = 'release' THEN
    IF (p_request_payload - ARRAY[
      'action', 'design_id', 'release_intent', 'blueprint', 'vex_opt_in'
    ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
    IF jsonb_typeof(p_request_payload->'vex_opt_in') <> 'boolean' THEN
      RAISE EXCEPTION 'VEX_OPT_IN_REQUIRED';
    END IF;
    v_result := private.release_design_v2(
      v_player_id,
      (p_request_payload->>'design_id')::UUID,
      COALESCE(NULLIF(
        p_request_payload->>'release_intent', ''
      ), 'first_drop'),
      COALESCE(p_request_payload->'blueprint', '{}'::JSONB),
      (p_request_payload->>'vex_opt_in')::BOOLEAN
    );
    v_result := v_result || jsonb_build_object('status', 'released');
  ELSE
    RAISE EXCEPTION 'INVALID_DESIGN_ACTION';
  END IF;

  v_result := v_result || jsonb_build_object(
    'receipt_version', p_rule_version,
    'operation', 'design_intent',
    'idempotency_key', p_idempotency_key
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'design_intent', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- First store preserves independent idle sources and records House Funds.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.authority_open_first_store_v1(
  p_auth_user_id UUID,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID;
  v_player public.players%ROWTYPE;
  v_brand public.brand_state%ROWTYPE;
  v_store public.stores%ROWTYPE;
  v_existing JSONB;
  v_store_type TEXT := COALESCE(p_request_payload->>'store_type', '');
  v_price_tier TEXT := COALESCE(p_request_payload->>'price_tier', '');
  v_capacity INTEGER;
  v_demand NUMERIC(14, 4);
  v_operating_cost NUMERIC(14, 4);
  v_audience TEXT;
  v_store_rate NUMERIC(14, 2);
  v_result JSONB;
BEGIN
  IF p_rule_version <> 'kingston-first-store.v1' THEN
    RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION';
  END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;
  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'first_store', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;
  IF (p_request_payload - ARRAY[
    'store_type', 'price_tier', 'inventory_capacity'
  ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;

  SELECT * INTO v_player
  FROM public.players AS player
  WHERE player.id = v_player_id
  FOR UPDATE;
  IF v_player.path <> 'mogul' THEN RAISE EXCEPTION 'MOGUL_ONLY'; END IF;
  SELECT * INTO v_brand
  FROM public.brand_state AS brand
  WHERE brand.player_id = v_player_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;
  IF EXISTS (
    SELECT 1 FROM public.stores AS store
    WHERE store.player_id = v_player_id
  ) THEN RAISE EXCEPTION 'FIRST_STORE_ALREADY_OPEN'; END IF;
  IF v_store_type NOT IN ('flagship', 'ecommerce') THEN
    RAISE EXCEPTION 'INVALID_STORE_TYPE';
  END IF;
  IF v_price_tier NOT IN ('accessible', 'signature', 'luxury') THEN
    RAISE EXCEPTION 'INVALID_PRICE_TIER';
  END IF;
  BEGIN
    v_capacity := (p_request_payload->>'inventory_capacity')::INTEGER;
  EXCEPTION WHEN invalid_text_representation THEN
    RAISE EXCEPTION 'INVALID_INVENTORY_CAPACITY';
  END;
  IF v_capacity NOT BETWEEN 12 AND 60 THEN
    RAISE EXCEPTION 'INVALID_INVENTORY_CAPACITY';
  END IF;

  v_audience := CASE v_price_tier
    WHEN 'accessible' THEN 'emerging'
    WHEN 'signature' THEN 'design-conscious'
    ELSE 'collector'
  END;
  v_demand := CASE v_price_tier
    WHEN 'accessible' THEN 18
    WHEN 'signature' THEN 10
    ELSE 5
  END;
  v_operating_cost := CASE v_store_type
    WHEN 'flagship' THEN 140
    ELSE 35
  END;

  INSERT INTO public.stores(
    player_id, type, city, tier, revenue_per_hour, loyalty, market_share,
    audience, price_tier, inventory_capacity, operating_cost_per_hour,
    expected_demand_per_day, decision_made_at, opened_at, updated_at
  ) VALUES (
    v_player_id, v_store_type, 'kingston', 1,
    ROUND(GREATEST(1, v_demand * 0.35 - v_operating_cost / 100), 4),
    100, 0, v_audience, v_price_tier, v_capacity, v_operating_cost,
    v_demand, clock_timestamp(), clock_timestamp(), clock_timestamp()
  ) RETURNING * INTO v_store;

  SELECT ROUND(COALESCE(SUM(store.revenue_per_hour), 0), 2)
  INTO v_store_rate
  FROM public.stores AS store
  WHERE store.player_id = v_player_id;
  UPDATE public.brand_state
  SET idle_store_revenue_per_hour = v_store_rate,
      idle_revenue_per_hour = ROUND(
        idle_base_revenue_per_hour + v_store_rate
          + idle_automation_revenue_per_hour,
        2
      ),
      updated_at = clock_timestamp()
  WHERE player_id = v_player_id;

  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key,
    amount, balance_after, cause
  ) VALUES (
    v_player_id, 'first_store_open', p_rule_version, p_idempotency_key,
    0, v_brand.house_funds,
    jsonb_build_object('store_id', v_store.id, 'city', 'kingston')
  );

  v_result := jsonb_build_object(
    'receipt_version', p_rule_version,
    'operation', 'first_store',
    'status', 'opened',
    'success', TRUE,
    'idempotency_key', p_idempotency_key,
    'store_id', v_store.id,
    'opening_cost', 0,
    'house_funds', v_brand.house_funds,
    'city', v_store.city,
    'store_type', v_store.type,
    'price_tier', v_store.price_tier,
    'inventory_capacity', v_store.inventory_capacity,
    'expected_demand_per_day', v_store.expected_demand_per_day,
    'operating_cost_per_hour', v_store.operating_cost_per_hour,
    'store_revenue_per_hour', v_store_rate,
    'total_idle_revenue_per_hour', ROUND(
      v_brand.idle_base_revenue_per_hour + v_store_rate
        + v_brand.idle_automation_revenue_per_hour,
      2
    )
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'first_store', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Owner projection exposes the separated values. `total_revenue` is a
-- temporary read alias for House Funds so the generated client model does not
-- silently display zero while the UI/model rename remains skill-blocked.
-- ---------------------------------------------------------------------------

DROP VIEW IF EXISTS api.brand_summary;
DROP FUNCTION IF EXISTS private.read_brand_summary();

CREATE FUNCTION private.read_brand_summary()
RETURNS TABLE(
  player_id UUID,
  heat INTEGER,
  hype_score NUMERIC,
  followers INTEGER,
  house_funds NUMERIC,
  lifetime_gross_revenue NUMERIC,
  lifetime_costs NUMERIC,
  lifetime_net_result NUMERIC,
  idle_revenue_per_hour NUMERIC,
  idle_base_revenue_per_hour NUMERIC,
  idle_store_revenue_per_hour NUMERIC,
  idle_automation_revenue_per_hour NUMERIC,
  momentum_buff_active BOOLEAN,
  momentum_buff_until TIMESTAMPTZ,
  last_active_at TIMESTAMPTZ,
  sustainability_tier INTEGER,
  dpp_enabled BOOLEAN,
  dpp_fully_mapped BOOLEAN,
  founder_rep INTEGER,
  current_tarnish INTEGER,
  kintsugi_level INTEGER,
  total_scandals_survived INTEGER,
  market_tier TEXT,
  warehouse_capacity BIGINT,
  current_inventory_value BIGINT,
  logistics_level INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    brand.player_id,
    brand.heat,
    brand.hype_score,
    brand.followers,
    brand.house_funds,
    brand.lifetime_gross_revenue,
    brand.lifetime_costs,
    brand.lifetime_net_result,
    brand.idle_revenue_per_hour,
    brand.idle_base_revenue_per_hour,
    brand.idle_store_revenue_per_hour,
    brand.idle_automation_revenue_per_hour,
    brand.momentum_buff_active,
    brand.momentum_buff_until,
    brand.last_active_at,
    brand.sustainability_tier,
    brand.dpp_enabled,
    brand.dpp_fully_mapped,
    brand.founder_rep,
    brand.current_tarnish,
    brand.kintsugi_level,
    brand.total_scandals_survived,
    brand.market_tier,
    brand.warehouse_capacity,
    brand.current_inventory_value,
    brand.logistics_level
  FROM public.brand_state AS brand
  WHERE brand.player_id = private.current_player_id();
$$;
REVOKE ALL ON FUNCTION private.read_brand_summary()
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.read_brand_summary()
  TO authenticated, service_role;

CREATE VIEW api.brand_summary WITH (security_invoker = true) AS
SELECT
  state.player_id,
  state.heat,
  state.hype_score,
  state.followers,
  state.house_funds,
  state.house_funds AS total_revenue,
  state.lifetime_gross_revenue,
  state.lifetime_costs,
  state.lifetime_net_result,
  state.idle_revenue_per_hour,
  state.idle_base_revenue_per_hour,
  state.idle_store_revenue_per_hour,
  state.idle_automation_revenue_per_hour,
  state.momentum_buff_active,
  state.momentum_buff_until,
  state.last_active_at,
  state.sustainability_tier,
  state.dpp_enabled,
  state.dpp_fully_mapped,
  state.founder_rep,
  state.current_tarnish,
  state.kintsugi_level,
  state.total_scandals_survived,
  state.market_tier,
  state.warehouse_capacity,
  state.current_inventory_value,
  state.logistics_level
FROM private.read_brand_summary() AS state;
REVOKE ALL ON api.brand_summary FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT ON api.brand_summary TO authenticated, service_role;

-- Reassert the final privilege boundary after replacements.
REVOKE ALL ON FUNCTION private.authority_founder_trial_v1(
  UUID, BOOLEAN, UUID, JSONB, TEXT
), private.authority_design_intent_v1(
  UUID, UUID, JSONB, TEXT
), private.authority_open_first_store_v1(
  UUID, UUID, JSONB, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.authority_founder_trial_v1(
  UUID, BOOLEAN, UUID, JSONB, TEXT
), private.authority_design_intent_v1(
  UUID, UUID, JSONB, TEXT
), private.authority_open_first_store_v1(
  UUID, UUID, JSONB, TEXT
) TO service_role;

COMMIT;
