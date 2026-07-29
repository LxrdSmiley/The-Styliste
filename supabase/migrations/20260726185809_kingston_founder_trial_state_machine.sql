-- GDD v8 §§4–6, 18.5–18.6, 19.2, 22.
-- Complete the smallest Kingston Founder Trial with server-owned, replay-safe
-- transitions. The client supplies only bounded interaction choices; it never
-- supplies an actor id, score, reward, or path ownership.
-- FOUNDER_TRIAL_ADVANCE_AVAILABLE

CREATE OR REPLACE FUNCTION private.authority_founder_trial_v1(
  p_auth_user_id UUID,
  p_actor_is_anonymous BOOLEAN,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_existing JSONB;
  v_player_id UUID;
  v_player public.players%ROWTYPE;
  v_trial public.founder_trials%ROWTYPE;
  v_action TEXT := COALESCE(p_request_payload->>'action', '');
  v_next_stage TEXT := COALESCE(p_request_payload->>'next_stage', '');
  v_brand_name TEXT;
  v_artisan_choice TEXT;
  v_architect_choice TEXT;
  v_response_choice TEXT;
  v_specialization TEXT;
  v_result JSONB;
  v_next_action TEXT;
  v_starting_house_funds CONSTANT NUMERIC(14, 2) := 100000;
BEGIN
  IF p_rule_version <> 'kingston-founder-trial.v1' THEN
    RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION';
  END IF;
  IF p_auth_user_id IS NULL THEN RAISE EXCEPTION 'IDENTITY_SUBJECT_REQUIRED'; END IF;
  IF p_idempotency_key IS NULL THEN RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED'; END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;

  PERFORM pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('kingston:' || p_auth_user_id::TEXT, 0)
  );
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'founder_trial', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;

  IF v_action = 'initialize' THEN
    IF (p_request_payload - ARRAY['action', 'brand_name']) <> '{}'::JSONB THEN
      RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
    END IF;
    v_brand_name := btrim(COALESCE(p_request_payload->>'brand_name', ''));
    IF char_length(v_brand_name) NOT BETWEEN 2 AND 40 THEN
      RAISE EXCEPTION 'INVALID_BRAND_NAME';
    END IF;

    SELECT identity.player_id INTO v_player_id
    FROM private.auth_player_identities AS identity
    WHERE identity.auth_user_id = p_auth_user_id
      AND identity.status = 'active'
    FOR UPDATE;

    IF FOUND THEN
      SELECT * INTO v_player FROM public.players AS player
      WHERE player.id = v_player_id FOR UPDATE;
      SELECT * INTO v_trial FROM public.founder_trials AS trial
      WHERE trial.player_id = v_player_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'FOUNDER_TRIAL_STATE_MISSING'; END IF;
      v_next_action := CASE v_trial.stage
        WHEN 'shared_starter_garment' THEN 'complete_artisan_sample'
        WHEN 'artisan_sample' THEN 'complete_architect_sample'
        WHEN 'architect_sample' THEN 'reveal_shared_result'
        WHEN 'result_visible' THEN 'choose_revision_or_business_response'
        WHEN 'revision_or_business_response' THEN 'select_founder_path'
        ELSE 'open_hq'
      END;
      v_result := jsonb_build_object(
        'receipt_version', p_rule_version,
        'operation', 'founder_trial',
        'status', 'resumed',
        'idempotency_key', p_idempotency_key,
        'player_id', v_player_id,
        'stage', v_trial.stage,
        'specialization', v_trial.specialization,
        'next_action', v_next_action,
        'onboarding_complete', v_player.onboarding_complete
      );
      RETURN private.record_kingston_receipt(
        p_auth_user_id, v_player_id, 'founder_trial', p_idempotency_key,
        p_request_payload, p_rule_version, v_result
      );
    END IF;

    IF EXISTS (SELECT 1 FROM public.players AS player WHERE player.id = p_auth_user_id) THEN
      RAISE EXCEPTION 'PLAYER_IDENTITY_CONFLICT';
    END IF;

    -- `players.path` remains non-null for compatibility with existing read
    -- projections. Founder-trial specialization is the authoritative choice
    -- until it is selected below, after which this placeholder is replaced.
    INSERT INTO public.players(
      id, brand_name, path, hq_city, onboarding_complete, is_anonymous
    ) VALUES (
      p_auth_user_id, v_brand_name, 'designer', 'kingston', FALSE,
      COALESCE(p_actor_is_anonymous, FALSE)
    );
    INSERT INTO private.auth_player_identities(auth_user_id, player_id)
    VALUES (p_auth_user_id, p_auth_user_id);
    INSERT INTO public.brand_state(
      player_id, total_revenue, house_funds,
      lifetime_gross_revenue, lifetime_costs, lifetime_net_result,
      hype_score, idle_revenue_per_hour,
      idle_base_revenue_per_hour, idle_store_revenue_per_hour,
      idle_automation_revenue_per_hour, luxe_tokens
    ) VALUES (
      p_auth_user_id, 0, v_starting_house_funds,
      0, 0, 0, 0, 0, 0, 0, 0, 0
    );
    INSERT INTO ledger.economy_ledger(
      player_id, entry_type, rule_version, idempotency_key,
      amount, balance_after, cause
    ) VALUES (
      p_auth_user_id, 'founder_house_funds', p_rule_version,
      p_idempotency_key, v_starting_house_funds, v_starting_house_funds,
      jsonb_build_object('source', 'founder_trial', 'city', 'kingston')
    );
    INSERT INTO public.founder_trials(player_id, result) VALUES (
      p_auth_user_id,
      jsonb_build_object(
        'shared_garment', 'Kingston starter garment',
        'path_status', 'unselected',
        'rule_version', p_rule_version
      )
    );
    v_player_id := p_auth_user_id;
    v_result := jsonb_build_object(
      'receipt_version', p_rule_version,
      'operation', 'founder_trial',
      'status', 'initialized',
      'idempotency_key', p_idempotency_key,
      'player_id', v_player_id,
      'stage', 'shared_starter_garment',
      'shared_garment', 'Kingston starter garment',
      'next_action', 'complete_artisan_sample',
      'onboarding_complete', FALSE
    );
  ELSIF v_action = 'advance' THEN
    v_player_id := private.lock_kingston_actor(p_auth_user_id);
    SELECT * INTO v_trial FROM public.founder_trials AS trial
    WHERE trial.player_id = v_player_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'FOUNDER_TRIAL_STATE_MISSING'; END IF;

    IF v_next_stage = 'complete_artisan_sample' THEN
      IF (p_request_payload - ARRAY['action', 'next_stage', 'artisan_choice']) <> '{}'::JSONB OR
         v_trial.stage <> 'shared_starter_garment' THEN
        RAISE EXCEPTION 'FOUNDER_TRIAL_STAGE_INVALID';
      END IF;
      v_artisan_choice := COALESCE(p_request_payload->>'artisan_choice', '');
      IF v_artisan_choice NOT IN ('draped_bodice', 'structured_bodice') THEN
        RAISE EXCEPTION 'INVALID_ARTISAN_CHOICE';
      END IF;
      UPDATE public.founder_trials
      SET stage = 'artisan_sample',
          result = result || jsonb_build_object('artisan_choice', v_artisan_choice),
          updated_at = clock_timestamp()
      WHERE player_id = v_player_id
      RETURNING * INTO v_trial;
      v_next_action := 'complete_architect_sample';
    ELSIF v_next_stage = 'complete_architect_sample' THEN
      IF (p_request_payload - ARRAY['action', 'next_stage', 'architect_choice']) <> '{}'::JSONB OR
         v_trial.stage <> 'artisan_sample' THEN
        RAISE EXCEPTION 'FOUNDER_TRIAL_STAGE_INVALID';
      END IF;
      v_architect_choice := COALESCE(p_request_payload->>'architect_choice', '');
      IF v_architect_choice NOT IN ('limited_run', 'neighborhood_run') THEN
        RAISE EXCEPTION 'INVALID_ARCHITECT_CHOICE';
      END IF;
      UPDATE public.founder_trials
      SET stage = 'architect_sample',
          result = result || jsonb_build_object('architect_choice', v_architect_choice),
          updated_at = clock_timestamp()
      WHERE player_id = v_player_id
      RETURNING * INTO v_trial;
      v_next_action := 'reveal_shared_result';
    ELSIF v_next_stage = 'reveal_shared_result' THEN
      IF (p_request_payload - ARRAY['action', 'next_stage']) <> '{}'::JSONB OR
         v_trial.stage <> 'architect_sample' THEN
        RAISE EXCEPTION 'FOUNDER_TRIAL_STAGE_INVALID';
      END IF;
      UPDATE public.founder_trials
      SET stage = 'result_visible', updated_at = clock_timestamp()
      WHERE player_id = v_player_id
      RETURNING * INTO v_trial;
      v_next_action := 'choose_revision_or_business_response';
    ELSIF v_next_stage = 'choose_revision_or_business_response' THEN
      IF (p_request_payload - ARRAY['action', 'next_stage', 'response_choice']) <> '{}'::JSONB OR
         v_trial.stage <> 'result_visible' THEN
        RAISE EXCEPTION 'FOUNDER_TRIAL_STAGE_INVALID';
      END IF;
      v_response_choice := COALESCE(p_request_payload->>'response_choice', '');
      IF v_response_choice NOT IN ('refine_silhouette', 'adjust_run_plan') THEN
        RAISE EXCEPTION 'INVALID_RESPONSE_CHOICE';
      END IF;
      UPDATE public.founder_trials
      SET stage = 'revision_or_business_response',
          result = result || jsonb_build_object('response_choice', v_response_choice),
          updated_at = clock_timestamp()
      WHERE player_id = v_player_id
      RETURNING * INTO v_trial;
      v_next_action := 'select_founder_path';
    ELSIF v_next_stage = 'select_founder_path' THEN
      IF (p_request_payload - ARRAY['action', 'next_stage', 'specialization']) <> '{}'::JSONB OR
         v_trial.stage <> 'revision_or_business_response' THEN
        RAISE EXCEPTION 'FOUNDER_TRIAL_STAGE_INVALID';
      END IF;
      v_specialization := COALESCE(p_request_payload->>'specialization', '');
      IF v_specialization NOT IN ('artisan', 'architect') THEN
        RAISE EXCEPTION 'INVALID_SPECIALIZATION';
      END IF;
      UPDATE public.players
      SET path = CASE v_specialization WHEN 'artisan' THEN 'designer' ELSE 'mogul' END,
          onboarding_complete = TRUE,
          last_active_at = clock_timestamp()
      WHERE id = v_player_id;
      UPDATE public.founder_trials
      SET stage = 'completed', specialization = v_specialization,
          result = result || jsonb_build_object(
            'specialization', v_specialization,
            'next_action', 'open_hq'
          ),
          updated_at = clock_timestamp(), completed_at = clock_timestamp()
      WHERE player_id = v_player_id
      RETURNING * INTO v_trial;
      v_next_action := 'open_hq';
    ELSE
      RAISE EXCEPTION 'INVALID_FOUNDER_TRIAL_STAGE';
    END IF;

    v_result := jsonb_build_object(
      'receipt_version', p_rule_version,
      'operation', 'founder_trial',
      'status', CASE WHEN v_trial.stage = 'completed' THEN 'completed' ELSE 'advanced' END,
      'idempotency_key', p_idempotency_key,
      'player_id', v_player_id,
      'stage', v_trial.stage,
      'specialization', v_trial.specialization,
      'result', v_trial.result,
      'next_action', v_next_action,
      'onboarding_complete', v_trial.stage = 'completed'
    );
  ELSE
    RAISE EXCEPTION 'INVALID_FOUNDER_TRIAL_ACTION';
  END IF;

  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'founder_trial', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;

REVOKE ALL ON FUNCTION private.authority_founder_trial_v1(
  UUID, BOOLEAN, UUID, JSONB, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.authority_founder_trial_v1(
  UUID, BOOLEAN, UUID, JSONB, TEXT
) TO service_role;
