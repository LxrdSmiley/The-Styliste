-- GDD v7 §19 / PROJECT_RULES §3
-- Client tokens can read only explicitly projected state. Every mutation is
-- an authenticated intent settled by a narrow API wrapper and a locked RPC.

CREATE SCHEMA IF NOT EXISTS private;
CREATE SCHEMA IF NOT EXISTS ledger;

REVOKE ALL ON SCHEMA private, ledger FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private, ledger TO service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA private
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA ledger
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA ledger
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;

CREATE TABLE IF NOT EXISTS ledger.economy_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE RESTRICT,
  entry_type TEXT NOT NULL,
  rule_version TEXT NOT NULL,
  idempotency_key UUID,
  amount NUMERIC(14, 2) NOT NULL,
  balance_after NUMERIC(14, 2) NOT NULL,
  cause JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  UNIQUE NULLS NOT DISTINCT (player_id, entry_type, idempotency_key)
);
CREATE INDEX IF NOT EXISTS economy_ledger_player_created_idx
  ON ledger.economy_ledger(player_id, created_at DESC);
ALTER TABLE ledger.economy_ledger ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ledger.economy_ledger FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON ledger.economy_ledger TO service_role;

CREATE TABLE IF NOT EXISTS ledger.idle_income_receipts (
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE RESTRICT,
  idempotency_key UUID NOT NULL,
  response JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY (player_id, idempotency_key)
);
ALTER TABLE ledger.idle_income_receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ledger.idle_income_receipts FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON ledger.idle_income_receipts TO service_role;

CREATE TABLE IF NOT EXISTS ledger.reward_policy_versions (
  policy_version TEXT PRIMARY KEY,
  free_premium_currency_cap INTEGER NOT NULL CHECK (free_premium_currency_cap >= 0),
  quest_reward_cap INTEGER NOT NULL CHECK (quest_reward_cap >= 0),
  gala_reward_cap INTEGER NOT NULL CHECK (gala_reward_cap >= 0),
  active BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  approved_by TEXT NOT NULL,
  CHECK ((active IS FALSE) OR policy_version <> '')
);
ALTER TABLE ledger.reward_policy_versions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ledger.reward_policy_versions FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON ledger.reward_policy_versions TO service_role;

CREATE TABLE IF NOT EXISTS ledger.reward_issuance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE RESTRICT,
  reward_kind TEXT NOT NULL,
  policy_version TEXT NOT NULL REFERENCES ledger.reward_policy_versions(policy_version),
  idempotency_key UUID NOT NULL,
  amount NUMERIC(14, 2) NOT NULL CHECK (amount >= 0),
  source_type TEXT NOT NULL,
  source_id UUID,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (player_id, reward_kind, idempotency_key)
);
ALTER TABLE ledger.reward_issuance ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ledger.reward_issuance FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON ledger.reward_issuance TO service_role;

-- Default policy is deliberately zeroed. Reward activation requires an audited
-- server-side policy update rather than a client-selected amount or multiplier.
INSERT INTO ledger.reward_policy_versions(
  policy_version, free_premium_currency_cap, quest_reward_cap, gala_reward_cap, active, approved_by
) VALUES ('early-game-v1', 0, 0, 0, TRUE, 'migration:20260721120635')
ON CONFLICT (policy_version) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.founder_trials (
  player_id UUID PRIMARY KEY REFERENCES public.players(id) ON DELETE CASCADE,
  stage TEXT NOT NULL DEFAULT 'shared_starter_garment' CHECK (stage IN (
    'shared_starter_garment', 'artisan_sample', 'architect_sample',
    'result_visible', 'revision_or_business_response', 'specialization_selected',
    'main_quest_handoff', 'completed'
  )),
  specialization TEXT CHECK (specialization IN ('artisan', 'architect')),
  result JSONB NOT NULL DEFAULT '{}'::jsonb,
  started_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  completed_at TIMESTAMPTZ
);
ALTER TABLE public.founder_trials ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.founder_trials FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.founder_trials TO service_role;

CREATE OR REPLACE FUNCTION private.advance_founder_trial(
  p_actor_id UUID,
  p_next_stage TEXT,
  p_specialization TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE v_trial public.founder_trials%ROWTYPE;
DECLARE v_expected_stage TEXT;
BEGIN
  -- This implementation is callable only by the service-role API wrapper.
  -- A non-service caller must still prove that its JWT subject owns the intent.
  IF p_actor_id IS NULL OR (
    (SELECT auth.role()) <> 'service_role'
    AND p_actor_id IS DISTINCT FROM (SELECT auth.uid())
  ) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_FOUNDER_TRIAL';
  END IF;
  INSERT INTO public.founder_trials(player_id) VALUES (p_actor_id)
  ON CONFLICT (player_id) DO NOTHING;
  SELECT * INTO v_trial FROM public.founder_trials WHERE player_id = p_actor_id FOR UPDATE;
  v_expected_stage := CASE v_trial.stage
    WHEN 'shared_starter_garment' THEN 'artisan_sample'
    WHEN 'artisan_sample' THEN 'architect_sample'
    WHEN 'architect_sample' THEN 'result_visible'
    WHEN 'result_visible' THEN 'revision_or_business_response'
    WHEN 'revision_or_business_response' THEN 'specialization_selected'
    WHEN 'specialization_selected' THEN 'main_quest_handoff'
    WHEN 'main_quest_handoff' THEN 'completed'
    ELSE 'completed'
  END;
  IF p_next_stage <> v_expected_stage THEN RAISE EXCEPTION 'INVALID_TRIAL_TRANSITION'; END IF;
  IF p_next_stage = 'specialization_selected' AND p_specialization NOT IN ('artisan', 'architect') THEN
    RAISE EXCEPTION 'INVALID_SPECIALIZATION';
  END IF;
  UPDATE public.founder_trials
  SET stage = p_next_stage, specialization = COALESCE(p_specialization, specialization),
      updated_at = clock_timestamp(),
      completed_at = CASE WHEN p_next_stage = 'completed' THEN clock_timestamp() ELSE completed_at END
  WHERE player_id = p_actor_id
  RETURNING * INTO v_trial;
  RETURN jsonb_build_object('stage', v_trial.stage, 'specialization', v_trial.specialization);
END;
$$;
REVOKE ALL ON FUNCTION private.advance_founder_trial(UUID, TEXT, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.advance_founder_trial(UUID, TEXT, TEXT) TO service_role;

-- Remove all direct client mutations from every current public table. This is
-- intentionally broader than the named economy tables so a new client path
-- cannot create an ownership, score, role, or moderation bypass by omission.
DO $$
DECLARE relation_name TEXT;
DECLARE policy_name TEXT;
BEGIN
  FOR relation_name IN
    SELECT c.relname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p')
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', relation_name);
    EXECUTE format('REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLE public.%I FROM PUBLIC, anon, authenticated', relation_name);
    FOR policy_name IN
      SELECT policyname
      FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = relation_name
        AND cmd IN ('INSERT', 'UPDATE', 'DELETE', 'ALL')
    LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', policy_name, relation_name);
    END LOOP;
  END LOOP;
END;
$$;

-- Keep owner-scoped read policies as defense in depth, but do not restore raw
-- public-schema grants. Client reads are introduced only through the reviewed
-- api projections in the later boundary migration.
DROP POLICY IF EXISTS "Players: read own" ON public.players;
CREATE POLICY "Players: read own" ON public.players FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = id);
DROP POLICY IF EXISTS "Designs: read own" ON public.designs;
CREATE POLICY "Designs: read own" ON public.designs FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = player_id);
DROP POLICY IF EXISTS "Brand state: read own" ON public.brand_state;
CREATE POLICY "Brand state: read own" ON public.brand_state FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = player_id);
DROP POLICY IF EXISTS "Player events: read own" ON public.player_events;
CREATE POLICY "Player events: read own" ON public.player_events FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) = player_id);
DROP POLICY IF EXISTS "Maisons: read all" ON public.maisons;
CREATE POLICY "Maisons: read all" ON public.maisons FOR SELECT TO authenticated USING (TRUE);
DROP POLICY IF EXISTS "Maison members: read all" ON public.maison_members;
CREATE POLICY "Maison members: read all" ON public.maison_members FOR SELECT TO authenticated USING (TRUE);
DROP POLICY IF EXISTS "Feed posts: read all" ON public.feed_posts;
CREATE POLICY "Feed posts: read all" ON public.feed_posts FOR SELECT TO authenticated USING (TRUE);

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;

-- Quarantine all historical privileged entry points. Moving them into an
-- unexposed schema removes their PostgREST surface; no client or service grant
-- remains. Replacements below have an explicit caller contract.
DO $$
DECLARE function_record RECORD;
BEGIN
  FOR function_record IN
    SELECT p.proname, pg_get_function_identity_arguments(p.oid) AS arguments
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname = ANY (ARRAY[
        'increment_post_reaction', 'increment_post_hype', 'inject_capital_bonus',
        'apply_idle_multiplier', 'apply_logistics_discount', 'reset_talent_stamina',
        'halt_supply_chain', 'process_idle_income', 'edge_drop_design'
      ])
  LOOP
    EXECUTE format('REVOKE ALL ON FUNCTION public.%I(%s) FROM PUBLIC, anon, authenticated, service_role', function_record.proname, function_record.arguments);
    EXECUTE format('ALTER FUNCTION public.%I(%s) SET SCHEMA private', function_record.proname, function_record.arguments);
    EXECUTE format('ALTER FUNCTION private.%I(%s) SET search_path TO pg_catalog', function_record.proname, function_record.arguments);
  END LOOP;
END;
$$;

-- Remove the historical raw-schema view. Its eventual replacement is an
-- owner-scoped api projection, not a public relation.
DROP VIEW IF EXISTS public.player_active_buffs;

ALTER TABLE public.designs
  ADD COLUMN IF NOT EXISTS design_blueprint JSONB,
  ADD COLUMN IF NOT EXISTS authoritative_result JSONB,
  ADD COLUMN IF NOT EXISTS result_version TEXT;

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
  v_balance NUMERIC(14, 2);
  v_response JSONB;
BEGIN
  -- Edge Functions validate the bearer JWT before passing its subject through
  -- the service-only wrapper. Direct callers cannot execute this function.
  IF p_actor_id IS NULL OR (
    (SELECT auth.role()) <> 'service_role'
    AND p_actor_id IS DISTINCT FROM (SELECT auth.uid())
  ) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_IDLE_SETTLEMENT';
  END IF;
  IF p_idempotency_key IS NULL THEN RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED'; END IF;

  SELECT response INTO v_existing
  FROM ledger.idle_income_receipts
  WHERE player_id = p_actor_id AND idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_existing; END IF;

  SELECT * INTO v_brand
  FROM public.brand_state
  WHERE player_id = p_actor_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;

  -- Re-check after the canonical state lock. Concurrent duplicate callers wait
  -- here, then return the original receipt instead of creating a second credit.
  SELECT response INTO v_existing
  FROM ledger.idle_income_receipts
  WHERE player_id = p_actor_id AND idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_existing; END IF;

  v_elapsed_seconds := GREATEST(0, LEAST(
    86400,
    EXTRACT(EPOCH FROM (v_now - COALESCE(v_brand.last_active_at, v_now)))::BIGINT
  ));
  v_amount := ROUND(GREATEST(0, v_brand.idle_revenue_per_hour) * v_elapsed_seconds / 3600.0, 2);
  v_balance := ROUND(v_brand.total_revenue + v_amount, 2);

  UPDATE public.brand_state
  SET total_revenue = v_balance,
      last_active_at = v_now,
      updated_at = v_now
  WHERE player_id = p_actor_id;

  INSERT INTO public.idle_income_log(player_id, computed_at, amount, multiplier, decay_factor)
  VALUES (p_actor_id, v_now, v_amount, 1, 1);
  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key, amount, balance_after, cause
  ) VALUES (
    p_actor_id, 'idle_income_settlement', 'idle-income-v1', p_idempotency_key,
    v_amount, v_balance, jsonb_build_object('elapsed_seconds', v_elapsed_seconds, 'server_time', v_now)
  );

  v_response := jsonb_build_object(
    'receipt_id', p_idempotency_key,
    'earned_amount', v_amount,
    'new_total_revenue', v_balance,
    'elapsed_seconds', v_elapsed_seconds,
    'rule_version', 'idle-income-v1',
    'settled_at', v_now
  );
  INSERT INTO ledger.idle_income_receipts(player_id, idempotency_key, response)
  VALUES (p_actor_id, p_idempotency_key, v_response);
  RETURN v_response;
END;
$$;
REVOKE ALL ON FUNCTION private.settle_idle_income(UUID, UUID) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.settle_idle_income(UUID, UUID) TO service_role;

CREATE OR REPLACE FUNCTION private.release_design(
  p_actor_id UUID,
  p_design_id UUID,
  p_release_intent TEXT,
  p_blueprint JSONB
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
  v_existing_post public.feed_posts%ROWTYPE;
  v_post public.feed_posts%ROWTYPE;
  v_drop public.garment_drops%ROWTYPE;
  v_zone_count INT;
  v_material_count INT;
  v_palette_count INT;
  v_construction_count INT;
  v_score NUMERIC(10, 2);
  v_followers_delta INT;
  v_heat_delta INT;
  v_xp_delta INT;
  v_verdict TEXT;
  v_headline TEXT;
  v_quote TEXT;
  v_result JSONB;
  v_tags TEXT[];
BEGIN
  -- The Edge Function verifies the caller JWT and passes that subject through
  -- the service-role-only API wrapper. Direct player tokens have no EXECUTE.
  IF p_actor_id IS NULL OR (
    (SELECT auth.role()) <> 'service_role'
    AND p_actor_id IS DISTINCT FROM (SELECT auth.uid())
  ) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_RELEASE';
  END IF;
  IF p_release_intent <> 'publish_first_drop' THEN RAISE EXCEPTION 'INVALID_RELEASE_INTENT'; END IF;
  IF jsonb_typeof(p_blueprint) <> 'object'
     OR EXISTS (
       SELECT 1 FROM jsonb_object_keys(p_blueprint) AS k(key)
       WHERE key <> ALL (ARRAY[
         'version', 'garment_category', 'editable_zones', 'materials', 'palette',
         'construction_choices', 'revision_lineage'
       ])
     )
     OR p_blueprint->>'version' <> '1'
     OR p_blueprint->>'garment_category' <> 'starter_garment'
     OR jsonb_typeof(p_blueprint->'editable_zones') <> 'array'
     OR jsonb_typeof(p_blueprint->'materials') <> 'array'
     OR jsonb_typeof(p_blueprint->'palette') <> 'array'
     OR jsonb_typeof(p_blueprint->'construction_choices') <> 'array'
     OR jsonb_typeof(p_blueprint->'revision_lineage') <> 'array' THEN
    RAISE EXCEPTION 'INVALID_DESIGN_BLUEPRINT';
  END IF;

  v_zone_count := jsonb_array_length(p_blueprint->'editable_zones');
  v_material_count := jsonb_array_length(p_blueprint->'materials');
  v_palette_count := jsonb_array_length(p_blueprint->'palette');
  v_construction_count := jsonb_array_length(p_blueprint->'construction_choices');
  IF v_zone_count NOT BETWEEN 1 AND 8 OR v_material_count NOT BETWEEN 1 AND 4
     OR v_palette_count NOT BETWEEN 1 AND 6 OR v_construction_count NOT BETWEEN 1 AND 6 THEN
    RAISE EXCEPTION 'INVALID_DESIGN_BLUEPRINT';
  END IF;

  SELECT * INTO v_design FROM public.designs
  WHERE id = p_design_id AND player_id = p_actor_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'DESIGN_NOT_FOUND_OR_NOT_OWNED'; END IF;
  IF v_design.status = 'dropped' THEN
    SELECT fp.* INTO v_existing_post
    FROM public.garment_drops gd
    JOIN public.feed_posts fp ON fp.id = gd.feed_post_id
    WHERE gd.design_id = p_design_id
    ORDER BY gd.dropped_at ASC LIMIT 1;
    IF FOUND THEN
      SELECT gd.* INTO v_drop
      FROM public.garment_drops gd
      WHERE gd.design_id = p_design_id
      ORDER BY gd.dropped_at ASC LIMIT 1;
      RETURN COALESCE(v_existing_post.content->'authoritative_result', '{}'::jsonb)
        || jsonb_build_object(
          'success', TRUE,
          'feed_post_id', v_existing_post.id,
          'garment_drop_id', v_drop.id,
          'design_id', p_design_id,
          'hype_score', v_existing_post.hype
        );
    END IF;
    RAISE EXCEPTION 'DESIGN_ALREADY_DROPPED';
  END IF;
  IF v_design.status <> 'complete' THEN RAISE EXCEPTION 'DESIGN_NOT_READY'; END IF;

  SELECT * INTO v_player FROM public.players WHERE id = p_actor_id FOR UPDATE;
  SELECT * INTO v_brand FROM public.brand_state WHERE player_id = p_actor_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;

  v_score := LEAST(100, GREATEST(0,
    35 + v_zone_count * 5 + v_material_count * 8 + v_palette_count * 3 + v_construction_count * 4
  ));
  v_followers_delta := FLOOR(v_score / 2)::INT;
  v_heat_delta := CEIL(v_score / 20)::INT;
  v_xp_delta := ROUND(v_score)::INT;
  v_verdict := CASE WHEN v_score >= 85 THEN 'Alpha' WHEN v_score >= 65 THEN 'Noticed' ELSE 'Developing' END;
  v_headline := CASE WHEN v_score >= 85 THEN 'A clear signature enters the room.' WHEN v_score >= 65 THEN 'The silhouette has a point of view.' ELSE 'The first cut is promising, not finished.' END;
  v_quote := CASE WHEN v_score >= 85 THEN 'The choices hold together under scrutiny.' WHEN v_score >= 65 THEN 'Commit to the strongest material decision next.' ELSE 'Revision will reveal the garment''s intent.' END;
  SELECT COALESCE(array_agg(tag), ARRAY['starter']::TEXT[]) INTO v_tags
  FROM (SELECT jsonb_array_elements_text(p_blueprint->'materials') AS tag LIMIT 3) AS material_tags;

  v_result := jsonb_build_object(
    'result_version', 'design-result-v1', 'hype_score', v_score,
    'vex_verdict', v_verdict, 'vex_headline', v_headline, 'vex_quote', v_quote,
    'causes', jsonb_build_array(
      jsonb_build_object('factor', 'editable_zones', 'count', v_zone_count),
      jsonb_build_object('factor', 'materials', 'count', v_material_count),
      jsonb_build_object('factor', 'palette', 'count', v_palette_count),
      jsonb_build_object('factor', 'construction_choices', 'count', v_construction_count)
    ),
    'followers_delta', v_followers_delta, 'brand_heat_delta', v_heat_delta,
    'xp_delta', v_xp_delta, 'next_objective', 'Review the customer and Vex result in the Feed.'
  );

  INSERT INTO public.feed_posts(player_id, type, content, hype, likes, comments_count)
  VALUES (
    p_actor_id, 'design_flex', jsonb_build_object(
      'event', 'alpha_dropped', 'design_id', p_design_id, 'design_name', v_design.name,
      'style_tags', to_jsonb(v_tags), 'authoritative_result', v_result,
      'vex_verdict', v_verdict, 'vex_headline', v_headline, 'vex_quote', v_quote,
      'brand_name', v_player.brand_name
    ), v_score, 0, 0
  ) RETURNING * INTO v_post;
  INSERT INTO public.garment_drops(player_id, design_id, style_tags, hype_score, feed_post_id)
  VALUES (p_actor_id, p_design_id, v_tags, v_score, v_post.id) RETURNING * INTO v_drop;
  UPDATE public.designs SET status = 'dropped', dropped_at = clock_timestamp(),
    hype_score = v_score, design_blueprint = p_blueprint,
    authoritative_result = v_result, result_version = 'design-result-v1'
  WHERE id = p_design_id;
  UPDATE public.brand_state SET followers = followers + v_followers_delta,
    heat = LEAST(100, heat + v_heat_delta), hype_score = GREATEST(hype_score, v_score),
    updated_at = clock_timestamp() WHERE player_id = p_actor_id;
  UPDATE public.players SET total_xp = total_xp + v_xp_delta,
    last_active_at = clock_timestamp() WHERE id = p_actor_id;
  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key, amount, balance_after, cause
  ) VALUES (
    p_actor_id, 'design_release', 'design-result-v1', p_design_id, 0,
    v_brand.total_revenue,
    jsonb_build_object('design_id', p_design_id, 'feed_post_id', v_post.id, 'result', v_result)
  );
  RETURN v_result || jsonb_build_object('success', TRUE, 'feed_post_id', v_post.id, 'garment_drop_id', v_drop.id, 'design_id', p_design_id);
END;
$$;
REVOKE ALL ON FUNCTION private.release_design(UUID, UUID, TEXT, JSONB) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.release_design(UUID, UUID, TEXT, JSONB) TO service_role;

-- Moderation is private data. A player can submit a bounded report intent only
-- through the verified Edge Function; the server supplies the reporter id.
CREATE OR REPLACE FUNCTION private.enforce_player_report_limits()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_daily_count INT;
BEGIN
  -- The only normal caller is the service-role report contract. Preserve the
  -- ownership assertion for any future non-service server caller.
  IF (SELECT auth.role()) <> 'service_role'
     AND ((SELECT auth.uid()) IS NULL OR (SELECT auth.uid()) IS DISTINCT FROM NEW.reporter_id) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_REPORTER';
  END IF;
  PERFORM pg_advisory_xact_lock(
    hashtextextended(NEW.reporter_id::TEXT || ':' || NEW.reported_player_id::TEXT, 0)
  );
  IF EXISTS (
    SELECT 1 FROM public.player_reports report
    WHERE report.reporter_id = NEW.reporter_id
      AND report.reported_player_id = NEW.reported_player_id
      AND report.created_at >= clock_timestamp() - INTERVAL '15 minutes'
  ) THEN RAISE EXCEPTION 'REPORT_RATE_LIMITED'; END IF;
  SELECT COUNT(*) INTO v_daily_count FROM public.player_reports report
  WHERE report.reporter_id = NEW.reporter_id
    AND report.created_at >= clock_timestamp() - INTERVAL '24 hours';
  IF v_daily_count >= 10 THEN RAISE EXCEPTION 'REPORT_DAILY_LIMIT'; END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION private.enforce_player_report_limits() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.enforce_player_report_limits() TO service_role;

CREATE OR REPLACE FUNCTION private.submit_player_report(
  p_actor_id UUID,
  p_reported_player_id UUID,
  p_category TEXT,
  p_description TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_report_id UUID;
BEGIN
  IF p_actor_id IS NULL OR p_reported_player_id IS NULL OR p_actor_id = p_reported_player_id
     OR ((SELECT auth.role()) <> 'service_role'
       AND p_actor_id IS DISTINCT FROM (SELECT auth.uid())) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_REPORTER';
  END IF;
  IF p_category NOT IN (
    'harassment', 'hate', 'spam', 'cheating', 'inappropriate_content', 'other'
  ) OR char_length(COALESCE(p_description, '')) > 1000 THEN
    RAISE EXCEPTION 'INVALID_REPORT';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_reported_player_id) THEN
    RAISE EXCEPTION 'REPORT_TARGET_NOT_FOUND';
  END IF;

  INSERT INTO public.player_reports(
    reporter_id, reported_id, reported_player_id, category, reason, description
  ) VALUES (
    p_actor_id, p_reported_player_id, p_reported_player_id, p_category, p_category,
    NULLIF(btrim(COALESCE(p_description, '')), '')
  ) RETURNING id INTO v_report_id;

  RETURN jsonb_build_object('report_id', v_report_id, 'status', 'accepted');
END;
$$;
REVOKE ALL ON FUNCTION private.submit_player_report(UUID, UUID, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.submit_player_report(UUID, UUID, TEXT, TEXT) TO service_role;

-- Viewing a result is a server-checked tutorial intent, never a client-owned
-- objective completion. Existing write triggers continue to record creation
-- events; this covers only the two explicit Early Game acknowledgement steps.
CREATE OR REPLACE FUNCTION private.record_verified_progression_event(
  p_actor_id UUID,
  p_event_key TEXT,
  p_entity_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE v_valid BOOLEAN := FALSE;
BEGIN
  IF p_actor_id IS NULL OR ((SELECT auth.role()) <> 'service_role'
      AND p_actor_id IS DISTINCT FROM (SELECT auth.uid())) THEN
    RAISE EXCEPTION 'UNAUTHORIZED_PROGRESS_EVENT';
  END IF;
  v_valid := CASE p_event_key
    WHEN 'first_drop_result_viewed' THEN EXISTS (
      SELECT 1 FROM public.feed_posts
      WHERE player_id = p_actor_id AND content->>'event' = 'alpha_dropped'
    )
    WHEN 'store_result_viewed' THEN EXISTS (
      SELECT 1 FROM public.stores WHERE player_id = p_actor_id
    )
    ELSE FALSE
  END;
  IF NOT v_valid THEN RAISE EXCEPTION 'INVALID_PROGRESS_EVENT'; END IF;
  INSERT INTO public.player_progression_events(player_id, event_key, entity_id)
  VALUES (p_actor_id, p_event_key, p_entity_id)
  ON CONFLICT (player_id, event_key, entity_id) DO NOTHING;
  UPDATE public.first_week_objectives
  SET status = 'completed', completed_at = COALESCE(completed_at, clock_timestamp())
  WHERE player_id = p_actor_id AND completion_event_key = p_event_key;
  RETURN jsonb_build_object('success', TRUE, 'event_key', p_event_key);
END;
$$;
REVOKE ALL ON FUNCTION private.record_verified_progression_event(UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.record_verified_progression_event(UUID, TEXT, UUID)
  TO service_role;
