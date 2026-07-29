-- GDD v8 §19: design progression is settled by the server-owned API path.
-- This retains the former rank-progression regression coverage while proving
-- the retired direct release function cannot be used as a client authority.

BEGIN;

SELECT plan(4);

SELECT ok(
  to_regprocedure('public.edge_drop_design(uuid,uuid,text[],text,text,text)') IS NULL,
  'the retired direct drop function is absent from the public authority surface'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'api.server_design_intent_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ),
  'authenticated clients cannot execute the server design wrapper directly'
);
SELECT ok(
  has_function_privilege(
    'service_role',
    'api.server_design_intent_v1(uuid,uuid,jsonb,text)',
    'EXECUTE'
  ),
  'only the server role can execute the design settlement wrapper'
);

SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', TRUE);

DO $$
DECLARE
  v_player UUID := gen_random_uuid();
  v_design UUID := gen_random_uuid();
  v_session UUID := gen_random_uuid();
  v_key UUID := gen_random_uuid();
  v_result JSONB;
  v_replay JSONB;
  v_xp_delta INTEGER;
  v_total_xp INTEGER;
  v_release_count INTEGER;
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
  INSERT INTO public.players(
    id, brand_name, path, hq_city, brand_rank, total_xp, onboarding_complete
  ) VALUES (v_player, 'Progression Contract', 'designer', 'kingston', 1, 950, TRUE);
  INSERT INTO private.auth_player_identities(auth_user_id, player_id)
  VALUES (v_player, v_player);
  INSERT INTO public.brand_state(player_id, heat, followers)
  VALUES (v_player, 50, 0);
  INSERT INTO public.designs(id, player_id, name, session_type, status)
  VALUES (v_design, v_player, 'Threshold Alpha', 'quick_sketch', 'complete');
  INSERT INTO public.atelier_sessions(
    id, player_id, fabric_color_hex, style_tags, minted_at, design_id
  ) VALUES (
    v_session, v_player, 'FAF7F0', ARRAY['minimalist']::TEXT[],
    clock_timestamp(), v_design
  );

  v_result := api.server_design_intent_v1(
    v_player,
    v_key,
    jsonb_build_object(
      'action', 'release',
      'design_id', v_design,
      'release_intent', 'publish_first_drop',
      'blueprint', v_blueprint,
      'vex_opt_in', FALSE
    ),
    'kingston-design-intent.v1'
  );
  v_replay := api.server_design_intent_v1(
    v_player,
    v_key,
    jsonb_build_object(
      'action', 'release',
      'design_id', v_design,
      'release_intent', 'publish_first_drop',
      'blueprint', v_blueprint,
      'vex_opt_in', FALSE
    ),
    'kingston-design-intent.v1'
  );
  v_xp_delta := (v_result->>'xp_delta')::INTEGER;
  SELECT total_xp INTO v_total_xp FROM public.players WHERE id = v_player;
  SELECT count(*) INTO v_release_count
  FROM ledger.economy_ledger
  WHERE player_id = v_player AND entry_type = 'design_release';

  IF v_xp_delta <= 0 OR v_total_xp <> 950 + v_xp_delta OR
     v_replay IS DISTINCT FROM v_result OR v_release_count <> 1 THEN
    RAISE EXCEPTION 'SERVER_DESIGN_PROGRESSION_OR_REPLAY_FAILED';
  END IF;
END;
$$;

RESET ROLE;
SELECT pass('one authoritative design release applies progression exactly once');
SELECT * FROM finish();

ROLLBACK;
