BEGIN;

SELECT plan(52);

SELECT ok(
  current_setting('server_version_num')::int >= 150000,
  'local PostgreSQL supports UNIQUE NULLS NOT DISTINCT'
);
SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_index AS i
    JOIN pg_class AS t ON t.oid = i.indrelid
    JOIN pg_namespace AS n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND t.relname = 'player_progression_events'
      AND i.indisunique
      AND i.indnullsnotdistinct
  ),
  'progression events use null-safe uniqueness'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM pg_class AS c
    JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname IN ('player_progression_events', 'first_week_objectives')
      AND c.relrowsecurity
  ),
  2,
  'both progression tables have RLS enabled'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM pg_policies
    WHERE schemaname = 'public'
      AND (
        (tablename = 'player_progression_events'
          AND policyname = 'Progression events: read own')
        OR (tablename = 'first_week_objectives'
          AND policyname = 'First week objectives: read own')
      )
      AND cmd = 'SELECT'
      AND roles @> ARRAY['authenticated']::name[]
  ),
  2,
  'both progression tables retain authenticated self-read policies'
);

SELECT ok(
  has_table_privilege('authenticated', 'public.player_progression_events', 'SELECT')
    AND has_table_privilege('authenticated', 'public.first_week_objectives', 'SELECT')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'UPDATE')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'DELETE')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'TRUNCATE')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'REFERENCES')
    AND NOT has_table_privilege('authenticated', 'public.player_progression_events', 'TRIGGER')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'UPDATE')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'DELETE')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'TRUNCATE')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'REFERENCES')
    AND NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'TRIGGER'),
  'authenticated has SELECT-only table privileges'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.player_progression_events', 'SELECT')
    AND NOT has_table_privilege('anon', 'public.player_progression_events', 'INSERT')
    AND NOT has_table_privilege('anon', 'public.player_progression_events', 'UPDATE')
    AND NOT has_table_privilege('anon', 'public.player_progression_events', 'DELETE')
    AND NOT has_table_privilege('anon', 'public.first_week_objectives', 'SELECT')
    AND NOT has_table_privilege('anon', 'public.first_week_objectives', 'INSERT')
    AND NOT has_table_privilege('anon', 'public.first_week_objectives', 'UPDATE')
    AND NOT has_table_privilege('anon', 'public.first_week_objectives', 'DELETE'),
  'anonymous has no progression table privileges'
);
SELECT ok(
  has_table_privilege('service_role', 'public.player_progression_events', 'SELECT')
    AND has_table_privilege('service_role', 'public.player_progression_events', 'INSERT')
    AND has_table_privilege('service_role', 'public.player_progression_events', 'UPDATE')
    AND has_table_privilege('service_role', 'public.player_progression_events', 'DELETE')
    AND has_table_privilege('service_role', 'public.first_week_objectives', 'SELECT')
    AND has_table_privilege('service_role', 'public.first_week_objectives', 'INSERT')
    AND has_table_privilege('service_role', 'public.first_week_objectives', 'UPDATE')
    AND has_table_privilege('service_role', 'public.first_week_objectives', 'DELETE')
    AND NOT has_table_privilege('service_role', 'public.player_progression_events', 'TRUNCATE')
    AND NOT has_table_privilege('service_role', 'public.player_progression_events', 'REFERENCES')
    AND NOT has_table_privilege('service_role', 'public.player_progression_events', 'TRIGGER')
    AND NOT has_table_privilege('service_role', 'public.first_week_objectives', 'TRUNCATE')
    AND NOT has_table_privilege('service_role', 'public.first_week_objectives', 'REFERENCES')
    AND NOT has_table_privilege('service_role', 'public.first_week_objectives', 'TRIGGER'),
  'service_role has only required progression table privileges'
);

SELECT ok(
  has_function_privilege(
    'authenticated',
    'public.record_progression_event(text,uuid)',
    'EXECUTE'
  )
    AND NOT has_function_privilege(
      'authenticated',
      'public.record_progression_event_internal(uuid,text,uuid,jsonb)',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'authenticated',
      'public.seed_first_week_objectives()',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'authenticated',
      'public.progression_event_trigger()',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'authenticated',
      'public.edge_open_first_store_atomic(uuid,text,text,text,integer,uuid)',
      'EXECUTE'
    ),
  'authenticated can execute only the validated progression wrapper'
);
SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.record_progression_event(text,uuid)',
    'EXECUTE'
  )
    AND NOT has_function_privilege(
      'anon',
      'public.record_progression_event_internal(uuid,text,uuid,jsonb)',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'anon',
      'public.seed_first_week_objectives()',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'anon',
      'public.progression_event_trigger()',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'anon',
      'public.edge_open_first_store_atomic(uuid,text,text,text,integer,uuid)',
      'EXECUTE'
    ),
  'anonymous cannot execute progression migration functions'
);
SELECT ok(
  has_function_privilege(
    'service_role',
    'public.edge_open_first_store_atomic(uuid,text,text,text,integer,uuid)',
    'EXECUTE'
  )
    AND NOT has_function_privilege(
      'service_role',
      'public.record_progression_event(text,uuid)',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'service_role',
      'public.record_progression_event_internal(uuid,text,uuid,jsonb)',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'service_role',
      'public.seed_first_week_objectives()',
      'EXECUTE'
    )
    AND NOT has_function_privilege(
      'service_role',
      'public.progression_event_trigger()',
      'EXECUTE'
    ),
  'service_role can execute only its intended service function'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
    CROSS JOIN LATERAL aclexplode(
      COALESCE(p.proacl, acldefault('f', p.proowner))
    ) AS acl
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'seed_first_week_objectives',
        'record_progression_event_internal',
        'record_progression_event',
        'progression_event_trigger',
        'edge_open_first_store_atomic'
      )
      AND acl.grantee = 0
      AND acl.privilege_type = 'EXECUTE'
  ),
  0,
  'PUBLIC cannot execute migration functions'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN (
        'seed_first_week_objectives',
        'record_progression_event_internal',
        'record_progression_event',
        'progression_event_trigger',
        'edge_open_first_store_atomic'
      )
      AND p.proconfig @> ARRAY['search_path=""']::text[]
  ),
  5,
  'all migration functions use an empty fixed search_path'
);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES
  ('00000000-0000-4000-8000-00000000a101', 'Progression Test A', 'designer', 'Paris'),
  ('00000000-0000-4000-8000-00000000b101', 'Progression Test B', 'mogul', 'London');

SELECT set_config('request.jwt.claim.role', 'service_role', true);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000a101', true);
SET LOCAL ROLE service_role;

SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000001',
      NULL,
      'system_eclipse',
      '{"event_key":"migration_fixture"}'::jsonb,
      TRUE
    )$$,
  'null-owner system Feed fixture can be inserted'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.feed_posts
    WHERE id = '10000000-0000-4000-8000-000000000001'
      AND player_id IS NULL
      AND is_system
  ),
  1,
  'null-owner system Feed fixture survives unchanged'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000001'
  ),
  0,
  'null-owner system Feed fixture creates no progression event'
);
SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000002',
      '00000000-0000-4000-8000-00000000a101',
      'design_flex',
      '{"event":"player_fixture_a"}'::jsonb,
      FALSE
    )$$,
  'first player-authored Feed fixture can be inserted'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000002'
      AND event_key = 'global_feed_participation'
  ),
  1,
  'first player-authored Feed fixture creates one progression event'
);
SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000003',
      '00000000-0000-4000-8000-00000000b101',
      'mogul_flex',
      '{"event":"player_fixture_b"}'::jsonb,
      FALSE
    )$$,
  'second player-authored Feed fixture can be inserted'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000003'
      AND event_key = 'global_feed_participation'
  ),
  1,
  'second player-authored Feed fixture creates one progression event'
);

RESET ROLE;

SELECT lives_ok(
  $$INSERT INTO public.player_progression_events (
      player_id,
      event_key,
      entity_id,
      metadata
    )
    SELECT
      fp.player_id,
      'global_feed_participation',
      fp.id,
      '{}'::jsonb
    FROM public.feed_posts AS fp
    JOIN public.players AS p ON p.id = fp.player_id
    WHERE fp.player_id IS NOT NULL
      AND fp.is_system IS NOT TRUE
    ON CONFLICT (player_id, event_key, entity_id) DO NOTHING$$,
  'first repeated Feed backfill succeeds'
);
SELECT lives_ok(
  $$INSERT INTO public.player_progression_events (
      player_id,
      event_key,
      entity_id,
      metadata
    )
    SELECT
      fp.player_id,
      'global_feed_participation',
      fp.id,
      '{}'::jsonb
    FROM public.feed_posts AS fp
    JOIN public.players AS p ON p.id = fp.player_id
    WHERE fp.player_id IS NOT NULL
      AND fp.is_system IS NOT TRUE
    ON CONFLICT (player_id, event_key, entity_id) DO NOTHING$$,
  'second repeated Feed backfill succeeds'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE event_key = 'global_feed_participation'
      AND entity_id IN (
        '10000000-0000-4000-8000-000000000002',
        '10000000-0000-4000-8000-000000000003'
      )
  ),
  2,
  'running the Feed backfill twice keeps one event per eligible post'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000001'
  ),
  0,
  'repeated Feed backfills continue to exclude system posts'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.feed_posts
    WHERE id IN (
      '10000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000002',
      '10000000-0000-4000-8000-000000000003'
    )
  ),
  3,
  'Feed backfills preserve all existing fixture rows'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.feed_posts
    WHERE (id = '10000000-0000-4000-8000-000000000001'
        AND player_id IS NULL AND is_system AND type = 'system_eclipse')
      OR (id = '10000000-0000-4000-8000-000000000002'
        AND player_id = '00000000-0000-4000-8000-00000000a101'
        AND is_system IS NOT TRUE)
      OR (id = '10000000-0000-4000-8000-000000000003'
        AND player_id = '00000000-0000-4000-8000-00000000b101'
        AND is_system IS NOT TRUE)
  ),
  3,
  'Feed backfills do not rewrite fixture ownership or system status'
);

SELECT set_config('request.jwt.claim.role', 'service_role', true);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000a101', true);
SET LOCAL ROLE service_role;

SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000004',
      NULL,
      'system_eclipse',
      '{"event_key":"future_system"}'::jsonb,
      TRUE
    )$$,
  'a future null-owner system Feed insert succeeds'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000004'
  ),
  0,
  'a future null-owner system Feed insert creates no event'
);
SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000005',
      '00000000-0000-4000-8000-00000000a101',
      'design_flex',
      '{"event":"future_player"}'::jsonb,
      FALSE
    )$$,
  'a future player Feed insert succeeds'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000005'
      AND event_key = 'global_feed_participation'
  ),
  1,
  'a future player Feed insert creates one event'
);
SELECT lives_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000006',
      '00000000-0000-4000-8000-00000000a101',
      'system_eclipse',
      '{"event_key":"owned_system"}'::jsonb,
      TRUE
    )$$,
  'a player-linked system Feed insert succeeds'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000006'
  ),
  0,
  'a player-linked system Feed insert creates no event'
);

RESET ROLE;

SELECT lives_ok(
  $$SELECT public.record_progression_event_internal(
      '00000000-0000-4000-8000-00000000a101',
      'store_result_viewed',
      NULL,
      '{}'::jsonb
    );
    SELECT public.record_progression_event_internal(
      '00000000-0000-4000-8000-00000000a101',
      'store_result_viewed',
      NULL,
      '{}'::jsonb
    )$$,
  'repeating a null-entity progression event succeeds idempotently'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE player_id = '00000000-0000-4000-8000-00000000a101'
      AND event_key = 'store_result_viewed'
      AND entity_id IS NULL
  ),
  1,
  'repeated null-entity progression events remain unique'
);

SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000a101', true);
SET LOCAL ROLE authenticated;

SELECT lives_ok(
  $$SELECT public.record_progression_event(
      'global_feed_participation',
      '10000000-0000-4000-8000-000000000002'
    )$$,
  'authenticated player can record participation for an owned player post'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE entity_id = '10000000-0000-4000-8000-000000000002'
      AND event_key = 'global_feed_participation'
  ),
  1,
  'validated wrapper does not duplicate an existing Feed event'
);
SELECT throws_ok(
  $$SELECT public.record_progression_event(
      'global_feed_participation',
      '10000000-0000-4000-8000-000000000003'
    )$$,
  'P0001',
  'INVALID_PROGRESS_EVENT',
  'authenticated player cannot claim another player Feed post'
);
SELECT throws_ok(
  $$SELECT public.record_progression_event(
      'global_feed_participation',
      '10000000-0000-4000-8000-000000000001'
    )$$,
  'P0001',
  'INVALID_PROGRESS_EVENT',
  'authenticated player cannot claim a null-owner system Feed post'
);
SELECT throws_ok(
  $$SELECT public.record_progression_event(
      'global_feed_participation',
      '10000000-0000-4000-8000-000000000006'
    )$$,
  'P0001',
  'INVALID_PROGRESS_EVENT',
  'authenticated player cannot claim a player-linked system Feed post'
);
SELECT throws_ok(
  $$SELECT public.record_progression_event('global_feed_participation', NULL)$$,
  'P0001',
  'INVALID_PROGRESS_EVENT',
  'global Feed participation requires a non-null entity ID'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.player_progression_events
    WHERE player_id = '00000000-0000-4000-8000-00000000b101'
  ),
  0,
  'authenticated player cannot read another player progression rows'
);
SELECT ok(
  (SELECT count(*) FROM public.player_progression_events) > 0,
  'authenticated player can read owned progression rows'
);
SELECT is(
  (
    SELECT count(*)::int
    FROM public.first_week_objectives
    WHERE player_id = '00000000-0000-4000-8000-00000000b101'
  ),
  0,
  'authenticated player cannot read another player objectives'
);
SELECT is(
  (SELECT count(*)::int FROM public.first_week_objectives),
  7,
  'authenticated player can read only the seven objectives seeded for that player'
);
SELECT throws_ok(
  $$INSERT INTO public.player_progression_events(player_id, event_key)
    VALUES ('00000000-0000-4000-8000-00000000a101', 'client_insert')$$,
  '42501',
  NULL,
  'authenticated cannot directly insert progression rows'
);
SELECT throws_ok(
  $$UPDATE public.first_week_objectives
    SET status = 'completed'
    WHERE player_id = '00000000-0000-4000-8000-00000000a101'$$,
  '42501',
  NULL,
  'authenticated cannot directly update objectives'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.record_progression_event_internal(uuid,text,uuid,jsonb)',
    'EXECUTE'
  )
    AND NOT has_function_privilege(
      'authenticated',
      'public.progression_event_trigger()',
      'EXECUTE'
    ),
  'authenticated cannot execute internal or trigger functions'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.role', 'anon', true);
SELECT set_config('request.jwt.claim.sub', '', true);
SET LOCAL ROLE anon;

SELECT throws_ok(
  $$SELECT * FROM public.player_progression_events$$,
  '42501',
  NULL,
  'anonymous cannot read progression rows'
);
SELECT throws_ok(
  $$SELECT * FROM public.first_week_objectives$$,
  '42501',
  NULL,
  'anonymous cannot read objectives'
);
SELECT throws_ok(
  $$INSERT INTO public.player_progression_events(player_id, event_key)
    VALUES ('00000000-0000-4000-8000-00000000a101', 'anon_insert')$$,
  '42501',
  NULL,
  'anonymous cannot insert progression rows'
);
SELECT throws_ok(
  $$UPDATE public.first_week_objectives SET status = 'completed'$$,
  '42501',
  NULL,
  'anonymous cannot update objectives'
);

RESET ROLE;
SELECT set_config('request.jwt.claim.role', 'service_role', true);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000a101', true);
SET LOCAL ROLE service_role;

SELECT throws_ok(
  $$INSERT INTO public.feed_posts(id, player_id, type, content, is_system)
    VALUES (
      '10000000-0000-4000-8000-000000000007',
      '00000000-0000-4000-8000-00000000c101',
      'design_flex',
      '{}'::jsonb,
      FALSE
    )$$,
  '23503',
  NULL,
  'Feed ownership foreign key rejects an orphaned player ID'
);

RESET ROLE;

SELECT is(
  (
    SELECT count(*)::int
    FROM public.feed_posts
    WHERE id IN (
      '10000000-0000-4000-8000-000000000001',
      '10000000-0000-4000-8000-000000000002',
      '10000000-0000-4000-8000-000000000003',
      '10000000-0000-4000-8000-000000000004',
      '10000000-0000-4000-8000-000000000005',
      '10000000-0000-4000-8000-000000000006'
    )
  ),
  6,
  'all valid system and player Feed fixtures remain unchanged'
);

SELECT * FROM finish();
ROLLBACK;
