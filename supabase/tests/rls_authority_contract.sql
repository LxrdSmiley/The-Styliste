-- Compatibility inventory guard for the final Kingston API surface.
-- Behavioral owner/replay/rollback cases live in the focused executable file:
--   supabase/tests/kingston_early_game_api_contract.test.sql
BEGIN;

SELECT plan(1);

CREATE TEMP TABLE expected_api_surface(kind TEXT, name TEXT, PRIMARY KEY(kind, name))
ON COMMIT DROP;
INSERT INTO expected_api_surface(kind, name) VALUES
  ('relation', 'brand_summary'),
  ('relation', 'design_release_receipts'),
  ('relation', 'design_session_state'),
  ('relation', 'feed_projection'),
  ('relation', 'first_store_receipts'),
  ('relation', 'first_week_objectives'),
  ('relation', 'founder_trial_state'),
  ('relation', 'idle_settlement_receipts'),
  ('relation', 'owned_designs'),
  ('relation', 'player_summary'),
  ('relation', 'progression_state'),
  ('relation', 'store_summary'),
  ('rpc', 'server_design_intent_v1'),
  ('rpc', 'server_capsule_foundation_intent_v1'),
  ('rpc', 'server_founder_trial_intent_v1'),
  ('rpc', 'server_open_first_store_v1'),
  ('rpc', 'server_progression_event_v1'),
  ('rpc', 'server_settle_idle_income_v1'),
  ('rpc', 'server_submit_player_report_v1');

DO $$
DECLARE v_unexpected TEXT; v_missing TEXT;
BEGIN
  SELECT string_agg(surface, ', ' ORDER BY surface) INTO v_unexpected
  FROM (
    SELECT 'relation:' || c.relname AS surface
    FROM pg_class AS c
    JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'api' AND c.relkind IN ('r', 'v', 'm', 'p')
      AND NOT EXISTS (
        SELECT 1 FROM expected_api_surface AS expected
        WHERE expected.kind = 'relation' AND expected.name = c.relname
      )
    UNION ALL
    SELECT 'rpc:' || p.proname
    FROM pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'api'
      AND NOT EXISTS (
        SELECT 1 FROM expected_api_surface AS expected
        WHERE expected.kind = 'rpc' AND expected.name = p.proname
      )
  ) AS unexpected(surface);
  IF v_unexpected IS NOT NULL THEN RAISE EXCEPTION 'UNEXPECTED_API_SURFACE: %', v_unexpected; END IF;

  SELECT string_agg(expected.kind || ':' || expected.name, ', ' ORDER BY expected.kind, expected.name)
  INTO v_missing
  FROM expected_api_surface AS expected
  WHERE (expected.kind = 'relation' AND to_regclass('api.' || expected.name) IS NULL)
     OR (expected.kind = 'rpc' AND NOT EXISTS (
       SELECT 1 FROM pg_proc AS p JOIN pg_namespace AS n ON n.oid = p.pronamespace
       WHERE n.nspname = 'api' AND p.proname = expected.name
     ));
  IF v_missing IS NOT NULL THEN RAISE EXCEPTION 'MISSING_API_SURFACE: %', v_missing; END IF;

  IF EXISTS (
    SELECT 1 FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'api' AND c.relkind = 'v'
      AND NOT ('security_invoker=true' = ANY(COALESCE(c.reloptions, ARRAY[]::TEXT[])))
  ) THEN RAISE EXCEPTION 'API_VIEW_NOT_SECURITY_INVOKER'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_proc AS p JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'api' AND p.prosecdef
  ) THEN RAISE EXCEPTION 'API_WRAPPER_SECURITY_DEFINER'; END IF;
  IF EXISTS (
    SELECT 1 FROM pg_proc AS p JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE n.nspname = 'api'
      AND (has_function_privilege('anon', p.oid, 'EXECUTE') OR
           has_function_privilege('authenticated', p.oid, 'EXECUTE'))
  ) THEN RAISE EXCEPTION 'CLIENT_EXECUTES_API_WRAPPER'; END IF;
END;
$$;

SELECT pass('RLS authority contract completed without a database violation');
SELECT * FROM finish();
ROLLBACK;
