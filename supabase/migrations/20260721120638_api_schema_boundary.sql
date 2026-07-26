-- GDD v7 §19 / PROJECT_RULES §3
-- The REST surface is limited to this reviewed projection schema. Internal
-- tables and all privileged implementations stay in public/private/ledger and
-- are not Data API relations.

CREATE SCHEMA IF NOT EXISTS api;
REVOKE ALL ON SCHEMA api FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA api TO authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA api
  REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA api
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;

-- Define the reviewed projection inventory now, but keep it fail-closed until
-- the later authority migration replaces these transitional security-invoker
-- definitions with owner-scoped private read helpers. Raw public relations do
-- not regain client grants during that transition.
CREATE OR REPLACE VIEW api.player_summary WITH (security_invoker = true) AS
SELECT id, brand_name, path, hq_city, brand_rank, total_xp, onboarding_complete,
  is_anonymous, is_joint_venture, sovereign_multipliers, joint_venture_unlocked_at,
  created_at, last_active_at, luxe_trust_score
FROM public.players
WHERE id = (SELECT auth.uid());

CREATE OR REPLACE VIEW api.brand_summary WITH (security_invoker = true) AS
SELECT player_id, heat, hype_score, followers, idle_revenue_per_hour,
  momentum_buff_active, momentum_buff_until, last_active_at, sustainability_tier,
  dpp_enabled, dpp_fully_mapped, founder_rep, current_tarnish, kintsugi_level,
  total_scandals_survived, market_tier, warehouse_capacity, current_inventory_value,
  logistics_level
FROM public.brand_state
WHERE player_id = (SELECT auth.uid());

CREATE OR REPLACE VIEW api.owned_designs WITH (security_invoker = true) AS
SELECT id, player_id, name, session_type, status, hype_score, is_alpha,
  fabric_data, created_at, dropped_at, authoritative_result, result_version
FROM public.designs
WHERE player_id = (SELECT auth.uid()) AND status <> 'draft';

CREATE OR REPLACE VIEW api.feed_projection WITH (security_invoker = true) AS
SELECT id, player_id, type, content, hype, likes, comments_count, created_at
FROM public.feed_posts;

CREATE OR REPLACE VIEW api.first_week_objectives WITH (security_invoker = true) AS
SELECT player_id, objective_key, path, title, description, status, completed_at
FROM public.first_week_objectives
WHERE player_id = (SELECT auth.uid());

CREATE OR REPLACE VIEW api.store_summary WITH (security_invoker = true) AS
SELECT id, player_id, type, city, tier, revenue_per_hour, loyalty, market_share,
  opened_at, audience, price_tier, inventory_capacity, operating_cost_per_hour,
  expected_demand_per_day, decision_made_at, updated_at
FROM public.stores
WHERE player_id = (SELECT auth.uid());

CREATE OR REPLACE VIEW api.public_profiles WITH (security_invoker = true) AS
SELECT id, brand_name, path, hq_city, created_at
FROM public.players;

-- These SECURITY INVOKER wrappers are service-role-only Edge Function contracts.
-- The Edge Function verifies the bearer JWT and passes its verified subject to
-- the locked private implementation. No security-definer function is exposed
-- through PostgREST and no player token has EXECUTE on either wrapper.
CREATE OR REPLACE FUNCTION api.server_settle_idle_income(
  p_actor_id UUID,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT private.settle_idle_income(p_actor_id, p_idempotency_key);
$$;

CREATE OR REPLACE FUNCTION api.server_release_design(
  p_actor_id UUID,
  p_design_id UUID,
  p_release_intent TEXT,
  p_blueprint JSONB
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT private.release_design(p_actor_id, p_design_id, p_release_intent, p_blueprint);
$$;

CREATE OR REPLACE FUNCTION api.server_submit_player_report(
  p_actor_id UUID,
  p_reported_player_id UUID,
  p_category TEXT,
  p_description TEXT
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT private.submit_player_report(
    p_actor_id, p_reported_player_id, p_category, p_description
  );
$$;

CREATE OR REPLACE FUNCTION api.server_record_progression_event(
  p_actor_id UUID,
  p_event_key TEXT,
  p_entity_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT private.record_verified_progression_event(p_actor_id, p_event_key, p_entity_id);
$$;

REVOKE ALL ON FUNCTION api.server_settle_idle_income(UUID, UUID),
  api.server_release_design(UUID, UUID, TEXT, JSONB),
  api.server_submit_player_report(UUID, UUID, TEXT, TEXT),
  api.server_record_progression_event(UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION api.server_settle_idle_income(UUID, UUID),
  api.server_release_design(UUID, UUID, TEXT, JSONB),
  api.server_submit_player_report(UUID, UUID, TEXT, TEXT),
  api.server_record_progression_event(UUID, TEXT, UUID) TO service_role;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON TABLES FROM PUBLIC, anon, authenticated;

-- Explicitly expose only the reviewed relation inventory. No raw wallet,
-- private profile, draft, fraud, moderation, or ledger relation exists here.
REVOKE ALL ON ALL TABLES IN SCHEMA api FROM PUBLIC, anon, authenticated;
GRANT SELECT ON api.player_summary, api.brand_summary, api.owned_designs,
  api.feed_projection, api.first_week_objectives, api.store_summary,
  api.public_profiles TO authenticated;

COMMENT ON SCHEMA api IS
  'Reviewed Data API boundary. Inventory is enforced by rls_authority_contract.sql.';
