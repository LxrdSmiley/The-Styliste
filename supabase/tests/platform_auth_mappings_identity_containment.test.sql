BEGIN;

SELECT plan(15);

SELECT ok(
  has_table_privilege('authenticated', 'public.platform_auth_mappings', 'SELECT'),
  'authenticated retains SELECT privilege'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'INSERT'),
  'authenticated cannot INSERT mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'UPDATE'),
  'authenticated cannot UPDATE mappings'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.platform_auth_mappings', 'DELETE'),
  'authenticated cannot DELETE mappings'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.platform_auth_mappings', 'SELECT'),
  'anon cannot SELECT mappings'
);
SELECT ok(
  has_table_privilege('service_role', 'public.platform_auth_mappings', 'INSERT'),
  'service_role retains INSERT privilege for server linking'
);

SELECT is(
  (
    SELECT count(*)::int
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'platform_auth_mappings'
      AND cmd = 'SELECT'
      AND roles @> ARRAY['authenticated']::name[]
  ),
  1,
  'exactly one authenticated self-read policy exists'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'platform_auth_mappings'
      AND cmd IN ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      AND (
        roles @> ARRAY['anon']::name[] OR
        roles @> ARRAY['authenticated']::name[] OR
        roles @> ARRAY['public']::name[]
      )
  ),
  0,
  'no client write policies exist'
);

SELECT set_config('request.jwt.claim.role', 'service_role', true);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-0000000000a1', true);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES
  ('00000000-0000-4000-8000-0000000000a1', 'RLS Test A', 'designer', 'Paris'),
  ('00000000-0000-4000-8000-0000000000b1', 'RLS Test B', 'mogul', 'London'),
  ('00000000-0000-4000-8000-0000000000c1', 'RLS Test C', 'designer', 'Tokyo');

SET LOCAL ROLE service_role;
INSERT INTO public.platform_auth_mappings(player_id, platform, platform_user_id)
VALUES
  ('00000000-0000-4000-8000-0000000000a1', 'play_games', 'isolated-platform-a'),
  ('00000000-0000-4000-8000-0000000000b1', 'play_games', 'isolated-platform-b'),
  ('00000000-0000-4000-8000-0000000000c1', 'game_center', 'isolated-platform-c');

SELECT is(
  (SELECT count(*)::int FROM public.platform_auth_mappings),
  3,
  'service_role can create isolated fixtures'
);
RESET ROLE;

SELECT set_config(
  'request.jwt.claims',
  '{"sub":"00000000-0000-4000-8000-0000000000a1","role":"authenticated","is_anonymous":false}',
  true
);
SET LOCAL ROLE authenticated;

SELECT is(
  (SELECT count(*)::int FROM public.platform_auth_mappings),
  1,
  'authenticated self-read returns exactly one row'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.platform_auth_mappings
    WHERE player_id = '00000000-0000-4000-8000-0000000000b1'
  ),
  0,
  'authenticated cannot read another player mapping'
);

SELECT throws_ok(
  $$INSERT INTO public.platform_auth_mappings(player_id, platform, platform_user_id)
    VALUES ('00000000-0000-4000-8000-0000000000a1', 'game_center', 'client-insert')$$,
  '42501',
  NULL,
  'authenticated INSERT is rejected'
);
SELECT throws_ok(
  $$UPDATE public.platform_auth_mappings
    SET platform_user_id = 'client-update'
    WHERE player_id = '00000000-0000-4000-8000-0000000000a1'$$,
  '42501',
  NULL,
  'authenticated UPDATE is rejected'
);
SELECT throws_ok(
  $$DELETE FROM public.platform_auth_mappings
    WHERE player_id = '00000000-0000-4000-8000-0000000000a1'$$,
  '42501',
  NULL,
  'authenticated DELETE is rejected'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.role', 'anon', true);
SELECT set_config('request.jwt.claim.sub', '', true);
SET LOCAL ROLE anon;

SELECT throws_ok(
  $$SELECT * FROM public.platform_auth_mappings$$,
  '42501',
  NULL,
  'anonymous SELECT is rejected'
);

SELECT * FROM finish();
ROLLBACK;
