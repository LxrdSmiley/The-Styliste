-- =============================================================================
-- The Styliste — Sovereign Genesis Migration
-- GDD §1.1 Screen 7 — Atomic player provisioning RPC
-- Alabaster Standard: One transaction, one empire, zero leaks
-- =============================================================================

-- =============================================================================
-- MARKET TIER ENUM: Starting conditions for Brand Footprint (Screen 4)
-- =============================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'market_tier'
  ) THEN
    CREATE TYPE market_tier AS ENUM (
      'high_luxury',    -- Low initial sales, massive hype ceiling
      'mid_luxury',     -- Balanced path
      'mass_market'     -- High initial volume, strict hype caps
    );
  END IF;
END $$;

-- =============================================================================
-- ALTER brand_state: Add market tier and avatar configuration
-- =============================================================================
ALTER TABLE public.brand_state 
  ADD COLUMN IF NOT EXISTS market_tier TEXT,
  ADD COLUMN IF NOT EXISTS avatar_configuration JSONB DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS hype_ceiling NUMERIC(14,2) DEFAULT 1000000;

-- =============================================================================
-- RPC: EXECUTE SOVEREIGN GENESIS
-- 
-- Atomic player provisioning called from Ascension Confirmation (Screen 7)
-- Creates players + brand_state + feed post in single transaction
-- Returns success/failure with player_id
-- =============================================================================
CREATE OR REPLACE FUNCTION execute_sovereign_genesis(
  p_user_id UUID,
  p_brand_name TEXT,
  p_career_path TEXT,      -- 'designer' | 'mogul'
  p_city TEXT,             -- 'new_york' | 'paris' | 'tokyo' | 'milan'
  p_market_tier TEXT,      -- 'high_luxury' | 'mid_luxury' | 'mass_market'
  p_avatar_config JSONB    -- {face, body, hair, fit}
)
RETURNS TABLE(
  success BOOLEAN, 
  message TEXT, 
  player_id UUID,
  starting_capital BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_player_id UUID;
  v_starting_capital BIGINT;
  v_starting_hype_cap NUMERIC;
  v_idle_income_per_hour BIGINT;
BEGIN
  -- Input validation
  IF p_career_path NOT IN ('designer', 'mogul') THEN
    RETURN QUERY SELECT FALSE, 'INVALID_CAREER_PATH', NULL::UUID, 0::BIGINT;
    RETURN;
  END IF;
  
  IF p_city NOT IN ('new_york', 'paris', 'tokyo', 'milan', 'london', 'seoul') THEN
    RETURN QUERY SELECT FALSE, 'INVALID_CITY', NULL::UUID, 0::BIGINT;
    RETURN;
  END IF;
  
  IF p_market_tier NOT IN ('high_luxury', 'mid_luxury', 'mass_market') THEN
    RETURN QUERY SELECT FALSE, 'INVALID_MARKET_TIER', NULL::UUID, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Check if player already exists
  IF EXISTS (SELECT 1 FROM public.players WHERE id = p_user_id) THEN
    RETURN QUERY SELECT FALSE, 'PLAYER_ALREADY_EXISTS', NULL::UUID, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Determine starting values based on tier
  SELECT 
    CASE p_market_tier
      WHEN 'high_luxury' THEN 50000     -- $50K, prestige focus
      WHEN 'mid_luxury' THEN 100000     -- $100K balanced
      WHEN 'mass_market' THEN 200000    -- $200K, volume play
    END,
    CASE p_market_tier
      WHEN 'high_luxury' THEN 1000000   -- 1M hype ceiling
      WHEN 'mid_luxury' THEN 500000
      WHEN 'mass_market' THEN 100000    -- Strict cap
    END,
    CASE p_market_tier
      WHEN 'high_luxury' THEN 500       -- $500/hr passive
      WHEN 'mid_luxury' THEN 1500
      WHEN 'mass_market' THEN 3000
    END
  INTO v_starting_capital, v_starting_hype_cap, v_idle_income_per_hour;
  
  -- Create player record
  INSERT INTO public.players (
    id,
    brand_name,
    path,
    hq_city,
    brand_rank,
    total_xp,
    onboarding_complete,
    is_anonymous,
    is_joint_venture,
    sovereign_multipliers,
    created_at
  ) VALUES (
    p_user_id,
    p_brand_name,
    p_career_path,
    p_city,
    1,                    -- Starting rank
    0,                    -- Starting XP
    TRUE,                 -- Onboarding complete
    FALSE,                -- Not anonymous
    FALSE,                -- Joint venture unlocked later
    0,                    -- No sovereign multipliers yet
    NOW()
  )
  RETURNING id INTO v_player_id;
  
  -- Initialize brand_state with starting capital
  INSERT INTO public.brand_state (
    player_id,
    total_revenue,
    hype_score,
    idle_revenue_per_hour,
    market_tier,
    avatar_configuration,
    hype_ceiling,
    luxe_tokens
  ) VALUES (
    v_player_id,
    v_starting_capital,      -- Starting money
    0,                       -- Starting hype
    v_idle_income_per_hour,
    p_market_tier,
    p_avatar_config,
    v_starting_hype_cap,
    0                        -- No luxe tokens initially
  );
  
  -- Create welcome feed post
  INSERT INTO feed_posts (
    player_id,
    type,
    content,
    hype,
    created_at
  ) VALUES (
    v_player_id,
    'genesis_complete',
    jsonb_build_object(
      'brand_name', p_brand_name,
      'city', p_city,
      'tier', p_market_tier,
      'path', p_career_path,
      'starting_capital', v_starting_capital,
      'hype_ceiling', v_starting_hype_cap
    ),
    100.0,
    NOW()
  );
  
  -- Log the genesis event
  RAISE NOTICE 'Sovereign Genesis: player_id=%, brand=%, tier=%, capital=%',
    v_player_id, p_brand_name, p_market_tier, v_starting_capital;
  
  RETURN QUERY SELECT TRUE, 'GENESIS_SUCCESSFUL', v_player_id, v_starting_capital;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION execute_sovereign_genesis(UUID, TEXT, TEXT, TEXT, TEXT, JSONB) 
  TO authenticated;

-- =============================================================================
-- COMMENT
-- =============================================================================
COMMENT ON FUNCTION execute_sovereign_genesis IS 
  'Atomic player provisioning for The Styliste onboarding. Creates players, brand_state, and welcome post. Returns player_id and starting_capital on success.';
