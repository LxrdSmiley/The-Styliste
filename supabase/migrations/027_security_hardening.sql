-- Security hardening: player-scoped RPC guard helpers and dangerous grant removal.

CREATE OR REPLACE FUNCTION public.assert_self(p_player_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.assert_self(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.assert_self(UUID) TO authenticated, service_role;

CREATE OR REPLACE FUNCTION public.grant_mini_game_reward(
  p_player_id UUID,
  p_game_key TEXT,
  p_result_key TEXT,
  p_amount BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.brand_state
  SET total_revenue = total_revenue + p_amount
  WHERE player_id = p_player_id;

  INSERT INTO public.idle_income_log (player_id, amount, multiplier, decay_factor)
  VALUES (p_player_id, p_amount, 1.0, 1.0);

  RETURN jsonb_build_object(
    'success', true,
    'game_key', p_game_key,
    'result_key', p_result_key,
    'currency', p_amount
  );
END;
$$;

REVOKE ALL ON FUNCTION public.grant_mini_game_reward(UUID, TEXT, TEXT, BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.grant_mini_game_reward(UUID, TEXT, TEXT, BIGINT) TO service_role;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'add_inventory') THEN
    REVOKE EXECUTE ON FUNCTION public.add_inventory(UUID, BIGINT) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'verify_and_grant_luxe') THEN
    REVOKE EXECUTE ON FUNCTION public.verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'record_failed_transaction') THEN
    REVOKE EXECUTE ON FUNCTION public.record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'increment_luxe_trust') THEN
    REVOKE EXECUTE ON FUNCTION public.increment_luxe_trust(UUID, INTEGER) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.increment_luxe_trust(UUID, INTEGER) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'trigger_scandal') THEN
    REVOKE EXECUTE ON FUNCTION public.trigger_scandal(UUID, TEXT, INTEGER, TEXT) FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.trigger_scandal(UUID, TEXT, INTEGER, TEXT) TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_global_trend_tsunami') THEN
    REVOKE EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() FROM authenticated;
    GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'inject_capital_bonus') THEN
    REVOKE EXECUTE ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_idle_multiplier') THEN
    REVOKE EXECUTE ON FUNCTION public.apply_idle_multiplier(UUID, NUMERIC, INT) FROM authenticated;
  END IF;

  IF to_regprocedure('public.reset_talent_stamina(uuid, uuid)') IS NOT NULL THEN
    REVOKE EXECUTE ON FUNCTION public.reset_talent_stamina(UUID, UUID) FROM authenticated;
  END IF;

  IF to_regprocedure('public.reset_talent_stamina(uuid, text)') IS NOT NULL THEN
    REVOKE EXECUTE ON FUNCTION public.reset_talent_stamina(UUID, TEXT) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_logistics_discount') THEN
    REVOKE EXECUTE ON FUNCTION public.apply_logistics_discount(UUID, NUMERIC, INT) FROM authenticated;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'halt_supply_chain') THEN
    REVOKE EXECUTE ON FUNCTION public.halt_supply_chain(UUID) FROM authenticated;
  END IF;
END $$;

-- =============================================================================
-- Advisor-driven hardening pass.
-- Supabase advisors flagged SECURITY DEFINER views, mutable search_path functions,
-- and SECURITY DEFINER functions still executable through PUBLIC/anon defaults.
-- Keep this migration idempotent so it can be re-run on local/branch databases.
-- =============================================================================

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;

-- assert_self does not need definer privileges; it only compares auth.uid().
CREATE OR REPLACE FUNCTION public.assert_self(p_player_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.assert_self(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.assert_self(UUID) TO authenticated, service_role;

-- Client calls claim-mini-game-reward; only the Edge Function may grant rewards.
CREATE OR REPLACE FUNCTION public.grant_mini_game_reward(
  p_player_id UUID,
  p_game_key TEXT,
  p_result_key TEXT,
  p_amount BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  IF p_game_key NOT IN ('supplier_raid', 'flash_sale', 'hostile_takeover', 'price_war') THEN
    RAISE EXCEPTION 'INVALID_GAME_KEY';
  END IF;

  IF p_amount < 0 OR p_amount > 5000 THEN
    RAISE EXCEPTION 'INVALID_REWARD_AMOUNT';
  END IF;

  UPDATE public.brand_state
  SET total_revenue = total_revenue + p_amount
  WHERE player_id = p_player_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PLAYER_BRAND_STATE_NOT_FOUND';
  END IF;

  INSERT INTO public.idle_income_log (player_id, amount, multiplier, decay_factor)
  VALUES (p_player_id, p_amount, 1.0, 1.0);

  RETURN jsonb_build_object(
    'success', true,
    'game_key', p_game_key,
    'result_key', p_result_key,
    'currency', p_amount
  );
END;
$$;

REVOKE ALL ON FUNCTION public.grant_mini_game_reward(UUID, TEXT, TEXT, BIGINT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_mini_game_reward(UUID, TEXT, TEXT, BIGINT) TO service_role;

-- Replace the broken two-arg hype RPC: migration 020 updated nonexistent
-- feed_posts.hype_count. This version deduplicates and increments feed_posts.hype.
CREATE OR REPLACE FUNCTION public.increment_post_hype(
  p_post_id UUID,
  p_player_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.assert_self(p_player_id);

  IF EXISTS (
    SELECT 1
    FROM public.post_reactions
    WHERE post_id = p_post_id
      AND player_id = p_player_id
      AND reaction_type = 'hype'
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'ALREADY_HYPED');
  END IF;

  INSERT INTO public.post_reactions (post_id, player_id, reaction_type)
  VALUES (p_post_id, p_player_id, 'hype');

  UPDATE public.feed_posts
  SET hype = hype + 1
  WHERE id = p_post_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'POST_NOT_FOUND';
  END IF;

  RETURN jsonb_build_object('success', true, 'hype_added', 1);
END;
$$;

REVOKE ALL ON FUNCTION public.increment_post_hype(UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.increment_post_hype(UUID, UUID) TO authenticated;

-- The one-arg legacy RPC can inflate any post and has no actor id. Retire it.
DO $$
BEGIN
  IF to_regprocedure('public.increment_post_hype(uuid)') IS NOT NULL THEN
    REVOKE ALL ON FUNCTION public.increment_post_hype(UUID) FROM PUBLIC, anon, authenticated;
  END IF;

  IF to_regprocedure('public.increment_post_reaction(uuid, text)') IS NOT NULL THEN
    REVOKE ALL ON FUNCTION public.increment_post_reaction(UUID, TEXT) FROM PUBLIC, anon, authenticated;
    ALTER FUNCTION public.increment_post_reaction(UUID, TEXT) SET search_path = public;
  END IF;
END $$;

-- Guard telemetry RPCs. Clients may only log events for their own player id.
CREATE OR REPLACE FUNCTION public.log_telemetry_event(
  p_player_id UUID,
  p_event_type TEXT,
  p_event_name TEXT,
  p_payload JSONB DEFAULT NULL,
  p_session_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  PERFORM public.assert_self(p_player_id);

  INSERT INTO public.telemetry_events (player_id, event_type, event_name, payload, session_id)
  VALUES (p_player_id, p_event_type, p_event_name, p_payload, p_session_id)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_telemetry_event(
  p_player_id UUID,
  p_event_type TEXT,
  p_event_name TEXT,
  p_payload JSONB DEFAULT NULL,
  p_session_id UUID DEFAULT NULL,
  p_device_info JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  PERFORM public.assert_self(p_player_id);

  INSERT INTO public.telemetry_events (player_id, event_type, event_name, payload, session_id, device_info)
  VALUES (p_player_id, p_event_type, p_event_name, p_payload, p_session_id, p_device_info)
  RETURNING id INTO v_event_id;

  RETURN v_event_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.batch_log_telemetry(p_events JSONB[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bad_count INT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT COUNT(*) INTO v_bad_count
  FROM unnest(p_events) AS e(event)
  WHERE (e.event->>'player_id')::UUID <> auth.uid();

  IF v_bad_count > 0 THEN
    RAISE EXCEPTION 'Telemetry player_id mismatch';
  END IF;

  INSERT INTO public.telemetry_events (player_id, event_type, event_name, payload, session_id, device_info, occurred_at)
  SELECT
    auth.uid(),
    e.event->>'event_type',
    e.event->>'event_name',
    e.event->'payload',
    NULLIF(e.event->>'session_id', '')::UUID,
    e.event->'device_info',
    COALESCE(NULLIF(e.event->>'occurred_at', '')::TIMESTAMPTZ, NOW())
  FROM unnest(p_events) AS e(event);
END;
$$;

REVOKE ALL ON FUNCTION public.log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID, JSONB) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.batch_log_telemetry(JSONB[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.batch_log_telemetry(JSONB[]) TO authenticated;

-- Fix mutable search_path advisor findings on trigger/cron helpers.
DO $$
BEGIN
  IF to_regprocedure('public.archive_expired_tsunami()') IS NOT NULL THEN
    ALTER FUNCTION public.archive_expired_tsunami() SET search_path = public;
  END IF;

  IF to_regprocedure('public.update_maison_hype_on_drop()') IS NOT NULL THEN
    ALTER FUNCTION public.update_maison_hype_on_drop() SET search_path = public;
  END IF;

  IF to_regprocedure('public.check_joint_venture_unlock()') IS NOT NULL THEN
    ALTER FUNCTION public.check_joint_venture_unlock() SET search_path = public;
  END IF;

  IF to_regprocedure('public.trigger_archive_sold_webhook()') IS NOT NULL THEN
    ALTER FUNCTION public.trigger_archive_sold_webhook() SET search_path = public;
  END IF;

  IF to_regprocedure('public.trigger_trend_tsunami_webhook()') IS NOT NULL THEN
    ALTER FUNCTION public.trigger_trend_tsunami_webhook() SET search_path = public;
  END IF;
END $$;

-- Re-grant only the RPCs intentionally callable from authenticated clients.
DO $$
BEGIN
  IF to_regprocedure('public.follow_player(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.follow_player(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.unfollow_player(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.unfollow_player(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.get_syndicate_feed(integer)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.get_syndicate_feed(INT) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_sovereign_genesis(uuid, text, text, text, text, jsonb)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_sovereign_genesis(UUID, TEXT, TEXT, TEXT, TEXT, JSONB) TO authenticated;
  END IF;
  IF to_regprocedure('public.unlock_joint_venture(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.unlock_joint_venture(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_memorialization(uuid, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_memorialization(UUID, TEXT) TO authenticated;
  END IF;
  IF to_regprocedure('public.get_sovereign_multiplier(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.get_sovereign_multiplier(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.apply_kintsugi_repair(uuid, integer)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.apply_kintsugi_repair(UUID, INTEGER) TO authenticated;
  END IF;
  IF to_regprocedure('public.apply_public_apology(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.apply_public_apology(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_casting_pull(uuid, text, boolean)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_casting_pull(UUID, TEXT, BOOLEAN) TO authenticated;
  END IF;
  IF to_regprocedure('public.get_player_roster(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.get_player_roster(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.submit_to_gala(uuid, uuid, uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.cast_gala_vote(uuid, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.cast_gala_vote(UUID, TEXT) TO authenticated;
  END IF;
  IF to_regprocedure('public.get_gala_leaderboard(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.get_gala_leaderboard(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_archive_purchase(uuid, uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_archive_purchase(UUID, UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.list_on_archive(uuid, uuid, bigint, boolean, uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.list_on_archive(UUID, UUID, BIGINT, BOOLEAN, UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.cancel_archive_listing(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.cancel_archive_listing(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_liquidation(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_liquidation(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.upgrade_logistics(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.upgrade_logistics(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.process_idle_income(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.process_idle_income(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.record_check_in(uuid)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.record_check_in(UUID) TO authenticated;
  END IF;
  IF to_regprocedure('public.register_fcm_token(uuid, text, text, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.register_fcm_token(UUID, TEXT, TEXT, TEXT) TO authenticated;
  END IF;
  IF to_regprocedure('public.execute_power_move(uuid, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.execute_power_move(UUID, TEXT) TO authenticated;
  END IF;
END $$;

-- Service-only RPCs and cron helpers.
DO $$
BEGIN
  IF to_regprocedure('public.verify_and_grant_luxe(uuid, text, text, text, text, numeric, integer)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) TO service_role;
  END IF;
  IF to_regprocedure('public.record_failed_transaction(uuid, text, text, numeric, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) TO service_role;
  END IF;
  IF to_regprocedure('public.trigger_scandal(uuid, text, integer, text)') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.trigger_scandal(UUID, TEXT, INTEGER, TEXT) TO service_role;
  END IF;
  IF to_regprocedure('public.calculate_global_trend_tsunami()') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO service_role;
  END IF;
  IF to_regprocedure('public.archive_expired_tsunami()') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.archive_expired_tsunami() TO service_role;
  END IF;
  IF to_regprocedure('public.rotate_gala_event()') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.rotate_gala_event() TO service_role;
  END IF;
  IF to_regprocedure('public.expire_archive_listings()') IS NOT NULL THEN
    GRANT EXECUTE ON FUNCTION public.expire_archive_listings() TO service_role;
  END IF;
END $$;

-- Restrict every existing public-schema policy to authenticated users. This
-- preserves intentional global reads inside the signed-in app while closing anon.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format(
      'ALTER POLICY %I ON %I.%I TO authenticated',
      r.policyname,
      r.schemaname,
      r.tablename
    );
  END LOOP;
END $$;

-- Performance advisor: add missing high-traffic FK indexes.
CREATE INDEX IF NOT EXISTS archive_listings_design_idx ON public.archive_listings(design_id);
CREATE INDEX IF NOT EXISTS archive_listings_gala_event_idx ON public.archive_listings(gala_event_id);
CREATE INDEX IF NOT EXISTS campaigns_maison_pool_idx ON public.campaigns(maison_pool_id);
CREATE INDEX IF NOT EXISTS district_takeover_log_defender_idx ON public.district_takeover_log(defender_maison_id);
CREATE INDEX IF NOT EXISTS equity_positions_brand_idx ON public.equity_positions(brand_id);
CREATE INDEX IF NOT EXISTS gala_submissions_design_idx ON public.gala_submissions(design_id);
CREATE INDEX IF NOT EXISTS gala_submissions_talent_idx ON public.gala_submissions(talent_id);
CREATE INDEX IF NOT EXISTS gala_vote_limits_event_idx ON public.gala_vote_limits(event_id);
CREATE INDEX IF NOT EXISTS garment_drops_design_idx ON public.garment_drops(design_id);
CREATE INDEX IF NOT EXISTS garment_drops_feed_post_idx ON public.garment_drops(feed_post_id);
CREATE INDEX IF NOT EXISTS loans_player_idx ON public.loans(player_id);
CREATE INDEX IF NOT EXISTS maisons_founder_idx ON public.maisons(founder_id);
CREATE INDEX IF NOT EXISTS partnerships_player_a_idx ON public.partnerships(player_a_id);
CREATE INDEX IF NOT EXISTS partnerships_player_b_idx ON public.partnerships(player_b_id);
CREATE INDEX IF NOT EXISTS player_events_event_idx ON public.player_events(event_id);
CREATE INDEX IF NOT EXISTS player_reports_reporter_idx ON public.player_reports(reporter_id);
CREATE INDEX IF NOT EXISTS player_reports_reported_idx ON public.player_reports(reported_id);
CREATE INDEX IF NOT EXISTS player_reports_reported_player_idx ON public.player_reports(reported_player_id);
CREATE INDEX IF NOT EXISTS provenance_ledger_listing_idx ON public.provenance_ledger(listing_id);
CREATE INDEX IF NOT EXISTS supply_chain_supplier_idx ON public.supply_chain(supplier_id);

-- Recreate exposed views as invoker views so underlying RLS applies to callers.
CREATE OR REPLACE VIEW public.daily_revenue_ledger
WITH (security_invoker = true) AS
SELECT
  player_id,
  date_trunc('day', computed_at)::date AS revenue_date,
  SUM(amount) AS revenue_total
FROM public.idle_income_log
GROUP BY player_id, date_trunc('day', computed_at)::date;

CREATE OR REPLACE VIEW public.supply_chain_status
WITH (security_invoker = true) AS
SELECT
  player_id,
  warehouse_capacity,
  current_inventory_value,
  logistics_level,
  ROUND((current_inventory_value::NUMERIC / NULLIF(warehouse_capacity, 0)) * 100, 1) AS fill_percent,
  (current_inventory_value >= warehouse_capacity) AS is_full,
  GREATEST(0, warehouse_capacity - current_inventory_value) AS remaining_space,
  idle_revenue_per_hour,
  last_active_at
FROM public.brand_state;

CREATE OR REPLACE VIEW public.player_active_buffs
WITH (security_invoker = true) AS
SELECT
  bs.player_id,
  buff,
  (buff->>'expires_at')::TIMESTAMPTZ AS expires_at
FROM public.brand_state bs
CROSS JOIN LATERAL jsonb_array_elements(bs.active_buffs) AS buff
WHERE bs.active_buffs IS NOT NULL
  AND jsonb_array_length(bs.active_buffs) > 0;

CREATE OR REPLACE VIEW public.archive_listings_enriched
WITH (security_invoker = true) AS
SELECT
  al.*,
  d.name AS design_name,
  d.hype_score,
  d.provenance_multiplier,
  d.has_sovereign_provenance,
  d.transfer_count,
  d.image_url AS design_image_url,
  p.display_name AS seller_name,
  bs.brand_rank AS seller_rank,
  bs.is_in_hall_of_sovereigns AS seller_is_sovereign,
  ge.theme_title AS gala_theme
FROM public.archive_listings al
JOIN public.designs d ON al.design_id = d.id
JOIN public.players p ON al.seller_id = p.id
LEFT JOIN public.brand_state bs ON al.seller_id = bs.player_id
LEFT JOIN public.gala_events ge ON al.gala_event_id = ge.id
WHERE al.status = 'active' AND al.expires_at > NOW();

CREATE OR REPLACE VIEW public.provenance_ledger_enriched
WITH (security_invoker = true) AS
SELECT
  pl.*,
  prev.display_name AS previous_owner_name,
  prev_bs.brand_rank AS previous_owner_rank,
  new_owner.display_name AS new_owner_name,
  new_bs.brand_rank AS new_owner_rank,
  d.name AS design_name
FROM public.provenance_ledger pl
JOIN public.players prev ON pl.previous_owner_id = prev.id
JOIN public.brand_state prev_bs ON pl.previous_owner_id = prev_bs.player_id
JOIN public.players new_owner ON pl.new_owner_id = new_owner.id
JOIN public.brand_state new_bs ON pl.new_owner_id = new_bs.player_id
JOIN public.designs d ON pl.design_id = d.id
ORDER BY pl.transferred_at DESC;

CREATE OR REPLACE VIEW public.retention_analytics
WITH (security_invoker = true) AS
SELECT
  DATE_TRUNC('day', occurred_at) AS day,
  event_type,
  COUNT(DISTINCT player_id) AS unique_players,
  COUNT(*) AS total_events,
  COUNT(DISTINCT session_id) AS unique_sessions
FROM public.telemetry_events
WHERE occurred_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', occurred_at), event_type
ORDER BY day DESC;

CREATE OR REPLACE VIEW public.notification_effectiveness
WITH (security_invoker = true) AS
SELECT
  te.payload->>'notification_type' AS notification_type,
  te.payload->>'notification_id' AS notification_id,
  COUNT(*) AS total_sent,
  COUNT(CASE WHEN te2.event_name = 'notification_opened' THEN 1 END) AS total_opened,
  ROUND(
    COUNT(CASE WHEN te2.event_name = 'notification_opened' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0),
    2
  ) AS open_rate_pct
FROM public.telemetry_events te
LEFT JOIN public.telemetry_events te2 ON
  te.player_id = te2.player_id
  AND te2.event_type = 'notification'
  AND te2.event_name = 'notification_opened'
  AND te2.payload->>'notification_id' = te.payload->>'notification_id'
  AND te2.occurred_at > te.occurred_at
WHERE te.event_type = 'notification'
  AND te.event_name = 'notification_sent'
  AND te.occurred_at >= NOW() - INTERVAL '7 days'
GROUP BY te.payload->>'notification_type', te.payload->>'notification_id';

CREATE OR REPLACE VIEW public.storefront_analytics
WITH (security_invoker = true) AS
SELECT
  DATE_TRUNC('day', purchased_at) AS day,
  product_id,
  platform,
  COUNT(*) AS transaction_count,
  SUM(amount_usd) AS revenue_usd,
  SUM(luxe_tokens_granted) AS luxe_granted,
  COUNT(CASE WHEN status = 'verified' THEN 1 END) AS successful_count,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_count
FROM public.fiat_transactions
GROUP BY DATE_TRUNC('day', purchased_at), product_id, platform
ORDER BY day DESC;

GRANT SELECT ON public.daily_revenue_ledger TO authenticated;
GRANT SELECT ON public.supply_chain_status TO authenticated;
GRANT SELECT ON public.player_active_buffs TO authenticated;
GRANT SELECT ON public.archive_listings_enriched TO authenticated;
GRANT SELECT ON public.provenance_ledger_enriched TO authenticated;
REVOKE SELECT ON public.retention_analytics FROM PUBLIC, anon, authenticated;
REVOKE SELECT ON public.notification_effectiveness FROM PUBLIC, anon, authenticated;
REVOKE SELECT ON public.storefront_analytics FROM PUBLIC, anon, authenticated;
