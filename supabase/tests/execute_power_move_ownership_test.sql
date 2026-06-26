BEGIN;

SELECT plan(7);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES
  (
    '10000000-0000-0000-0000-000000000001',
    'Power Move Owner',
    'mogul',
    'Kingston'
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'Power Move Other',
    'designer',
    'Paris'
  );

INSERT INTO public.brand_state(player_id, total_revenue, current_tarnish)
VALUES
  ('10000000-0000-0000-0000-000000000001', 10000, 40),
  ('10000000-0000-0000-0000-000000000002', 5000, 50);

SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.execute_power_move(uuid,text)',
    'EXECUTE'
  ),
  'anon cannot execute execute_power_move'
);

SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.apply_public_apology(uuid)',
    'EXECUTE'
  ),
  'anon cannot execute apply_public_apology'
);

SELECT ok(
  has_function_privilege(
    'authenticated',
    'public.execute_power_move(uuid,text)',
    'EXECUTE'
  ),
  'authenticated can execute execute_power_move'
);

SELECT ok(
  has_function_privilege(
    'authenticated',
    'public.apply_public_apology(uuid)',
    'EXECUTE'
  ),
  'authenticated can execute apply_public_apology'
);

DO $$
DECLARE
  v_result JSON;
  v_tarnish INTEGER;
  v_revenue NUMERIC;
BEGIN
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
  PERFORM set_config(
    'request.jwt.claim.sub',
    '10000000-0000-0000-0000-000000000001',
    true
  );

  v_result := public.execute_power_move(
    '10000000-0000-0000-0000-000000000001',
    'public_apology'
  );

  IF COALESCE((v_result->>'success')::BOOLEAN, false) IS NOT TRUE THEN
    RAISE EXCEPTION 'same-player public_apology did not succeed';
  END IF;

  SELECT current_tarnish, total_revenue
  INTO v_tarnish, v_revenue
  FROM public.brand_state
  WHERE player_id = '10000000-0000-0000-0000-000000000001';

  IF v_tarnish <> 10 THEN
    RAISE EXCEPTION 'public_apology tarnish reduction failed: %', v_tarnish;
  END IF;

  IF v_revenue <> 9000 THEN
    RAISE EXCEPTION 'public_apology revenue cost failed: %', v_revenue;
  END IF;
END;
$$;

SELECT pass('same-player public_apology succeeds');

DO $$
DECLARE
  v_tarnish INTEGER;
  v_revenue NUMERIC;
BEGIN
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
  PERFORM set_config(
    'request.jwt.claim.sub',
    '10000000-0000-0000-0000-000000000001',
    true
  );

  BEGIN
    PERFORM public.execute_power_move(
      '10000000-0000-0000-0000-000000000002',
      'public_apology'
    );
    RAISE EXCEPTION 'cross-player execute_power_move unexpectedly succeeded';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'cross-player execute_power_move unexpectedly succeeded' THEN
      RAISE;
    END IF;

    IF LOWER(SQLERRM) NOT LIKE '%unauthorized%' THEN
      RAISE;
    END IF;
  END;

  SELECT current_tarnish, total_revenue
  INTO v_tarnish, v_revenue
  FROM public.brand_state
  WHERE player_id = '10000000-0000-0000-0000-000000000002';

  IF v_tarnish <> 50 OR v_revenue <> 5000 THEN
    RAISE EXCEPTION 'cross-player failure mutated target state';
  END IF;
END;
$$;

SELECT pass('cross-player execute_power_move fails without mutation');

DO $$
BEGIN
  PERFORM set_config('request.jwt.claim.role', 'anon', true);
  PERFORM set_config(
    'request.jwt.claim.sub',
    '00000000-0000-0000-0000-000000000000',
    true
  );

  BEGIN
    PERFORM public.execute_power_move(
      '10000000-0000-0000-0000-000000000001',
      'public_apology'
    );
    RAISE EXCEPTION 'unauthenticated execute_power_move unexpectedly succeeded';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'unauthenticated execute_power_move unexpectedly succeeded' THEN
      RAISE;
    END IF;

    IF LOWER(SQLERRM) NOT LIKE '%unauthorized%' THEN
      RAISE;
    END IF;
  END;

  BEGIN
    PERFORM public.apply_public_apology(
      '10000000-0000-0000-0000-000000000001'
    );
    RAISE EXCEPTION 'unauthenticated apply_public_apology unexpectedly succeeded';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'unauthenticated apply_public_apology unexpectedly succeeded' THEN
      RAISE;
    END IF;

    IF LOWER(SQLERRM) NOT LIKE '%unauthorized%' THEN
      RAISE;
    END IF;
  END;
END;
$$;

SELECT pass('unauthenticated execution paths fail');

SELECT * FROM finish();

ROLLBACK;
