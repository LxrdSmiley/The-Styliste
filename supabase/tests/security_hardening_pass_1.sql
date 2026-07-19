BEGIN;
-- GDD v7 §§19.2–19.3 and §22: quarantined reward paths must fail closed,
-- remain replay-safe, and produce explicit acceptance evidence.
SELECT plan(15);
SELECT set_config('request.jwt.claim.role', 'service_role', true);

INSERT INTO public.players(id, brand_name, path, hq_city)
VALUES (
  '00000000-0000-4000-8000-00000000d101',
  'Security Test',
  'mogul',
  'Kingston'
);

INSERT INTO public.brand_state(player_id, total_revenue, logistics_level)
VALUES ('00000000-0000-4000-8000-00000000d101', 10000, 2);

CREATE TEMP TABLE mini_game_quarantine_snapshot AS
SELECT
  player.id AS player_id,
  player.total_xp,
  brand.total_revenue,
  brand.luxe_tokens,
  brand.hype_score,
  brand.current_inventory_value,
  (
    SELECT count(*)::BIGINT
    FROM public.mini_game_attempts AS attempt
    WHERE attempt.player_id = player.id
  ) AS reward_history_count
FROM public.players AS player
JOIN public.brand_state AS brand ON brand.player_id = player.id
WHERE player.id = '00000000-0000-4000-8000-00000000d101';

SELECT throws_ok(
  $$SELECT public.edge_start_mini_game(
      '00000000-0000-4000-8000-00000000d101',
      'price_war',
      NULL
    )$$,
  'P0001',
  'MINI_GAME_REWARDS_UNAVAILABLE',
  'mini-game start reports the approved quarantine response'
);

SELECT is(
  (SELECT total_revenue FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.total_revenue,
  'quarantined mini-game grants zero House Funds'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT luxe_tokens FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.luxe_tokens,
  'quarantined mini-game grants zero Luxe'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT total_xp FROM public.players WHERE id = snapshot.player_id),
  snapshot.total_xp,
  'quarantined mini-game grants zero XP'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT hype_score FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.hype_score,
  'quarantined mini-game grants zero Hype'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT current_inventory_value FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.current_inventory_value,
  'quarantined mini-game grants zero inventory'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (
    SELECT count(*)::BIGINT
    FROM public.mini_game_attempts AS attempt
    WHERE attempt.player_id = snapshot.player_id
  ),
  snapshot.reward_history_count,
  'quarantined mini-game creates zero reward history'
)
FROM mini_game_quarantine_snapshot AS snapshot;

SELECT throws_ok(
  $$SELECT public.edge_start_mini_game(
      '00000000-0000-4000-8000-00000000d101',
      'price_war',
      NULL
    )$$,
  'P0001',
  'MINI_GAME_REWARDS_UNAVAILABLE',
  'replayed mini-game start reports the same quarantine response'
);

SELECT is(
  (SELECT total_revenue FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.total_revenue,
  'replay grants zero House Funds'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT luxe_tokens FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.luxe_tokens,
  'replay grants zero Luxe'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT total_xp FROM public.players WHERE id = snapshot.player_id),
  snapshot.total_xp,
  'replay grants zero XP'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT hype_score FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.hype_score,
  'replay grants zero Hype'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (SELECT current_inventory_value FROM public.brand_state WHERE player_id = snapshot.player_id),
  snapshot.current_inventory_value,
  'replay grants zero inventory'
)
FROM mini_game_quarantine_snapshot AS snapshot;
SELECT is(
  (
    SELECT count(*)::BIGINT
    FROM public.mini_game_attempts AS attempt
    WHERE attempt.player_id = snapshot.player_id
  ),
  snapshot.reward_history_count,
  'replay creates zero reward history'
)
FROM mini_game_quarantine_snapshot AS snapshot;

DO $$
DECLARE
  v_player UUID := '00000000-0000-4000-8000-00000000d101';
  v_reported_player UUID := gen_random_uuid();
  v_other_reported_player UUID := gen_random_uuid();
  v_store UUID := gen_random_uuid();
  v_maison UUID := gen_random_uuid();
  v_session JSONB;
  v_result JSONB;
  v_session_id UUID;
  v_upgrade_key UUID := gen_random_uuid();
  v_donation_key UUID := gen_random_uuid();
  v_before NUMERIC;
  v_after NUMERIC;
  v_count INT;
BEGIN
  INSERT INTO public.players(id, brand_name, path, hq_city)
  VALUES (v_reported_player, 'Reported Security Test', 'designer', 'Paris');
  INSERT INTO public.players(id, brand_name, path, hq_city)
  VALUES (v_other_reported_player, 'Other Report Test', 'designer', 'London');
  INSERT INTO public.stores(id, player_id, type, city, tier, revenue_per_hour)
  VALUES (v_store, v_player, 'flagship', 'Kingston', 1, 100);
  INSERT INTO public.maisons(id, name, founder_id)
  VALUES (v_maison, 'Security Test Maison', v_player);
  INSERT INTO public.maison_members(maison_id, player_id, role)
  VALUES (v_maison, v_player, 'founder');

  BEGIN
    PERFORM public.edge_start_mini_game(v_player, 'supplier_raid', NULL);
    RAISE EXCEPTION 'retired supplier raid unexpectedly started';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%MINI_GAME_REWARDS_UNAVAILABLE%'
        AND SQLERRM NOT LIKE '%STANDALONE_GAME_RETIRED%' THEN
      RAISE;
    END IF;
  END;

  BEGIN
    INSERT INTO public.mini_game_attempts(
      player_id,
      game_key,
      challenge,
      expires_at
    )
    VALUES (
      v_player,
      'staff_rally',
      '{}'::JSONB,
      NOW() + INTERVAL '1 minute'
    );
    RAISE EXCEPTION 'retired staff rally attempt unexpectedly inserted';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%STANDALONE_GAME_RETIRED%' THEN RAISE; END IF;
  END;

  v_session := public.edge_start_atelier_session(
    v_player,
    'FAF7F0',
    ARRAY['minimal', 'future']
  );
  v_session_id := (v_session->>'session_id')::UUID;
  UPDATE public.atelier_sessions
  SET started_at = NOW() - INTERVAL '6 seconds'
  WHERE id = v_session_id;
  v_result := public.edge_mint_atelier_session(v_player, v_session_id);
  IF (v_result->>'hype_score')::NUMERIC NOT BETWEEN 0 AND 100 THEN
    RAISE EXCEPTION 'server hype out of bounds';
  END IF;
  IF (public.edge_mint_atelier_session(v_player, v_session_id)->>'id')
      <> (v_result->>'id') THEN
    RAISE EXCEPTION 'atelier mint is not idempotent';
  END IF;

  PERFORM public.edge_upgrade_store_atomic(v_player, v_store, v_upgrade_key);
  PERFORM public.edge_upgrade_store_atomic(v_player, v_store, v_upgrade_key);
  SELECT tier INTO v_count FROM public.stores WHERE id = v_store;
  IF v_count <> 2 THEN RAISE EXCEPTION 'store idempotency failed'; END IF;

  SELECT total_revenue INTO v_before FROM public.brand_state
  WHERE player_id = v_player;
  PERFORM public.edge_maison_donate_atomic(
    v_player, 100, v_donation_key
  );
  PERFORM public.edge_maison_donate_atomic(
    v_player, 100, v_donation_key
  );
  SELECT total_revenue INTO v_after FROM public.brand_state
  WHERE player_id = v_player;
  IF v_before - v_after <> 100 THEN
    RAISE EXCEPTION 'donation idempotency failed';
  END IF;
  SELECT COUNT(*) INTO v_count FROM public.maison_treasury_ledger
  WHERE player_id = v_player AND amount = 100;
  IF v_count <> 1 THEN RAISE EXCEPTION 'duplicate donation ledger row'; END IF;

  SELECT luxe_tokens INTO v_count FROM public.brand_state
  WHERE player_id = v_player;
  PERFORM public.edge_redeem_iap_atomic(
    v_player, 'ios', 'security-test-transaction',
    encode(digest(gen_random_uuid()::TEXT, 'sha256'), 'hex'),
    'initiates_cache', 100, v_player, 'sandbox'
  );
  PERFORM public.edge_redeem_iap_atomic(
    v_player, 'ios', 'security-test-transaction',
    encode(digest(gen_random_uuid()::TEXT, 'sha256'), 'hex'),
    'initiates_cache', 100, v_player, 'sandbox'
  );
  SELECT luxe_tokens - v_count INTO v_count FROM public.brand_state
  WHERE player_id = v_player;
  IF v_count <> 100 THEN RAISE EXCEPTION 'IAP idempotency failed'; END IF;

  UPDATE public.brand_state
  SET total_revenue = 1000,
      current_tarnish = 25,
      prestige_tokens = 10,
      kintsugi_level = 0
  WHERE player_id = v_player;
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
  PERFORM set_config('request.jwt.claim.sub', v_player::TEXT, true);
  PERFORM public.apply_kintsugi_repair();
  SELECT total_revenue INTO v_after FROM public.brand_state
  WHERE player_id = v_player;
  IF v_after <> 700 THEN RAISE EXCEPTION 'Kintsugi capital cost failed'; END IF;
  SELECT prestige_tokens INTO v_count FROM public.brand_state
  WHERE player_id = v_player;
  IF v_count <> 0 THEN RAISE EXCEPTION 'Kintsugi prestige cost failed'; END IF;
  SELECT current_tarnish + kintsugi_level INTO v_count
  FROM public.brand_state WHERE player_id = v_player;
  IF v_count <> 1 THEN RAISE EXCEPTION 'Kintsugi repair state failed'; END IF;

  INSERT INTO public.player_reports(
    reporter_id,
    reported_id,
    reported_player_id,
    reason,
    category,
    description
  )
  VALUES (
    v_player,
    v_reported_player,
    v_reported_player,
    'spam',
    'spam',
    'Security regression report'
  );

  BEGIN
    INSERT INTO public.player_reports(
      reporter_id,
      reported_id,
      reported_player_id,
      reason,
      category
    )
    VALUES (
      v_player,
      v_reported_player,
      v_reported_player,
      'spam',
      'spam'
    );
    RAISE EXCEPTION 'duplicate report unexpectedly succeeded';
  EXCEPTION WHEN OTHERS THEN
    IF SQLERRM NOT LIKE '%REPORT_RATE_LIMITED%' THEN RAISE; END IF;
  END;

  BEGIN
    INSERT INTO public.player_reports(
      reporter_id,
      reported_id,
      reported_player_id,
      reason,
      category
    )
    VALUES (
      v_player,
      v_other_reported_player,
      v_other_reported_player,
      'forged_category',
      'forged_category'
    );
    RAISE EXCEPTION 'invalid report category unexpectedly succeeded';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
END;
$$;

SELECT pass('security hardening pass 1 regression checks completed');
SELECT * FROM finish();

ROLLBACK;
