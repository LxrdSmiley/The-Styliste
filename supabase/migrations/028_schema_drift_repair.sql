-- =============================================================================
-- Schema Drift Repair Before Alpha
-- GDD §5.7, §6.9, §8.9.9, §8.12
-- =============================================================================

-- Archive functions require ownership transfer. Existing schema only had player_id.
ALTER TABLE public.designs
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES public.players(id);

UPDATE public.designs
SET owner_id = player_id
WHERE owner_id IS NULL;

CREATE INDEX IF NOT EXISTS designs_owner_idx ON public.designs(owner_id);

-- Latest Gala function must validate ownership and active event.
DROP FUNCTION IF EXISTS public.submit_to_gala(UUID, UUID, UUID);
CREATE OR REPLACE FUNCTION public.submit_to_gala(
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
  PERFORM public.assert_self(p_player_id);

  IF NOT EXISTS (
    SELECT 1 FROM public.designs
    WHERE id = p_design_id AND COALESCE(owner_id, player_id) = p_player_id
  ) THEN
    RAISE EXCEPTION 'DESIGN_NOT_OWNED';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.gala_events
    WHERE id = p_event_id AND status = 'active'
  ) THEN
    RAISE EXCEPTION 'GALA_EVENT_NOT_ACTIVE';
  END IF;

  SELECT id INTO v_existing
  FROM public.gala_submissions
  WHERE player_id = p_player_id AND event_id = p_event_id;

  IF v_existing IS NOT NULL THEN
    RETURN QUERY SELECT v_existing, FALSE, 'ALREADY_SUBMITTED';
    RETURN;
  END IF;

  INSERT INTO public.gala_submissions (player_id, design_id, event_id, submitted_at)
  VALUES (p_player_id, p_design_id, p_event_id, NOW())
  RETURNING id INTO v_submission_id;

  PERFORM public.increment_luxe_trust(p_player_id, 1);

  RETURN QUERY SELECT v_submission_id, TRUE, 'SUBMISSION_ACCEPTED';
END;
$$;

REVOKE ALL ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_to_gala(UUID, UUID, UUID) TO authenticated;

-- 019_luxe_trust_score referenced last_check_in_at, but 016 created last_check_in.
DROP FUNCTION IF EXISTS public.record_check_in(UUID);
CREATE OR REPLACE FUNCTION public.record_check_in(p_player_id UUID)
RETURNS TABLE(success BOOLEAN, streak INTEGER, reward_luxe INTEGER, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_check_in DATE;
  v_streak INTEGER := 1;
  v_reward INTEGER := 10;
BEGIN
  PERFORM public.assert_self(p_player_id);

  SELECT last_check_in, current_streak
  INTO v_last_check_in, v_streak
  FROM public.daily_check_ins
  WHERE player_id = p_player_id;

  IF v_last_check_in = CURRENT_DATE THEN
    RETURN QUERY SELECT FALSE, v_streak, 0, 'ALREADY_CLAIMED';
    RETURN;
  END IF;

  IF v_last_check_in = CURRENT_DATE - INTERVAL '1 day' THEN
    v_streak := v_streak + 1;
  ELSE
    v_streak := 1;
  END IF;

  v_reward := 10 + LEAST(v_streak, 30);

  INSERT INTO public.daily_check_ins (player_id, current_streak, last_check_in, total_check_ins)
  VALUES (p_player_id, v_streak, CURRENT_DATE, 1)
  ON CONFLICT (player_id) DO UPDATE
  SET current_streak = EXCLUDED.current_streak,
      last_check_in = EXCLUDED.last_check_in,
      total_check_ins = public.daily_check_ins.total_check_ins + 1;

  UPDATE public.brand_state
  SET luxe_tokens = luxe_tokens + v_reward
  WHERE player_id = p_player_id;

  PERFORM public.increment_luxe_trust(p_player_id, 1);

  RETURN QUERY SELECT TRUE, v_streak, v_reward, 'CHECK_IN_CLAIMED';
END;
$$;

REVOKE ALL ON FUNCTION public.record_check_in(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_check_in(UUID) TO authenticated;

-- Do not log pure currency rewards into provenance_ledger; it is design ownership history.
CREATE OR REPLACE FUNCTION public.inject_capital_bonus(
  p_player_id UUID,
  p_amount INT,
  p_reason TEXT DEFAULT 'mini_game_reward'
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

  RETURN public.grant_mini_game_reward(
    p_player_id,
    'hostile_takeover',
    p_reason,
    p_amount
  );
END;
$$;

REVOKE ALL ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) TO service_role;
