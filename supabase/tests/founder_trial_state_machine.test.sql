-- GDD v8 §§4–6, 18.5–18.6, 19.2, 22.
-- Disposable-local contract proof for the bounded, server-owned Founder Trial.
-- The transaction rolls back all fixtures and receipts after the assertions.

BEGIN;

SELECT plan(1);

SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', TRUE);

DO $$
DECLARE
  v_artisan_id UUID := '00000000-0000-4000-8000-00000000b001';
  v_architect_id UUID := '00000000-0000-4000-8000-00000000c001';
  v_result JSONB;
  v_completion JSONB;
BEGIN
  -- Artisan account: initialization is replay-safe and admits no actor field.
  v_result := api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b101',
    jsonb_build_object('action', 'initialize', 'brand_name', 'Artisan House'),
    'kingston-founder-trial.v1'
  );
  IF v_result->>'stage' <> 'shared_starter_garment' THEN
    RAISE EXCEPTION 'FOUNDER_INITIAL_STAGE_FAILED';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE player_id = v_artisan_id AND entry_type = 'founder_house_funds') <> 1 THEN
    RAISE EXCEPTION 'FOUNDER_INITIAL_LEDGER_COUNT_FAILED';
  END IF;
  BEGIN
    PERFORM api.server_founder_trial_intent_v1(
      v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b102',
      jsonb_build_object(
        'action', 'advance',
        'next_stage', 'complete_artisan_sample',
        'artisan_choice', 'draped_bodice',
        'player_id', v_architect_id
      ),
      'kingston-founder-trial.v1'
    );
    RAISE EXCEPTION 'FORGED_FOUNDER_ACTOR_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'FORGED_FOUNDER_ACTOR_ACCEPTED' OR
       SQLERRM NOT LIKE '%FOUNDER_TRIAL_STAGE_INVALID%' THEN
      RAISE;
    END IF;
  END;

  PERFORM api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b103',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'complete_artisan_sample',
      'artisan_choice', 'draped_bodice'
    ),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b104',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'complete_architect_sample',
      'architect_choice', 'neighborhood_run'
    ),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b105',
    jsonb_build_object('action', 'advance', 'next_stage', 'reveal_shared_result'),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b106',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'choose_revision_or_business_response',
      'response_choice', 'refine_silhouette'
    ),
    'kingston-founder-trial.v1'
  );
  v_completion := api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b107',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'select_founder_path',
      'specialization', 'artisan'
    ),
    'kingston-founder-trial.v1'
  );
  IF v_completion->>'stage' <> 'completed' OR
     v_completion->>'specialization' <> 'artisan' OR
     v_completion->>'next_action' <> 'open_hq' OR
     NOT COALESCE((v_completion->>'onboarding_complete')::BOOLEAN, FALSE) THEN
    RAISE EXCEPTION 'ARTISAN_COMPLETION_RECEIPT_FAILED';
  END IF;
  IF api.server_founder_trial_intent_v1(
       v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b107',
       jsonb_build_object(
         'action', 'advance',
         'next_stage', 'select_founder_path',
         'specialization', 'artisan'
       ),
       'kingston-founder-trial.v1'
     ) IS DISTINCT FROM v_completion THEN
    RAISE EXCEPTION 'ARTISAN_COMPLETION_REPLAY_CHANGED';
  END IF;
  v_result := api.server_founder_trial_intent_v1(
    v_artisan_id, TRUE, '00000000-0000-4000-8000-00000000b108',
    jsonb_build_object('action', 'initialize', 'brand_name', 'Ignored Resume Name'),
    'kingston-founder-trial.v1'
  );
  IF v_result->>'status' <> 'resumed' OR v_result->>'stage' <> 'completed' THEN
    RAISE EXCEPTION 'RETURNING_FOUNDER_DID_NOT_RESUME';
  END IF;

  -- Architect account completes the same shared trial with the other valid path.
  PERFORM api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c101',
    jsonb_build_object('action', 'initialize', 'brand_name', 'Architect House'),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c102',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'complete_artisan_sample',
      'artisan_choice', 'structured_bodice'
    ),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c103',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'complete_architect_sample',
      'architect_choice', 'limited_run'
    ),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c104',
    jsonb_build_object('action', 'advance', 'next_stage', 'reveal_shared_result'),
    'kingston-founder-trial.v1'
  );
  PERFORM api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c105',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'choose_revision_or_business_response',
      'response_choice', 'adjust_run_plan'
    ),
    'kingston-founder-trial.v1'
  );
  v_result := api.server_founder_trial_intent_v1(
    v_architect_id, FALSE, '00000000-0000-4000-8000-00000000c106',
    jsonb_build_object(
      'action', 'advance',
      'next_stage', 'select_founder_path',
      'specialization', 'architect'
    ),
    'kingston-founder-trial.v1'
  );
  IF v_result->>'stage' <> 'completed' OR
     v_result->>'specialization' <> 'architect' THEN
    RAISE EXCEPTION 'ARCHITECT_COMPLETION_RECEIPT_FAILED';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.players
    WHERE id = v_artisan_id AND path = 'designer' AND onboarding_complete
  ) OR NOT EXISTS (
    SELECT 1 FROM public.players
    WHERE id = v_architect_id AND path = 'mogul' AND onboarding_complete
  ) THEN
    RAISE EXCEPTION 'FOUNDER_PATH_WAS_NOT_SERVER_CONFIRMED';
  END IF;
  IF (SELECT count(*) FROM ledger.economy_ledger
      WHERE player_id IN (v_artisan_id, v_architect_id)
        AND entry_type = 'founder_house_funds') <> 2 THEN
    RAISE EXCEPTION 'FOUNDER_RETRY_DUPLICATED_STARTING_LEDGER';
  END IF;
  IF (SELECT count(*) FROM ledger.reward_issuance
      WHERE player_id IN (v_artisan_id, v_architect_id)) <> 0 THEN
    RAISE EXCEPTION 'FOUNDER_TRIAL_ISSUED_UNAPPROVED_REWARD';
  END IF;
END;
$$;

RESET ROLE;
SELECT pass('bounded Founder Trial state machine preserves authority and replay invariants');
SELECT * FROM finish();
ROLLBACK;
