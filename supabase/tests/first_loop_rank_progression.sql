BEGIN;
SELECT plan(1);
SELECT set_config('request.jwt.claim.role', 'service_role', true);

DO $$
DECLARE
  v_player UUID := gen_random_uuid();
  v_design UUID := gen_random_uuid();
  v_clamped_player UUID := gen_random_uuid();
  v_clamped_design UUID := gen_random_uuid();
  v_first RECORD;
  v_duplicate RECORD;
  v_clamped RECORD;
  v_rank INT;
  v_total_xp INT;
  v_count INT;
BEGIN
  INSERT INTO public.players(
    id, brand_name, path, hq_city, brand_rank, total_xp
  )
  VALUES (
    v_player, 'Rank Test', 'designer', 'Paris', 1, 950
  );

  INSERT INTO public.brand_state(player_id, heat, followers)
  VALUES (v_player, 50, 0);

  INSERT INTO public.designs(
    id, player_id, owner_id, name, session_type, status, hype_score,
    is_alpha, fabric_data
  )
  VALUES (
    v_design, v_player, v_player, 'Threshold Alpha', 'quick_sketch',
    'complete', 80, TRUE, '{"color_hex":"FAF7F0"}'::JSONB
  );

  SELECT *
  INTO v_first
  FROM public.edge_drop_design(
    v_player,
    v_design,
    ARRAY['minimal'],
    NULL,
    NULL,
    NULL
  );

  IF v_first.xp_delta <> 80 THEN
    RAISE EXCEPTION 'drop XP delta mismatch';
  END IF;
  IF v_first.current_rank <> 2 THEN
    RAISE EXCEPTION 'rank threshold did not increment';
  END IF;
  IF v_first.rank_progress_percent <> 3.0 THEN
    RAISE EXCEPTION 'rank progress percent mismatch';
  END IF;
  IF v_first.rank_up_occurred IS NOT TRUE THEN
    RAISE EXCEPTION 'rank_up_occurred was not true';
  END IF;

  SELECT brand_rank, total_xp
  INTO v_rank, v_total_xp
  FROM public.players
  WHERE id = v_player;

  IF v_rank <> 2 OR v_total_xp <> 1030 THEN
    RAISE EXCEPTION 'player row rank/xp not updated';
  END IF;

  SELECT *
  INTO v_duplicate
  FROM public.edge_drop_design(
    v_player,
    v_design,
    ARRAY['minimal'],
    NULL,
    NULL,
    NULL
  );

  IF v_duplicate.xp_delta <> 0 THEN
    RAISE EXCEPTION 'duplicate drop duplicated XP';
  END IF;
  IF v_duplicate.rank_up_occurred IS NOT FALSE THEN
    RAISE EXCEPTION 'duplicate drop reported rank up';
  END IF;

  SELECT COUNT(*)
  INTO v_count
  FROM public.garment_drops
  WHERE design_id = v_design;

  IF v_count <> 1 THEN
    RAISE EXCEPTION 'duplicate drop created extra garment drop';
  END IF;

  INSERT INTO public.players(
    id, brand_name, path, hq_city, brand_rank, total_xp
  )
  VALUES (
    v_clamped_player, 'Clamp Test', 'designer', 'Paris', 10, 9950
  );

  INSERT INTO public.brand_state(player_id, heat, followers)
  VALUES (v_clamped_player, 50, 0);

  INSERT INTO public.designs(
    id, player_id, owner_id, name, session_type, status, hype_score,
    is_alpha, fabric_data
  )
  VALUES (
    v_clamped_design, v_clamped_player, v_clamped_player, 'Clamp Alpha',
    'quick_sketch', 'complete', 100, TRUE, '{"color_hex":"FAF7F0"}'::JSONB
  );

  SELECT *
  INTO v_clamped
  FROM public.edge_drop_design(
    v_clamped_player,
    v_clamped_design,
    ARRAY['minimal'],
    NULL,
    NULL,
    NULL
  );

  IF v_clamped.current_rank <> 10 THEN
    RAISE EXCEPTION 'rank did not clamp at 10';
  END IF;
  IF v_clamped.rank_progress_percent <> 100.0 THEN
    RAISE EXCEPTION 'rank 10 progress did not remain bounded';
  END IF;
END;
$$;

SELECT pass('first loop Rank 1-10 progression is server-authoritative');
SELECT * FROM finish();

ROLLBACK;
