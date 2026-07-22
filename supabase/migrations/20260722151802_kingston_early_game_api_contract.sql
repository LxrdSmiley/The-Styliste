-- GDD v7 §§19.2, 19.4-19.10, 21.3, 21.4, and 22.
-- Directive 1: one fail-closed Kingston Early Game API authority boundary.
--
-- Lock order for every mutation:
--   1. per-auth-subject advisory transaction lock
--   2. identity mapping / player row
--   3. operation-specific rows in stable identifier order
--   4. append-only operation receipt and economic ledger entry

CREATE SCHEMA IF NOT EXISTS api;
CREATE SCHEMA IF NOT EXISTS private;
CREATE SCHEMA IF NOT EXISTS ledger;

-- ---------------------------------------------------------------------------
-- Fail-closed schema and default privilege baseline.
-- ---------------------------------------------------------------------------

REVOKE ALL ON SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public
  FROM PUBLIC, anon, authenticated;

REVOKE ALL ON SCHEMA private, ledger FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA private, ledger
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA private, ledger
  FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA private, ledger
  FROM PUBLIC, anon, authenticated;

REVOKE ALL ON SCHEMA api FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA api FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA api
  FROM PUBLIC, anon, authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA private
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA private
  REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA private
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ledger
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ledger
  REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA ledger
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA api
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA api
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Explicit Auth subject -> player identity bridge.
-- Existing rows preserve the repository's proven genesis invariant:
-- execute_sovereign_genesis asserted auth.uid() and inserted players.id from it.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS private.auth_player_identities (
  auth_user_id UUID PRIMARY KEY,
  player_id UUID NOT NULL UNIQUE
    REFERENCES public.players(id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'locked', 'retired')),
  source TEXT NOT NULL DEFAULT 'supabase_auth_subject'
    CHECK (source = 'supabase_auth_subject'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  CHECK (auth_user_id = player_id)
);
CREATE INDEX IF NOT EXISTS auth_player_identities_player_status_idx
  ON private.auth_player_identities(player_id, status);
ALTER TABLE private.auth_player_identities ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON private.auth_player_identities
  FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON private.auth_player_identities TO service_role;

INSERT INTO private.auth_player_identities(auth_user_id, player_id, status)
SELECT player.id, player.id, 'active'
FROM public.players AS player
ON CONFLICT (auth_user_id) DO UPDATE
SET player_id = EXCLUDED.player_id,
    updated_at = clock_timestamp()
WHERE private.auth_player_identities.player_id = EXCLUDED.player_id;

CREATE INDEX IF NOT EXISTS feed_posts_player_type_created_idx
  ON public.feed_posts(player_id, type, created_at DESC)
  WHERE player_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- One append-only idempotency and audit receipt ledger for all six endpoints.
-- The original request is retained for exact/conflicting replay detection but
-- is never included in a player-facing projection.
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ledger.kingston_operation_receipts (
  auth_user_id UUID NOT NULL,
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE RESTRICT,
  operation TEXT NOT NULL CHECK (operation IN (
    'founder_trial',
    'design_intent',
    'first_store',
    'idle_settlement',
    'progression_event',
    'player_report'
  )),
  idempotency_key UUID NOT NULL,
  request_payload JSONB NOT NULL,
  rule_version TEXT NOT NULL,
  receipt JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY (auth_user_id, operation, idempotency_key),
  CHECK (auth_user_id = player_id),
  CHECK (jsonb_typeof(request_payload) = 'object'),
  CHECK (jsonb_typeof(receipt) = 'object')
);
CREATE INDEX IF NOT EXISTS kingston_receipts_player_operation_created_idx
  ON ledger.kingston_operation_receipts(
    player_id,
    operation,
    created_at DESC
  );
ALTER TABLE ledger.kingston_operation_receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ledger.kingston_operation_receipts
  FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON ledger.kingston_operation_receipts TO service_role;

CREATE OR REPLACE FUNCTION private.reject_kingston_receipt_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RAISE EXCEPTION 'KINGSTON_RECEIPTS_ARE_APPEND_ONLY';
END;
$$;
REVOKE ALL ON FUNCTION private.reject_kingston_receipt_mutation()
  FROM PUBLIC, anon, authenticated, service_role;

DROP TRIGGER IF EXISTS kingston_receipts_append_only
  ON ledger.kingston_operation_receipts;
CREATE TRIGGER kingston_receipts_append_only
  BEFORE UPDATE OR DELETE ON ledger.kingston_operation_receipts
  FOR EACH ROW EXECUTE FUNCTION private.reject_kingston_receipt_mutation();

-- ---------------------------------------------------------------------------
-- Identity, lock, replay, and receipt helpers.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.resolve_player_id(p_auth_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID;
  v_count INTEGER;
BEGIN
  IF p_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'IDENTITY_SUBJECT_REQUIRED';
  END IF;

  SELECT count(*), (array_agg(identity.player_id))[1]
  INTO v_count, v_player_id
  FROM private.auth_player_identities AS identity
  WHERE identity.auth_user_id = p_auth_user_id
    AND identity.status = 'active';

  IF v_count = 0 THEN RAISE EXCEPTION 'IDENTITY_MAPPING_MISSING'; END IF;
  IF v_count <> 1 THEN RAISE EXCEPTION 'IDENTITY_MAPPING_AMBIGUOUS'; END IF;
  IF v_player_id IS DISTINCT FROM p_auth_user_id THEN
    RAISE EXCEPTION 'IDENTITY_MAPPING_FOREIGN';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.players AS player WHERE player.id = v_player_id
  ) THEN
    RAISE EXCEPTION 'IDENTITY_PLAYER_MISSING';
  END IF;

  RETURN v_player_id;
END;
$$;
REVOKE ALL ON FUNCTION private.resolve_player_id(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.resolve_player_id(UUID) TO service_role;

CREATE OR REPLACE FUNCTION private.current_player_id()
RETURNS UUID
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_subject UUID := (SELECT auth.uid());
BEGIN
  IF v_subject IS NULL THEN RAISE EXCEPTION 'AUTHENTICATION_REQUIRED'; END IF;
  RETURN private.resolve_player_id(v_subject);
END;
$$;
REVOKE ALL ON FUNCTION private.current_player_id()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.current_player_id() TO authenticated;

CREATE OR REPLACE FUNCTION private.lock_kingston_actor(p_auth_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID;
BEGIN
  IF p_auth_user_id IS NULL THEN RAISE EXCEPTION 'IDENTITY_SUBJECT_REQUIRED'; END IF;
  PERFORM pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('kingston:' || p_auth_user_id::TEXT, 0)
  );
  v_player_id := private.resolve_player_id(p_auth_user_id);
  PERFORM 1
  FROM public.players AS player
  WHERE player.id = v_player_id
  FOR UPDATE;
  RETURN v_player_id;
END;
$$;
REVOKE ALL ON FUNCTION private.lock_kingston_actor(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.lock_kingston_actor(UUID) TO service_role;

CREATE OR REPLACE FUNCTION private.get_kingston_receipt(
  p_auth_user_id UUID,
  p_operation TEXT,
  p_idempotency_key UUID,
  p_request_payload JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_request JSONB;
  v_receipt JSONB;
BEGIN
  IF p_idempotency_key IS NULL THEN
    RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED';
  END IF;
  SELECT stored.request_payload, stored.receipt
  INTO v_request, v_receipt
  FROM ledger.kingston_operation_receipts AS stored
  WHERE stored.auth_user_id = p_auth_user_id
    AND stored.operation = p_operation
    AND stored.idempotency_key = p_idempotency_key;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF v_request IS DISTINCT FROM COALESCE(p_request_payload, '{}'::JSONB) THEN
    RAISE EXCEPTION 'IDEMPOTENCY_KEY_CONFLICT';
  END IF;
  RETURN v_receipt;
END;
$$;
REVOKE ALL ON FUNCTION private.get_kingston_receipt(UUID, TEXT, UUID, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.get_kingston_receipt(UUID, TEXT, UUID, JSONB)
  TO service_role;

CREATE OR REPLACE FUNCTION private.record_kingston_receipt(
  p_auth_user_id UUID,
  p_player_id UUID,
  p_operation TEXT,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT,
  p_receipt JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO ledger.kingston_operation_receipts(
    auth_user_id,
    player_id,
    operation,
    idempotency_key,
    request_payload,
    rule_version,
    receipt
  ) VALUES (
    p_auth_user_id,
    p_player_id,
    p_operation,
    p_idempotency_key,
    COALESCE(p_request_payload, '{}'::JSONB),
    p_rule_version,
    p_receipt
  );
  RETURN p_receipt;
END;
$$;
REVOKE ALL ON FUNCTION private.record_kingston_receipt(
  UUID, UUID, TEXT, UUID, JSONB, TEXT, JSONB
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.record_kingston_receipt(
  UUID, UUID, TEXT, UUID, JSONB, TEXT, JSONB
) TO service_role;

-- ---------------------------------------------------------------------------
-- Owner-scoped read helpers. These SECURITY DEFINER helpers live in an
-- unexposed schema, validate auth.uid() through the identity bridge, return
-- explicit fields only, and are consumed by security-invoker api views.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.read_player_summary()
RETURNS TABLE(
  id UUID,
  brand_name TEXT,
  path TEXT,
  hq_city TEXT,
  brand_rank INTEGER,
  total_xp INTEGER,
  onboarding_complete BOOLEAN,
  is_anonymous BOOLEAN,
  is_joint_venture BOOLEAN,
  sovereign_multipliers INTEGER,
  joint_venture_unlocked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  last_active_at TIMESTAMPTZ,
  luxe_trust_score INTEGER
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    player.id,
    player.brand_name,
    player.path,
    player.hq_city,
    player.brand_rank,
    player.total_xp,
    player.onboarding_complete,
    player.is_anonymous,
    player.is_joint_venture,
    player.sovereign_multipliers,
    player.joint_venture_unlocked_at,
    player.created_at,
    player.last_active_at,
    player.luxe_trust_score
  FROM public.players AS player
  WHERE player.id = private.current_player_id();
$$;

CREATE OR REPLACE FUNCTION private.read_brand_summary()
RETURNS TABLE(
  player_id UUID,
  heat INTEGER,
  hype_score NUMERIC,
  followers INTEGER,
  idle_revenue_per_hour NUMERIC,
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
    brand.idle_revenue_per_hour,
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

CREATE OR REPLACE FUNCTION private.read_founder_trial_state()
RETURNS TABLE(
  player_id UUID,
  stage TEXT,
  specialization TEXT,
  result JSONB,
  started_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    trial.player_id,
    trial.stage,
    trial.specialization,
    trial.result,
    trial.started_at,
    trial.updated_at,
    trial.completed_at
  FROM public.founder_trials AS trial
  WHERE trial.player_id = private.current_player_id();
$$;

CREATE OR REPLACE FUNCTION private.read_owned_designs()
RETURNS TABLE(
  id UUID,
  player_id UUID,
  name TEXT,
  session_type TEXT,
  status TEXT,
  hype_score NUMERIC,
  is_alpha BOOLEAN,
  fabric_data JSONB,
  created_at TIMESTAMPTZ,
  dropped_at TIMESTAMPTZ,
  authoritative_result JSONB,
  result_version TEXT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    design.id,
    design.player_id,
    design.name,
    design.session_type,
    design.status,
    design.hype_score,
    design.is_alpha,
    design.fabric_data,
    design.created_at,
    design.dropped_at,
    design.authoritative_result,
    design.result_version
  FROM public.designs AS design
  WHERE design.player_id = private.current_player_id()
    AND design.status <> 'draft';
$$;

CREATE OR REPLACE FUNCTION private.read_design_session_state()
RETURNS TABLE(
  session_id UUID,
  player_id UUID,
  fabric_color_hex TEXT,
  style_tags TEXT[],
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  minted_at TIMESTAMPTZ,
  design_id UUID
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    session.id,
    session.player_id,
    session.fabric_color_hex,
    session.style_tags,
    session.started_at,
    session.expires_at,
    session.minted_at,
    session.design_id
  FROM public.atelier_sessions AS session
  WHERE session.player_id = private.current_player_id()
    AND session.expires_at > now() - INTERVAL '24 hours';
$$;

CREATE OR REPLACE FUNCTION private.read_owner_feed_projection()
RETURNS TABLE(
  id UUID,
  player_id UUID,
  type TEXT,
  content JSONB,
  hype NUMERIC,
  likes INTEGER,
  comments_count INTEGER,
  created_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    post.id,
    post.player_id,
    post.type,
    post.content,
    post.hype,
    post.likes,
    post.comments_count,
    post.created_at
  FROM public.feed_posts AS post
  WHERE post.player_id = private.current_player_id()
    AND post.type IN ('design_flex', 'design_drop', 'genesis_complete');
$$;

CREATE OR REPLACE FUNCTION private.read_first_week_objectives()
RETURNS TABLE(
  player_id UUID,
  objective_key TEXT,
  path TEXT,
  title TEXT,
  description TEXT,
  status TEXT,
  completed_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    objective.player_id,
    objective.objective_key,
    objective.path,
    objective.title,
    objective.description,
    objective.status,
    objective.completed_at
  FROM public.first_week_objectives AS objective
  WHERE objective.player_id = private.current_player_id();
$$;

CREATE OR REPLACE FUNCTION private.read_store_summary()
RETURNS TABLE(
  id UUID,
  player_id UUID,
  type TEXT,
  city TEXT,
  tier INTEGER,
  revenue_per_hour NUMERIC,
  loyalty INTEGER,
  market_share NUMERIC,
  opened_at TIMESTAMPTZ,
  audience TEXT,
  price_tier TEXT,
  inventory_capacity INTEGER,
  operating_cost_per_hour NUMERIC,
  expected_demand_per_day NUMERIC,
  decision_made_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    store.id,
    store.player_id,
    store.type,
    store.city,
    store.tier,
    store.revenue_per_hour,
    store.loyalty,
    store.market_share,
    store.opened_at,
    store.audience,
    store.price_tier,
    store.inventory_capacity,
    store.operating_cost_per_hour,
    store.expected_demand_per_day,
    store.decision_made_at,
    store.updated_at
  FROM public.stores AS store
  WHERE store.player_id = private.current_player_id();
$$;

CREATE OR REPLACE FUNCTION private.read_progression_state()
RETURNS TABLE(
  id UUID,
  player_id UUID,
  event_key TEXT,
  entity_id UUID,
  occurred_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    event.id,
    event.player_id,
    event.event_key,
    event.entity_id,
    event.occurred_at
  FROM public.player_progression_events AS event
  WHERE event.player_id = private.current_player_id();
$$;

CREATE OR REPLACE FUNCTION private.read_kingston_receipts(p_operation TEXT)
RETURNS TABLE(
  player_id UUID,
  idempotency_key UUID,
  rule_version TEXT,
  receipt JSONB,
  created_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    stored.player_id,
    stored.idempotency_key,
    stored.rule_version,
    stored.receipt,
    stored.created_at
  FROM ledger.kingston_operation_receipts AS stored
  WHERE stored.player_id = private.current_player_id()
    AND stored.operation = p_operation;
$$;

REVOKE EXECUTE ON FUNCTION private.read_player_summary(),
  private.read_brand_summary(),
  private.read_founder_trial_state(),
  private.read_owned_designs(),
  private.read_design_session_state(),
  private.read_owner_feed_projection(),
  private.read_first_week_objectives(),
  private.read_store_summary(),
  private.read_progression_state(),
  private.read_kingston_receipts(TEXT)
  FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA private TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION private.read_player_summary(),
  private.read_brand_summary(),
  private.read_founder_trial_state(),
  private.read_owned_designs(),
  private.read_design_session_state(),
  private.read_owner_feed_projection(),
  private.read_first_week_objectives(),
  private.read_store_summary(),
  private.read_progression_state(),
  private.read_kingston_receipts(TEXT)
  TO authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Six server-owned Kingston Early Game mutation authorities.
-- Each function accepts the actor only in the server-only wrapper argument,
-- never inside the client request payload. Every request is serialized by the
-- same per-subject advisory lock and returns an append-only versioned receipt.
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
  v_market_tier TEXT;
  v_starting_capital BIGINT;
  v_idle_rate BIGINT;
  v_hype_ceiling NUMERIC;
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
      'action', 'brand_name', 'career_path', 'market_tier', 'avatar_config'
    ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
    IF EXISTS (
      SELECT 1 FROM private.auth_player_identities AS identity
      WHERE identity.auth_user_id = p_auth_user_id
    ) THEN
      RAISE EXCEPTION 'FOUNDER_ALREADY_INITIALIZED';
    END IF;
    IF EXISTS (SELECT 1 FROM public.players AS player WHERE player.id = p_auth_user_id) THEN
      RAISE EXCEPTION 'PLAYER_IDENTITY_CONFLICT';
    END IF;

    v_brand_name := btrim(COALESCE(p_request_payload->>'brand_name', ''));
    v_path := COALESCE(p_request_payload->>'career_path', '');
    v_market_tier := COALESCE(p_request_payload->>'market_tier', '');
    IF char_length(v_brand_name) NOT BETWEEN 2 AND 40 THEN
      RAISE EXCEPTION 'INVALID_BRAND_NAME';
    END IF;
    IF v_path NOT IN ('designer', 'mogul') THEN RAISE EXCEPTION 'INVALID_CAREER_PATH'; END IF;
    IF v_market_tier NOT IN ('high_luxury', 'mid_luxury', 'mass_market') THEN
      RAISE EXCEPTION 'INVALID_MARKET_TIER';
    END IF;
    IF jsonb_typeof(COALESCE(p_request_payload->'avatar_config', '{}'::JSONB)) <> 'object' THEN
      RAISE EXCEPTION 'INVALID_AVATAR_CONFIG';
    END IF;

    v_starting_capital := CASE v_market_tier
      WHEN 'high_luxury' THEN 50000 WHEN 'mid_luxury' THEN 100000 ELSE 200000 END;
    v_idle_rate := CASE v_market_tier
      WHEN 'high_luxury' THEN 500 WHEN 'mid_luxury' THEN 1500 ELSE 3000 END;
    v_hype_ceiling := CASE v_market_tier
      WHEN 'high_luxury' THEN 1000000 WHEN 'mid_luxury' THEN 500000 ELSE 100000 END;

    INSERT INTO public.players(
      id, brand_name, path, hq_city, onboarding_complete, is_anonymous
    ) VALUES (
      p_auth_user_id, v_brand_name, v_path, 'kingston', TRUE,
      COALESCE(p_actor_is_anonymous, FALSE)
    );
    INSERT INTO private.auth_player_identities(auth_user_id, player_id)
    VALUES (p_auth_user_id, p_auth_user_id);
    INSERT INTO public.brand_state(
      player_id, total_revenue, hype_score, idle_revenue_per_hour,
      market_tier, avatar_configuration, hype_ceiling, luxe_tokens
    ) VALUES (
      p_auth_user_id, v_starting_capital, 0, v_idle_rate,
      v_market_tier, COALESCE(p_request_payload->'avatar_config', '{}'::JSONB),
      v_hype_ceiling, 0
    );
    INSERT INTO ledger.economy_ledger(
      player_id, entry_type, rule_version, idempotency_key,
      amount, balance_after, cause
    ) VALUES (
      p_auth_user_id, 'founder_capital', p_rule_version, p_idempotency_key,
      v_starting_capital, v_starting_capital,
      jsonb_build_object('market_tier', v_market_tier, 'city', 'kingston')
    );
    INSERT INTO public.founder_trials(player_id) VALUES (p_auth_user_id);
    INSERT INTO public.feed_posts(player_id, type, content, hype)
    VALUES (
      p_auth_user_id,
      'genesis_complete',
      jsonb_build_object(
        'brand_name', v_brand_name,
        'city', 'kingston',
        'tier', v_market_tier,
        'path', v_path
      ),
      100
    );
    v_player_id := p_auth_user_id;
    v_result := jsonb_build_object(
      'receipt_version', p_rule_version,
      'operation', 'founder_trial',
      'status', 'initialized',
      'idempotency_key', p_idempotency_key,
      'player_id', v_player_id,
      'stage', 'shared_starter_garment',
      'starting_capital', v_starting_capital,
      'hq_city', 'kingston'
    );
  ELSIF v_action = 'advance' THEN
    IF (p_request_payload - ARRAY[
      'action', 'next_stage', 'specialization'
    ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
    v_player_id := private.lock_kingston_actor(p_auth_user_id);
    v_result := private.advance_founder_trial(
      v_player_id,
      p_request_payload->>'next_stage',
      NULLIF(p_request_payload->>'specialization', '')
    );
    v_result := jsonb_build_object(
      'receipt_version', p_rule_version,
      'operation', 'founder_trial',
      'status', 'advanced',
      'idempotency_key', p_idempotency_key,
      'result', v_result
    );
  ELSE
    RAISE EXCEPTION 'INVALID_FOUNDER_TRIAL_ACTION';
  END IF;

  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'founder_trial', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

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
  IF p_rule_version <> 'kingston-design-intent.v1' THEN RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION'; END IF;
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
    IF jsonb_typeof(COALESCE(p_request_payload->'style_tags', 'null'::JSONB)) <> 'array' THEN
      RAISE EXCEPTION 'INVALID_STYLE_TAGS';
    END IF;
    SELECT ARRAY(SELECT jsonb_array_elements_text(p_request_payload->'style_tags'))
    INTO v_style_tags;
    IF cardinality(v_style_tags) NOT BETWEEN 1 AND 3 THEN RAISE EXCEPTION 'INVALID_STYLE_TAGS'; END IF;
    INSERT INTO public.atelier_sessions(player_id, fabric_color_hex, style_tags)
    VALUES (v_player_id, p_request_payload->>'fabric_color_hex', v_style_tags)
    RETURNING * INTO v_session;
    v_result := jsonb_build_object(
      'status', 'started', 'session_id', v_session.id,
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
    IF v_session.expires_at <= clock_timestamp() THEN RAISE EXCEPTION 'ATELIER_SESSION_EXPIRED'; END IF;
    IF v_session.design_id IS NOT NULL THEN RAISE EXCEPTION 'ATELIER_SESSION_ALREADY_MINTED'; END IF;
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
        'materials', to_jsonb(v_session.style_tags),
        'palette', jsonb_build_array(v_session.fabric_color_hex)
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
      'action', 'design_id', 'release_intent', 'blueprint'
    ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
    v_result := private.release_design(
      v_player_id,
      (p_request_payload->>'design_id')::UUID,
      COALESCE(NULLIF(p_request_payload->>'release_intent', ''), 'first_drop'),
      COALESCE(p_request_payload->'blueprint', '{}'::JSONB)
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
  v_store public.stores%ROWTYPE;
  v_existing JSONB;
  v_store_type TEXT := COALESCE(p_request_payload->>'store_type', '');
  v_price_tier TEXT := COALESCE(p_request_payload->>'price_tier', '');
  v_capacity INTEGER;
  v_demand NUMERIC(14, 4);
  v_operating_cost NUMERIC(14, 4);
  v_audience TEXT;
  v_result JSONB;
BEGIN
  IF p_rule_version <> 'kingston-first-store.v1' THEN RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION'; END IF;
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
  SELECT * INTO v_player FROM public.players WHERE id = v_player_id FOR UPDATE;
  IF v_player.path <> 'mogul' THEN RAISE EXCEPTION 'MOGUL_ONLY'; END IF;
  PERFORM 1 FROM public.brand_state AS brand
  WHERE brand.player_id = v_player_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;
  IF EXISTS (SELECT 1 FROM public.stores WHERE player_id = v_player_id) THEN
    RAISE EXCEPTION 'FIRST_STORE_ALREADY_OPEN';
  END IF;
  IF v_store_type NOT IN ('flagship', 'ecommerce') THEN RAISE EXCEPTION 'INVALID_STORE_TYPE'; END IF;
  IF v_price_tier NOT IN ('accessible', 'signature', 'luxury') THEN RAISE EXCEPTION 'INVALID_PRICE_TIER'; END IF;
  BEGIN
    v_capacity := (p_request_payload->>'inventory_capacity')::INTEGER;
  EXCEPTION WHEN invalid_text_representation THEN
    RAISE EXCEPTION 'INVALID_INVENTORY_CAPACITY';
  END;
  IF v_capacity NOT BETWEEN 12 AND 60 THEN RAISE EXCEPTION 'INVALID_INVENTORY_CAPACITY'; END IF;
  v_audience := CASE v_price_tier
    WHEN 'accessible' THEN 'emerging' WHEN 'signature' THEN 'design-conscious' ELSE 'collector' END;
  v_demand := CASE v_price_tier WHEN 'accessible' THEN 18 WHEN 'signature' THEN 10 ELSE 5 END;
  v_operating_cost := CASE v_store_type WHEN 'flagship' THEN 140 ELSE 35 END;

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
  UPDATE public.brand_state
  SET idle_revenue_per_hour = (
        SELECT COALESCE(SUM(store.revenue_per_hour), 0)
        FROM public.stores AS store WHERE store.player_id = v_player_id
      ),
      updated_at = clock_timestamp()
  WHERE player_id = v_player_id;
  INSERT INTO ledger.economy_ledger(
    player_id, entry_type, rule_version, idempotency_key,
    amount, balance_after, cause
  )
  SELECT
    v_player_id, 'first_store_open', p_rule_version, p_idempotency_key,
    0, brand.total_revenue,
    jsonb_build_object('store_id', v_store.id, 'city', 'kingston')
  FROM public.brand_state AS brand
  WHERE brand.player_id = v_player_id;

  v_result := jsonb_build_object(
    'receipt_version', p_rule_version,
    'operation', 'first_store',
    'status', 'opened',
    'success', TRUE,
    'idempotency_key', p_idempotency_key,
    'store_id', v_store.id,
    'opening_cost', 0,
    'city', v_store.city,
    'store_type', v_store.type,
    'price_tier', v_store.price_tier,
    'inventory_capacity', v_store.inventory_capacity,
    'expected_demand_per_day', v_store.expected_demand_per_day,
    'operating_cost_per_hour', v_store.operating_cost_per_hour,
    'revenue_per_hour', v_store.revenue_per_hour
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'first_store', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

CREATE OR REPLACE FUNCTION private.authority_idle_settlement_v1(
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
DECLARE v_player_id UUID; v_existing JSONB; v_result JSONB;
BEGIN
  IF p_rule_version <> 'kingston-idle-settlement.v1' THEN RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION'; END IF;
  IF COALESCE(p_request_payload, '{}'::JSONB) <> '{}'::JSONB THEN RAISE EXCEPTION 'IDLE_PAYLOAD_MUST_BE_EMPTY'; END IF;
  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'idle_settlement', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;
  v_result := private.settle_idle_income(v_player_id, p_idempotency_key);
  v_result := v_result || jsonb_build_object(
    'receipt_version', p_rule_version, 'operation', 'idle_settlement',
    'status', 'settled', 'idempotency_key', p_idempotency_key
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'idle_settlement', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

CREATE OR REPLACE FUNCTION private.authority_progression_event_v1(
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
DECLARE v_player_id UUID; v_existing JSONB; v_result JSONB; v_entity_id UUID;
BEGIN
  IF p_rule_version <> 'kingston-progression-event.v1' THEN RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION'; END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' OR
     (p_request_payload - ARRAY['event_key', 'entity_id']) <> '{}'::JSONB THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;
  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'progression_event', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;
  IF NULLIF(p_request_payload->>'entity_id', '') IS NOT NULL THEN
    v_entity_id := (p_request_payload->>'entity_id')::UUID;
  END IF;
  v_result := private.record_verified_progression_event(
    v_player_id, p_request_payload->>'event_key', v_entity_id
  );
  v_result := v_result || jsonb_build_object(
    'receipt_version', p_rule_version, 'operation', 'progression_event',
    'status', 'recorded', 'idempotency_key', p_idempotency_key
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'progression_event', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

CREATE OR REPLACE FUNCTION private.authority_submit_player_report_v1(
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
DECLARE v_player_id UUID; v_existing JSONB; v_result JSONB;
BEGIN
  IF p_rule_version <> 'kingston-player-report.v1' THEN RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION'; END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' OR
     (p_request_payload - ARRAY[
       'reported_player_id', 'category', 'description'
     ]) <> '{}'::JSONB THEN RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD'; END IF;
  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'player_report', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;
  v_result := private.submit_player_report(
    v_player_id,
    (p_request_payload->>'reported_player_id')::UUID,
    p_request_payload->>'category',
    COALESCE(p_request_payload->>'description', '')
  );
  v_result := v_result || jsonb_build_object(
    'receipt_version', p_rule_version, 'operation', 'player_report',
    'status', 'accepted', 'idempotency_key', p_idempotency_key
  );
  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'player_report', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

REVOKE ALL ON FUNCTION private.authority_founder_trial_v1(UUID, BOOLEAN, UUID, JSONB, TEXT),
  private.authority_design_intent_v1(UUID, UUID, JSONB, TEXT),
  private.authority_open_first_store_v1(UUID, UUID, JSONB, TEXT),
  private.authority_idle_settlement_v1(UUID, UUID, JSONB, TEXT),
  private.authority_progression_event_v1(UUID, UUID, JSONB, TEXT),
  private.authority_submit_player_report_v1(UUID, UUID, JSONB, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.authority_founder_trial_v1(UUID, BOOLEAN, UUID, JSONB, TEXT),
  private.authority_design_intent_v1(UUID, UUID, JSONB, TEXT),
  private.authority_open_first_store_v1(UUID, UUID, JSONB, TEXT),
  private.authority_idle_settlement_v1(UUID, UUID, JSONB, TEXT),
  private.authority_progression_event_v1(UUID, UUID, JSONB, TEXT),
  private.authority_submit_player_report_v1(UUID, UUID, JSONB, TEXT)
  TO service_role;

-- ---------------------------------------------------------------------------
-- Exact Data API allowlist: owner-safe read projections and six service-only
-- versioned wrappers. No raw public/private/ledger relation is exposed.
-- ---------------------------------------------------------------------------

DROP VIEW IF EXISTS api.public_profiles;
DROP VIEW IF EXISTS
  api.player_summary,
  api.brand_summary,
  api.founder_trial_state,
  api.owned_designs,
  api.design_session_state,
  api.feed_projection,
  api.first_week_objectives,
  api.store_summary,
  api.progression_state,
  api.design_release_receipts,
  api.first_store_receipts,
  api.idle_settlement_receipts;
DROP FUNCTION IF EXISTS api.server_settle_idle_income(UUID, UUID);
DROP FUNCTION IF EXISTS api.server_release_design(UUID, UUID, TEXT, JSONB);
DROP FUNCTION IF EXISTS api.server_submit_player_report(UUID, UUID, TEXT, TEXT);
DROP FUNCTION IF EXISTS api.server_record_progression_event(UUID, TEXT, UUID);
CREATE OR REPLACE VIEW api.player_summary WITH (security_invoker = true) AS
  SELECT state.id, state.brand_name, state.path, state.hq_city,
    state.brand_rank, state.total_xp, state.onboarding_complete,
    state.is_anonymous, state.is_joint_venture, state.sovereign_multipliers,
    state.joint_venture_unlocked_at, state.created_at, state.last_active_at,
    state.luxe_trust_score
  FROM private.read_player_summary() AS state;
CREATE OR REPLACE VIEW api.brand_summary WITH (security_invoker = true) AS
  SELECT state.player_id, state.heat, state.hype_score, state.followers,
    state.idle_revenue_per_hour, state.momentum_buff_active,
    state.momentum_buff_until, state.last_active_at,
    state.sustainability_tier, state.dpp_enabled, state.dpp_fully_mapped,
    state.founder_rep, state.current_tarnish, state.kintsugi_level,
    state.total_scandals_survived, state.market_tier,
    state.warehouse_capacity, state.current_inventory_value,
    state.logistics_level
  FROM private.read_brand_summary() AS state;
CREATE OR REPLACE VIEW api.founder_trial_state WITH (security_invoker = true) AS
  SELECT state.player_id, state.stage, state.specialization, state.result,
    state.started_at, state.updated_at, state.completed_at
  FROM private.read_founder_trial_state() AS state;
CREATE OR REPLACE VIEW api.owned_designs WITH (security_invoker = true) AS
  SELECT design.id, design.player_id, design.name, design.session_type,
    design.status, design.hype_score, design.is_alpha, design.fabric_data,
    design.created_at, design.dropped_at, design.authoritative_result,
    design.result_version
  FROM private.read_owned_designs() AS design;
CREATE OR REPLACE VIEW api.design_session_state WITH (security_invoker = true) AS
  SELECT session.session_id, session.player_id, session.fabric_color_hex,
    session.style_tags, session.started_at, session.expires_at,
    session.minted_at, session.design_id
  FROM private.read_design_session_state() AS session;
CREATE OR REPLACE VIEW api.feed_projection WITH (security_invoker = true) AS
  SELECT post.id, post.player_id, post.type, post.content, post.hype,
    post.likes, post.comments_count, post.created_at
  FROM private.read_owner_feed_projection() AS post;
CREATE OR REPLACE VIEW api.first_week_objectives WITH (security_invoker = true) AS
  SELECT objective.player_id, objective.objective_key, objective.path,
    objective.title, objective.description, objective.status,
    objective.completed_at
  FROM private.read_first_week_objectives() AS objective;
CREATE OR REPLACE VIEW api.store_summary WITH (security_invoker = true) AS
  SELECT store.id, store.player_id, store.type, store.city, store.tier,
    store.revenue_per_hour, store.loyalty, store.market_share, store.opened_at,
    store.audience, store.price_tier, store.inventory_capacity,
    store.operating_cost_per_hour, store.expected_demand_per_day,
    store.decision_made_at, store.updated_at
  FROM private.read_store_summary() AS store;
CREATE OR REPLACE VIEW api.progression_state WITH (security_invoker = true) AS
  SELECT event.id, event.player_id, event.event_key, event.entity_id,
    event.occurred_at
  FROM private.read_progression_state() AS event;
CREATE OR REPLACE VIEW api.design_release_receipts WITH (security_invoker = true) AS
  SELECT receipt.player_id, receipt.idempotency_key, receipt.rule_version,
    receipt.receipt, receipt.created_at
  FROM private.read_kingston_receipts('design_intent') AS receipt;
CREATE OR REPLACE VIEW api.first_store_receipts WITH (security_invoker = true) AS
  SELECT receipt.player_id, receipt.idempotency_key, receipt.rule_version,
    receipt.receipt, receipt.created_at
  FROM private.read_kingston_receipts('first_store') AS receipt;
CREATE OR REPLACE VIEW api.idle_settlement_receipts WITH (security_invoker = true) AS
  SELECT receipt.player_id, receipt.idempotency_key, receipt.rule_version,
    receipt.receipt, receipt.created_at
  FROM private.read_kingston_receipts('idle_settlement') AS receipt;

CREATE OR REPLACE FUNCTION api.server_founder_trial_intent_v1(
  p_auth_user_id UUID, p_actor_is_anonymous BOOLEAN, p_idempotency_key UUID,
  p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_founder_trial_v1(
    p_auth_user_id, p_actor_is_anonymous, p_idempotency_key,
    p_request_payload, p_rule_version
  );
$$;
CREATE OR REPLACE FUNCTION api.server_design_intent_v1(
  p_auth_user_id UUID, p_idempotency_key UUID, p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_design_intent_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;
CREATE OR REPLACE FUNCTION api.server_open_first_store_v1(
  p_auth_user_id UUID, p_idempotency_key UUID, p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_open_first_store_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;
CREATE OR REPLACE FUNCTION api.server_settle_idle_income_v1(
  p_auth_user_id UUID, p_idempotency_key UUID, p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_idle_settlement_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;
CREATE OR REPLACE FUNCTION api.server_progression_event_v1(
  p_auth_user_id UUID, p_idempotency_key UUID, p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_progression_event_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;
CREATE OR REPLACE FUNCTION api.server_submit_player_report_v1(
  p_auth_user_id UUID, p_idempotency_key UUID, p_request_payload JSONB, p_rule_version TEXT
)
RETURNS JSONB LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
  SELECT private.authority_submit_player_report_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;

REVOKE ALL ON ALL TABLES IN SCHEMA api FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA api TO authenticated, service_role;
GRANT SELECT ON api.player_summary, api.brand_summary, api.founder_trial_state,
  api.owned_designs, api.design_session_state, api.feed_projection,
  api.first_week_objectives, api.store_summary, api.progression_state,
  api.design_release_receipts, api.first_store_receipts,
  api.idle_settlement_receipts TO authenticated, service_role;

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA api FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api.server_founder_trial_intent_v1(UUID, BOOLEAN, UUID, JSONB, TEXT),
  api.server_design_intent_v1(UUID, UUID, JSONB, TEXT),
  api.server_open_first_store_v1(UUID, UUID, JSONB, TEXT),
  api.server_settle_idle_income_v1(UUID, UUID, JSONB, TEXT),
  api.server_progression_event_v1(UUID, UUID, JSONB, TEXT),
  api.server_submit_player_report_v1(UUID, UUID, JSONB, TEXT)
  TO service_role;

COMMENT ON TABLE ledger.kingston_operation_receipts IS
  'Append-only, versioned request and response receipts for the six Kingston Early Game endpoints.';
