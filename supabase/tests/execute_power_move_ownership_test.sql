-- GDD v8 §19: later-wave Power Moves must have no client or unreviewed server
-- execution path during the Kingston Gate A slice.

BEGIN;

SELECT plan(7);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'Power Move Owner', 'mogul', 'kingston'),
  ('10000000-0000-0000-0000-000000000002', 'Power Move Other', 'designer', 'kingston');
INSERT INTO public.brand_state(player_id, total_revenue, current_tarnish)
VALUES
  ('10000000-0000-0000-0000-000000000001', 10000, 40),
  ('10000000-0000-0000-0000-000000000002', 5000, 50);

SELECT ok(
  NOT has_function_privilege('anon', 'public.execute_power_move(uuid,text)', 'EXECUTE'),
  'anon cannot execute the retired Power Move dispatcher'
);
SELECT ok(
  NOT has_function_privilege('anon', 'public.apply_public_apology(uuid)', 'EXECUTE'),
  'anon cannot execute the retired apology function'
);
SELECT ok(
  NOT has_function_privilege('authenticated', 'public.execute_power_move(uuid,text)', 'EXECUTE'),
  'authenticated cannot execute the retired Power Move dispatcher'
);
SELECT ok(
  NOT has_function_privilege('authenticated', 'public.apply_public_apology(uuid)', 'EXECUTE'),
  'authenticated cannot execute the retired apology function'
);
SELECT ok(
  NOT has_function_privilege('service_role', 'public.execute_power_move(uuid,text)', 'EXECUTE'),
  'service role has no unreviewed public Power Move bypass'
);

SELECT set_config('request.jwt.claim.role', 'authenticated', TRUE);
SELECT set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', TRUE);
SET LOCAL ROLE authenticated;

DO $$
BEGIN
  BEGIN
    PERFORM public.execute_power_move(
      '10000000-0000-0000-0000-000000000001', 'public_apology'
    );
    RAISE EXCEPTION 'OWNER_POWER_MOVE_EXECUTED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM public.execute_power_move(
      '10000000-0000-0000-0000-000000000002', 'public_apology'
    );
    RAISE EXCEPTION 'FOREIGN_POWER_MOVE_EXECUTED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;

RESET ROLE;
SELECT ok(
  (SELECT current_tarnish = 40 AND total_revenue = 10000
   FROM public.brand_state
   WHERE player_id = '10000000-0000-0000-0000-000000000001')
  AND
  (SELECT current_tarnish = 50 AND total_revenue = 5000
   FROM public.brand_state
   WHERE player_id = '10000000-0000-0000-0000-000000000002'),
  'authenticated owner and stranger attempts fail without mutation'
);

SET LOCAL ROLE anon;
SELECT throws_ok(
  $$SELECT public.apply_public_apology('10000000-0000-0000-0000-000000000001')$$,
  '42501',
  NULL,
  'anonymous execution of the retired apology function is rejected'
);

RESET ROLE;
SELECT * FROM finish();

ROLLBACK;
