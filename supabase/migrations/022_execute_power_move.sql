CREATE OR REPLACE FUNCTION public.execute_power_move(
  p_player_id UUID,
  p_move_key TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_cost NUMERIC := 0;
  v_effect JSONB := '{}'::jsonb;
BEGIN
  PERFORM public.assert_self(p_player_id);

  CASE p_move_key
    WHEN 'public_apology' THEN
      SELECT capital_spent
      FROM public.apply_public_apology(p_player_id)
      INTO v_cost;
      v_effect := jsonb_build_object('crisis_reduction', 30);
    ELSE
      RAISE EXCEPTION 'Unknown power move: %', p_move_key;
  END CASE;

  RETURN json_build_object(
    'success', true,
    'move_key', p_move_key,
    'cost', COALESCE(v_cost, 0),
    'effect', v_effect
  );
END;
$$;

REVOKE ALL ON FUNCTION public.execute_power_move(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.execute_power_move(UUID, TEXT) TO authenticated;
