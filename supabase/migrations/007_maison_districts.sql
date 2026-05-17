-- =============================================================================
-- The Styliste — Maison District Warfare Migration
-- GDD v6 — Turf War: 9 districts across 3 cities, 30-day Aurelian Watermarks
-- Alabaster Standard: Architect Capital + Artisan Hype = Effective Power
-- =============================================================================

-- =============================================================================
-- FASHION DISTRICTS: The 9 territories (3 cities × 3 districts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fashion_districts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  city                TEXT NOT NULL,
  controlling_maison_id UUID REFERENCES public.maisons(id) ON DELETE SET NULL,
  controlled_since    TIMESTAMPTZ,
  base_takeover_cost  BIGINT NOT NULL DEFAULT 10000,
  total_hype          BIGINT NOT NULL DEFAULT 0, -- Aggregated from member designs
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast city-based queries
CREATE INDEX fashion_districts_city_idx ON public.fashion_districts(city);
CREATE INDEX fashion_districts_controller_idx ON public.fashion_districts(controlling_maison_id);

ALTER TABLE public.fashion_districts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Fashion districts: read all" ON public.fashion_districts FOR SELECT USING (TRUE);
-- No client INSERT/UPDATE — only RPC

-- =============================================================================
-- DISTRICT LEGACY WATERMARKS: Permanent 30-day prestige
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.district_legacy_watermarks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  maison_id   UUID NOT NULL REFERENCES public.maisons(id) ON DELETE CASCADE,
  district_id UUID NOT NULL REFERENCES public.fashion_districts(id) ON DELETE CASCADE,
  achieved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(maison_id, district_id)
);

CREATE INDEX watermark_maison_idx ON public.district_legacy_watermarks(maison_id);
CREATE INDEX watermark_district_idx ON public.district_legacy_watermarks(district_id);

ALTER TABLE public.district_legacy_watermarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Watermarks: read all" ON public.district_legacy_watermarks FOR SELECT USING (TRUE);

-- =============================================================================
-- DISTRICT TAKEOVER LOG: Battle audit trail
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.district_takeover_log (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  district_id         UUID NOT NULL REFERENCES public.fashion_districts(id),
  attacker_maison_id  UUID NOT NULL REFERENCES public.maisons(id),
  defender_maison_id  UUID REFERENCES public.maisons(id),
  attacker_bid        BIGINT NOT NULL,
  attacker_hype       BIGINT NOT NULL DEFAULT 0,
  defender_power      BIGINT,
  defense_multiplier  NUMERIC(4,2) NOT NULL DEFAULT 1.0,
  was_successful      BOOLEAN NOT NULL,
  taken_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX takeover_log_district_idx ON public.district_takeover_log(district_id);
CREATE INDEX takeover_log_attacker_idx ON public.district_takeover_log(attacker_maison_id);

ALTER TABLE public.district_takeover_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Takeover log: read all" ON public.district_takeover_log FOR SELECT USING (TRUE);

-- =============================================================================
-- SEED: The 9 Districts (3 cities × 3 districts)
-- =============================================================================
INSERT INTO public.fashion_districts (name, city, base_takeover_cost) VALUES
  -- New York
  ('SoHo', 'New York', 15000),
  ('Meatpacking', 'New York', 12000),
  ('Williamsburg', 'New York', 10000),
  -- Tokyo
  ('Ginza', 'Tokyo', 18000),
  ('Harajuku', 'Tokyo', 15000),
  ('Shibuya', 'Tokyo', 12000),
  -- Paris
  ('Le Marais', 'Paris', 16000),
  ('Saint-Germain', 'Paris', 14000),
  ('Montmartre', 'Paris', 11000)
ON CONFLICT DO NOTHING;

-- =============================================================================
-- RPC: ATTEMPT DISTRICT TAKEOVER
-- 
-- Hybrid power formula: effective_power = bid * (1 + (maison_hype / 1000))
-- Defense multiplier: +5% per day held, capped at 2.5x
-- Row-level locking prevents race conditions
-- =============================================================================
CREATE OR REPLACE FUNCTION public.attempt_district_takeover(
  p_attacker_maison_id UUID,
  p_district_id UUID,
  p_capital_bid BIGINT
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  new_controller UUID,
  defense_multiplier NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_district RECORD;
  v_attacker RECORD;
  v_defender RECORD;
  v_defense_multiplier NUMERIC := 1.0;
  v_attacker_power NUMERIC;
  v_defender_power NUMERIC;
  v_days_held INTEGER := 0;
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.maison_members
    WHERE maison_id = p_attacker_maison_id
      AND player_id = auth.uid()
      AND role IN ('founder', 'executive_director')
  ) THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Step 1: Lock the district row (prevents concurrent takeovers)
  SELECT * INTO v_district
  FROM fashion_districts
  WHERE id = p_district_id
  FOR UPDATE;

  IF v_district IS NULL THEN
    RETURN QUERY SELECT FALSE, 'DISTRICT_NOT_FOUND', NULL::UUID, 1.0::NUMERIC;
    RETURN;
  END IF;

  -- Step 2: Get attacker data (treasury + hype)
  SELECT treasury, total_hype INTO v_attacker
  FROM maisons
  WHERE id = p_attacker_maison_id;

  IF v_attacker IS NULL THEN
    RETURN QUERY SELECT FALSE, 'MAISON_NOT_FOUND', NULL::UUID, 1.0::NUMERIC;
    RETURN;
  END IF;

  -- Step 3: Check attacker treasury
  IF v_attacker.treasury < p_capital_bid THEN
    RETURN QUERY SELECT FALSE, 'INSUFFICIENT_CAPITAL', NULL::UUID, 1.0::NUMERIC;
    RETURN;
  END IF;

  -- Step 4: Calculate attacker effective power
  -- Formula: bid * (1 + (hype / 1000))
  v_attacker_power := p_capital_bid * (1.0 + (COALESCE(v_attacker.total_hype, 0) / 1000.0));

  -- Step 5: If district is owned, calculate defender power
  IF v_district.controlling_maison_id IS NOT NULL THEN
    -- Can't attack your own district
    IF v_district.controlling_maison_id = p_attacker_maison_id THEN
      RETURN QUERY SELECT FALSE, 'ALREADY_CONTROLLED', p_attacker_maison_id, 1.0::NUMERIC;
      RETURN;
    END IF;

    -- Get defender data
    SELECT treasury, total_hype INTO v_defender
    FROM maisons
    WHERE id = v_district.controlling_maison_id;

    -- Calculate days held
    IF v_district.controlled_since IS NOT NULL THEN
      v_days_held := EXTRACT(DAY FROM (NOW() - v_district.controlled_since))::INTEGER;
    END IF;

    -- Defense multiplier: +5% per day, capped at 2.5x
    v_defense_multiplier := LEAST(1.0 + (v_days_held * 0.05), 2.5);

    -- Defender power: treasury * defense_multiplier * (1 + hype/1000)
    v_defender_power := COALESCE(v_defender.treasury, 0) * v_defense_multiplier * 
                       (1.0 + (COALESCE(v_defender.total_hype, 0) / 1000.0));

    -- Check if attacker wins
    IF v_attacker_power <= v_defender_power THEN
      -- Log failed attempt
      INSERT INTO district_takeover_log (
        district_id, attacker_maison_id, defender_maison_id,
        attacker_bid, attacker_hype, defender_power, defense_multiplier, was_successful
      ) VALUES (
        p_district_id, p_attacker_maison_id, v_district.controlling_maison_id,
        p_capital_bid, v_attacker.total_hype, v_defender_power::BIGINT, 
        v_defense_multiplier, FALSE
      );

      RETURN QUERY SELECT FALSE, 'BID_TOO_LOW', v_district.controlling_maison_id, v_defense_multiplier;
      RETURN;
    END IF;
  END IF;

  -- Step 6: Execute takeover
  -- Deduct from attacker treasury
  UPDATE maisons 
  SET treasury = treasury - p_capital_bid 
  WHERE id = p_attacker_maison_id;

  -- Update district control
  UPDATE fashion_districts 
  SET controlling_maison_id = p_attacker_maison_id,
      controlled_since = NOW()
  WHERE id = p_district_id;

  -- Step 7: Log successful takeover
  INSERT INTO district_takeover_log (
    district_id, attacker_maison_id, defender_maison_id,
    attacker_bid, attacker_hype, defender_power, defense_multiplier, was_successful
  ) VALUES (
    p_district_id, p_attacker_maison_id, v_district.controlling_maison_id,
    p_capital_bid, v_attacker.total_hype, 
    COALESCE(v_defender_power, 0)::BIGINT, v_defense_multiplier, TRUE
  );

  -- Step 8: Create feed post for successful takeover
  INSERT INTO feed_posts (player_id, type, content, hype)
  SELECT 
    founder_id,
    'district_takeover',
    jsonb_build_object(
      'district_name', v_district.name,
      'city', v_district.city,
      'maison_id', p_attacker_maison_id,
      'maison_name', m.name,
      'previous_owner', v_district.controlling_maison_id,
      'bid', p_capital_bid,
      'defense_multiplier', v_defense_multiplier
    ),
    p_capital_bid / 100.0
  FROM maisons m
  WHERE m.id = p_attacker_maison_id;

  -- Return success
  RETURN QUERY SELECT TRUE, 'TAKEOVER_SUCCESSFUL', p_attacker_maison_id, v_defense_multiplier;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.attempt_district_takeover(UUID, UUID, BIGINT) TO service_role;

-- =============================================================================
-- TRIGGER: Update maison total_hype when designs are dropped
-- =============================================================================
CREATE OR REPLACE FUNCTION public.update_maison_hype_on_drop()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update the controlling maison's total_hype if design matches district
  -- This is a simplified version; production would aggregate all member designs
  UPDATE fashion_districts
  SET total_hype = total_hype + NEW.hype_score
  WHERE id IN (
    SELECT fd.id 
    FROM fashion_districts fd
    JOIN maisons m ON fd.controlling_maison_id = m.id
    WHERE m.id IN (
      SELECT maison_id FROM maison_members WHERE player_id = NEW.player_id
    )
  );
  
  RETURN NEW;
END;
$$;

-- Comment for future implementation
COMMENT ON FUNCTION public.attempt_district_takeover IS 
  'Hybrid power formula: effective_power = bid * (1 + maison_hype/1000). Defense: +5%/day (max 2.5x). Uses FOR UPDATE locking.';
