-- GDD v8 §§4–6, 18.5–18.6, 19.2, 21–22.
-- Gate A Wave 2A: a deliberately bounded Kingston capsule foundation.
--
-- This migration extends the existing reviewed mutation convention only:
-- Flutter -> capsule-foundation Edge Function -> api RPC wrapper -> private
-- authority function.  It has no sampling, manufacturing, release, reward,
-- score, Hype, progression, or market outcome path.

ALTER TABLE ledger.kingston_operation_receipts
  DROP CONSTRAINT IF EXISTS kingston_operation_receipts_operation_check;
ALTER TABLE ledger.kingston_operation_receipts
  ADD CONSTRAINT kingston_operation_receipts_operation_check
  CHECK (operation IN (
    'founder_trial',
    'design_intent',
    'first_store',
    'idle_settlement',
    'progression_event',
    'player_report',
    'capsule_foundation'
  ));

CREATE TABLE private.kingston_capsules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- A Founder owns one Kingston House in the current Gate A model.  This
  -- key is resolved from the verified auth identity; it is never client input.
  house_player_id UUID NOT NULL UNIQUE
    REFERENCES public.players(id) ON DELETE RESTRICT,
  founder_specialization TEXT NOT NULL
    CHECK (founder_specialization IN ('artisan', 'architect')),
  stage TEXT NOT NULL DEFAULT 'brief_draft'
    CHECK (stage IN (
      'brief_draft',
      'brief_confirmed',
      'hero_piece_complete',
      'commercial_anchor_complete',
      'experimental_piece_complete',
      'readiness_confirmed',
      'sampling_unavailable'
    )),
  brief JSONB NOT NULL DEFAULT '{}'::JSONB,
  readiness JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
  CHECK (jsonb_typeof(brief) = 'object'),
  CHECK (jsonb_typeof(readiness) = 'object')
);

CREATE TABLE private.kingston_capsule_looks (
  capsule_id UUID NOT NULL REFERENCES private.kingston_capsules(id)
    ON DELETE RESTRICT,
  role TEXT NOT NULL CHECK (role IN (
    'hero_piece',
    'commercial_anchor',
    'experimental_piece'
  )),
  grammar JSONB,
  completed_at TIMESTAMPTZ,
  PRIMARY KEY (capsule_id, role),
  CHECK (grammar IS NULL OR jsonb_typeof(grammar) = 'object')
);

ALTER TABLE private.kingston_capsules ENABLE ROW LEVEL SECURITY;
ALTER TABLE private.kingston_capsule_looks ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON private.kingston_capsules, private.kingston_capsule_looks
  FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON private.kingston_capsules,
  private.kingston_capsule_looks TO service_role;

CREATE OR REPLACE FUNCTION private.capsule_state_receipt(
  p_capsule_id UUID,
  p_idempotency_key UUID,
  p_rule_version TEXT,
  p_status TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_capsule private.kingston_capsules%ROWTYPE;
  v_looks JSONB;
BEGIN
  SELECT * INTO v_capsule
  FROM private.kingston_capsules AS capsule
  WHERE capsule.id = p_capsule_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'CAPSULE_STATE_MISSING'; END IF;

  SELECT pg_catalog.jsonb_agg(
    pg_catalog.jsonb_build_object(
      'role', look.role,
      'grammar', look.grammar,
      'completed_at', look.completed_at
    ) ORDER BY CASE look.role
      WHEN 'hero_piece' THEN 1
      WHEN 'commercial_anchor' THEN 2
      WHEN 'experimental_piece' THEN 3
    END
  ) INTO v_looks
  FROM private.kingston_capsule_looks AS look
  WHERE look.capsule_id = p_capsule_id;

  RETURN pg_catalog.jsonb_build_object(
    'receipt_version', p_rule_version,
    'operation', 'capsule_foundation',
    'status', p_status,
    'idempotency_key', p_idempotency_key,
    'capsule', pg_catalog.jsonb_build_object(
      'stage', v_capsule.stage,
      'founder_specialization', v_capsule.founder_specialization,
      'brief', v_capsule.brief,
      'looks', COALESCE(v_looks, '[]'::JSONB),
      'readiness', v_capsule.readiness,
      'sampling', pg_catalog.jsonb_build_object(
        'status', CASE WHEN v_capsule.stage = 'sampling_unavailable'
          THEN 'unavailable' ELSE 'not_reached' END,
        'reason', CASE WHEN v_capsule.stage = 'sampling_unavailable'
          THEN 'Sampling is not part of the Kingston proof-of-fun build.'
          ELSE 'Complete the three-look capsule before this boundary.' END
      ),
      'created_at', v_capsule.created_at,
      'updated_at', v_capsule.updated_at
    )
  );
END;
$$;
REVOKE ALL ON FUNCTION private.capsule_state_receipt(UUID, UUID, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.capsule_state_receipt(UUID, UUID, TEXT, TEXT)
  TO service_role;

CREATE OR REPLACE FUNCTION private.authority_capsule_foundation_v1(
  p_auth_user_id UUID,
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
  v_player_id UUID;
  v_existing JSONB;
  v_result JSONB;
  v_capsule private.kingston_capsules%ROWTYPE;
  v_trial public.founder_trials%ROWTYPE;
  v_action TEXT := COALESCE(p_request_payload->>'action', '');
  v_role TEXT := COALESCE(p_request_payload->>'role', '');
  v_brief JSONB := p_request_payload->'brief';
  v_grammar JSONB := p_request_payload->'grammar';
  v_expected_role TEXT;
BEGIN
  IF p_rule_version <> 'kingston-capsule-foundation.v1' THEN
    RAISE EXCEPTION 'UNSUPPORTED_RULE_VERSION';
  END IF;
  IF p_auth_user_id IS NULL THEN RAISE EXCEPTION 'IDENTITY_SUBJECT_REQUIRED'; END IF;
  IF p_idempotency_key IS NULL THEN RAISE EXCEPTION 'IDEMPOTENCY_KEY_REQUIRED'; END IF;
  IF jsonb_typeof(COALESCE(p_request_payload, 'null'::JSONB)) <> 'object' THEN
    RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
  END IF;

  v_player_id := private.lock_kingston_actor(p_auth_user_id);
  v_existing := private.get_kingston_receipt(
    p_auth_user_id, 'capsule_foundation', p_idempotency_key, p_request_payload
  );
  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;

  SELECT * INTO v_trial
  FROM public.founder_trials AS trial
  WHERE trial.player_id = v_player_id
  FOR UPDATE;
  IF NOT FOUND OR v_trial.stage <> 'completed' OR
     v_trial.specialization NOT IN ('artisan', 'architect') THEN
    RAISE EXCEPTION 'FOUNDER_TRIAL_COMPLETION_REQUIRED';
  END IF;

  SELECT * INTO v_capsule
  FROM private.kingston_capsules AS capsule
  WHERE capsule.house_player_id = v_player_id
  FOR UPDATE;

  IF v_action = 'initialize' THEN
    IF (p_request_payload - ARRAY['action']) <> '{}'::JSONB THEN
      RAISE EXCEPTION 'INVALID_REQUEST_PAYLOAD';
    END IF;
    IF NOT FOUND THEN
      INSERT INTO private.kingston_capsules(
        house_player_id, founder_specialization
      ) VALUES (v_player_id, v_trial.specialization)
      RETURNING * INTO v_capsule;
      INSERT INTO private.kingston_capsule_looks(capsule_id, role) VALUES
        (v_capsule.id, 'hero_piece'),
        (v_capsule.id, 'commercial_anchor'),
        (v_capsule.id, 'experimental_piece');
      v_result := private.capsule_state_receipt(
        v_capsule.id, p_idempotency_key, p_rule_version, 'initialized'
      );
    ELSE
      v_result := private.capsule_state_receipt(
        v_capsule.id, p_idempotency_key, p_rule_version, 'restored'
      );
    END IF;
  ELSE
    IF NOT FOUND THEN RAISE EXCEPTION 'CAPSULE_STATE_MISSING'; END IF;

    IF v_action = 'save_brief' THEN
      IF (p_request_payload - ARRAY['action', 'brief']) <> '{}'::JSONB OR
         v_capsule.stage <> 'brief_draft' OR
         jsonb_typeof(COALESCE(v_brief, 'null'::JSONB)) <> 'object' OR
         (v_brief - ARRAY[
           'title', 'narrative', 'target_audience', 'house_code',
           'palette_direction', 'material_direction'
         ]) <> '{}'::JSONB OR
         jsonb_typeof(v_brief->'title') <> 'string' OR
         char_length(v_brief->>'title') NOT BETWEEN 2 AND 48 OR
         jsonb_typeof(v_brief->'narrative') <> 'string' OR
         char_length(v_brief->>'narrative') NOT BETWEEN 12 AND 240 OR
         v_brief->>'target_audience' NOT IN ('kingston_creatives', 'city_evenings') OR
         v_brief->>'house_code' NOT IN ('tailored_radiance', 'soft_structure') OR
         v_brief->>'palette_direction' NOT IN ('ivory_obsidian', 'kingston_blue_ivory') OR
         v_brief->>'material_direction' NOT IN ('cotton_twill', 'linen_blend') THEN
        RAISE EXCEPTION 'INVALID_COLLECTION_BRIEF';
      END IF;
      UPDATE private.kingston_capsules
      SET brief = v_brief, stage = 'brief_confirmed', updated_at = clock_timestamp()
      WHERE id = v_capsule.id
      RETURNING * INTO v_capsule;
      v_result := private.capsule_state_receipt(
        v_capsule.id, p_idempotency_key, p_rule_version, 'brief_confirmed'
      );
    ELSIF v_action = 'save_look' THEN
      IF (p_request_payload - ARRAY['action', 'role', 'grammar']) <> '{}'::JSONB OR
         jsonb_typeof(COALESCE(v_grammar, 'null'::JSONB)) <> 'object' OR
         (v_grammar - ARRAY['silhouette', 'material', 'palette', 'construction']) <> '{}'::JSONB OR
         v_grammar->>'silhouette' NOT IN ('column', 'draped', 'structured') OR
         v_grammar->>'material' NOT IN ('cotton_twill', 'linen_blend') OR
         v_grammar->>'palette' NOT IN ('ivory_obsidian', 'kingston_blue_ivory') OR
         v_grammar->>'construction' NOT IN ('straight_seam', 'soft_drape', 'sharp_panel') THEN
        RAISE EXCEPTION 'INVALID_LOOK_GRAMMAR';
      END IF;
      v_expected_role := CASE v_capsule.stage
        WHEN 'brief_confirmed' THEN 'hero_piece'
        WHEN 'hero_piece_complete' THEN 'commercial_anchor'
        WHEN 'commercial_anchor_complete' THEN 'experimental_piece'
        ELSE NULL
      END;
      IF v_expected_role IS NULL OR v_role <> v_expected_role THEN
        RAISE EXCEPTION 'CAPSULE_LOOK_ORDER_INVALID';
      END IF;
      UPDATE private.kingston_capsule_looks
      SET grammar = v_grammar, completed_at = clock_timestamp()
      WHERE capsule_id = v_capsule.id AND role = v_role;
      UPDATE private.kingston_capsules
      SET stage = CASE v_role
          WHEN 'hero_piece' THEN 'hero_piece_complete'
          WHEN 'commercial_anchor' THEN 'commercial_anchor_complete'
          ELSE 'experimental_piece_complete'
        END,
        updated_at = clock_timestamp()
      WHERE id = v_capsule.id
      RETURNING * INTO v_capsule;
      v_result := private.capsule_state_receipt(
        v_capsule.id, p_idempotency_key, p_rule_version, 'look_confirmed'
      );
    ELSIF v_action = 'evaluate_readiness' THEN
      IF (p_request_payload - ARRAY['action']) <> '{}'::JSONB OR
         v_capsule.stage <> 'experimental_piece_complete' THEN
        RAISE EXCEPTION 'CAPSULE_READINESS_UNAVAILABLE';
      END IF;
      IF (SELECT count(*) FROM private.kingston_capsule_looks AS look
          WHERE look.capsule_id = v_capsule.id AND look.grammar IS NOT NULL) <> 3 THEN
        RAISE EXCEPTION 'CAPSULE_LOOKS_INCOMPLETE';
      END IF;
      UPDATE private.kingston_capsules
      SET stage = 'sampling_unavailable',
          readiness = jsonb_build_object(
            'status', 'ready',
            'version', p_rule_version,
            'causes', jsonb_build_array(
              'Founder Trial complete',
              'Collection Brief confirmed',
              'Hero Piece confirmed',
              'Commercial Anchor confirmed',
              'Experimental Piece confirmed'
            )
          ),
          updated_at = clock_timestamp()
      WHERE id = v_capsule.id
      RETURNING * INTO v_capsule;
      v_result := private.capsule_state_receipt(
        v_capsule.id, p_idempotency_key, p_rule_version, 'readiness_confirmed'
      );
    ELSE
      RAISE EXCEPTION 'INVALID_CAPSULE_ACTION';
    END IF;
  END IF;

  RETURN private.record_kingston_receipt(
    p_auth_user_id, v_player_id, 'capsule_foundation', p_idempotency_key,
    p_request_payload, p_rule_version, v_result
  );
END;
$$;
REVOKE ALL ON FUNCTION private.authority_capsule_foundation_v1(
  UUID, UUID, JSONB, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION private.authority_capsule_foundation_v1(
  UUID, UUID, JSONB, TEXT
) TO service_role;

CREATE OR REPLACE FUNCTION api.server_capsule_foundation_intent_v1(
  p_auth_user_id UUID,
  p_idempotency_key UUID,
  p_request_payload JSONB,
  p_rule_version TEXT
)
RETURNS JSONB
LANGUAGE sql
SECURITY INVOKER
SET search_path = ''
AS $$
  SELECT private.authority_capsule_foundation_v1(
    p_auth_user_id, p_idempotency_key, p_request_payload, p_rule_version
  );
$$;
REVOKE ALL ON FUNCTION api.server_capsule_foundation_intent_v1(
  UUID, UUID, JSONB, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION api.server_capsule_foundation_intent_v1(
  UUID, UUID, JSONB, TEXT
) TO service_role;

COMMENT ON TABLE private.kingston_capsules IS
  'Gate A Kingston capsule state. One active capsule per verified Founder House; no sampling or release authority.';
COMMENT ON TABLE private.kingston_capsule_looks IS
  'Exactly three canonical Wave 2A look slots. Values are bounded server-side and contain no score or reward inputs.';
