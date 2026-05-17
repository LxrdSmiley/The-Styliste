-- =============================================================================
-- The Styliste — Luxe Trust Score Migration
-- GDD §8.12 — Trust Score is a relationship meter, not a wealth meter
-- Increments via: daily check-ins, quest completions, gala entries, kintsugi
-- Default 50 = warm baseline on first load (not cold for new players)
-- =============================================================================

-- Add luxe_trust_score column to players table
ALTER TABLE public.players
  ADD COLUMN IF NOT EXISTS luxe_trust_score INT NOT NULL DEFAULT 50;

-- =============================================================================
-- HELPER: Safely increment trust score (capped at 100)
-- =============================================================================
CREATE OR REPLACE FUNCTION increment_luxe_trust(
  p_player_id UUID,
  p_amount INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.players
  SET luxe_trust_score = LEAST(luxe_trust_score + p_amount, 100)
  WHERE id = p_player_id;
END;
$$;

GRANT EXECUTE ON FUNCTION increment_luxe_trust(UUID, INT) TO authenticated;

-- =============================================================================
-- PATCH: record_check_in — +1 Trust Score per daily claim
-- =============================================================================
-- DROP required: RETURNS TABLE column list changed from 016 (42P13 blocks CREATE OR REPLACE)
DROP FUNCTION IF EXISTS record_check_in(UUID);
CREATE OR REPLACE FUNCTION record_check_in(p_player_id UUID)
RETURNS TABLE(
  streak INTEGER,
  is_new_day BOOLEAN,
  reward_type TEXT,
  reward_amount INTEGER,
  next_milestone INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_check_in TIMESTAMPTZ;
  v_current_streak INT := 0;
  v_new_streak INT;
  v_is_new_day BOOL := FALSE;
  v_reward_type TEXT := 'none';
  v_reward_amount INT := 0;
  v_next_milestone INT;
  v_hours_since_last FLOAT;
BEGIN
  PERFORM public.assert_self(p_player_id);
  -- Auth guard
  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Get last check-in
  SELECT last_check_in_at, current_streak
  INTO v_last_check_in, v_current_streak
  FROM public.daily_check_ins
  WHERE player_id = p_player_id;

  IF NOT FOUND THEN
    -- First check-in ever
    v_is_new_day := TRUE;
    v_new_streak := 1;

    INSERT INTO public.daily_check_ins (player_id, current_streak, last_check_in_at, total_check_ins)
    VALUES (p_player_id, 1, NOW(), 1);
  ELSE
    v_hours_since_last := EXTRACT(EPOCH FROM (NOW() - v_last_check_in)) / 3600.0;

    IF v_hours_since_last < 20 THEN
      -- Already checked in today — no update
      v_is_new_day := FALSE;
      v_new_streak := v_current_streak;
    ELSIF v_hours_since_last <= 48 THEN
      -- Valid streak continuation
      v_is_new_day := TRUE;
      v_new_streak := v_current_streak + 1;

      UPDATE public.daily_check_ins
      SET current_streak = v_new_streak,
          last_check_in_at = NOW(),
          total_check_ins = total_check_ins + 1
      WHERE player_id = p_player_id;
    ELSE
      -- Streak broken
      v_is_new_day := TRUE;
      v_new_streak := 1;

      UPDATE public.daily_check_ins
      SET current_streak = 1,
          last_check_in_at = NOW(),
          total_check_ins = total_check_ins + 1
      WHERE player_id = p_player_id;
    END IF;
  END IF;

  -- Grant streak milestone rewards
  IF v_is_new_day THEN
    -- +1 Luxe Trust Score per daily claim (GDD §8.12)
    PERFORM increment_luxe_trust(p_player_id, 1);

    IF v_new_streak = 7 THEN
      v_reward_type := 'capital_bonus';
      v_reward_amount := 5000;
      UPDATE public.brand_state SET total_revenue = total_revenue + 5000 WHERE player_id = p_player_id;
    ELSIF v_new_streak = 30 THEN
      v_reward_type := 'luxe_tokens';
      v_reward_amount := 100;
      UPDATE public.brand_state SET luxe_tokens = luxe_tokens + 100 WHERE player_id = p_player_id;
    ELSIF v_new_streak % 7 = 0 THEN
      v_reward_type := 'capital_bonus';
      v_reward_amount := 2500;
      UPDATE public.brand_state SET total_revenue = total_revenue + 2500 WHERE player_id = p_player_id;
    ELSE
      v_reward_type := 'idle_boost';
      v_reward_amount := 1;
    END IF;
  END IF;

  -- Next milestone
  v_next_milestone := CASE
    WHEN v_new_streak < 7 THEN 7
    WHEN v_new_streak < 14 THEN 14
    WHEN v_new_streak < 30 THEN 30
    ELSE ((v_new_streak / 7) + 1) * 7
  END;

  RETURN QUERY SELECT v_new_streak, v_is_new_day, v_reward_type, v_reward_amount, v_next_milestone;
END;
$$;

GRANT EXECUTE ON FUNCTION record_check_in(UUID) TO authenticated;

-- =============================================================================
-- PATCH: submit_to_gala — +1 Trust Score per entry (GDD §6.9)
-- =============================================================================
-- DROP required: RETURNS TABLE column order changed from 012 (42P13 blocks CREATE OR REPLACE)
DROP FUNCTION IF EXISTS submit_to_gala(UUID, UUID, UUID);
CREATE OR REPLACE FUNCTION submit_to_gala(
  p_player_id UUID,
  p_design_id UUID,
  p_event_id UUID
)
RETURNS TABLE(submission_id UUID, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_submission_id UUID;
  v_existing UUID;
BEGIN
  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Check for existing submission in this event
  SELECT id INTO v_existing
  FROM public.gala_submissions
  WHERE player_id = p_player_id AND event_id = p_event_id;

  IF v_existing IS NOT NULL THEN
    RETURN QUERY SELECT v_existing, FALSE, 'ALREADY_SUBMITTED';
    RETURN;
  END IF;

  -- Create submission
  INSERT INTO public.gala_submissions (player_id, design_id, event_id, submitted_at)
  VALUES (p_player_id, p_design_id, p_event_id, NOW())
  RETURNING id INTO v_submission_id;

  -- +1 Luxe Trust Score for gala participation (GDD §8.12)
  PERFORM increment_luxe_trust(p_player_id, 1);

  RETURN QUERY SELECT v_submission_id, TRUE, 'SUBMISSION_ACCEPTED';
END;
$$;

GRANT EXECUTE ON FUNCTION submit_to_gala(UUID, UUID, UUID) TO authenticated;

-- =============================================================================
-- PATCH: apply_kintsugi_repair — +5 Trust Score on resolution (GDD §8.9.2)
-- Kintsugi is the highest-prestige crisis path — founder grows through crisis
-- =============================================================================
-- DROP required: RETURNS TABLE column order changed from 010 (42P13 blocks CREATE OR REPLACE)
DROP FUNCTION IF EXISTS apply_kintsugi_repair(UUID, INTEGER);
CREATE OR REPLACE FUNCTION apply_kintsugi_repair(
  p_player_id UUID,
  p_prestige_token_cost INTEGER DEFAULT 10
)
RETURNS TABLE(
  success BOOLEAN,
  new_kintsugi_level INTEGER,
  capital_spent BIGINT,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_capital BIGINT;
  v_repair_cost BIGINT;
  v_current_tarnish INT;
  v_kintsugi_level INT;
BEGIN
  PERFORM public.assert_self(p_player_id);
  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Get current state
  SELECT total_revenue, current_tarnish, kintsugi_level
  INTO v_current_capital, v_current_tarnish, v_kintsugi_level
  FROM public.brand_state
  WHERE player_id = p_player_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 0, 0::BIGINT, 'BRAND_NOT_FOUND';
    RETURN;
  END IF;

  -- Kintsugi costs 30% of current capital
  v_repair_cost := (v_current_capital * 0.30)::BIGINT;

  IF v_current_capital < v_repair_cost THEN
    RETURN QUERY SELECT FALSE, v_kintsugi_level, 0::BIGINT, 'INSUFFICIENT_CAPITAL';
    RETURN;
  END IF;

  -- Apply repair: deduct capital, reset tarnish, increment level
  UPDATE public.brand_state
  SET
    total_revenue = total_revenue - v_repair_cost,
    current_tarnish = 0,
    kintsugi_level = COALESCE(kintsugi_level, 0) + 1
  WHERE player_id = p_player_id
  RETURNING kintsugi_level INTO v_kintsugi_level;

  -- +5 Luxe Trust Score for Kintsugi completion (GDD §8.9.2 — highest prestige path)
  PERFORM increment_luxe_trust(p_player_id, 5);

  RETURN QUERY SELECT TRUE, v_kintsugi_level, v_repair_cost, 'REPAIR_COMPLETE';
END;
$$;

GRANT EXECUTE ON FUNCTION apply_kintsugi_repair(UUID, INTEGER) TO authenticated;

-- =============================================================================
-- COMMENT
-- =============================================================================
COMMENT ON COLUMN public.players.luxe_trust_score IS
  'GDD §8.12: Luxe relationship meter 0-100. Default 50 (warm). +1 daily check-in, +1 gala entry, +2 casting gold, +5 kintsugi resolution.';

COMMENT ON FUNCTION increment_luxe_trust IS
  'Safely increments luxe_trust_score by p_amount, capped at 100.';


