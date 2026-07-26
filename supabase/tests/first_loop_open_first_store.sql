BEGIN;
SELECT plan(1);
SELECT set_config('request.jwt.claim.role', 'service_role', true);

DO $$
DECLARE
  v_player UUID := gen_random_uuid();
  v_designer UUID := gen_random_uuid();
  v_first JSONB;
  v_second JSONB;
  v_count INT;
  v_idle NUMERIC;
  v_type TEXT;
  v_city TEXT;
  v_tier INT;
  v_revenue NUMERIC;
  v_market_share NUMERIC;
BEGIN
  INSERT INTO public.players(id, brand_name, path, hq_city)
  VALUES (v_player, 'Starter Store Test', 'mogul', 'paris');
  INSERT INTO public.brand_state(player_id, total_revenue)
  VALUES (v_player, 0);

  v_first := public.edge_open_first_store_atomic(v_player);

  IF v_first->>'created' <> 'true' THEN
    RAISE EXCEPTION 'first call did not create a store';
  END IF;

  SELECT COUNT(*)
  INTO v_count
  FROM public.stores
  WHERE player_id = v_player;

  IF v_count <> 1 THEN
    RAISE EXCEPTION 'first call created wrong store count';
  END IF;

  SELECT type, city, tier, revenue_per_hour, market_share
  INTO v_type, v_city, v_tier, v_revenue, v_market_share
  FROM public.stores
  WHERE player_id = v_player;

  IF v_type <> 'ecommerce' THEN
    RAISE EXCEPTION 'starter store type mismatch';
  END IF;
  IF v_city <> 'paris' THEN
    RAISE EXCEPTION 'starter store city mismatch';
  END IF;
  IF v_tier <> 1 THEN
    RAISE EXCEPTION 'starter store tier mismatch';
  END IF;
  IF v_revenue <> 500 THEN
    RAISE EXCEPTION 'starter store revenue mismatch';
  END IF;
  IF v_market_share <> 0 THEN
    RAISE EXCEPTION 'starter store market share mismatch';
  END IF;

  SELECT idle_revenue_per_hour
  INTO v_idle
  FROM public.brand_state
  WHERE player_id = v_player;

  IF v_idle <> 500 THEN
    RAISE EXCEPTION 'starter store did not update idle rate';
  END IF;

  v_second := public.edge_open_first_store_atomic(v_player);

  IF v_second->>'created' <> 'false' THEN
    RAISE EXCEPTION 'second call was not idempotent';
  END IF;

  SELECT COUNT(*)
  INTO v_count
  FROM public.stores
  WHERE player_id = v_player;

  IF v_count <> 1 THEN
    RAISE EXCEPTION 'second call duplicated the starter store';
  END IF;

  INSERT INTO public.players(id, brand_name, path, hq_city)
  VALUES (v_designer, 'Designer Store Guard', 'designer', 'paris');
  INSERT INTO public.brand_state(player_id, total_revenue)
  VALUES (v_designer, 0);

  BEGIN
    PERFORM public.edge_open_first_store_atomic(v_designer);
    RAISE EXCEPTION 'designer path unexpectedly opened a store';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%MOGUL_PATH_REQUIRED%' THEN RAISE; END IF;
  END;
END;
$$;

SELECT pass('first loop starter store creation is idempotent and guarded');
SELECT * FROM finish();

ROLLBACK;
