-- Milestone 3A1 authority containment. Real independent-session concurrency
-- runs through m3a1_casting_concurrency.ps1 because this test role cannot use
-- passwordless database-to-database connections and credentials do not belong
-- in a repository test.
BEGIN;

SELECT no_plan();

CREATE TEMP TABLE m3a1_snapshot AS
SELECT
  (SELECT count(*)::bigint FROM public.fashion_districts) AS district_count,
  (SELECT COALESCE(sum(treasury), 0)::numeric FROM public.maisons) AS treasury_total,
  (SELECT count(*)::bigint FROM public.gala_events) AS gala_event_count,
  (SELECT count(*)::bigint FROM public.gala_votes) AS gala_vote_count,
  (SELECT COALESCE(sum(luxe_won), 0)::bigint FROM public.gala_submissions) AS gala_award_total,
  (SELECT count(*)::bigint FROM public.mini_game_attempts) AS mini_attempt_count,
  (SELECT COALESCE(sum(total_revenue), 0)::numeric FROM public.brand_state) AS house_funds_total;

INSERT INTO public.players (id, brand_name, path, hq_city)
VALUES
  ('00000000-0000-4000-8000-00000000c101', 'M3A1 Single', 'mogul', 'Paris'),
  ('00000000-0000-4000-8000-00000000c102', 'M3A1 Ten', 'mogul', 'Paris'),
  ('00000000-0000-4000-8000-00000000c103', 'M3A1 Insufficient', 'mogul', 'Paris'),
  ('00000000-0000-4000-8000-00000000c104', 'M3A1 District', 'mogul', 'Paris'),
  ('00000000-0000-4000-8000-00000000c105', 'M3A1 Gala', 'mogul', 'Paris'),
  ('00000000-0000-4000-8000-00000000c106', 'M3A1 Mini', 'mogul', 'Paris');

INSERT INTO public.brand_state (player_id, luxe_tokens)
VALUES
  ('00000000-0000-4000-8000-00000000c101', 100),
  ('00000000-0000-4000-8000-00000000c102', 1000),
  ('00000000-0000-4000-8000-00000000c103', 99),
  ('00000000-0000-4000-8000-00000000c104', 500),
  ('00000000-0000-4000-8000-00000000c105', 500),
  ('00000000-0000-4000-8000-00000000c106', 500);

-- Effective privilege checks include a direct ACL test for PUBLIC (grantee 0)
-- and role-effective checks for anon, authenticated, and service_role.
SELECT ok(
  NOT EXISTS (
    SELECT 1
    FROM pg_proc p
    CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl, acldefault('f', p.proowner))) privilege
    WHERE p.oid = 'public.attempt_district_takeover(uuid,uuid,bigint)'::regprocedure
      AND privilege.grantee = 0
      AND privilege.privilege_type = 'EXECUTE'
  )
    AND NOT has_function_privilege('anon', 'public.attempt_district_takeover(uuid,uuid,bigint)', 'EXECUTE')
    AND NOT has_function_privilege('authenticated', 'public.attempt_district_takeover(uuid,uuid,bigint)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.attempt_district_takeover(uuid,uuid,bigint)', 'EXECUTE'),
  'district takeover is not executable by PUBLIC, anon, authenticated, or service_role'
);
SELECT ok(
  to_regprocedure('public.execute_casting_pull(uuid,text,boolean)') IS NULL
    AND NOT EXISTS (
      SELECT 1
      FROM pg_proc p
      CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl, acldefault('f', p.proowner))) privilege
      WHERE p.oid = 'public.execute_casting_pull(text,boolean)'::regprocedure
        AND privilege.grantee = 0
        AND privilege.privilege_type = 'EXECUTE'
    )
    AND has_function_privilege('authenticated', 'public.execute_casting_pull(text,boolean)', 'EXECUTE')
    AND NOT has_function_privilege('anon', 'public.execute_casting_pull(text,boolean)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.execute_casting_pull(text,boolean)', 'EXECUTE'),
  'only authenticated callers can execute the auth-derived Casting signature'
);
SELECT ok(
  NOT EXISTS (
    SELECT 1
    FROM pg_proc p
    CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl, acldefault('f', p.proowner))) privilege
    WHERE p.oid IN (
      'public.cast_gala_vote(uuid,text)'::regprocedure,
      'public.rotate_gala_event()'::regprocedure
    )
      AND privilege.grantee = 0
      AND privilege.privilege_type = 'EXECUTE'
  )
    AND NOT has_function_privilege('authenticated', 'public.cast_gala_vote(uuid,text)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.cast_gala_vote(uuid,text)', 'EXECUTE')
    AND NOT has_function_privilege('authenticated', 'public.rotate_gala_event()', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.rotate_gala_event()', 'EXECUTE'),
  'Gala voting and settlement are unavailable to client and service roles'
);
SELECT ok(
  NOT EXISTS (
    SELECT 1
    FROM pg_proc p
    CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl, acldefault('f', p.proowner))) privilege
    WHERE p.oid IN (
      'public.edge_start_mini_game(uuid,text,uuid)'::regprocedure,
      'public.edge_claim_mini_game(uuid,uuid,jsonb)'::regprocedure,
      'public.grant_mini_game_reward(uuid,text,text,bigint)'::regprocedure,
      'public.inject_capital_bonus(uuid,integer,text)'::regprocedure
    )
      AND privilege.grantee = 0
      AND privilege.privilege_type = 'EXECUTE'
  )
    AND NOT has_function_privilege('authenticated', 'public.edge_start_mini_game(uuid,text,uuid)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.edge_start_mini_game(uuid,text,uuid)', 'EXECUTE')
    AND NOT has_function_privilege('authenticated', 'public.edge_claim_mini_game(uuid,uuid,jsonb)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.edge_claim_mini_game(uuid,uuid,jsonb)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.grant_mini_game_reward(uuid,text,text,bigint)', 'EXECUTE')
    AND NOT has_function_privilege('service_role', 'public.inject_capital_bonus(uuid,integer,text)', 'EXECUTE'),
  'mini-game Edge and direct reward boundaries are unavailable to every caller'
);
SELECT ok(
  NOT has_table_privilege('authenticated', 'public.gacha_pity_state', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.player_roster', 'INSERT')
    AND NOT has_table_privilege('authenticated', 'public.gala_votes', 'INSERT')
    AND NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename IN ('gacha_pity_state', 'player_roster', 'gala_votes')
        AND policyname IN ('Pity: insert own', 'Roster: insert own', 'Votes: insert own')
    ),
  'clients cannot forge pity, Talent ownership, or paid Gala votes through tables'
);

-- AUD-001: every client bid sign reaches a denied execution boundary.
SELECT set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000c104","role":"authenticated","is_anonymous":false}', true);
SET LOCAL ROLE authenticated;
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.attempt_district_takeover('00000000-0000-4000-8000-00000000c104', (SELECT id FROM public.fashion_districts ORDER BY id LIMIT 1), -1);
      RAISE EXCEPTION 'district takeover executed';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
  END $body$;
$test$, 'negative district bid is denied before mutation');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.attempt_district_takeover('00000000-0000-4000-8000-00000000c104', (SELECT id FROM public.fashion_districts ORDER BY id LIMIT 1), 0);
      RAISE EXCEPTION 'district takeover executed';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
  END $body$;
$test$, 'zero district bid is denied before mutation');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.attempt_district_takeover('00000000-0000-4000-8000-00000000c104', (SELECT id FROM public.fashion_districts ORDER BY id LIMIT 1), 500);
      RAISE EXCEPTION 'district takeover executed';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
  END $body$;
$test$, 'positive district bid is denied before mutation');
RESET ROLE;
SELECT is((SELECT COALESCE(sum(treasury), 0)::numeric FROM public.maisons), (SELECT treasury_total FROM m3a1_snapshot), 'denied district bids leave treasury unchanged');
SELECT is((SELECT count(*)::bigint FROM public.fashion_districts), (SELECT district_count FROM m3a1_snapshot), 'denied district bids leave district records unchanged');

-- AUD-003: accepted calls derive identity from the request JWT and settle all
-- balance, pity, and roster changes together.
SELECT set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000c101","role":"authenticated","is_anonymous":false}', true);
SET LOCAL ROLE authenticated;
SELECT is((SELECT luxe_spent FROM public.execute_casting_pull('standard', FALSE)), 100, 'single pull deducts exactly one 100-Luxe cost');
RESET ROLE;
SELECT is((SELECT luxe_tokens FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-00000000c101'), 0, 'single pull balance is exact and non-negative');
SELECT is((SELECT total_pulls FROM public.gacha_pity_state WHERE player_id = '00000000-0000-4000-8000-00000000c101' AND banner_id = 'standard'), 1, 'single pull increments pity once');
SELECT is((SELECT count(*)::integer FROM public.player_roster WHERE player_id = '00000000-0000-4000-8000-00000000c101'), 1, 'single pull creates one roster award for an empty fixture');

SELECT set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000c102","role":"authenticated","is_anonymous":false}', true);
SET LOCAL ROLE authenticated;
SELECT is((SELECT luxe_spent FROM public.execute_casting_pull('standard', TRUE)), 1000, 'ten pull deducts exactly one 1000-Luxe cost');
RESET ROLE;
SELECT is((SELECT luxe_tokens FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-00000000c102'), 0, 'ten pull balance is exact and non-negative');
SELECT is((SELECT total_pulls FROM public.gacha_pity_state WHERE player_id = '00000000-0000-4000-8000-00000000c102' AND banner_id = 'standard'), 10, 'ten pull increments pity per completed pull');
SELECT ok((SELECT count(*) FROM public.player_roster WHERE player_id = '00000000-0000-4000-8000-00000000c102') BETWEEN 1 AND 10, 'ten pull roster awards are bounded by accepted pull results');

SELECT set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000c103","role":"authenticated","is_anonymous":false}', true);
SET LOCAL ROLE authenticated;
SELECT ok(NOT (SELECT success FROM public.execute_casting_pull('standard', FALSE)), 'insufficient Luxe rejects Casting');
RESET ROLE;
SELECT is((SELECT luxe_tokens FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-00000000c103'), 99, 'rejected Casting does not change Luxe');
SELECT is((SELECT count(*)::integer FROM public.gacha_pity_state WHERE player_id = '00000000-0000-4000-8000-00000000c103'), 0, 'rejected Casting does not create or increment pity');
SELECT is((SELECT count(*)::integer FROM public.player_roster WHERE player_id = '00000000-0000-4000-8000-00000000c103'), 0, 'rejected Casting does not create roster ownership');

-- AUD-004/005: denials and repeated privileged body calls cannot change Gala.
SELECT set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000c105","role":"authenticated","is_anonymous":false}', true);
SET LOCAL ROLE authenticated;
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.cast_gala_vote('00000000-0000-4000-8000-00000000c105', 'timeless');
      RAISE EXCEPTION 'Gala vote executed';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
  END $body$;
$test$, 'authenticated paid Gala vote is denied');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.rotate_gala_event();
      RAISE EXCEPTION 'Gala settlement executed';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
  END $body$;
$test$, 'authenticated Gala settlement is denied');
RESET ROLE;
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.rotate_gala_event();
      RAISE EXCEPTION 'Gala settlement was not quarantined';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'GALA_SETTLEMENT_QUARANTINED' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'privileged automated settlement attempt is inert');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.rotate_gala_event();
      RAISE EXCEPTION 'Gala settlement was not quarantined';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'GALA_SETTLEMENT_QUARANTINED' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'repeated automated settlement attempt remains inert');
SELECT is((SELECT count(*)::bigint FROM public.gala_events), (SELECT gala_event_count FROM m3a1_snapshot), 'Gala event records remain unchanged');
SELECT is((SELECT count(*)::bigint FROM public.gala_votes), (SELECT gala_vote_count FROM m3a1_snapshot), 'Gala containment creates no votes or score changes');
SELECT is((SELECT COALESCE(sum(luxe_won), 0)::bigint FROM public.gala_submissions), (SELECT gala_award_total FROM m3a1_snapshot), 'repeated settlement creates no awards');
SELECT is((SELECT luxe_tokens FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-00000000c105'), 500, 'denied paid voting does not deduct Luxe');

-- AUD-008: direct, valid-looking, and replayed reward routes are all inert.
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.edge_start_mini_game('00000000-0000-4000-8000-00000000c106', 'price_war', NULL);
      RAISE EXCEPTION 'mini-game start executed';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'forged mini-game start cannot create an attempt');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.edge_claim_mini_game('00000000-0000-4000-8000-00000000c106', '00000000-0000-4000-8000-00000000c109', '{"outcome":"win","score":999999}'::jsonb);
      RAISE EXCEPTION 'mini-game claim executed';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'valid-looking mini-game proof cannot mint a reward');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.edge_claim_mini_game('00000000-0000-4000-8000-00000000c106', '00000000-0000-4000-8000-00000000c109', '{"outcome":"win","score":999999}'::jsonb);
      RAISE EXCEPTION 'mini-game replay executed';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'replayed mini-game proof cannot mint a reward');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.grant_mini_game_reward('00000000-0000-4000-8000-00000000c106', 'price_war', 'win', 5000);
      RAISE EXCEPTION 'direct mini-game grant executed';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'service-grant alias cannot bypass mini-game containment');
SELECT lives_ok($test$
  DO $body$ BEGIN
    BEGIN
      PERFORM public.inject_capital_bonus('00000000-0000-4000-8000-00000000c106', 5000, 'mini_game_reward');
      RAISE EXCEPTION 'capital bonus executed';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN RAISE; END IF;
    END;
  END $body$;
$test$, 'capital bonus alias cannot bypass mini-game containment');
SELECT is((SELECT count(*)::bigint FROM public.mini_game_attempts), (SELECT mini_attempt_count FROM m3a1_snapshot), 'contained mini-game calls preserve attempt history');
SELECT is((SELECT COALESCE(sum(total_revenue), 0)::numeric FROM public.brand_state), (SELECT house_funds_total FROM m3a1_snapshot), 'contained mini-game calls preserve House Funds');
SELECT is((SELECT luxe_tokens FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-00000000c106'), 500, 'contained mini-game calls do not grant fixture Luxe');

SELECT * FROM finish();
ROLLBACK;
