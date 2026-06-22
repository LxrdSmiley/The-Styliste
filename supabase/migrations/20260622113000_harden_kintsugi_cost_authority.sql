-- Keep the Kintsugi price and player identity server-owned.

DROP FUNCTION IF EXISTS public.apply_kintsugi_repair(UUID, INTEGER);

CREATE OR REPLACE FUNCTION public.apply_kintsugi_repair()
RETURNS TABLE(
  success BOOLEAN,
  new_kintsugi_level INTEGER,
  capital_spent BIGINT,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID := auth.uid();
  v_prestige_token_cost CONSTANT INTEGER := 10;
  v_current_capital NUMERIC;
  v_repair_cost BIGINT;
  v_current_tarnish INT;
  v_kintsugi_level INT;
  v_current_prestige INT;
BEGIN
  IF v_player_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED';
  END IF;

  SELECT
    bs.total_revenue,
    bs.current_tarnish,
    bs.kintsugi_level,
    bs.prestige_tokens
  INTO
    v_current_capital,
    v_current_tarnish,
    v_kintsugi_level,
    v_current_prestige
  FROM public.brand_state bs
  WHERE bs.player_id = v_player_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 0, 0::BIGINT, 'BRAND_NOT_FOUND'::TEXT;
    RETURN;
  END IF;
  IF v_current_tarnish <= 0 THEN
    RETURN QUERY SELECT
      FALSE,
      v_kintsugi_level,
      0::BIGINT,
      'NO_TARNISH_TO_REPAIR'::TEXT;
    RETURN;
  END IF;
  IF v_current_prestige < v_prestige_token_cost THEN
    RETURN QUERY SELECT
      FALSE,
      v_kintsugi_level,
      0::BIGINT,
      'INSUFFICIENT_PRESTIGE_TOKENS'::TEXT;
    RETURN;
  END IF;

  v_repair_cost := FLOOR(v_current_capital * 0.30)::BIGINT;

  UPDATE public.brand_state bs
  SET total_revenue = bs.total_revenue - v_repair_cost,
      prestige_tokens = bs.prestige_tokens - v_prestige_token_cost,
      current_tarnish = 0,
      kintsugi_level = bs.kintsugi_level + 1,
      total_scandals_survived = bs.total_scandals_survived + 1,
      updated_at = NOW()
  WHERE bs.player_id = v_player_id
  RETURNING bs.kintsugi_level INTO v_kintsugi_level;

  PERFORM public.increment_luxe_trust(v_player_id, 5);

  RETURN QUERY SELECT
    TRUE,
    v_kintsugi_level,
    v_repair_cost,
    'REPAIR_COMPLETE'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.apply_kintsugi_repair()
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.apply_kintsugi_repair()
  TO authenticated;
