-- GDD v8 §§4–6, 18.5–18.6, 19.2, 21–22.
-- Disposable-local proof for the Gate A Wave 2A capsule contract. It leaves
-- no fixture behind and proves only the verified Founder may advance the
-- server-owned state machine.

BEGIN;

SELECT plan(1);

SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', TRUE);

DO $$
DECLARE
  v_owner UUID := '00000000-0000-4000-8000-00000000ca01';
  v_stranger UUID := '00000000-0000-4000-8000-00000000ca02';
  v_first JSONB;
  v_replay JSONB;
  v_brief JSONB := jsonb_build_object(
    'title', 'Port Royal After Dark',
    'narrative', 'A precise Kingston capsule that balances ceremony with ease.',
    'target_audience', 'kingston_creatives',
    'house_code', 'tailored_radiance',
    'palette_direction', 'kingston_blue_ivory',
    'material_direction', 'linen_blend'
  );
  v_hero JSONB := jsonb_build_object(
    'silhouette', 'draped', 'material', 'linen_blend',
    'palette', 'kingston_blue_ivory', 'construction', 'soft_drape'
  );
  v_anchor JSONB := jsonb_build_object(
    'silhouette', 'structured', 'material', 'cotton_twill',
    'palette', 'ivory_obsidian', 'construction', 'sharp_panel'
  );
  v_experimental JSONB := jsonb_build_object(
    'silhouette', 'column', 'material', 'linen_blend',
    'palette', 'kingston_blue_ivory', 'construction', 'straight_seam'
  );
BEGIN
  INSERT INTO public.players(id, brand_name, path, hq_city, onboarding_complete)
  VALUES
    (v_owner, 'Capsule Owner', 'designer', 'kingston', TRUE),
    (v_stranger, 'Capsule Stranger', 'mogul', 'kingston', TRUE);
  INSERT INTO private.auth_player_identities(auth_user_id, player_id)
  VALUES (v_owner, v_owner), (v_stranger, v_stranger);
  INSERT INTO public.founder_trials(
    player_id, stage, specialization, result, completed_at
  ) VALUES
    (v_owner, 'completed', 'artisan', '{}'::JSONB, clock_timestamp()),
    (v_stranger, 'completed', 'architect', '{}'::JSONB, clock_timestamp());

  v_first := api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb01',
    jsonb_build_object('action', 'initialize'),
    'kingston-capsule-foundation.v1'
  );
  IF v_first->>'status' <> 'initialized' OR
     v_first #>> '{capsule,stage}' <> 'brief_draft' OR
     jsonb_array_length(v_first #> '{capsule,looks}') <> 3 OR
     v_first #>> '{capsule,founder_specialization}' <> 'artisan' THEN
    RAISE EXCEPTION 'CAPSULE_INITIALIZATION_FAILED';
  END IF;
  v_replay := api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb01',
    jsonb_build_object('action', 'initialize'),
    'kingston-capsule-foundation.v1'
  );
  IF v_first IS DISTINCT FROM v_replay THEN
    RAISE EXCEPTION 'CAPSULE_EXACT_REPLAY_CHANGED';
  END IF;
  BEGIN
    PERFORM api.server_capsule_foundation_intent_v1(
      v_owner, '00000000-0000-4000-8000-00000000cb01',
      jsonb_build_object('action', 'evaluate_readiness'),
      'kingston-capsule-foundation.v1'
    );
    RAISE EXCEPTION 'CAPSULE_CONFLICTING_REPLAY_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'CAPSULE_CONFLICTING_REPLAY_ACCEPTED' OR
       SQLERRM NOT LIKE '%IDEMPOTENCY_KEY_CONFLICT%' THEN RAISE; END IF;
  END;
  BEGIN
    PERFORM api.server_capsule_foundation_intent_v1(
      v_stranger, '00000000-0000-4000-8000-00000000cb02',
      jsonb_build_object(
        'action', 'save_brief', 'capsule_id', v_owner, 'brief', v_brief
      ),
      'kingston-capsule-foundation.v1'
    );
    RAISE EXCEPTION 'FOREIGN_CAPSULE_FIELD_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'FOREIGN_CAPSULE_FIELD_ACCEPTED' OR
       SQLERRM NOT LIKE '%CAPSULE_STATE_MISSING%' THEN RAISE; END IF;
  END;

  PERFORM api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb03',
    jsonb_build_object('action', 'save_brief', 'brief', v_brief),
    'kingston-capsule-foundation.v1'
  );
  BEGIN
    PERFORM api.server_capsule_foundation_intent_v1(
      v_owner, '00000000-0000-4000-8000-00000000cb04',
      jsonb_build_object(
        'action', 'save_look', 'role', 'commercial_anchor', 'grammar', v_anchor
      ),
      'kingston-capsule-foundation.v1'
    );
    RAISE EXCEPTION 'OUT_OF_ORDER_LOOK_ACCEPTED';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'OUT_OF_ORDER_LOOK_ACCEPTED' OR
       SQLERRM NOT LIKE '%CAPSULE_LOOK_ORDER_INVALID%' THEN RAISE; END IF;
  END;
  PERFORM api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb05',
    jsonb_build_object('action', 'save_look', 'role', 'hero_piece', 'grammar', v_hero),
    'kingston-capsule-foundation.v1'
  );
  PERFORM api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb06',
    jsonb_build_object('action', 'save_look', 'role', 'commercial_anchor', 'grammar', v_anchor),
    'kingston-capsule-foundation.v1'
  );
  PERFORM api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb07',
    jsonb_build_object('action', 'save_look', 'role', 'experimental_piece', 'grammar', v_experimental),
    'kingston-capsule-foundation.v1'
  );
  v_first := api.server_capsule_foundation_intent_v1(
    v_owner, '00000000-0000-4000-8000-00000000cb08',
    jsonb_build_object('action', 'evaluate_readiness'),
    'kingston-capsule-foundation.v1'
  );
  IF v_first->>'status' <> 'readiness_confirmed' OR
     v_first #>> '{capsule,stage}' <> 'sampling_unavailable' OR
     v_first #>> '{capsule,readiness,status}' <> 'ready' OR
     v_first #>> '{capsule,sampling,status}' <> 'unavailable' OR
     (SELECT count(*) FROM private.kingston_capsule_looks WHERE grammar IS NOT NULL) <> 3 THEN
    RAISE EXCEPTION 'CAPSULE_READINESS_OR_BOUNDARY_FAILED';
  END IF;
  IF EXISTS (
    SELECT 1 FROM ledger.economy_ledger WHERE player_id = v_owner
  ) OR EXISTS (
    SELECT 1 FROM ledger.reward_issuance WHERE player_id = v_owner
  ) THEN
    RAISE EXCEPTION 'CAPSULE_ISSUED_UNAPPROVED_ECONOMIC_OUTCOME';
  END IF;
END;
$$;

RESET ROLE;

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000ca01', TRUE);
SELECT set_config('request.jwt.claim.role', 'authenticated', TRUE);
DO $$
BEGIN
  BEGIN
    PERFORM 1 FROM private.kingston_capsules;
    RAISE EXCEPTION 'CLIENT_PRIVATE_CAPSULE_READ_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
  BEGIN
    PERFORM api.server_capsule_foundation_intent_v1(
      '00000000-0000-4000-8000-00000000ca01',
      '00000000-0000-4000-8000-00000000cb09',
      jsonb_build_object('action', 'initialize'),
      'kingston-capsule-foundation.v1'
    );
    RAISE EXCEPTION 'CLIENT_CAPSULE_WRAPPER_EXECUTION_SUCCEEDED';
  EXCEPTION WHEN insufficient_privilege THEN NULL;
  END;
END;
$$;
RESET ROLE;

SELECT pass('capsule foundation preserves ordered owner-only state, exact replay, and the sampling boundary');
SELECT * FROM finish();
ROLLBACK;
