-- GDD v8 §19: progression is server-recorded and client-readable only through
-- reviewed API projections. This replaces the retired public-wrapper model.

BEGIN;

SELECT plan(15);

SELECT ok(
  current_setting('server_version_num')::INT >= 150000,
  'local PostgreSQL supports null-safe progression uniqueness'
);
SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS schema ON schema.oid = relation.relnamespace
    WHERE schema.nspname = 'public'
      AND relation.relname = 'player_progression_events'
      AND relation.relrowsecurity
  ),
  'progression event base table has RLS enabled'
);
SELECT ok(
  EXISTS (
    SELECT 1
    FROM pg_class AS relation
    JOIN pg_namespace AS schema ON schema.oid = relation.relnamespace
    WHERE schema.nspname = 'public'
      AND relation.relname = 'first_week_objectives'
      AND relation.relrowsecurity
  ),
  'first-week objective base table has RLS enabled'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.player_progression_events', 'SELECT'),
  'authenticated players have no raw progression-table read privilege'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.first_week_objectives', 'SELECT'),
  'authenticated players have no raw objective-table read privilege'
);
SELECT ok(
  NOT has_table_privilege('anon', 'public.player_progression_events', 'SELECT'),
  'anonymous callers have no raw progression-table read privilege'
);
SELECT ok(
  has_table_privilege('authenticated', 'api.progression_state', 'SELECT'),
  'authenticated players can read the reviewed progression projection'
);
SELECT ok(
  has_table_privilege('authenticated', 'api.first_week_objectives', 'SELECT'),
  'authenticated players can read the reviewed objective projection'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'api.server_progression_event_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ),
  'authenticated players cannot execute the server progression wrapper'
);
SELECT ok(
  has_function_privilege(
    'service_role',
    'api.server_progression_event_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ),
  'service role can execute the reviewed progression wrapper'
);

SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', TRUE);

DO $$
DECLARE
  v_owner UUID := '00000000-0000-4000-8000-00000000a101';
  v_stranger UUID := '00000000-0000-4000-8000-00000000b101';
  v_key UUID := '00000000-0000-4000-8000-00000000a151';
  v_result JSONB;
  v_replay JSONB;
BEGIN
  INSERT INTO public.players(id, brand_name, path, hq_city, onboarding_complete)
  VALUES
    (v_owner, 'Progression Owner', 'designer', 'kingston', TRUE),
    (v_stranger, 'Progression Stranger', 'mogul', 'kingston', TRUE);
  INSERT INTO private.auth_player_identities(auth_user_id, player_id)
  VALUES (v_owner, v_owner), (v_stranger, v_stranger);
  INSERT INTO public.brand_state(player_id) VALUES (v_owner), (v_stranger);
  INSERT INTO public.feed_posts(player_id, type, content, is_system)
  VALUES (
    v_owner,
    'design_flex',
    jsonb_build_object('event', 'alpha_dropped'),
    FALSE
  );

  v_result := api.server_progression_event_v1(
    v_owner,
    v_key,
    jsonb_build_object('event_key', 'first_drop_result_viewed'),
    'kingston-progression-event.v1'
  );
  v_replay := api.server_progression_event_v1(
    v_owner,
    v_key,
    jsonb_build_object('event_key', 'first_drop_result_viewed'),
    'kingston-progression-event.v1'
  );
  IF v_result IS DISTINCT FROM v_replay OR
     (SELECT count(*) FROM public.player_progression_events
      WHERE player_id = v_owner AND event_key = 'first_drop_result_viewed') <> 1 OR
     (SELECT count(*) FROM ledger.kingston_operation_receipts
      WHERE player_id = v_owner AND operation = 'progression_event'
        AND idempotency_key = v_key) <> 1 THEN
    RAISE EXCEPTION 'SERVER_PROGRESSION_REPLAY_FAILED';
  END IF;
END;
$$;

SELECT pass('server progression event produces one event and one receipt on replay');

RESET ROLE;
SELECT set_config('request.jwt.claim.role', 'authenticated', TRUE);
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000a101', TRUE);
SET LOCAL ROLE authenticated;

SELECT is(
  (
    SELECT count(*)::INT
    FROM api.progression_state
    WHERE event_key = 'first_drop_result_viewed'
  ),
  1,
  'owner reads the verified result-view event through the API projection'
);
SELECT is(
  (
    SELECT count(*)::INT
    FROM api.progression_state
    WHERE player_id = '00000000-0000-4000-8000-00000000b101'
  ),
  0,
  'owner cannot read a stranger progression row through the API projection'
);

DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM public.player_progression_events;
    RAISE EXCEPTION 'RAW_PROGRESSION_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    INSERT INTO public.player_progression_events(player_id, event_key)
    VALUES ('00000000-0000-4000-8000-00000000a101', 'client_insert');
    RAISE EXCEPTION 'RAW_PROGRESSION_WRITE_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('authenticated raw progression read and write attempts are rejected');

SELECT set_config('request.jwt.claim.role', 'anon', TRUE);
SET LOCAL ROLE anon;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM api.progression_state;
    RAISE EXCEPTION 'ANON_API_PROGRESSION_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;
SELECT pass('anonymous caller cannot read the progression API projection');

SELECT * FROM finish();
ROLLBACK;
