-- Security Hardening Audit Pass 1 execution.
-- All privileged functions are service-role-only and use server time.

CREATE TABLE IF NOT EXISTS public.security_idempotency_keys (
  actor_id UUID NOT NULL,
  action TEXT NOT NULL,
  idempotency_key UUID NOT NULL,
  response JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (actor_id, action, idempotency_key)
);
ALTER TABLE public.security_idempotency_keys ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.security_idempotency_keys FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.security_idempotency_keys TO service_role;

CREATE TABLE IF NOT EXISTS public.mini_game_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  game_key TEXT NOT NULL CHECK (
    game_key IN (
      'supplier_raid',
      'flash_sale',
      'hostile_takeover',
      'price_war',
      'power_move_combo',
      'staff_rally'
    )
  ),
  talent_id UUID,
  challenge JSONB NOT NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  claimed_at TIMESTAMPTZ,
  result_key TEXT,
  reward JSONB,
  CHECK (expires_at > started_at)
);
CREATE INDEX IF NOT EXISTS mini_game_attempts_player_game_idx
  ON public.mini_game_attempts(player_id, game_key, started_at DESC);
ALTER TABLE public.mini_game_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.mini_game_attempts FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.mini_game_attempts TO service_role;

CREATE TABLE IF NOT EXISTS public.atelier_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  fabric_color_hex TEXT NOT NULL CHECK (fabric_color_hex ~ '^[0-9A-F]{6}$'),
  style_tags TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 minutes'),
  minted_at TIMESTAMPTZ,
  design_id UUID REFERENCES public.designs(id),
  CHECK (cardinality(style_tags) BETWEEN 1 AND 3)
);
CREATE INDEX IF NOT EXISTS atelier_sessions_player_idx
  ON public.atelier_sessions(player_id, started_at DESC);
ALTER TABLE public.atelier_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.atelier_sessions FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.atelier_sessions TO service_role;

CREATE TABLE IF NOT EXISTS public.privileged_job_runs (
  job_key TEXT NOT NULL,
  period_key TEXT NOT NULL,
  claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (job_key, period_key)
);
ALTER TABLE public.privileged_job_runs ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.privileged_job_runs FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.privileged_job_runs TO service_role;

CREATE TABLE IF NOT EXISTS public.webhook_receipts (
  source TEXT NOT NULL,
  event_id TEXT NOT NULL,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (source, event_id)
);
ALTER TABLE public.webhook_receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.webhook_receipts FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.webhook_receipts TO service_role;

ALTER TABLE public.iap_receipts
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS account_token UUID,
  ADD COLUMN IF NOT EXISTS environment TEXT,
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'credited';

CREATE UNIQUE INDEX IF NOT EXISTS iap_receipts_platform_transaction_idx
  ON public.iap_receipts(platform, transaction_id)
  WHERE transaction_id IS NOT NULL;

CREATE OR REPLACE FUNCTION public.edge_claim_job_run(
  p_job_key TEXT,
  p_period_key TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  INSERT INTO public.privileged_job_runs(job_key, period_key)
  VALUES (LEFT(p_job_key, 80), LEFT(p_period_key, 80))
  ON CONFLICT DO NOTHING;
  RETURN FOUND;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_claim_job_run(TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_claim_job_run(TEXT, TEXT) TO service_role;

CREATE OR REPLACE FUNCTION public.edge_claim_webhook_event(
  p_source TEXT,
  p_event_id TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;
  IF LENGTH(TRIM(p_event_id)) < 8 OR LENGTH(p_event_id) > 200 THEN
    RAISE EXCEPTION 'INVALID_EVENT_ID';
  END IF;

  INSERT INTO public.webhook_receipts(source, event_id)
  VALUES (LEFT(p_source, 40), p_event_id)
  ON CONFLICT DO NOTHING;
  RETURN FOUND;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_claim_webhook_event(TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_claim_webhook_event(TEXT, TEXT)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_start_mini_game(
  p_player_id UUID,
  p_game_key TEXT,
  p_talent_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_attempt public.mini_game_attempts%ROWTYPE;
  v_challenge JSONB;
  v_cooldown INTERVAL;
  v_duration INTERVAL;
  v_sequence TEXT[];
  v_tiers INT[];
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;
  IF p_game_key NOT IN (
    'supplier_raid', 'flash_sale', 'hostile_takeover',
    'price_war', 'power_move_combo', 'staff_rally'
  ) THEN
    RAISE EXCEPTION 'INVALID_GAME_KEY';
  END IF;

  v_cooldown := CASE p_game_key
    WHEN 'power_move_combo' THEN INTERVAL '72 hours'
    WHEN 'hostile_takeover' THEN INTERVAL '24 hours'
    WHEN 'staff_rally' THEN INTERVAL '1 hour'
    ELSE INTERVAL '5 minutes'
  END;
  v_duration := CASE p_game_key
    WHEN 'flash_sale' THEN INTERVAL '75 seconds'
    WHEN 'supplier_raid' THEN INTERVAL '45 seconds'
    WHEN 'hostile_takeover' THEN INTERVAL '40 seconds'
    ELSE INTERVAL '25 seconds'
  END;

  IF EXISTS (
    SELECT 1
    FROM public.mini_game_attempts a
    WHERE a.player_id = p_player_id
      AND a.game_key = p_game_key
      AND a.claimed_at IS NOT NULL
      AND a.claimed_at > NOW() - v_cooldown
  ) THEN
    RAISE EXCEPTION 'MINI_GAME_COOLDOWN';
  END IF;

  IF (
    SELECT COUNT(*)
    FROM public.mini_game_attempts a
    WHERE a.player_id = p_player_id
      AND a.started_at >= CURRENT_DATE
  ) >= 20 THEN
    RAISE EXCEPTION 'DAILY_ATTEMPT_LIMIT';
  END IF;

  IF p_game_key = 'staff_rally' THEN
    IF p_talent_id IS NULL OR NOT EXISTS (
      SELECT 1 FROM public.player_roster pr
      WHERE pr.player_id = p_player_id AND pr.talent_id = p_talent_id
    ) THEN
      RAISE EXCEPTION 'TALENT_NOT_OWNED';
    END IF;
  END IF;

  IF p_game_key = 'power_move_combo' THEN
    SELECT ARRAY_AGG(symbol ORDER BY random())
    INTO v_sequence
    FROM unnest(ARRAY['trend', 'shield', 'bolt', 'star']) AS symbol;
    v_challenge := jsonb_build_object('sequence', to_jsonb(v_sequence));
  ELSIF p_game_key = 'flash_sale' THEN
    SELECT ARRAY_AGG(1 + FLOOR(random() * 3)::INT)
    INTO v_tiers FROM generate_series(1, 14);
    v_challenge := jsonb_build_object('tiers', to_jsonb(v_tiers));
  ELSIF p_game_key = 'supplier_raid' THEN
    SELECT ARRAY_AGG(FLOOR(random() * 4)::INT)
    INTO v_tiers FROM generate_series(1, 12);
    v_challenge := jsonb_build_object('cards', to_jsonb(v_tiers));
  ELSIF p_game_key = 'hostile_takeover' THEN
    v_challenge := jsonb_build_object('required_taps', 20);
  ELSIF p_game_key = 'price_war' THEN
    v_challenge := jsonb_build_object('rounds', 3, 'minimum', 0.4, 'maximum', 0.6);
  ELSE
    v_challenge := jsonb_build_object('required_hits', 4, 'minimum', 0.8);
  END IF;

  INSERT INTO public.mini_game_attempts(
    player_id, game_key, talent_id, challenge, expires_at
  )
  VALUES (p_player_id, p_game_key, p_talent_id, v_challenge, NOW() + v_duration)
  RETURNING * INTO v_attempt;

  RETURN jsonb_build_object(
    'attempt_id', v_attempt.id,
    'game_key', v_attempt.game_key,
    'challenge', v_attempt.challenge,
    'started_at', v_attempt.started_at,
    'expires_at', v_attempt.expires_at
  );
END;
$$;
REVOKE ALL ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_start_mini_game(UUID, TEXT, UUID)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_claim_mini_game(
  p_player_id UUID,
  p_attempt_id UUID,
  p_proof JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_attempt public.mini_game_attempts%ROWTYPE;
  v_reward INT := 0;
  v_valid BOOLEAN := FALSE;
  v_result TEXT := 'loss';
  v_values JSONB;
  v_required INT;
  v_response JSONB;
  v_match_count INT := 0;
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  SELECT * INTO v_attempt
  FROM public.mini_game_attempts a
  WHERE a.id = p_attempt_id AND a.player_id = p_player_id
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'ATTEMPT_NOT_FOUND'; END IF;
  IF v_attempt.claimed_at IS NOT NULL THEN RAISE EXCEPTION 'ATTEMPT_ALREADY_CLAIMED'; END IF;
  IF v_attempt.expires_at < NOW() THEN RAISE EXCEPTION 'ATTEMPT_EXPIRED'; END IF;
  IF NOW() < v_attempt.started_at + INTERVAL '1 second' THEN
    RAISE EXCEPTION 'ATTEMPT_TOO_FAST';
  END IF;

  IF v_attempt.game_key = 'price_war' THEN
    v_values := COALESCE(p_proof->'tap_values', '[]'::JSONB);
    SELECT COUNT(*) = 3
      AND BOOL_AND((value #>> '{}')::NUMERIC BETWEEN 0.4 AND 0.6)
    INTO v_valid FROM jsonb_array_elements(v_values) AS value;
    v_reward := CASE WHEN v_valid THEN 200 ELSE 0 END;
    v_result := CASE WHEN v_valid THEN 'standard_win' ELSE 'loss' END;
  ELSIF v_attempt.game_key = 'power_move_combo' THEN
    v_valid := COALESCE(p_proof->'sequence', '[]'::JSONB)
      = v_attempt.challenge->'sequence'
      AND NOW() >= v_attempt.started_at + INTERVAL '3 seconds';
    v_result := CASE WHEN v_valid THEN 'standard_win' ELSE 'loss' END;
  ELSIF v_attempt.game_key = 'hostile_takeover' THEN
    v_required := (v_attempt.challenge->>'required_taps')::INT;
    v_valid := COALESCE((p_proof->>'tap_count')::INT, 0) >= v_required
      AND NOW() >= v_attempt.started_at + INTERVAL '5 seconds';
    v_reward := CASE WHEN v_valid THEN 5000 ELSE 0 END;
    v_result := CASE WHEN v_valid THEN 'complete_takeover' ELSE 'loss' END;
  ELSIF v_attempt.game_key = 'supplier_raid' THEN
    SELECT COUNT(DISTINCT (value #>> '{}')::INT)
    INTO v_match_count
    FROM jsonb_array_elements(COALESCE(p_proof->'claimed_indices', '[]'::JSONB)) value
    WHERE (value #>> '{}')::INT BETWEEN 0
      AND jsonb_array_length(v_attempt.challenge->'cards') - 1;
    v_valid := v_match_count >= 6;
    v_reward := CASE WHEN v_match_count = 12 THEN 500 WHEN v_valid THEN 250 ELSE 0 END;
    v_result := CASE WHEN v_match_count = 12 THEN 'perfect_win'
      WHEN v_valid THEN 'standard_win' ELSE 'loss' END;
  ELSIF v_attempt.game_key = 'flash_sale' THEN
    SELECT COUNT(DISTINCT (entry->>'index')::INT)
    INTO v_match_count
    FROM jsonb_array_elements(COALESCE(p_proof->'matches', '[]'::JSONB)) entry
    WHERE (entry->>'index')::INT BETWEEN 0
        AND jsonb_array_length(v_attempt.challenge->'tiers') - 1
      AND (entry->>'tier')::INT =
        (v_attempt.challenge->'tiers'->>((entry->>'index')::INT))::INT;
    v_valid := v_match_count >= 10;
    v_reward := CASE WHEN v_match_count >= 14 THEN 300 WHEN v_valid THEN 150 ELSE 0 END;
    v_result := CASE WHEN v_match_count >= 14 THEN 'perfect_win'
      WHEN v_valid THEN 'standard_win' ELSE 'loss' END;
  ELSE
    IF COALESCE(p_proof->>'outcome', '') = 'loss' THEN
      v_valid := FALSE;
      v_result := 'loss';
    ELSE
      SELECT COUNT(*) >= 4
        AND BOOL_AND((value #>> '{}')::NUMERIC > 0.8)
      INTO v_valid
      FROM jsonb_array_elements(COALESCE(p_proof->'hit_values', '[]'::JSONB)) value;
      v_result := CASE WHEN v_valid THEN 'stamina_reset' ELSE 'loss' END;
    END IF;
  END IF;

  IF v_reward > 0 THEN
    UPDATE public.brand_state
    SET total_revenue = total_revenue + v_reward, updated_at = NOW()
    WHERE player_id = p_player_id;
  END IF;

  IF v_attempt.game_key = 'power_move_combo' AND v_valid THEN
    UPDATE public.brand_state
    SET pending_power_move_multiplier = 1.5,
        power_move_expires_at = NOW() + INTERVAL '24 hours',
        updated_at = NOW()
    WHERE player_id = p_player_id;
  END IF;

  IF v_attempt.game_key = 'staff_rally' THEN
    UPDATE public.player_roster
    SET stamina = CASE WHEN v_valid THEN 100 ELSE stamina END,
        last_stamina_refresh = CASE WHEN v_valid THEN NOW() ELSE last_stamina_refresh END,
        gala_cooldown_until = CASE WHEN v_valid THEN gala_cooldown_until
          ELSE NOW() + INTERVAL '24 hours' END
    WHERE player_id = p_player_id AND talent_id = v_attempt.talent_id;
  END IF;

  v_response := jsonb_build_object(
    'success', TRUE,
    'result_key', v_result,
    'reward', jsonb_build_object('currency', v_reward),
    'server_time', NOW()
  );

  IF v_attempt.game_key = 'staff_rally' AND NOT v_valid THEN
    v_response := v_response || jsonb_build_object(
      'cooldown_until', NOW() + INTERVAL '24 hours'
    );
  END IF;

  UPDATE public.mini_game_attempts
  SET claimed_at = NOW(), result_key = v_result, reward = v_response->'reward'
  WHERE id = v_attempt.id;

  RETURN v_response;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_claim_mini_game(UUID, UUID, JSONB)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_start_atelier_session(
  p_player_id UUID,
  p_fabric_color_hex TEXT,
  p_style_tags TEXT[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_session public.atelier_sessions%ROWTYPE;
  v_color TEXT;
  v_tags TEXT[];
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  v_color := UPPER(REGEXP_REPLACE(COALESCE(p_fabric_color_hex, ''), '[^0-9A-Fa-f]', '', 'g'));
  IF LENGTH(v_color) <> 6 THEN v_color := 'FAF7F0'; END IF;

  SELECT ARRAY_AGG(tag ORDER BY ordinal)
  INTO v_tags
  FROM (
    SELECT DISTINCT ON (LOWER(TRIM(raw_tag)))
      LOWER(TRIM(raw_tag)) AS tag, ordinal
    FROM unnest(COALESCE(p_style_tags, '{}'::TEXT[]))
      WITH ORDINALITY AS input(raw_tag, ordinal)
    WHERE LENGTH(TRIM(raw_tag)) BETWEEN 1 AND 48
    ORDER BY LOWER(TRIM(raw_tag)), ordinal
    LIMIT 3
  ) normalized;
  IF COALESCE(cardinality(v_tags), 0) = 0 THEN
    v_tags := ARRAY['atelier'];
  END IF;

  INSERT INTO public.atelier_sessions(player_id, fabric_color_hex, style_tags)
  VALUES (p_player_id, v_color, v_tags)
  RETURNING * INTO v_session;

  RETURN jsonb_build_object(
    'session_id', v_session.id,
    'started_at', v_session.started_at,
    'expires_at', v_session.expires_at
  );
END;
$$;
REVOKE ALL ON FUNCTION public.edge_start_atelier_session(UUID, TEXT, TEXT[])
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_start_atelier_session(UUID, TEXT, TEXT[])
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_update_atelier_session(
  p_player_id UUID,
  p_session_id UUID,
  p_fabric_color_hex TEXT,
  p_style_tags TEXT[]
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_color TEXT;
  v_tags TEXT[];
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;
  v_color := UPPER(REGEXP_REPLACE(COALESCE(p_fabric_color_hex, ''), '[^0-9A-Fa-f]', '', 'g'));
  IF LENGTH(v_color) <> 6 THEN v_color := 'FAF7F0'; END IF;
  SELECT ARRAY_AGG(tag ORDER BY ordinal)
  INTO v_tags
  FROM (
    SELECT DISTINCT ON (LOWER(TRIM(raw_tag)))
      LOWER(TRIM(raw_tag)) AS tag, ordinal
    FROM unnest(COALESCE(p_style_tags, '{}'::TEXT[]))
      WITH ORDINALITY AS input(raw_tag, ordinal)
    WHERE LENGTH(TRIM(raw_tag)) BETWEEN 1 AND 48
    ORDER BY LOWER(TRIM(raw_tag)), ordinal
    LIMIT 3
  ) normalized;
  IF COALESCE(cardinality(v_tags), 0) = 0 THEN v_tags := ARRAY['atelier']; END IF;

  UPDATE public.atelier_sessions
  SET fabric_color_hex = v_color, style_tags = v_tags
  WHERE id = p_session_id AND player_id = p_player_id
    AND minted_at IS NULL AND expires_at > NOW();
  RETURN FOUND;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_update_atelier_session(UUID, UUID, TEXT, TEXT[])
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_update_atelier_session(UUID, UUID, TEXT, TEXT[])
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_mint_atelier_session(
  p_player_id UUID,
  p_session_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_session public.atelier_sessions%ROWTYPE;
  v_design public.designs%ROWTYPE;
  v_logistics INT := 1;
  v_sustainability INT := 0;
  v_material NUMERIC;
  v_aesthetic NUMERIC;
  v_trend NUMERIC := 1.0;
  v_talent_bonus NUMERIC := 0;
  v_hype NUMERIC;
  v_name TEXT;
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  SELECT * INTO v_session
  FROM public.atelier_sessions s
  WHERE s.id = p_session_id AND s.player_id = p_player_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'ATELIER_SESSION_NOT_FOUND'; END IF;

  IF v_session.design_id IS NOT NULL THEN
    SELECT * INTO v_design FROM public.designs WHERE id = v_session.design_id;
    RETURN to_jsonb(v_design);
  END IF;
  IF v_session.expires_at < NOW() THEN RAISE EXCEPTION 'ATELIER_SESSION_EXPIRED'; END IF;
  IF NOW() < v_session.started_at + INTERVAL '5 seconds' THEN
    RAISE EXCEPTION 'ATELIER_INTERACTION_REQUIRED';
  END IF;

  SELECT COALESCE(bs.logistics_level, 1), COALESCE(bs.sustainability_tier, 0)
  INTO v_logistics, v_sustainability
  FROM public.brand_state bs WHERE bs.player_id = p_player_id;

  v_material := LEAST(95, 55 + v_logistics * 5 + v_sustainability * 4);
  v_aesthetic := LEAST(90, 60 + cardinality(v_session.style_tags) * 6);

  SELECT COALESCE(MAX(tt.multiplier), 1.0)
  INTO v_trend
  FROM public.trend_tsunamis tt
  WHERE tt.expires_at > NOW()
    AND LOWER(tt.tag_name) = ANY(v_session.style_tags);

  SELECT LEAST(
    25,
    COALESCE(SUM((LEAST(GREATEST(tp.base_hype_multiplier, 1.0), 2.0) - 1.0) * 10), 0)
  )
  INTO v_talent_bonus
  FROM public.player_roster pr
  JOIN public.talent_pool tp ON tp.id = pr.talent_id
  WHERE pr.player_id = p_player_id AND tp.tier = 'sovereign';

  v_hype := ROUND(
    LEAST(100, LEAST(100, v_aesthetic * LEAST(v_trend, 2.0))
      * (v_material / 100.0) + v_talent_bonus),
    2
  );
  v_name := INITCAP(v_session.style_tags[1]) || ' Alpha ' ||
    SUBSTRING(v_session.id::TEXT, 1, 4);

  INSERT INTO public.designs(
    player_id, owner_id, name, session_type, status, hype_score,
    is_alpha, fabric_data
  )
  VALUES (
    p_player_id, p_player_id, v_name, 'quick_sketch', 'complete', v_hype,
    TRUE, jsonb_build_object(
      'color_hex', v_session.fabric_color_hex,
      'material_quality', v_material,
      'aesthetic_alignment', v_aesthetic,
      'style_tags', to_jsonb(v_session.style_tags),
      'trend_multiplier', v_trend,
      'atelier_session_id', v_session.id
    )
  )
  RETURNING * INTO v_design;

  UPDATE public.atelier_sessions
  SET minted_at = NOW(), design_id = v_design.id
  WHERE id = v_session.id;

  RETURN to_jsonb(v_design);
END;
$$;
REVOKE ALL ON FUNCTION public.edge_mint_atelier_session(UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_mint_atelier_session(UUID, UUID)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_upgrade_store_atomic(
  p_player_id UUID,
  p_store_id UUID,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_store public.stores%ROWTYPE;
  v_brand public.brand_state%ROWTYPE;
  v_cost NUMERIC;
  v_response JSONB;
BEGIN
  IF auth.role() <> 'service_role' THEN RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED'; END IF;

  SELECT response INTO v_response
  FROM public.security_idempotency_keys
  WHERE actor_id = p_player_id AND action = 'upgrade_store'
    AND idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_response; END IF;

  SELECT * INTO v_store FROM public.stores
  WHERE id = p_store_id AND player_id = p_player_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'STORE_NOT_FOUND_OR_NOT_OWNED'; END IF;
  SELECT * INTO v_brand FROM public.brand_state
  WHERE player_id = p_player_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;

  v_cost := ROUND(500.0 * POWER(1.5, v_store.tier), 4);
  IF v_brand.total_revenue < v_cost THEN RAISE EXCEPTION 'INSUFFICIENT_CAPITAL'; END IF;

  UPDATE public.stores
  SET tier = tier + 1,
      revenue_per_hour = ROUND(revenue_per_hour * 1.4, 4)
  WHERE id = v_store.id;
  UPDATE public.brand_state
  SET total_revenue = total_revenue - v_cost,
      idle_revenue_per_hour = (
        SELECT COALESCE(SUM(s.revenue_per_hour), 0)
        FROM public.stores s WHERE s.player_id = p_player_id
      ),
      updated_at = NOW()
  WHERE player_id = p_player_id;

  SELECT jsonb_build_object(
    'success', TRUE,
    'new_tier', s.tier,
    'new_revenue_per_hour', s.revenue_per_hour,
    'new_total_revenue', bs.total_revenue,
    'new_idle_revenue_per_hour', bs.idle_revenue_per_hour
  )
  INTO v_response
  FROM public.stores s
  JOIN public.brand_state bs ON bs.player_id = s.player_id
  WHERE s.id = v_store.id;

  INSERT INTO public.security_idempotency_keys
  VALUES (p_player_id, 'upgrade_store', p_idempotency_key, v_response, NOW());
  RETURN v_response;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_upgrade_store_atomic(UUID, UUID, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_upgrade_store_atomic(UUID, UUID, UUID)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_maison_donate_atomic(
  p_player_id UUID,
  p_amount NUMERIC,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_maison_id UUID;
  v_balance NUMERIC;
  v_response JSONB;
BEGIN
  IF auth.role() <> 'service_role' THEN RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED'; END IF;
  IF p_amount <= 0 OR p_amount <> FLOOR(p_amount) THEN RAISE EXCEPTION 'INVALID_AMOUNT'; END IF;

  SELECT response INTO v_response
  FROM public.security_idempotency_keys
  WHERE actor_id = p_player_id AND action = 'maison_donate'
    AND idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_response; END IF;

  SELECT mm.maison_id INTO v_maison_id
  FROM public.maison_members mm
  WHERE mm.player_id = p_player_id FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'NOT_A_MEMBER'; END IF;

  SELECT total_revenue INTO v_balance FROM public.brand_state
  WHERE player_id = p_player_id FOR UPDATE;
  IF v_balance < p_amount THEN RAISE EXCEPTION 'INSUFFICIENT_CAPITAL'; END IF;

  UPDATE public.brand_state
  SET total_revenue = total_revenue - p_amount, updated_at = NOW()
  WHERE player_id = p_player_id
  RETURNING total_revenue INTO v_balance;

  INSERT INTO public.maison_treasury_ledger(maison_id, player_id, amount)
  VALUES (v_maison_id, p_player_id, p_amount);

  v_response := jsonb_build_object(
    'success', TRUE, 'new_balance', v_balance,
    'maison_id', v_maison_id, 'donated', p_amount
  );
  INSERT INTO public.security_idempotency_keys
  VALUES (p_player_id, 'maison_donate', p_idempotency_key, v_response, NOW());
  RETURN v_response;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_maison_donate_atomic(UUID, NUMERIC, UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_maison_donate_atomic(UUID, NUMERIC, UUID)
  TO service_role;

CREATE OR REPLACE FUNCTION public.edge_redeem_iap_atomic(
  p_player_id UUID,
  p_platform TEXT,
  p_transaction_id TEXT,
  p_receipt_hash TEXT,
  p_product_id TEXT,
  p_luxe_grant INT,
  p_account_token UUID,
  p_environment TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_balance INT;
  v_existing public.iap_receipts%ROWTYPE;
BEGIN
  IF auth.role() <> 'service_role' THEN RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED'; END IF;
  IF p_account_token IS DISTINCT FROM p_player_id THEN RAISE EXCEPTION 'ACCOUNT_MISMATCH'; END IF;
  IF p_luxe_grant <= 0 OR LENGTH(p_transaction_id) < 3 THEN RAISE EXCEPTION 'INVALID_PURCHASE'; END IF;

  SELECT * INTO v_existing FROM public.iap_receipts
  WHERE platform = p_platform AND transaction_id = p_transaction_id;
  IF FOUND THEN
    IF v_existing.player_id <> p_player_id THEN RAISE EXCEPTION 'TRANSACTION_OWNERSHIP_MISMATCH'; END IF;
    RETURN jsonb_build_object(
      'success', TRUE, 'already_credited', TRUE,
      'luxe_granted', v_existing.luxe_granted
    );
  END IF;

  PERFORM 1 FROM public.brand_state WHERE player_id = p_player_id FOR UPDATE;
  SELECT * INTO v_existing FROM public.iap_receipts
  WHERE platform = p_platform AND transaction_id = p_transaction_id;
  IF FOUND THEN
    IF v_existing.player_id <> p_player_id THEN RAISE EXCEPTION 'TRANSACTION_OWNERSHIP_MISMATCH'; END IF;
    RETURN jsonb_build_object(
      'success', TRUE, 'already_credited', TRUE,
      'luxe_granted', v_existing.luxe_granted
    );
  END IF;
  INSERT INTO public.iap_receipts(
    receipt_hash, player_id, product_id, platform, luxe_granted,
    transaction_id, account_token, environment, status
  )
  VALUES (
    p_receipt_hash, p_player_id, p_product_id, p_platform, p_luxe_grant,
    p_transaction_id, p_account_token, LEFT(COALESCE(p_environment, 'unknown'), 30),
    'credited'
  );

  UPDATE public.brand_state
  SET luxe_tokens = luxe_tokens + p_luxe_grant, updated_at = NOW()
  WHERE player_id = p_player_id
  RETURNING luxe_tokens INTO v_balance;

  RETURN jsonb_build_object(
    'success', TRUE, 'already_credited', FALSE,
    'luxe_granted', p_luxe_grant, 'new_balance', v_balance
  );
END;
$$;
REVOKE ALL ON FUNCTION public.edge_redeem_iap_atomic(
  UUID, TEXT, TEXT, TEXT, TEXT, INT, UUID, TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_redeem_iap_atomic(
  UUID, TEXT, TEXT, TEXT, TEXT, INT, UUID, TEXT
) TO service_role;

CREATE OR REPLACE FUNCTION public.protect_player_roster_gameplay_fields()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF auth.role() <> 'service_role' AND (
    NEW.stamina IS DISTINCT FROM OLD.stamina
    OR NEW.last_stamina_refresh IS DISTINCT FROM OLD.last_stamina_refresh
    OR NEW.gala_cooldown_until IS DISTINCT FROM OLD.gala_cooldown_until
  ) THEN
    RAISE EXCEPTION 'PROTECTED_GAMEPLAY_FIELDS';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.protect_player_roster_gameplay_fields()
  FROM PUBLIC, anon, authenticated;
DROP TRIGGER IF EXISTS protect_player_roster_gameplay_fields
  ON public.player_roster;
CREATE TRIGGER protect_player_roster_gameplay_fields
BEFORE UPDATE ON public.player_roster
FOR EACH ROW EXECUTE FUNCTION public.protect_player_roster_gameplay_fields();

REVOKE INSERT, UPDATE, DELETE ON public.designs FROM anon, authenticated;
GRANT SELECT ON public.designs TO authenticated;

COMMENT ON TABLE public.mini_game_attempts IS
  'Service-owned deterministic mini-game challenges and one-time claims.';
COMMENT ON TABLE public.atelier_sessions IS
  'Service-owned Atelier sessions; Hype inputs are derived from database state.';
