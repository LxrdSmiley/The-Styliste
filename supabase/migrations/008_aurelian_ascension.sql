-- =============================================================================
-- The Styliste — Aurelian Ascension Migration
-- GDD v6 §3.5 — Rank 50 Joint Venture & Rank 100 Memorialization
-- Alabaster Standard: Permanent prestige, no wipes, account-wide multipliers
-- =============================================================================

-- =============================================================================
-- ALTER PLAYERS: Add ascension tracking fields
-- =============================================================================
ALTER TABLE public.players 
  ADD COLUMN IF NOT EXISTS is_joint_venture BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS sovereign_multipliers INT NOT NULL DEFAULT 0 CHECK (sovereign_multipliers <= 20),
  ADD COLUMN IF NOT EXISTS joint_venture_unlocked_at TIMESTAMPTZ;

-- =============================================================================
-- HALL OF SOVEREIGNS: Permanent memorialization gallery
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.hall_of_sovereigns (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  brand_name          TEXT NOT NULL,
  ascended_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  final_market_cap    BIGINT NOT NULL DEFAULT 0,
  final_hype_score    NUMERIC(14,2) NOT NULL DEFAULT 0,
  statue_tier         TEXT NOT NULL CHECK (statue_tier IN ('Quartz', 'Gold', 'Alabaster')),
  career_path         TEXT NOT NULL CHECK (career_path IN ('designer', 'mogul')),
  joint_venture_flag  BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(player_id, brand_name)
);

CREATE INDEX hall_of_sovereigns_player_idx ON public.hall_of_sovereigns(player_id);
CREATE INDEX hall_of_sovereigns_ascended_idx ON public.hall_of_sovereigns(ascended_at DESC);
CREATE INDEX hall_of_sovereigns_tier_idx ON public.hall_of_sovereigns(statue_tier);

ALTER TABLE public.hall_of_sovereigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Hall of Sovereigns: read all" ON public.hall_of_sovereigns FOR SELECT USING (TRUE);
-- No INSERT/UPDATE/DELETE for client — only RPC

-- =============================================================================
-- RPC: UNLOCK JOINT VENTURE (Rank 50)
-- 
-- Validates rank >= 50, unlocks dual-path gameplay
-- =============================================================================
CREATE OR REPLACE FUNCTION public.unlock_joint_venture(p_player_id UUID)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Check if already unlocked
  IF EXISTS (
    SELECT 1 FROM public.players 
    WHERE id = p_player_id AND is_joint_venture = TRUE
  ) THEN
    RETURN QUERY SELECT FALSE, 'JOINT_VENTURE_ALREADY_UNLOCKED';
    RETURN;
  END IF;
  
  -- Validate rank requirement
  IF NOT EXISTS (
    SELECT 1 FROM public.players 
    WHERE id = p_player_id AND brand_rank >= 50
  ) THEN
    RETURN QUERY SELECT FALSE, 'RANK_REQUIREMENT_NOT_MET_50';
    RETURN;
  END IF;
  
  -- Unlock joint venture
  UPDATE public.players 
  SET is_joint_venture = TRUE,
      joint_venture_unlocked_at = NOW()
  WHERE id = p_player_id;
    
  -- Create feed event
  INSERT INTO feed_posts (player_id, type, content, hype)
  SELECT 
    p_player_id,
    'joint_venture_unlocked',
    jsonb_build_object(
      'brand_name', brand_name,
      'previous_path', path
    ),
    500.0
  FROM public.players 
  WHERE id = p_player_id;
    
  RETURN QUERY SELECT TRUE, 'JOINT_VENTURE_UNLOCKED';
END;
$$;

-- =============================================================================
-- RPC: EXECUTE MEMORIALIZATION (Rank 100)
-- 
-- Auto-calculates statue tier based on sovereign_multipliers count:
--   1st memorialization = Quartz
--   2nd-4th memorializations = Gold  
--   5th+ memorializations = Alabaster
-- Grants +1 sovereign multiplier (max 20)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.execute_memorialization(
  p_player_id UUID,
  p_brand_name TEXT
)
RETURNS TABLE(
  success BOOLEAN, 
  message TEXT, 
  sovereign_count INT, 
  statue_tier TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_player RECORD;
  v_market_cap BIGINT;
  v_hype_score NUMERIC;
  v_new_count INT;
  v_tier TEXT;
  v_current_multipliers INT;
BEGIN
  -- Get player data
  SELECT * INTO v_player FROM public.players WHERE id = p_player_id;
  
  IF v_player IS NULL THEN
    RETURN QUERY SELECT FALSE, 'PLAYER_NOT_FOUND', 0, ''::TEXT;
    RETURN;
  END IF;
  
  -- Validate rank requirement (Rank 100)
  IF v_player.brand_rank < 100 THEN
    RETURN QUERY SELECT FALSE, 'RANK_REQUIREMENT_NOT_MET_100', 0, ''::TEXT;
    RETURN;
  END IF;
  
  -- Check for duplicate brand name memorialization
  IF EXISTS (
    SELECT 1 FROM public.hall_of_sovereigns 
    WHERE player_id = p_player_id AND brand_name = p_brand_name
  ) THEN
    RETURN QUERY SELECT FALSE, 'BRAND_ALREADY_MEMORIALIZED', 0, ''::TEXT;
    RETURN;
  END IF;
  
  -- Get current multiplier count to determine tier
  v_current_multipliers := COALESCE(v_player.sovereign_multipliers, 0);
  
  -- Determine statue tier based on progression
  -- 1st = Quartz, 2nd-4th = Gold, 5th+ = Alabaster
  IF v_current_multipliers = 0 THEN
    v_tier := 'Quartz';
  ELSIF v_current_multipliers BETWEEN 1 AND 3 THEN
    v_tier := 'Gold';
  ELSE
    v_tier := 'Alabaster';
  END IF;
  
  -- Get final stats from brand_state
  SELECT bs.total_revenue::BIGINT, bs.hype_score 
  INTO v_market_cap, v_hype_score
  FROM public.brand_state bs 
  WHERE bs.player_id = p_player_id;
  
  -- Insert into Hall of Sovereigns
  INSERT INTO public.hall_of_sovereigns (
    player_id, brand_name, final_market_cap, final_hype_score,
    statue_tier, career_path, joint_venture_flag
  ) VALUES (
    p_player_id, p_brand_name, COALESCE(v_market_cap, 0), COALESCE(v_hype_score, 0),
    v_tier, v_player.path, v_player.is_joint_venture
  );
  
  -- Increment sovereign multipliers (capped at 20)
  UPDATE public.players 
  SET sovereign_multipliers = LEAST(sovereign_multipliers + 1, 20)
  WHERE id = p_player_id
  RETURNING sovereign_multipliers INTO v_new_count;
  
  -- Create global feed event for ascension
  INSERT INTO feed_posts (player_id, type, content, hype)
  VALUES (
    p_player_id,
    'aurelian_ascension',
    jsonb_build_object(
      'brand_name', p_brand_name,
      'statue_tier', v_tier,
      'market_cap', v_market_cap,
      'hype_score', v_hype_score,
      'career_path', v_player.path,
      'joint_venture', v_player.is_joint_venture,
      'sovereign_multiplier', v_new_count
    ),
    COALESCE(v_hype_score, 0) / 10.0
  );
  
  RETURN QUERY SELECT TRUE, 'MEMORIALIZATION_SUCCESSFUL', v_new_count, v_tier;
END;
$$;

-- =============================================================================
-- RPC: GET SOVEREIGN MULTIPLIER BONUS
-- 
-- Returns the calculated bonus multiplier (1.0 + count * 0.25)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_sovereign_multiplier(p_player_id UUID)
RETURNS NUMERIC(4,2)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INT;
BEGIN
  SELECT sovereign_multipliers INTO v_count
  FROM public.players WHERE id = p_player_id;
  
  RETURN 1.0 + (COALESCE(v_count, 0) * 0.25);
END;
$$;

-- =============================================================================
-- TRIGGER: Auto-unlock Joint Venture at Rank 50
-- =============================================================================
CREATE OR REPLACE FUNCTION public.check_joint_venture_unlock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.brand_rank >= 50 AND OLD.brand_rank < 50 AND NOT NEW.is_joint_venture THEN
    NEW.is_joint_venture := TRUE;
    NEW.joint_venture_unlocked_at := NOW();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_joint_venture ON public.players;
CREATE TRIGGER trg_check_joint_venture
  BEFORE UPDATE OF brand_rank ON public.players
  FOR EACH ROW
  EXECUTE FUNCTION public.check_joint_venture_unlock();

-- =============================================================================
-- GRANT PERMISSIONS
-- =============================================================================
GRANT EXECUTE ON FUNCTION public.unlock_joint_venture(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.execute_memorialization(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_sovereign_multiplier(UUID) TO authenticated;

-- =============================================================================
-- COMMENTS
-- =============================================================================
COMMENT ON TABLE public.hall_of_sovereigns IS 
  'Permanent memorialization gallery for Rank 100 ascensions. Statue tiers: Quartz (1st), Gold (2nd-4th), Alabaster (5th+).';
  
COMMENT ON FUNCTION public.execute_memorialization IS 
  'Auto-calculates statue tier, grants +1 sovereign multiplier (max 20), creates global feed event.';
