-- The Styliste vertical-slice foundation.
-- Server-owned first-store creation and first-week progression.
-- No client insert/update privilege is granted for either surface.

ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS audience TEXT NOT NULL DEFAULT 'balanced',
  ADD COLUMN IF NOT EXISTS price_tier TEXT NOT NULL DEFAULT 'signature',
  ADD COLUMN IF NOT EXISTS inventory_capacity INTEGER NOT NULL DEFAULT 24,
  ADD COLUMN IF NOT EXISTS operating_cost_per_hour NUMERIC(14, 4) NOT NULL DEFAULT 25,
  ADD COLUMN IF NOT EXISTS expected_demand_per_day NUMERIC(14, 4) NOT NULL DEFAULT 8,
  ADD COLUMN IF NOT EXISTS decision_made_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.brands_equity
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS stores_player_opened_idx
  ON public.stores(player_id, opened_at DESC);

CREATE TABLE IF NOT EXISTS public.player_progression_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  event_key TEXT NOT NULL,
  entity_id UUID,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE NULLS NOT DISTINCT (player_id, event_key, entity_id)
);

CREATE INDEX IF NOT EXISTS player_progression_events_player_idx
  ON public.player_progression_events(player_id, occurred_at DESC);

ALTER TABLE public.player_progression_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Progression events: read own" ON public.player_progression_events;
CREATE POLICY "Progression events: read own"
  ON public.player_progression_events FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = player_id);
REVOKE ALL ON TABLE public.player_progression_events
  FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT ON TABLE public.player_progression_events TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.player_progression_events
  TO service_role;

CREATE TABLE IF NOT EXISTS public.first_week_objectives (
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  objective_key TEXT NOT NULL,
  path TEXT NOT NULL CHECK (path IN ('designer', 'mogul', 'shared')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  completion_event_key TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
  completed_at TIMESTAMPTZ,
  source_event_id UUID,
  PRIMARY KEY (player_id, objective_key)
);

CREATE INDEX IF NOT EXISTS first_week_objectives_player_idx
  ON public.first_week_objectives(player_id, status, objective_key);

ALTER TABLE public.first_week_objectives ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "First week objectives: read own" ON public.first_week_objectives;
CREATE POLICY "First week objectives: read own"
  ON public.first_week_objectives FOR SELECT
  TO authenticated
  USING ((SELECT auth.uid()) = player_id);
REVOKE ALL ON TABLE public.first_week_objectives
  FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT ON TABLE public.first_week_objectives TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.first_week_objectives
  TO service_role;

INSERT INTO public.first_week_objectives
  (player_id, objective_key, path, title, description, completion_event_key)
SELECT p.id, x.objective_key, x.path, x.title, x.description, x.completion_event_key
FROM public.players p
JOIN (
  VALUES
    ('shared_feed_participation', 'shared', 'Enter the Global Feed', 'Publish or participate in the Feed so the world can react.', 'global_feed_participation'),
    ('designer_first_design', 'designer', 'Create your first design', 'Make a design decision in the Atelier.', 'first_design_created'),
    ('designer_first_drop', 'designer', 'Release your first drop', 'Put your first design in front of the world.', 'first_drop_released'),
    ('designer_react_to_result', 'designer', 'React to the result', 'Read the market response and choose your next move.', 'first_drop_result_viewed'),
    ('mogul_first_store', 'mogul', 'Open your first store', 'Choose a city, format, and operating strategy.', 'first_store_opened'),
    ('mogul_first_store_decision', 'mogul', 'Make a store decision', 'Set the price and inventory posture for your first location.', 'first_store_decision'),
    ('mogul_react_to_sales', 'mogul', 'React to the result', 'Review your first sales result and adapt the empire.', 'store_result_viewed')
) AS x(objective_key, path, title, description, completion_event_key)
  ON x.path = 'shared' OR x.path = p.path
ON CONFLICT (player_id, objective_key) DO NOTHING;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime')
     AND NOT EXISTS (
       SELECT 1
       FROM pg_publication p
       JOIN pg_publication_rel pr ON pr.prpubid = p.oid
       JOIN pg_class c ON c.oid = pr.prrelid
       JOIN pg_namespace n ON n.oid = c.relnamespace
       WHERE p.pubname = 'supabase_realtime'
         AND n.nspname = 'public'
         AND c.relname = 'first_week_objectives'
     ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.first_week_objectives;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.seed_first_week_objectives()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.first_week_objectives
    (player_id, objective_key, path, title, description, completion_event_key)
  VALUES
    (NEW.id, 'shared_feed_participation', 'shared', 'Enter the Global Feed',
      'Publish or participate in the Feed so the world can react.', 'global_feed_participation'),
    (NEW.id, 'designer_first_design', 'designer', 'Create your first design',
      'Make a design decision in the Atelier.', 'first_design_created'),
    (NEW.id, 'designer_first_drop', 'designer', 'Release your first drop',
      'Put your first design in front of the world.', 'first_drop_released'),
    (NEW.id, 'designer_react_to_result', 'designer', 'React to the result',
      'Read the market response and choose your next move.', 'first_drop_result_viewed'),
    (NEW.id, 'mogul_first_store', 'mogul', 'Open your first store',
      'Choose a city, format, and operating strategy.', 'first_store_opened'),
    (NEW.id, 'mogul_first_store_decision', 'mogul', 'Make a store decision',
      'Set the price and inventory posture for your first location.', 'first_store_decision'),
    (NEW.id, 'mogul_react_to_sales', 'mogul', 'React to the result',
      'Review your first sales result and adapt the empire.', 'store_result_viewed')
  ON CONFLICT (player_id, objective_key) DO NOTHING;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.seed_first_week_objectives()
  FROM PUBLIC, anon, authenticated, service_role;

DROP TRIGGER IF EXISTS seed_first_week_objectives_on_player ON public.players;
CREATE TRIGGER seed_first_week_objectives_on_player
  AFTER INSERT ON public.players
  FOR EACH ROW EXECUTE FUNCTION public.seed_first_week_objectives();

CREATE OR REPLACE FUNCTION public.record_progression_event_internal(
  p_player_id UUID,
  p_event_key TEXT,
  p_entity_id UUID DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO public.player_progression_events(player_id, event_key, entity_id, metadata)
  VALUES (p_player_id, p_event_key, p_entity_id, COALESCE(p_metadata, '{}'::jsonb))
  ON CONFLICT (player_id, event_key, entity_id) DO NOTHING
  RETURNING id INTO v_event_id;

  UPDATE public.first_week_objectives
  SET status = 'completed', completed_at = COALESCE(completed_at, NOW()), source_event_id = COALESCE(source_event_id, v_event_id)
  WHERE player_id = p_player_id
    AND completion_event_key = p_event_key;
END;
$$;

REVOKE ALL ON FUNCTION public.record_progression_event_internal(UUID, TEXT, UUID, JSONB)
  FROM PUBLIC, anon, authenticated, service_role;

INSERT INTO public.player_progression_events(player_id, event_key, entity_id, metadata)
SELECT d.player_id, 'first_design_created', d.id, '{}'::jsonb
FROM public.designs d
ON CONFLICT (player_id, event_key, entity_id) DO NOTHING;

INSERT INTO public.player_progression_events(player_id, event_key, entity_id, metadata)
SELECT g.player_id, 'first_drop_released', g.id, '{}'::jsonb
FROM public.garment_drops g
ON CONFLICT (player_id, event_key, entity_id) DO NOTHING;

INSERT INTO public.player_progression_events(player_id, event_key, entity_id, metadata)
SELECT s.player_id, 'first_store_opened', s.id, '{}'::jsonb
FROM public.stores s
ON CONFLICT (player_id, event_key, entity_id) DO NOTHING;

INSERT INTO public.player_progression_events (
  player_id,
  event_key,
  entity_id,
  metadata
)
SELECT
  fp.player_id,
  'global_feed_participation',
  fp.id,
  '{}'::jsonb
FROM public.feed_posts AS fp
JOIN public.players AS p
  ON p.id = fp.player_id
WHERE fp.player_id IS NOT NULL
  AND fp.is_system IS NOT TRUE
ON CONFLICT (player_id, event_key, entity_id) DO NOTHING;

UPDATE public.first_week_objectives o
SET status = 'completed', completed_at = COALESCE(o.completed_at, NOW())
WHERE EXISTS (
  SELECT 1
  FROM public.player_progression_events e
  WHERE e.player_id = o.player_id
    AND e.event_key = o.completion_event_key
);

CREATE OR REPLACE FUNCTION public.record_progression_event(
  p_event_key TEXT,
  p_entity_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_player_id UUID := auth.uid();
  v_valid BOOLEAN := FALSE;
BEGIN
  IF v_player_id IS NULL THEN RAISE EXCEPTION 'UNAUTHORIZED'; END IF;

  v_valid := CASE p_event_key
    WHEN 'global_feed_participation' THEN p_entity_id IS NOT NULL AND EXISTS (
      SELECT 1
      FROM public.feed_posts
      WHERE id = p_entity_id
        AND player_id = v_player_id
        AND is_system IS NOT TRUE
    )
    WHEN 'first_drop_result_viewed' THEN EXISTS (
      SELECT 1 FROM public.feed_posts
      WHERE player_id = v_player_id AND content->>'event' = 'alpha_dropped'
    )
    WHEN 'store_result_viewed' THEN EXISTS (
      SELECT 1 FROM public.stores WHERE player_id = v_player_id
    )
    ELSE FALSE
  END;

  IF NOT v_valid THEN RAISE EXCEPTION 'INVALID_PROGRESS_EVENT'; END IF;
  PERFORM public.record_progression_event_internal(v_player_id, p_event_key, p_entity_id);
  RETURN jsonb_build_object('success', TRUE, 'event_key', p_event_key);
END;
$$;

REVOKE ALL ON FUNCTION public.record_progression_event(TEXT, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.record_progression_event(TEXT, UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.progression_event_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF TG_TABLE_NAME = 'designs' THEN
    PERFORM public.record_progression_event_internal(NEW.player_id, 'first_design_created', NEW.id);
  ELSIF TG_TABLE_NAME = 'garment_drops' THEN
    PERFORM public.record_progression_event_internal(NEW.player_id, 'first_drop_released', NEW.id);
  ELSIF TG_TABLE_NAME = 'stores' THEN
    PERFORM public.record_progression_event_internal(NEW.player_id, 'first_store_opened', NEW.id);
    IF NEW.decision_made_at IS NOT NULL THEN
      PERFORM public.record_progression_event_internal(NEW.player_id, 'first_store_decision', NEW.id);
    END IF;
  ELSIF TG_TABLE_NAME = 'feed_posts'
      AND NEW.player_id IS NOT NULL
      AND NEW.is_system IS NOT TRUE THEN
    PERFORM public.record_progression_event_internal(NEW.player_id, 'global_feed_participation', NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.progression_event_trigger()
  FROM PUBLIC, anon, authenticated, service_role;

DROP TRIGGER IF EXISTS progression_event_on_design ON public.designs;
CREATE TRIGGER progression_event_on_design
  AFTER INSERT ON public.designs FOR EACH ROW EXECUTE FUNCTION public.progression_event_trigger();

DROP TRIGGER IF EXISTS progression_event_on_drop ON public.garment_drops;
CREATE TRIGGER progression_event_on_drop
  AFTER INSERT ON public.garment_drops FOR EACH ROW EXECUTE FUNCTION public.progression_event_trigger();

DROP TRIGGER IF EXISTS progression_event_on_store ON public.stores;
CREATE TRIGGER progression_event_on_store
  AFTER INSERT ON public.stores FOR EACH ROW EXECUTE FUNCTION public.progression_event_trigger();

DROP TRIGGER IF EXISTS progression_event_on_feed_post ON public.feed_posts;
CREATE TRIGGER progression_event_on_feed_post
  AFTER INSERT ON public.feed_posts FOR EACH ROW EXECUTE FUNCTION public.progression_event_trigger();

CREATE OR REPLACE FUNCTION public.edge_open_first_store_atomic(
  p_player_id UUID,
  p_city TEXT,
  p_store_type TEXT,
  p_price_tier TEXT,
  p_inventory_capacity INTEGER,
  p_idempotency_key UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_player public.players%ROWTYPE;
  v_brand public.brand_state%ROWTYPE;
  v_store public.stores%ROWTYPE;
  v_response JSONB;
  v_cost NUMERIC(14, 2);
  v_demand NUMERIC(14, 4);
  v_operating_cost NUMERIC(14, 4);
  v_audience TEXT;
BEGIN
  IF current_user <> 'service_role' THEN RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED'; END IF;

  SELECT response INTO v_response
  FROM public.security_idempotency_keys
  WHERE actor_id = p_player_id AND action = 'open_first_store' AND idempotency_key = p_idempotency_key;
  IF FOUND THEN RETURN v_response; END IF;

  SELECT * INTO v_player FROM public.players WHERE id = p_player_id FOR UPDATE;
  IF NOT FOUND OR v_player.path <> 'mogul' THEN RAISE EXCEPTION 'MOGUL_ONLY'; END IF;
  IF EXISTS (SELECT 1 FROM public.stores WHERE player_id = p_player_id) THEN
    RAISE EXCEPTION 'FIRST_STORE_ALREADY_OPEN';
  END IF;
  IF p_city NOT IN ('new_york', 'paris', 'tokyo') THEN RAISE EXCEPTION 'INVALID_STARTER_CITY'; END IF;
  IF p_store_type NOT IN ('flagship', 'ecommerce') THEN RAISE EXCEPTION 'INVALID_STORE_TYPE'; END IF;
  IF p_price_tier NOT IN ('accessible', 'signature', 'luxury') THEN RAISE EXCEPTION 'INVALID_PRICE_TIER'; END IF;
  IF p_inventory_capacity NOT BETWEEN 12 AND 60 THEN RAISE EXCEPTION 'INVALID_INVENTORY_CAPACITY'; END IF;

  v_cost := CASE p_store_type WHEN 'flagship' THEN 15000 ELSE 8000 END;
  v_audience := CASE p_price_tier WHEN 'accessible' THEN 'emerging' WHEN 'signature' THEN 'design-conscious' ELSE 'collector' END;
  v_demand := CASE p_price_tier WHEN 'accessible' THEN 18 WHEN 'signature' THEN 10 ELSE 5 END;
  v_operating_cost := CASE p_store_type WHEN 'flagship' THEN 140 ELSE 35 END;

  SELECT * INTO v_brand FROM public.brand_state WHERE player_id = p_player_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND'; END IF;
  IF v_brand.total_revenue < v_cost THEN RAISE EXCEPTION 'INSUFFICIENT_CAPITAL'; END IF;

  INSERT INTO public.stores(
    player_id, type, city, tier, revenue_per_hour, loyalty, market_share,
    audience, price_tier, inventory_capacity, operating_cost_per_hour,
    expected_demand_per_day, decision_made_at, opened_at, updated_at
  ) VALUES (
    p_player_id, p_store_type, p_city, 1,
    ROUND(GREATEST(1, v_demand * 0.35 - v_operating_cost / 100), 4),
    100, 0, v_audience, p_price_tier, p_inventory_capacity,
    v_operating_cost, v_demand, NOW(), NOW(), NOW()
  ) RETURNING * INTO v_store;

  UPDATE public.brand_state
  SET total_revenue = total_revenue - v_cost,
      idle_revenue_per_hour = (SELECT COALESCE(SUM(revenue_per_hour), 0) FROM public.stores WHERE player_id = p_player_id),
      updated_at = NOW()
  WHERE player_id = p_player_id;

  SELECT jsonb_build_object(
    'success', TRUE,
    'store_id', v_store.id,
    'opening_cost', v_cost,
    'city', v_store.city,
    'store_type', v_store.type,
    'price_tier', v_store.price_tier,
    'inventory_capacity', v_store.inventory_capacity,
    'expected_demand_per_day', v_store.expected_demand_per_day,
    'operating_cost_per_hour', v_store.operating_cost_per_hour,
    'revenue_per_hour', v_store.revenue_per_hour
  ) INTO v_response;

  INSERT INTO public.security_idempotency_keys(actor_id, action, idempotency_key, response, created_at)
  VALUES (p_player_id, 'open_first_store', p_idempotency_key, v_response, NOW());
  RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION public.edge_open_first_store_atomic(UUID, TEXT, TEXT, TEXT, INTEGER, UUID)
  FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.edge_open_first_store_atomic(UUID, TEXT, TEXT, TEXT, INTEGER, UUID)
  TO service_role;

COMMENT ON TABLE public.first_week_objectives IS
  'Server-derived first-week objectives. Completion is driven by authoritative progression events, never local booleans.';
COMMENT ON FUNCTION public.edge_open_first_store_atomic(UUID, TEXT, TEXT, TEXT, INTEGER, UUID) IS
  'Idempotent, locked, server-authoritative Mogul first-store transaction.';
