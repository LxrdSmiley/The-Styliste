-- Milestone 3A1: finish immediate authority containment without altering
-- historical data. This migration supersedes only the incomplete callable
-- authority decisions in 20260718072833_immediate_authority_containment.sql.

-- AUD-001: District settlement has no approved automated caller during the
-- containment period, so no role may execute the legacy mutation.
REVOKE ALL ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT)
  FROM PUBLIC, anon, authenticated, service_role;

-- AUD-003: Talent ownership and pity are written exclusively by the locked
-- server-side Casting mutation. Direct client inserts could forge ownership or
-- manipulate pity before a valid pull is accepted.
DROP POLICY IF EXISTS "Roster: insert own" ON public.player_roster;
DROP POLICY IF EXISTS "Pity: insert own" ON public.gacha_pity_state;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.player_roster
  FROM PUBLIC, anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.gacha_pity_state
  FROM PUBLIC, anon, authenticated;

-- The pre-3A1 signature accepted a caller-supplied player identifier. Remove
-- the unsafe overload entirely; the callable interface below derives the actor
-- only from auth.uid().
REVOKE ALL ON FUNCTION public.execute_casting_pull(UUID, TEXT, BOOLEAN)
  FROM PUBLIC, anon, authenticated, service_role;
DROP FUNCTION IF EXISTS public.execute_casting_pull(UUID, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION public.execute_casting_pull(
  p_banner_id TEXT DEFAULT 'standard',
  p_is_ten_pull BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  success BOOLEAN,
  pulls JSONB,
  luxe_spent INTEGER,
  prestige_earned INTEGER,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_player_id UUID := auth.uid();
  v_luxe_cost INTEGER := CASE WHEN p_is_ten_pull THEN 1000 ELSE 100 END;
  v_current_luxe INTEGER;
  v_pity_count INTEGER;
  v_pull_count INTEGER := CASE WHEN p_is_ten_pull THEN 10 ELSE 1 END;
  v_pull_results JSONB := '[]'::JSONB;
  v_total_prestige INTEGER := 0;
  v_talent_record RECORD;
  v_roll NUMERIC;
  v_tier public.talent_tier;
  v_is_dupe BOOLEAN;
  v_prestige_value INTEGER;
  v_guaranteed_assigned BOOLEAN := FALSE;
BEGIN
  IF v_player_id IS NULL THEN
    RAISE EXCEPTION 'AUTHENTICATION_REQUIRED';
  END IF;

  -- Fixed lock order for every pull shape: balance, pity, then roster.
  SELECT luxe_tokens
  INTO v_current_luxe
  FROM public.brand_state
  WHERE player_id = v_player_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PLAYER_BRAND_STATE_NOT_FOUND';
  END IF;

  -- Check before materializing pity so rejected calls change no state.
  IF v_current_luxe < v_luxe_cost THEN
    RETURN QUERY SELECT
      FALSE,
      '[]'::JSONB,
      0,
      0,
      'INSUFFICIENT_LUXE_TOKENS'::TEXT;
    RETURN;
  END IF;

  INSERT INTO public.gacha_pity_state (
    player_id,
    banner_id,
    pulls_since_sovereign,
    total_pulls
  )
  VALUES (v_player_id, p_banner_id, 0, 0)
  ON CONFLICT (player_id, banner_id) DO NOTHING;

  SELECT pulls_since_sovereign
  INTO v_pity_count
  FROM public.gacha_pity_state
  WHERE player_id = v_player_id
    AND banner_id = p_banner_id
  FOR UPDATE;

  UPDATE public.brand_state
  SET luxe_tokens = luxe_tokens - v_luxe_cost
  WHERE player_id = v_player_id
    AND luxe_tokens >= v_luxe_cost;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'INSUFFICIENT_LUXE_TOKENS';
  END IF;

  FOR v_i IN 1..v_pull_count LOOP
    IF v_pity_count >= 89 THEN
      v_tier := 'sovereign';
      v_pity_count := 0;
    ELSE
      v_roll := ROUND((random() * 100)::NUMERIC, 2);
      v_tier := (CASE
        WHEN v_roll >= 99.00 THEN 'sovereign'
        WHEN v_roll >= 90.00 THEN 'iconic'
        WHEN v_roll >= 60.00 THEN 'established'
        ELSE 'rising_star'
      END)::public.talent_tier;

      IF v_tier = 'sovereign' THEN
        v_pity_count := 0;
      END IF;
    END IF;

    -- Preserve the existing ten-pull compatibility behavior. Formula work is
    -- explicitly deferred from this containment migration.
    IF p_is_ten_pull
        AND v_i = 1
        AND v_tier = 'rising_star'
        AND NOT v_guaranteed_assigned THEN
      v_guaranteed_assigned := TRUE;
    END IF;

    SELECT *
    INTO v_talent_record
    FROM public.talent_pool
    WHERE tier = v_tier
      AND is_active = TRUE
    ORDER BY random()
    LIMIT 1;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'ACTIVE_TALENT_NOT_FOUND_FOR_TIER';
    END IF;

    PERFORM 1
    FROM public.player_roster
    WHERE player_id = v_player_id
      AND talent_id = v_talent_record.id
    FOR UPDATE;
    v_is_dupe := FOUND;

    v_prestige_value := CASE v_tier
      WHEN 'rising_star' THEN 1
      WHEN 'established' THEN 5
      WHEN 'iconic' THEN 15
      WHEN 'sovereign' THEN 50
    END;

    IF v_is_dupe THEN
      UPDATE public.brand_state
      SET prestige_tokens = prestige_tokens + v_prestige_value
      WHERE player_id = v_player_id;
      v_total_prestige := v_total_prestige + v_prestige_value;
    ELSE
      INSERT INTO public.player_roster (
        player_id,
        talent_id,
        acquisition_source
      )
      VALUES (v_player_id, v_talent_record.id, 'casting_call');
    END IF;

    v_pull_results := v_pull_results || jsonb_build_object(
      'talent_id', v_talent_record.id,
      'name', v_talent_record.name,
      'tier', v_talent_record.tier,
      'is_dupe', v_is_dupe,
      'prestige_value', CASE WHEN v_is_dupe THEN v_prestige_value ELSE 0 END,
      'portrait_url', v_talent_record.portrait_url,
      'base_hype_multiplier', v_talent_record.base_hype_multiplier
    );

    v_pity_count := v_pity_count + 1;
  END LOOP;

  UPDATE public.gacha_pity_state
  SET pulls_since_sovereign = v_pity_count,
      total_pulls = total_pulls + v_pull_count,
      last_pull_at = NOW()
  WHERE player_id = v_player_id
    AND banner_id = p_banner_id;

  RETURN QUERY SELECT
    TRUE,
    v_pull_results,
    v_luxe_cost,
    v_total_prestige,
    'CASTING_SUCCESSFUL'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.execute_casting_pull(TEXT, BOOLEAN)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.execute_casting_pull(TEXT, BOOLEAN)
  TO authenticated;

-- AUD-004 and AUD-005: no vote or settlement caller remains executable. The
-- function body also remains inert for privileged scheduler owners that do not
-- depend on function grants.
DROP POLICY IF EXISTS "Votes: insert own" ON public.gala_votes;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.gala_votes
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.cast_gala_vote(UUID, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.rotate_gala_event()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  RAISE EXCEPTION 'GALA_SETTLEMENT_QUARANTINED';
END;
$$;

REVOKE ALL ON FUNCTION public.rotate_gala_event()
  FROM PUBLIC, anon, authenticated, service_role;

-- AUD-008: keep every historical mini-game row but make the previous Edge and
-- direct-grant boundaries deterministic no-ops with no executable role.
CREATE OR REPLACE FUNCTION public.edge_start_mini_game(
  p_player_id UUID,
  p_game_key TEXT,
  p_talent_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
  PERFORM p_player_id, p_game_key, p_talent_id;
  RAISE EXCEPTION 'MINI_GAME_REWARDS_UNAVAILABLE';
END;
$$;

CREATE OR REPLACE FUNCTION public.edge_claim_mini_game(
  p_player_id UUID,
  p_attempt_id UUID,
  p_proof JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
  PERFORM p_player_id, p_attempt_id, p_proof;
  RAISE EXCEPTION 'MINI_GAME_REWARDS_UNAVAILABLE';
END;
$$;

CREATE OR REPLACE FUNCTION public.grant_mini_game_reward(
  p_player_id UUID,
  p_game_key TEXT,
  p_result_key TEXT,
  p_amount BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
  PERFORM p_player_id, p_game_key, p_result_key, p_amount;
  RAISE EXCEPTION 'MINI_GAME_REWARDS_UNAVAILABLE';
END;
$$;

CREATE OR REPLACE FUNCTION public.inject_capital_bonus(
  p_player_id UUID,
  p_amount INTEGER,
  p_reason TEXT DEFAULT 'mini_game_reward'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog
AS $$
BEGIN
  PERFORM p_player_id, p_amount, p_reason;
  RAISE EXCEPTION 'MINI_GAME_REWARDS_UNAVAILABLE';
END;
$$;

REVOKE ALL ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public.grant_mini_game_reward(UUID, TEXT, TEXT, BIGINT)
  FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION public.inject_capital_bonus(UUID, INTEGER, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

COMMENT ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT) IS
  'Quarantined from every callable role pending authoritative district settlement.';
COMMENT ON FUNCTION public.execute_casting_pull(TEXT, BOOLEAN) IS
  'Authenticated Casting derives player identity from auth.uid() and locks balance, pity, then roster.';
COMMENT ON FUNCTION public.rotate_gala_event() IS
  'Quarantined pending approved, idempotent Gala settlement.';
COMMENT ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB) IS
  'Quarantined: mini-game proofs cannot mint economy value.';
