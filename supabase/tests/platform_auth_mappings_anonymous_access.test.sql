BEGIN;

SELECT plan(9);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES (
  '00000000-0000-4000-8000-00000000a901',
  'Anonymous Policy Test',
  'mogul',
  'Paris'
);

INSERT INTO public.brand_state(player_id)
VALUES ('00000000-0000-4000-8000-00000000a901');

INSERT INTO public.stores(player_id, type, city, tier, revenue_per_hour)
VALUES (
  '00000000-0000-4000-8000-00000000a901',
  'ecommerce',
  'paris',
  1,
  0
);

INSERT INTO public.platform_auth_mappings(
  player_id,
  platform,
  platform_user_id
)
VALUES (
  '00000000-0000-4000-8000-00000000a901',
  'game_center',
  'platform-policy-fixture'
);

SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'platform_auth_mappings'
      AND policyname = 'Platform mappings: permanent identities only'
      AND cmd = 'SELECT'
      AND roles = ARRAY['authenticated']::name[]
      AND qual ILIKE '%is_anonymous%'
      AND qual ILIKE '%IS FALSE%'
  ),
  'platform mapping policy requires a non-anonymous Supabase identity'
);

SELECT ok(
  NOT has_table_privilege('anon', 'public.platform_auth_mappings', 'SELECT'),
  'the unauthenticated anon database role cannot read platform mappings'
);

SELECT ok(
  has_table_privilege('authenticated', 'public.platform_auth_mappings', 'SELECT')
    AND NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'UPDATE')
    AND NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'DELETE'),
  'authenticated clients retain read-only table privileges'
);

SELECT ok(
  has_table_privilege('service_role', 'public.platform_auth_mappings', 'SELECT')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'INSERT')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'UPDATE')
    AND has_table_privilege('service_role', 'public.platform_auth_mappings', 'DELETE'),
  'the server-verified linking path retains its service-role privileges'
);

SELECT set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-4000-8000-00000000a901","role":"authenticated","is_anonymous":true}',
  true
);
SET LOCAL ROLE authenticated;

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.platform_auth_mappings
    WHERE player_id = '00000000-0000-4000-8000-00000000a901'
  ),
  0,
  'an anonymous Supabase session cannot read its platform mapping'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.players
    WHERE id = '00000000-0000-4000-8000-00000000a901'
  ),
  1,
  'an anonymous Supabase session can still read its own player row'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.brand_state
    WHERE player_id = '00000000-0000-4000-8000-00000000a901'
  ),
  1,
  'an anonymous Supabase session can still read its own brand state'
);

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.stores
    WHERE player_id = '00000000-0000-4000-8000-00000000a901'
  ),
  1,
  'an anonymous Supabase session can still read its own first-loop store'
);

RESET ROLE;
SELECT set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-4000-8000-00000000a901","role":"authenticated","is_anonymous":false}',
  true
);
SET LOCAL ROLE authenticated;

SELECT is(
  (
    SELECT count(*)::integer
    FROM public.platform_auth_mappings
    WHERE player_id = '00000000-0000-4000-8000-00000000a901'
  ),
  1,
  'a linked permanent session can read its own platform mapping'
);

RESET ROLE;
SELECT * FROM finish();

ROLLBACK;
