-- =============================================================================
-- Closed Alpha Public RPC Lockdown
-- Locks down anon execution, makes exposed views obey caller/RLS, and hardens
-- Gala voting for real tournament traffic.
-- =============================================================================

-- Functions in exposed schemas are RPCs in Supabase. Keep future functions
-- private-by-default, then explicitly grant the small app-facing surface below.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM authenticated;

-- Any older public function without an explicit search_path receives one. The
-- existing SQL bodies use public-qualified objects inconsistently, so public is
-- the compatibility-preserving path for this pass.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT
      n.nspname,
      p.proname,
      pg_get_function_identity_arguments(p.oid) AS identity_args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND NOT EXISTS (
        SELECT 1
        FROM unnest(COALESCE(p.proconfig, ARRAY[]::TEXT[])) AS cfg(setting)
        WHERE cfg.setting LIKE 'search_path=%'
      )
  LOOP
    EXECUTE format(
      'ALTER FUNCTION %I.%I(%s) SET search_path = public',
      r.nspname,
      r.proname,
      r.identity_args
    );
  END LOOP;
END $$;

-- Close anon policies added after the previous hardening pass. Closed alpha
-- public reads mean signed-in app users, not unauthenticated traffic.
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

-- SECURITY DEFINER views bypass RLS by default. These two are player-scoped
-- reads and should be evaluated as the caller so underlying policies apply.
CREATE OR REPLACE VIEW public.daily_revenue_ledger
WITH (security_invoker = true) AS
SELECT
  player_id,
  date_trunc('day', computed_at)::date AS revenue_date,
  SUM(amount) AS revenue_total
FROM public.idle_income_log
GROUP BY player_id, date_trunc('day', computed_at)::date;

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

REVOKE ALL ON TABLE public.daily_revenue_ledger FROM PUBLIC, anon;
REVOKE ALL ON TABLE public.player_active_buffs FROM PUBLIC, anon;
GRANT SELECT ON TABLE public.daily_revenue_ledger TO authenticated;
GRANT SELECT ON TABLE public.player_active_buffs TO authenticated;

-- Tournament reads are intentional for signed-in players; writes go through RPCs.
REVOKE ALL ON TABLE public.gala_events FROM anon;
REVOKE ALL ON TABLE public.gala_submissions FROM anon;
REVOKE ALL ON TABLE public.gala_votes FROM anon;
REVOKE ALL ON TABLE public.gala_vote_limits FROM anon;

GRANT SELECT ON TABLE public.gala_events TO authenticated;
GRANT SELECT ON TABLE public.gala_submissions TO authenticated;
GRANT SELECT ON TABLE public.gala_votes TO authenticated;
GRANT SELECT ON TABLE public.gala_vote_limits TO authenticated;

REVOKE INSERT, UPDATE, DELETE ON TABLE public.gala_events FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.gala_submissions FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.gala_votes FROM authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.gala_vote_limits FROM authenticated;

-- Gala traffic indexes: leaderboard pagination, event operations, daily limits,
-- and duplicate-vote enforcement.
CREATE INDEX IF NOT EXISTS gala_submissions_event_score_id_idx
  ON public.gala_submissions(event_id, current_score DESC, id);
CREATE INDEX IF NOT EXISTS gala_submissions_event_submitted_idx
  ON public.gala_submissions(event_id, submitted_at DESC);
CREATE INDEX IF NOT EXISTS gala_submissions_event_player_idx
  ON public.gala_submissions(event_id, player_id);
CREATE INDEX IF NOT EXISTS gala_vote_limits_event_date_idx
  ON public.gala_vote_limits(event_id, vote_date);
CREATE INDEX IF NOT EXISTS gala_vote_limits_player_date_idx
  ON public.gala_vote_limits(player_id, vote_date DESC);

-- If any duplicate votes slipped in before the unique guard, keep the earliest
-- vote and rebuild derived counters from the remaining ledger.
WITH ranked_votes AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY submission_id, voter_id
      ORDER BY voted_at ASC, id ASC
    ) AS rn
  FROM public.gala_votes
)
DELETE FROM public.gala_votes gv
USING ranked_votes rv
WHERE gv.id = rv.id
  AND rv.rn > 1;

WITH vote_totals AS (
  SELECT
    submission_id,
    COALESCE(SUM(final_points), 0)::NUMERIC(14,2) AS current_score,
    COUNT(*)::INTEGER AS vote_count,
    COUNT(*) FILTER (WHERE vote_tier = 'adore')::INTEGER AS adore_count,
    COUNT(*) FILTER (WHERE vote_tier = 'iconic')::INTEGER AS iconic_count,
    COUNT(*) FILTER (WHERE vote_tier = 'sovereign')::INTEGER AS sovereign_count,
    COUNT(*) FILTER (WHERE vote_tier = 'timeless')::INTEGER AS timeless_count
  FROM public.gala_votes
  GROUP BY submission_id
)
UPDATE public.gala_submissions gs
SET current_score = vt.current_score,
    vote_count = vt.vote_count,
    adore_count = vt.adore_count,
    iconic_count = vt.iconic_count,
    sovereign_count = vt.sovereign_count,
    timeless_count = vt.timeless_count
FROM vote_totals vt
WHERE gs.id = vt.submission_id;

UPDATE public.gala_submissions gs
SET current_score = 0,
    vote_count = 0,
    adore_count = 0,
    iconic_count = 0,
    sovereign_count = 0,
    timeless_count = 0
WHERE NOT EXISTS (
  SELECT 1
  FROM public.gala_votes gv
  WHERE gv.submission_id = gs.id
);

CREATE UNIQUE INDEX IF NOT EXISTS gala_votes_submission_voter_unique_idx
  ON public.gala_votes(submission_id, voter_id);

-- Cast Gala Vote: no anon, no direct table writes, duplicate-safe, and daily
-- vote limits are serialized per player/event/day with FOR UPDATE.
CREATE OR REPLACE FUNCTION public.cast_gala_vote(
  p_submission_id UUID,
  p_vote_tier TEXT
)
RETURNS TABLE(success BOOLEAN, final_points NUMERIC, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_voter_id UUID := auth.uid();
  v_vote_tier TEXT := lower(trim(COALESCE(p_vote_tier, '')));
  v_event_id UUID;
  v_event_status TEXT;
  v_event_ends TIMESTAMPTZ;
  v_designer_id UUID;
  v_talent_multiplier NUMERIC(3,2);
  v_base_points INTEGER;
  v_final_points NUMERIC(6,2);
  v_luxe_cost INTEGER;
  v_current_luxe INTEGER;
  v_vote_date DATE := CURRENT_DATE;
  v_daily_used INTEGER;
  v_daily_limit INTEGER;
  v_vote_id UUID;
BEGIN
  IF v_voter_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'AUTH_REQUIRED'::TEXT;
    RETURN;
  END IF;

  IF v_vote_tier NOT IN ('adore', 'iconic', 'sovereign', 'timeless') THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'INVALID_VOTE_TIER'::TEXT;
    RETURN;
  END IF;

  SELECT
    gs.event_id,
    gs.player_id,
    ge.status,
    ge.ends_at,
    LEAST(GREATEST(COALESCE(tp.base_hype_multiplier, 1.0), 1.0), 2.0)::NUMERIC(3,2)
  INTO
    v_event_id,
    v_designer_id,
    v_event_status,
    v_event_ends,
    v_talent_multiplier
  FROM public.gala_submissions gs
  JOIN public.gala_events ge ON ge.id = gs.event_id
  LEFT JOIN public.talent_pool tp ON gs.talent_id = tp.id
  WHERE gs.id = p_submission_id;

  IF v_event_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'SUBMISSION_NOT_FOUND'::TEXT;
    RETURN;
  END IF;

  IF v_designer_id = v_voter_id THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'CANNOT_VOTE_SELF'::TEXT;
    RETURN;
  END IF;

  IF v_event_status NOT IN ('active', 'voting') OR v_event_ends <= NOW() THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'EVENT_NOT_VOTING'::TEXT;
    RETURN;
  END IF;

  v_daily_limit := CASE v_vote_tier
    WHEN 'adore' THEN 100
    WHEN 'iconic' THEN 10
    WHEN 'sovereign' THEN 3
    WHEN 'timeless' THEN 1
  END;

  v_luxe_cost := CASE WHEN v_vote_tier = 'timeless' THEN 10 ELSE 0 END;

  INSERT INTO public.gala_vote_limits (player_id, event_id, vote_date)
  VALUES (v_voter_id, v_event_id, v_vote_date)
  ON CONFLICT (player_id, event_id, vote_date) DO NOTHING;

  SELECT CASE v_vote_tier
      WHEN 'adore' THEN adore_used
      WHEN 'iconic' THEN iconic_used
      WHEN 'sovereign' THEN sovereign_used
      WHEN 'timeless' THEN timeless_used
    END
  INTO v_daily_used
  FROM public.gala_vote_limits
  WHERE player_id = v_voter_id
    AND event_id = v_event_id
    AND vote_date = v_vote_date
  FOR UPDATE;

  IF COALESCE(v_daily_used, 0) >= v_daily_limit THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'DAILY_LIMIT_REACHED'::TEXT;
    RETURN;
  END IF;

  IF v_luxe_cost > 0 THEN
    SELECT luxe_tokens INTO v_current_luxe
    FROM public.brand_state
    WHERE player_id = v_voter_id
    FOR UPDATE;

    IF COALESCE(v_current_luxe, 0) < v_luxe_cost THEN
      RETURN QUERY SELECT FALSE, 0::NUMERIC, 'INSUFFICIENT_LUXE'::TEXT;
      RETURN;
    END IF;
  END IF;

  v_base_points := CASE v_vote_tier
    WHEN 'adore' THEN 1
    WHEN 'iconic' THEN 3
    WHEN 'sovereign' THEN 10
    WHEN 'timeless' THEN 50
  END;

  v_final_points := v_base_points * (1.0 + (v_talent_multiplier - 1.0) * 0.5);

  INSERT INTO public.gala_votes (
    submission_id,
    voter_id,
    vote_tier,
    base_points,
    talent_multiplier,
    final_points,
    luxe_spent
  ) VALUES (
    p_submission_id,
    v_voter_id,
    v_vote_tier,
    v_base_points,
    v_talent_multiplier,
    v_final_points,
    v_luxe_cost
  )
  ON CONFLICT (submission_id, voter_id) DO NOTHING
  RETURNING id INTO v_vote_id;

  IF v_vote_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'ALREADY_VOTED'::TEXT;
    RETURN;
  END IF;

  IF v_luxe_cost > 0 THEN
    UPDATE public.brand_state
    SET luxe_tokens = luxe_tokens - v_luxe_cost
    WHERE player_id = v_voter_id;
  END IF;

  UPDATE public.gala_vote_limits
  SET adore_used = adore_used + CASE WHEN v_vote_tier = 'adore' THEN 1 ELSE 0 END,
      iconic_used = iconic_used + CASE WHEN v_vote_tier = 'iconic' THEN 1 ELSE 0 END,
      sovereign_used = sovereign_used + CASE WHEN v_vote_tier = 'sovereign' THEN 1 ELSE 0 END,
      timeless_used = timeless_used + CASE WHEN v_vote_tier = 'timeless' THEN 1 ELSE 0 END
  WHERE player_id = v_voter_id
    AND event_id = v_event_id
    AND vote_date = v_vote_date;

  UPDATE public.gala_submissions
  SET current_score = current_score + v_final_points,
      vote_count = vote_count + 1,
      adore_count = adore_count + CASE WHEN v_vote_tier = 'adore' THEN 1 ELSE 0 END,
      iconic_count = iconic_count + CASE WHEN v_vote_tier = 'iconic' THEN 1 ELSE 0 END,
      sovereign_count = sovereign_count + CASE WHEN v_vote_tier = 'sovereign' THEN 1 ELSE 0 END,
      timeless_count = timeless_count + CASE WHEN v_vote_tier = 'timeless' THEN 1 ELSE 0 END
  WHERE id = p_submission_id;

  RETURN QUERY SELECT TRUE, v_final_points, 'VOTE_CAST'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.cast_gala_vote(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.cast_gala_vote(UUID, TEXT) TO authenticated;

-- Archive purchase remains player-facing, but never anon-facing. This also
-- fixes the rank lookup to use players.brand_rank instead of the text display
-- field on brand_state.
CREATE OR REPLACE FUNCTION public.execute_archive_purchase(
  p_buyer_id UUID,
  p_listing_id UUID
)
RETURNS TABLE(success BOOLEAN, transaction_id UUID, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_listing RECORD;
  v_design RECORD;
  v_buyer_capital NUMERIC;
  v_tax_amount BIGINT;
  v_payout_amount BIGINT;
  v_transaction_id UUID;
  v_seller_rank INTEGER;
  v_seller_hall_flag BOOLEAN;
  v_is_sovereign BOOLEAN;
  v_provenance_multiplier NUMERIC(4,2);
  v_new_transfer_count INTEGER;
BEGIN
  PERFORM public.assert_self(p_buyer_id);

  SELECT * INTO v_listing
  FROM public.archive_listings
  WHERE id = p_listing_id
    AND status = 'active'
    AND expires_at > NOW()
  FOR UPDATE;

  IF v_listing IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'LISTING_NOT_AVAILABLE'::TEXT;
    RETURN;
  END IF;

  IF v_listing.seller_id = p_buyer_id THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'CANNOT_BUY_OWN_LISTING'::TEXT;
    RETURN;
  END IF;

  SELECT total_revenue INTO v_buyer_capital
  FROM public.brand_state
  WHERE player_id = p_buyer_id
  FOR UPDATE;

  IF COALESCE(v_buyer_capital, 0) < v_listing.listing_price THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'INSUFFICIENT_CAPITAL'::TEXT;
    RETURN;
  END IF;

  SELECT * INTO v_design
  FROM public.designs
  WHERE id = v_listing.design_id
  FOR UPDATE;

  IF v_design IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'DESIGN_NOT_FOUND'::TEXT;
    RETURN;
  END IF;

  IF v_listing.listing_price < GREATEST(1000, (v_design.hype_score * 10)::BIGINT) THEN
    RETURN QUERY SELECT FALSE, NULL::UUID,
      format(
        'PRICE_BELOW_FLOOR: Minimum is %s Capital',
        GREATEST(1000, (v_design.hype_score * 10)::BIGINT)
      )::TEXT;
    RETURN;
  END IF;

  v_tax_amount := (v_listing.listing_price * 30) / 100;
  v_payout_amount := v_listing.listing_price - v_tax_amount;

  UPDATE public.brand_state
  SET total_revenue = total_revenue - v_listing.listing_price
  WHERE player_id = p_buyer_id;

  UPDATE public.brand_state
  SET total_revenue = total_revenue + v_payout_amount
  WHERE player_id = v_listing.seller_id;

  SELECT p.brand_rank, COALESCE(bs.is_in_hall_of_sovereigns, FALSE)
  INTO v_seller_rank, v_seller_hall_flag
  FROM public.players p
  LEFT JOIN public.brand_state bs ON bs.player_id = p.id
  WHERE p.id = v_listing.seller_id;

  v_is_sovereign := COALESCE(v_seller_hall_flag, FALSE) OR COALESCE(v_seller_rank, 0) >= 100;

  v_new_transfer_count := COALESCE(v_design.transfer_count, 0) + 1;
  v_provenance_multiplier := 1.0 + LEAST(v_new_transfer_count * 0.10, 1.0);

  IF v_is_sovereign OR COALESCE(v_design.has_sovereign_provenance, FALSE) THEN
    v_provenance_multiplier := v_provenance_multiplier + 0.50;
  END IF;

  v_provenance_multiplier := LEAST(v_provenance_multiplier, 2.50);

  UPDATE public.designs
  SET owner_id = p_buyer_id,
      provenance_multiplier = v_provenance_multiplier,
      has_sovereign_provenance = (v_is_sovereign OR COALESCE(has_sovereign_provenance, FALSE)),
      transfer_count = v_new_transfer_count
  WHERE id = v_listing.design_id;

  INSERT INTO public.provenance_ledger (
    design_id,
    listing_id,
    previous_owner_id,
    new_owner_id,
    sale_price,
    platform_tax,
    seller_payout
  ) VALUES (
    v_listing.design_id,
    p_listing_id,
    v_listing.seller_id,
    p_buyer_id,
    v_listing.listing_price,
    v_tax_amount,
    v_payout_amount
  )
  RETURNING id INTO v_transaction_id;

  UPDATE public.archive_listings
  SET status = 'sold'
  WHERE id = p_listing_id;

  RETURN QUERY SELECT TRUE, v_transaction_id, 'PURCHASE_SUCCESSFUL'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.execute_archive_purchase(UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.execute_archive_purchase(UUID, UUID) TO authenticated;

-- Trend calculation is privileged. It may be called by service-role Edge
-- Functions or scheduled database jobs, but not by anon/authenticated clients.
CREATE OR REPLACE FUNCTION public.calculate_global_trend_tsunami()
RETURNS TABLE(
  crest_tag TEXT,
  crest_multiplier NUMERIC,
  surge_tags TEXT[],
  processed_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_now TIMESTAMPTZ := NOW();
  v_window_start TIMESTAMPTZ := v_now - INTERVAL '48 hours';
  v_processed_count BIGINT;
BEGIN
  IF COALESCE(auth.role(), 'service_role') NOT IN ('service_role') THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  INSERT INTO public.trend_tsunami_archive (
    id,
    tag_name,
    multiplier,
    rank,
    total_weight,
    starts_at,
    expires_at
  )
  SELECT
    id,
    tag_name,
    multiplier,
    rank,
    total_weight,
    starts_at,
    expires_at
  FROM public.trend_tsunamis
  WHERE expires_at < v_now
  ON CONFLICT (id) DO NOTHING;

  DELETE FROM public.trend_tsunamis
  WHERE expires_at < v_now;

  IF EXISTS (
    SELECT 1
    FROM public.trend_tsunamis
    WHERE expires_at > v_now
    LIMIT 1
  ) THEN
    RETURN QUERY
    SELECT
      (SELECT tt.tag_name FROM public.trend_tsunamis tt WHERE tt.rank = 1 AND tt.expires_at > v_now LIMIT 1),
      (SELECT tt.multiplier FROM public.trend_tsunamis tt WHERE tt.rank = 1 AND tt.expires_at > v_now LIMIT 1),
      (SELECT COALESCE(ARRAY_AGG(tt.tag_name), '{}'::TEXT[]) FROM public.trend_tsunamis tt WHERE tt.rank IN (2, 3) AND tt.expires_at > v_now),
      (SELECT COUNT(*) FROM public.garment_drops gd WHERE gd.dropped_at > v_window_start);
    RETURN;
  END IF;

  WITH weighted_drops AS (
    SELECT
      gd.id,
      gd.style_tags,
      gd.hype_score,
      COALESCE(fp.likes, 0) AS feed_likes
    FROM public.garment_drops gd
    LEFT JOIN public.feed_posts fp ON fp.id = gd.feed_post_id
    WHERE gd.dropped_at > v_window_start
  ),
  tag_weights AS (
    SELECT
      UNNEST(style_tags) AS tag,
      (hype_score + (feed_likes * 10)) AS weight
    FROM weighted_drops
  ),
  aggregated_tags AS (
    SELECT
      tag,
      SUM(weight) AS total_weight,
      ROW_NUMBER() OVER (ORDER BY SUM(weight) DESC) AS tag_rank
    FROM tag_weights
    GROUP BY tag
    HAVING SUM(weight) > 0
    ORDER BY total_weight DESC
    LIMIT 3
  )
  INSERT INTO public.trend_tsunamis (
    tag_name,
    multiplier,
    rank,
    total_weight,
    starts_at,
    expires_at
  )
  SELECT
    tag,
    1.5,
    tag_rank,
    total_weight,
    v_now,
    v_now + INTERVAL '48 hours'
  FROM aggregated_tags
  ON CONFLICT DO NOTHING;

  SELECT COUNT(*) INTO v_processed_count
  FROM public.garment_drops
  WHERE dropped_at > v_window_start;

  RETURN QUERY
  SELECT
    (SELECT tt.tag_name FROM public.trend_tsunamis tt WHERE tt.rank = 1 AND tt.expires_at > v_now LIMIT 1),
    (SELECT tt.multiplier FROM public.trend_tsunamis tt WHERE tt.rank = 1 AND tt.expires_at > v_now LIMIT 1),
    (SELECT COALESCE(ARRAY_AGG(tt.tag_name), '{}'::TEXT[]) FROM public.trend_tsunamis tt WHERE tt.rank IN (2, 3) AND tt.expires_at > v_now),
    v_processed_count;
END;
$$;

REVOKE ALL ON FUNCTION public.calculate_global_trend_tsunami() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO service_role;

-- Re-assert the intentionally callable signed-in RPCs touched by this pass.
GRANT EXECUTE ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_gala_leaderboard(UUID) TO authenticated;

COMMENT ON FUNCTION public.cast_gala_vote(UUID, TEXT) IS
  'Closed-alpha Gala vote RPC: authenticated only, unique per submission/voter, daily limits serialized with row locks.';
COMMENT ON FUNCTION public.execute_archive_purchase(UUID, UUID) IS
  'Authenticated Archive purchase RPC with buyer guard, listing/design row locks, and corrected seller rank provenance.';
COMMENT ON FUNCTION public.calculate_global_trend_tsunami() IS
  'Service-only trend aggregation over recent garment drops; not callable from anon or authenticated clients.';
