-- First repeatable loop: Mogul starter store action.
-- Creates exactly one starter ecommerce store for a Mogul player with no stores.

CREATE OR REPLACE FUNCTION public.edge_open_first_store_atomic(
  p_player_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_player public.players%ROWTYPE;
  v_store public.stores%ROWTYPE;
  v_existing_store public.stores%ROWTYPE;
  v_idle_revenue_per_hour NUMERIC := 0;
  v_city TEXT;
BEGIN
  IF current_setting('request.jwt.claim.role', true) <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtext('open_first_store:' || p_player_id::TEXT));

  SELECT *
  INTO v_player
  FROM public.players
  WHERE id = p_player_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PLAYER_NOT_FOUND';
  END IF;

  IF v_player.path <> 'mogul' THEN
    RAISE EXCEPTION 'MOGUL_PATH_REQUIRED';
  END IF;

  SELECT *
  INTO v_existing_store
  FROM public.stores
  WHERE player_id = p_player_id
  ORDER BY opened_at ASC
  LIMIT 1;

  IF FOUND THEN
    SELECT COALESCE(bs.idle_revenue_per_hour, 0)
    INTO v_idle_revenue_per_hour
    FROM public.brand_state bs
    WHERE bs.player_id = p_player_id;

    RETURN jsonb_build_object(
      'success', TRUE,
      'created', FALSE,
      'message', 'FIRST_STORE_ALREADY_OPEN',
      'store', to_jsonb(v_existing_store),
      'idle_revenue_per_hour', v_idle_revenue_per_hour
    );
  END IF;

  v_city := CASE LOWER(TRIM(v_player.hq_city))
    WHEN 'new york' THEN 'new_york'
    WHEN 'new_york' THEN 'new_york'
    WHEN 'paris' THEN 'paris'
    WHEN 'tokyo' THEN 'tokyo'
    WHEN 'london' THEN 'london'
    WHEN 'milan' THEN 'milan'
    WHEN 'seoul' THEN 'seoul'
    WHEN 'nairobi' THEN 'nairobi'
    WHEN 'sao paulo' THEN 'sao_paulo'
    WHEN 'sao_paulo' THEN 'sao_paulo'
    WHEN 'amsterdam' THEN 'amsterdam'
    WHEN 'los angeles' THEN 'los_angeles'
    WHEN 'los_angeles' THEN 'los_angeles'
    ELSE 'paris'
  END;

  INSERT INTO public.stores(
    player_id,
    type,
    city,
    tier,
    revenue_per_hour,
    market_share
  )
  VALUES (
    p_player_id,
    'ecommerce',
    v_city,
    1,
    500,
    0
  )
  RETURNING * INTO v_store;

  UPDATE public.brand_state bs
  SET idle_revenue_per_hour = (
        SELECT COALESCE(SUM(s.revenue_per_hour), 0)
        FROM public.stores s
        WHERE s.player_id = p_player_id
      ),
      updated_at = NOW()
  WHERE bs.player_id = p_player_id
  RETURNING bs.idle_revenue_per_hour INTO v_idle_revenue_per_hour;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND';
  END IF;

  RETURN jsonb_build_object(
    'success', TRUE,
    'created', TRUE,
    'message', 'FIRST_STORE_OPENED',
    'store', to_jsonb(v_store),
    'idle_revenue_per_hour', v_idle_revenue_per_hour
  );
END;
$$;

REVOKE ALL ON FUNCTION public.edge_open_first_store_atomic(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_open_first_store_atomic(UUID)
  TO service_role;

COMMENT ON FUNCTION public.edge_open_first_store_atomic(UUID) IS
  'Server-authoritative first Mogul action: opens one starter ecommerce store idempotently.';
