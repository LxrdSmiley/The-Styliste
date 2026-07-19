-- Milestone 3A1 — Immediate Authority Containment
--
-- This is a forward-only containment migration. It intentionally preserves
-- player records, balances, event history, and future redesign decisions.
-- The affected surfaces remain unavailable until their authoritative rules are
-- separately reviewed and implemented.

-- AUD-001: District takeovers remain server-owned, but are not safe to expose
-- to clients until bid validation and settlement are redesigned.
REVOKE ALL ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT)
  TO service_role;

-- AUD-003: Serialize each player's casting balance and pity state. The
-- function preserves existing costs, odds, result shape, and settlement rules.
CREATE OR REPLACE FUNCTION public.execute_casting_pull(
  p_player_id UUID,
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
SET search_path = public
AS $$
DECLARE
  v_luxe_cost INTEGER := CASE WHEN p_is_ten_pull THEN 1000 ELSE 100 END;
  v_current_luxe INTEGER;
  v_pity_count INTEGER;
  v_pull_count INTEGER := CASE WHEN p_is_ten_pull THEN 10 ELSE 1 END;
  v_pull_results JSONB := '[]'::JSONB;
  v_total_prestige INTEGER := 0;
  v_talent_record RECORD;
  v_roll NUMERIC;
  v_tier talent_tier;
  v_is_dupe BOOLEAN;
  v_prestige_value INTEGER;
  v_i INTEGER;
  v_guaranteed_assigned BOOLEAN := FALSE;
BEGIN
  PERFORM public.assert_self(p_player_id);

  -- Lock the player's balance first. Every casting attempt for this player
  -- acquires locks in this order: brand_state, then gacha_pity_state.
  SELECT luxe_tokens
  INTO v_current_luxe
  FROM public.brand_state
  WHERE player_id = p_player_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND';
  END IF;

  IF v_current_luxe < v_luxe_cost THEN
    RETURN QUERY SELECT FALSE, '[]'::JSONB, 0, 0,
      'INSUFFICIENT_LUXE_TOKENS'::TEXT;
    RETURN;
  END IF;

  -- Materialize the pity row before locking it so concurrent first pulls use
  -- the table's primary key as the serialization point.
  INSERT INTO public.gacha_pity_state (
    player_id,
    banner_id,
    pulls_since_sovereign,
    total_pulls
  )
  VALUES (p_player_id, p_banner_id, 0, 0)
  ON CONFLICT (player_id, banner_id) DO NOTHING;

  SELECT pulls_since_sovereign
  INTO v_pity_count
  FROM public.gacha_pity_state
  WHERE player_id = p_player_id
    AND banner_id = p_banner_id
  FOR UPDATE;

  UPDATE public.brand_state
  SET luxe_tokens = luxe_tokens - v_luxe_cost
  WHERE player_id = p_player_id;

  FOR v_i IN 1..v_pull_count LOOP
    v_pity_count := v_pity_count + 1;

    IF v_pity_count >= 90 THEN
      v_tier := 'sovereign';
      v_pity_count := 0;
    ELSE
      v_roll := ROUND((random() * 100)::NUMERIC, 2);
      v_tier := CASE
        WHEN v_roll >= 99.00 THEN 'sovereign'
        WHEN v_roll >= 90.00 THEN 'iconic'
        WHEN v_roll >= 60.00 THEN 'established'
        ELSE 'rising_star'
      END;

      IF v_tier = 'sovereign' THEN
        v_pity_count := 0;
      END IF;
    END IF;

    -- Preserve the existing ten-pull compatibility behavior; formula work is
    -- deliberately deferred to Milestone 3B2.
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

    SELECT EXISTS(
      SELECT 1
      FROM public.player_roster
      WHERE player_id = p_player_id
        AND talent_id = v_talent_record.id
    )
    INTO v_is_dupe;

    v_prestige_value := CASE v_tier
      WHEN 'rising_star' THEN 1
      WHEN 'established' THEN 5
      WHEN 'iconic' THEN 15
      WHEN 'sovereign' THEN 50
    END;

    IF v_is_dupe THEN
      UPDATE public.brand_state
      SET prestige_tokens = prestige_tokens + v_prestige_value
      WHERE player_id = p_player_id;
      v_total_prestige := v_total_prestige + v_prestige_value;
    ELSE
      INSERT INTO public.player_roster (
        player_id,
        talent_id,
        acquisition_source
      )
      VALUES (p_player_id, v_talent_record.id, 'casting_call');
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
  END LOOP;

  UPDATE public.gacha_pity_state
  SET pulls_since_sovereign = v_pity_count,
      total_pulls = total_pulls + v_pull_count,
      last_pull_at = NOW()
  WHERE player_id = p_player_id
    AND banner_id = p_banner_id;

  RETURN QUERY SELECT
    TRUE,
    v_pull_results,
    v_luxe_cost,
    v_total_prestige,
    'CASTING_SUCCESSFUL'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.execute_casting_pull(UUID, TEXT, BOOLEAN)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.execute_casting_pull(UUID, TEXT, BOOLEAN)
  TO authenticated;

-- AUD-004: Quarantine paid Gala scoring until the GDD v7 formula is available.
REVOKE ALL ON FUNCTION public.cast_gala_vote(UUID, TEXT)
  FROM PUBLIC, anon, authenticated, service_role;

-- AUD-005: Do not permit any settlement or prize payout until single-settlement
-- rules, idempotency, and the final Gala formula are approved.
CREATE OR REPLACE FUNCTION public.rotate_gala_event()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RAISE EXCEPTION 'GALA_SETTLEMENT_QUARANTINED';
END;
$$;

REVOKE ALL ON FUNCTION public.rotate_gala_event()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.rotate_gala_event() TO service_role;

-- AUD-008: Client-provided mini-game proofs can no longer reach any reward,
-- progression, roster, or balance mutation. Existing attempts are preserved.
CREATE OR REPLACE FUNCTION public.edge_start_mini_game(
  p_player_id UUID,
  p_game_key TEXT,
  p_talent_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
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
SET search_path = ''
AS $$
BEGIN
  RAISE EXCEPTION 'MINI_GAME_REWARDS_UNAVAILABLE';
END;
$$;

REVOKE ALL ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB)
  TO service_role;

COMMENT ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT) IS
  'Quarantined from client execution pending authoritative district settlement.';
COMMENT ON FUNCTION public.cast_gala_vote(UUID, TEXT) IS
  'Quarantined pending GDD v7 Gala scoring implementation.';
COMMENT ON FUNCTION public.rotate_gala_event() IS
  'Quarantined pending an idempotent, single-settlement Gala implementation.';
COMMENT ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID) IS
  'Quarantined: client mini-game proofs cannot produce authoritative rewards.';
COMMENT ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB) IS
  'Quarantined: client mini-game proofs cannot produce authoritative rewards.';
