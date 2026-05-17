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
