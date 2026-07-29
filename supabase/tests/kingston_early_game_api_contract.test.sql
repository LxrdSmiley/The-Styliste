-- GDD v7 §§19.2, 19.4-19.10, 21.3, 21.4, 22.
-- Executable disposable-local contract checks. Every assertion raises on fail;
-- the transaction rolls back so no fixture survives the test.
BEGIN;

SELECT plan(1);

DO $$
BEGIN
  IF has_function_privilege(
    'anon',
    'api.server_settle_idle_income_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ) OR has_function_privilege(
    'authenticated',
    'api.server_settle_idle_income_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ) THEN RAISE EXCEPTION 'CLIENT_EXECUTES_SERVER_WRAPPER'; END IF;
  IF has_table_privilege('anon', 'public.brand_state', 'SELECT') OR
     has_table_privilege('authenticated', 'public.brand_state', 'UPDATE') OR
     has_table_privilege('authenticated', 'ledger.economy_ledger', 'SELECT') THEN
    RAISE EXCEPTION 'BASE_TABLE_PRIVILEGE_LEAK';
  END IF;
END;
$$;

INSERT INTO public.players(id, brand_name, path, hq_city, onboarding_complete)
VALUES
  ('00000000-0000-4000-8000-000000001001', 'Contract Owner', 'designer', 'kingston', TRUE),
  ('00000000-0000-4000-8000-000000001002', 'Contract Stranger', 'designer', 'kingston', TRUE),
  ('00000000-0000-4000-8000-000000001003', 'Contract Mogul', 'mogul', 'kingston', TRUE),
  ('00000000-0000-4000-8000-000000001004', 'Missing Mapping', 'designer', 'kingston', TRUE);
INSERT INTO private.auth_player_identities(auth_user_id, player_id)
VALUES
  ('00000000-0000-4000-8000-000000001001', '00000000-0000-4000-8000-000000001001'),
  ('00000000-0000-4000-8000-000000001002', '00000000-0000-4000-8000-000000001002'),
  ('00000000-0000-4000-8000-000000001003', '00000000-0000-4000-8000-000000001003');
INSERT INTO public.brand_state(
  player_id, total_revenue, house_funds, idle_revenue_per_hour,
  idle_base_revenue_per_hour, last_active_at
)
VALUES
  ('00000000-0000-4000-8000-000000001001', 0, 1000, 100, 100, clock_timestamp() - INTERVAL '1 hour'),
  ('00000000-0000-4000-8000-000000001002', 0, 1000, 100, 100, clock_timestamp() - INTERVAL '1 hour'),
  ('00000000-0000-4000-8000-000000001003', 0, 0, 100, 100, clock_timestamp() - INTERVAL '1 hour'),
  ('00000000-0000-4000-8000-000000001004', 0, 1000, 100, 100, clock_timestamp() - INTERVAL '1 hour');
INSERT INTO public.designs(id, player_id, name, session_type, status)
VALUES (
  '00000000-0000-4000-8000-00000000d001',
  '00000000-0000-4000-8000-000000001001',
  'Contract Alpha', 'quick_sketch', 'complete'
);
INSERT INTO public.atelier_sessions(
  id, player_id, fabric_color_hex, style_tags, minted_at, design_id
) VALUES (
  '00000000-0000-4000-8000-00000000e001',
  '00000000-0000-4000-8000-000000001001',
  'FAF7F0', ARRAY['minimalist']::TEXT[], clock_timestamp(),
  '00000000-0000-4000-8000-00000000d001'
);

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000001001', TRUE);
SELECT set_config('request.jwt.claim.role', 'authenticated', TRUE);
DO $$
BEGIN
  IF (SELECT count(*) FROM api.player_summary) <> 1 OR
     NOT EXISTS (
       SELECT 1 FROM api.player_summary
       WHERE id = '00000000-0000-4000-8000-000000001001'
     ) THEN RAISE EXCEPTION 'OWNER_READ_FAILED'; END IF;
  IF EXISTS (
    SELECT 1 FROM api.player_summary
    WHERE id = '00000000-0000-4000-8000-000000001002'
  ) THEN RAISE EXCEPTION 'STRANGER_ROW_VISIBLE'; END IF;
  BEGIN
    UPDATE public.brand_state SET total_revenue = 999999
    WHERE player_id = '00000000-0000-4000-8000-000000001001';
    RAISE EXCEPTION 'DIRECT_OWNER_WRITE_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM api.server_settle_idle_income_v1(
      '00000000-0000-4000-8000-000000001001',
      '00000000-0000-4000-8000-00000000a001', '{}'::JSONB,
      'kingston-idle-settlement.v1'
    );
    RAISE EXCEPTION 'AUTHENTICATED_WRAPPER_EXECUTION_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;

SET LOCAL ROLE anon;
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM api.player_summary;
    RAISE EXCEPTION 'ANON_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM api.server_settle_idle_income_v1(
      '00000000-0000-4000-8000-000000001001',
      '00000000-0000-4000-8000-00000000a002', '{}'::JSONB,
      'kingston-idle-settlement.v1'
    );
    RAISE EXCEPTION 'ANON_WRAPPER_EXECUTION_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;

SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', TRUE);
DO $$
DECLARE
  v_first JSONB;
  v_replay JSONB;
  v_blueprint JSONB := jsonb_build_object(
    'version', 1,
    'garment_category', 'starter_garment',
    'editable_zones', jsonb_build_array('bodice'),
    'materials', jsonb_build_array('minimalist'),
    'palette', jsonb_build_array('FAF7F0'),
    'construction_choices', jsonb_build_array('straight_seam'),
    'revision_lineage', '[]'::JSONB
  );
BEGIN
  -- Missing and foreign identity mappings fail closed.
  BEGIN
    PERFORM api.server_settle_idle_income_v1(
      '00000000-0000-4000-8000-000000001004',
      '00000000-0000-4000-8000-00000000a004', '{}'::JSONB,
      'kingston-idle-settlement.v1'
    );
    RAISE EXCEPTION 'MISSING_MAPPING_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'MISSING_MAPPING_ACCEPTED' OR SQLERRM NOT LIKE '%IDENTITY_MAPPING_MISSING%' THEN RAISE; END IF;
  END;
  BEGIN
    INSERT INTO private.auth_player_identities(auth_user_id, player_id)
    VALUES (
      '00000000-0000-4000-8000-000000001099',
      '00000000-0000-4000-8000-000000001002'
    );
    RAISE EXCEPTION 'FOREIGN_MAPPING_ACCEPTED';
  EXCEPTION WHEN check_violation THEN NULL;
  END;

  -- Founder first request, exact replay, and conflicting replay.
  v_first := api.server_founder_trial_intent_v1(
    '00000000-0000-4000-8000-000000001010', TRUE,
    '00000000-0000-4000-8000-00000000a010',
    jsonb_build_object(
      'action', 'initialize', 'brand_name', 'Anonymous Founder'
    ), 'kingston-founder-trial.v1'
  );
  v_replay := api.server_founder_trial_intent_v1(
    '00000000-0000-4000-8000-000000001010', TRUE,
    '00000000-0000-4000-8000-00000000a010',
    jsonb_build_object(
      'action', 'initialize', 'brand_name', 'Anonymous Founder'
    ), 'kingston-founder-trial.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'FOUNDER_REPLAY_CHANGED'; END IF;
  BEGIN
    PERFORM api.server_founder_trial_intent_v1(
      '00000000-0000-4000-8000-000000001010', TRUE,
      '00000000-0000-4000-8000-00000000a010',
      jsonb_build_object(
        'action', 'initialize', 'brand_name', 'Conflicting Founder'
      ), 'kingston-founder-trial.v1'
    );
    RAISE EXCEPTION 'CONFLICTING_FOUNDER_REPLAY_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'CONFLICTING_FOUNDER_REPLAY_ACCEPTED' OR
       SQLERRM NOT LIKE '%IDEMPOTENCY_KEY_CONFLICT%' THEN RAISE; END IF;
  END;
  BEGIN
    PERFORM api.server_founder_trial_intent_v1(
      '00000000-0000-4000-8000-000000001011', FALSE,
      '00000000-0000-4000-8000-00000000a011',
      jsonb_build_object('action', 'invented'), 'kingston-founder-trial.v1'
    );
    RAISE EXCEPTION 'MALFORMED_FOUNDER_REQUEST_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'MALFORMED_FOUNDER_REQUEST_ACCEPTED' OR
       SQLERRM NOT LIKE '%INVALID_FOUNDER_TRIAL_ACTION%' THEN RAISE; END IF;
  END;

  -- Design owner/replay/conflict/foreign resource containment.
  v_first := api.server_design_intent_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a020',
    jsonb_build_object(
      'action', 'release',
      'design_id', '00000000-0000-4000-8000-00000000d001',
      'release_intent', 'publish_first_drop', 'blueprint', v_blueprint,
      'vex_opt_in', TRUE
    ), 'kingston-design-intent.v1'
  );
  v_replay := api.server_design_intent_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a020',
    jsonb_build_object(
      'action', 'release',
      'design_id', '00000000-0000-4000-8000-00000000d001',
      'release_intent', 'publish_first_drop', 'blueprint', v_blueprint,
      'vex_opt_in', TRUE
    ), 'kingston-design-intent.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'DESIGN_REPLAY_CHANGED'; END IF;
  BEGIN
    PERFORM api.server_design_intent_v1(
      '00000000-0000-4000-8000-000000001002',
      '00000000-0000-4000-8000-00000000a021',
      jsonb_build_object(
        'action', 'release',
        'design_id', '00000000-0000-4000-8000-00000000d001',
        'release_intent', 'publish_first_drop', 'blueprint', v_blueprint,
        'vex_opt_in', TRUE
      ), 'kingston-design-intent.v1'
    );
    RAISE EXCEPTION 'FOREIGN_DESIGN_RELEASE_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'FOREIGN_DESIGN_RELEASE_ACCEPTED' OR
       SQLERRM NOT LIKE '%DESIGN_NOT_FOUND_OR_NOT_OWNED%' THEN RAISE; END IF;
  END;

  -- Invalid catalog request rolls back, then valid first-store replays.
  BEGIN
    PERFORM api.server_open_first_store_v1(
      '00000000-0000-4000-8000-000000001003',
      '00000000-0000-4000-8000-00000000a030',
      jsonb_build_object(
        'store_type', 'flagship', 'price_tier', 'luxury',
        'inventory_capacity', 999
      ), 'kingston-first-store.v1'
    );
    RAISE EXCEPTION 'INVALID_INVENTORY_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'INVALID_INVENTORY_ACCEPTED' OR
       SQLERRM NOT LIKE '%INVALID_INVENTORY_CAPACITY%' THEN RAISE; END IF;
  END;
  IF EXISTS (SELECT 1 FROM public.stores WHERE player_id = '00000000-0000-4000-8000-000000001003') THEN
    RAISE EXCEPTION 'INDUCED_FAILURE_DID_NOT_ROLL_BACK';
  END IF;
  v_first := api.server_open_first_store_v1(
    '00000000-0000-4000-8000-000000001003',
    '00000000-0000-4000-8000-00000000a031',
    jsonb_build_object(
      'store_type', 'flagship', 'price_tier', 'luxury',
      'inventory_capacity', 24
    ), 'kingston-first-store.v1'
  );
  v_replay := api.server_open_first_store_v1(
    '00000000-0000-4000-8000-000000001003',
    '00000000-0000-4000-8000-00000000a031',
    jsonb_build_object(
      'store_type', 'flagship', 'price_tier', 'luxury',
      'inventory_capacity', 24
    ), 'kingston-first-store.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'STORE_REPLAY_CHANGED'; END IF;
  IF (SELECT house_funds FROM public.brand_state WHERE player_id = '00000000-0000-4000-8000-000000001003') < 0 THEN
    RAISE EXCEPTION 'DEBT_FREE_STORE_CREATED_NEGATIVE_BALANCE';
  END IF;
  IF (SELECT idle_base_revenue_per_hour FROM public.brand_state
      WHERE player_id = '00000000-0000-4000-8000-000000001003') <> 100 OR
     (SELECT idle_store_revenue_per_hour FROM public.brand_state
      WHERE player_id = '00000000-0000-4000-8000-000000001003') <= 0 THEN
    RAISE EXCEPTION 'FIRST_STORE_ERASED_OR_FAILED_TO_SEPARATE_IDLE_SOURCE';
  END IF;

  -- Idle uses server time, one ledger entry, and stable replay.
  UPDATE public.brand_state SET last_active_at = clock_timestamp() - INTERVAL '1 hour'
  WHERE player_id = '00000000-0000-4000-8000-000000001001';
  v_first := api.server_settle_idle_income_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a040', '{}'::JSONB,
    'kingston-idle-settlement.v1'
  );
  v_replay := api.server_settle_idle_income_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a040', '{}'::JSONB,
    'kingston-idle-settlement.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'IDLE_REPLAY_CHANGED'; END IF;
  IF COALESCE((v_first->>'house_funds')::NUMERIC, -1) <= 1000 OR
     COALESCE((v_first->>'lifetime_gross_revenue')::NUMERIC, -1) <= 0 OR
     COALESCE((v_first->>'lifetime_net_result')::NUMERIC, -1) <= 0 THEN
    RAISE EXCEPTION 'IDLE_ECONOMY_FIELDS_NOT_SEPARATED';
  END IF;

  -- Verified progression and non-economic report are still idempotent.
  v_first := api.server_progression_event_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a050',
    jsonb_build_object('event_key', 'first_drop_result_viewed'),
    'kingston-progression-event.v1'
  );
  v_replay := api.server_progression_event_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a050',
    jsonb_build_object('event_key', 'first_drop_result_viewed'),
    'kingston-progression-event.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'PROGRESSION_REPLAY_CHANGED'; END IF;
  v_first := api.server_submit_player_report_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a060',
    jsonb_build_object(
      'reported_player_id', '00000000-0000-4000-8000-000000001002',
      'category', 'spam', 'description', 'contract test'
    ), 'kingston-player-report.v1'
  );
  v_replay := api.server_submit_player_report_v1(
    '00000000-0000-4000-8000-000000001001',
    '00000000-0000-4000-8000-00000000a060',
    jsonb_build_object(
      'reported_player_id', '00000000-0000-4000-8000-000000001002',
      'category', 'spam', 'description', 'contract test'
    ), 'kingston-player-report.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN RAISE EXCEPTION 'REPORT_REPLAY_CHANGED'; END IF;
END;
$$;
RESET ROLE;

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000001010', TRUE);
SELECT set_config('request.jwt.claim.role', 'authenticated', TRUE);
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM api.player_summary
    WHERE id = '00000000-0000-4000-8000-000000001010' AND is_anonymous
  ) THEN RAISE EXCEPTION 'ANONYMOUS_AUTH_ACCOUNT_OWNER_READ_FAILED'; END IF;
END;
$$;
RESET ROLE;

DO $$
BEGIN
  IF (SELECT count(*)
      FROM ledger.kingston_operation_receipts
      WHERE player_id IN (
        '00000000-0000-4000-8000-000000001001',
        '00000000-0000-4000-8000-000000001003',
        '00000000-0000-4000-8000-000000001010'
      )) <> 6 THEN
    RAISE EXCEPTION 'UNEXPECTED_KINGSTON_RECEIPT_COUNT';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE entry_type = 'design_release'
        AND player_id = '00000000-0000-4000-8000-000000001001') <> 1 THEN
    RAISE EXCEPTION 'DESIGN_LEDGER_DUPLICATED';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE entry_type = 'idle_income_settlement'
        AND idempotency_key = '00000000-0000-4000-8000-00000000a040') <> 1 THEN
    RAISE EXCEPTION 'IDLE_LEDGER_DUPLICATED';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE entry_type = 'first_store_open'
        AND idempotency_key = '00000000-0000-4000-8000-00000000a031') <> 1 THEN
    RAISE EXCEPTION 'STORE_LEDGER_DUPLICATED';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE entry_type = 'founder_house_funds'
        AND idempotency_key = '00000000-0000-4000-8000-00000000a010') <> 1 THEN
    RAISE EXCEPTION 'FOUNDER_LEDGER_DUPLICATED';
  END IF;
END;
$$;

SELECT pass('Kingston API authority contract completed without a database violation');
SELECT * FROM finish();
ROLLBACK;
