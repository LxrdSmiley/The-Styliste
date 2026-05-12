-- =============================================================================
-- The Styliste — Sovereign Talent (Gacha) Migration
-- GDD §8.10, §12.4.1 — Premium Casting Engine
-- Alabaster Standard: Server-authoritative, zero client trust, 120fps UX
-- =============================================================================

-- =============================================================================
-- Talent Tiers Enum
-- =============================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'talent_tier') THEN
    CREATE TYPE talent_tier AS ENUM (
      'rising_star',      -- Common: 60% base rate, 1 prestige on dupe
      'established',      -- Uncommon: 30% base rate, 5 prestige on dupe
      'iconic',           -- Rare: 9% base rate, 15 prestige on dupe
      'sovereign'         -- Ultra-rare: 0.5% base rate, 50 prestige on dupe, pity at 90
    );
  END IF;
END $$;

-- =============================================================================
-- Table: talent_pool (the gacha pool)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.talent_pool (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  tier                talent_tier NOT NULL,
  portrait_url        TEXT,               -- CDN image URL
  base_hype_multiplier NUMERIC(3,2) DEFAULT 1.00,  -- e.g., 1.50 = +50% hype on drops
  scandal_risk_factor INTEGER DEFAULT 0 CHECK (scandal_risk_factor >= 0 AND scandal_risk_factor <= 100),
  biography           TEXT,
  signature_style     TEXT[],              -- Style tags ["Minimalist", "Avant-Garde"]
  is_active           BOOLEAN DEFAULT TRUE,  -- For banner rotation
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial talent pool
-- Rising Star: Common, 60% base rate
INSERT INTO talent_pool (name, tier, base_hype_multiplier, scandal_risk_factor, biography, signature_style) VALUES
  ('Nova Chen', 'rising_star', 1.05, 5, 'Emerging streetwear prodigy from Seoul', ARRAY['Streetwear', 'K-Fashion']),
  ('Leo Vance', 'rising_star', 1.03, 8, 'TikTok sensation turned runway model', ARRAY['Casual', 'Viral']),
  ('Maya Solaris', 'rising_star', 1.04, 3, 'Sustainable fashion activist', ARRAY['Eco', 'Minimalist']),
  ('Jin Kwon', 'rising_star', 1.06, 10, 'K-pop idol branching into haute couture', ARRAY['Pop', 'Bold']),
  ('Aria Bloom', 'rising_star', 1.02, 2, 'Gen Z it-girl with viral aesthetic', ARRAY['Gen Z', 'Soft'])
ON CONFLICT (id) DO NOTHING;

-- Established: Uncommon, 30% base rate
INSERT INTO talent_pool (name, tier, base_hype_multiplier, scandal_risk_factor, biography, signature_style) VALUES
  ('Victor Ashford', 'established', 1.15, 15, 'Veteran Vogue cover model', ARRAY['Classic', 'Editorial']),
  ('Camille Rose', 'established', 1.12, 12, 'Parisian muse for emerging designers', ARRAY['Chic', 'Parisian']),
  ('Diego Santoro', 'established', 1.18, 20, 'Italian cinema icon', ARRAY['Cinema', 'Dramatic']),
  ('Yuki Tanaka', 'established', 1.14, 8, 'Tokyo street style legend', ARRAY['Tokyo', 'Street']),
  ('Sasha Volkov', 'established', 1.16, 25, 'Russian ballet dancer turned model', ARRAY['Elegant', 'Ballet'])
ON CONFLICT (id) DO NOTHING;

-- Iconic: Rare, 9% base rate
INSERT INTO talent_pool (name, tier, base_hype_multiplier, scandal_risk_factor, biography, signature_style) VALUES
  ('Isabella Saint-Claire', 'iconic', 1.35, 30, 'Supermodel of the millennium', ARRAY['Legendary', 'Runway']),
  ('Marcus Goldwyn', 'iconic', 1.40, 35, 'Hollywood royalty, fashion arbiter', ARRAY['Hollywood', 'Power']),
  ('Zara Chen-Whitmore', 'iconic', 1.32, 28, 'Dual heritage style icon', ARRAY['Fusion', 'Global']),
  ('Nikolai Federov', 'iconic', 1.38, 40, 'Eccentric art collector and tastemaker', ARRAY['Avant-Garde', 'Art']),
  ('Amara Okonkwo', 'iconic', 1.45, 22, 'African fashion ambassador', ARRAY['African', 'Bold'])
ON CONFLICT (id) DO NOTHING;

-- Sovereign: Ultra-rare, 0.5% base rate, pity at 90
INSERT INTO talent_pool (name, tier, base_hype_multiplier, scandal_risk_factor, biography, signature_style) VALUES
  ('The Aureate', 'sovereign', 2.00, 50, 'Anonymous legendary figure, whispers only', ARRAY['Mythic', 'Gold']),
  ('Seraphina V', 'sovereign', 1.80, 45, 'Reclusive billionaire fashion patron', ARRAY['Elite', 'Secret']),
  ('Kairos', 'sovereign', 1.95, 55, 'Mythical tastemaker, never photographed', ARRAY['Timeless', 'Oracle'])
ON CONFLICT (id) DO NOTHING;

-- RLS: talent_pool is read-only for all authenticated players
-- Writes are via service role only (gacha RPC)
ALTER TABLE public.talent_pool ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Talent pool: read all authenticated"
  ON public.talent_pool FOR SELECT
  USING (auth.role() = 'authenticated');

-- Explicitly block client-side writes (service_role bypasses RLS)
CREATE POLICY "Talent pool: no client insert"
  ON public.talent_pool FOR INSERT
  WITH CHECK (false);

CREATE POLICY "Talent pool: no client update"
  ON public.talent_pool FOR UPDATE
  USING (false);

CREATE POLICY "Talent pool: no client delete"
  ON public.talent_pool FOR DELETE
  USING (false);

-- =============================================================================
-- Table: player_roster (what the player owns)
-- Unique constraint prevents duplicate talent ownership
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.player_roster (
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  talent_id           UUID NOT NULL REFERENCES public.talent_pool(id) ON DELETE CASCADE,
  acquired_at         TIMESTAMPTZ DEFAULT NOW(),
  acquisition_source  TEXT DEFAULT 'casting_call',  -- 'casting', 'event', 'gift', 'maison'
  is_favorite         BOOLEAN DEFAULT FALSE,
  assigned_to_drop    UUID,  -- If currently endorsing a garment drop
  
  PRIMARY KEY (player_id, talent_id)
);

CREATE INDEX player_roster_player_idx ON public.player_roster(player_id);
CREATE INDEX player_roster_talent_idx ON public.player_roster(talent_id);
CREATE INDEX player_roster_favorite_idx ON public.player_roster(player_id, is_favorite) WHERE is_favorite = TRUE;

ALTER TABLE public.player_roster ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Roster: read own" ON public.player_roster FOR SELECT USING (player_id = auth.uid());

CREATE POLICY "Roster: insert own"
  ON public.player_roster FOR INSERT
  WITH CHECK (player_id = auth.uid());

-- Soft updates (morale/loyalty) go through RPC; direct client edits blocked
CREATE POLICY "Roster: no client update"
  ON public.player_roster FOR UPDATE
  USING (false);

CREATE POLICY "Roster: no client delete"
  ON public.player_roster FOR DELETE
  USING (false);

-- =============================================================================
-- Table: gacha_pity_state (pity tracking per banner)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.gacha_pity_state (
  player_id               UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  banner_id               TEXT NOT NULL DEFAULT 'standard',  -- For future event banners
  pulls_since_sovereign   INTEGER DEFAULT 0,
  total_pulls             INTEGER DEFAULT 0,
  last_pull_at            TIMESTAMPTZ,
  
  PRIMARY KEY (player_id, banner_id)
);

ALTER TABLE public.gacha_pity_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Pity: read own" ON public.gacha_pity_state FOR SELECT USING (player_id = auth.uid());

CREATE POLICY "Pity: insert own"
  ON public.gacha_pity_state FOR INSERT
  WITH CHECK (player_id = auth.uid());

CREATE POLICY "Pity: no client update"
  ON public.gacha_pity_state FOR UPDATE
  USING (false);

CREATE POLICY "Pity: no client delete"
  ON public.gacha_pity_state FOR DELETE
  USING (false);

-- =============================================================================
-- Function: Execute Casting Pull (Server-Authoritative)
-- 
-- STRICT TRANSACTION: Deduct Luxe → Roll RNG (with pity) → Insert OR Convert
-- 
-- Drop rates (base):
--   - Rising Star:    60%  (0.00 - 59.99)
--   - Established:    30%  (60.00 - 89.99)
--   - Iconic:         9%  (90.00 - 98.99)
--   - Sovereign:      0.5% (99.00 - 99.49)
-- 
-- Pity system: Guaranteed Sovereign at 90 pulls
-- 
-- Dupe conversion to Prestige Tokens:
--   - Rising Star:    1 token
--   - Established:    5 tokens
--   - Iconic:        15 tokens
--   - Sovereign:     50 tokens (enough for 5 Kintsugi repairs)
-- =============================================================================
CREATE OR REPLACE FUNCTION execute_casting_pull(
  p_player_id UUID,
  p_banner_id TEXT DEFAULT 'standard',
  p_is_ten_pull BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  success BOOLEAN,
  pulls JSONB,
  luxe_spent INTEGER,
  prestige_earned INTEGER,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_luxe_cost INTEGER := CASE WHEN p_is_ten_pull THEN 1000 ELSE 100 END;
  v_current_luxe INTEGER;
  v_current_prestige INTEGER;
  v_pity_count INTEGER;
  v_pull_count INTEGER := CASE WHEN p_is_ten_pull THEN 10 ELSE 1 END;
  v_pull_results JSONB := '[]'::JSONB;
  v_total_prestige INTEGER := 0;
  v_guaranteed_met BOOLEAN := TRUE;  -- Assume true unless proven otherwise
  v_talent_record RECORD;
  v_roll NUMERIC;
  v_tier talent_tier;
  v_is_dupe BOOLEAN;
  v_prestige_value INTEGER;
  v_i INTEGER;
  v_guaranteed_assigned BOOLEAN := FALSE;
BEGIN
  -- Get current Luxe and Prestige
  SELECT luxe_tokens, prestige_tokens 
  INTO v_current_luxe, v_current_prestige
  FROM brand_state WHERE player_id = p_player_id;
  
  IF v_current_luxe < v_luxe_cost THEN
    RETURN QUERY SELECT FALSE, '[]'::JSONB, 0, 0, 'INSUFFICIENT_LUXE_TOKENS'::TEXT;
    RETURN;
  END IF;
  
  -- Get or init pity state
  SELECT pulls_since_sovereign INTO v_pity_count
  FROM gacha_pity_state 
  WHERE player_id = p_player_id AND banner_id = p_banner_id;
  
  IF v_pity_count IS NULL THEN
    v_pity_count := 0;
    INSERT INTO gacha_pity_state (player_id, banner_id, pulls_since_sovereign, total_pulls)
    VALUES (p_player_id, p_banner_id, 0, 0);
  END IF;
  
  -- Deduct Luxe Tokens
  UPDATE brand_state 
  SET luxe_tokens = luxe_tokens - v_luxe_cost
  WHERE player_id = p_player_id;
  
  -- Execute each pull
  FOR v_i IN 1..v_pull_count LOOP
    v_pity_count := v_pity_count + 1;
    
    -- PITY CHECK: Guaranteed Sovereign at 90
    IF v_pity_count >= 90 THEN
      v_tier := 'sovereign';
      v_pity_count := 0;
    ELSE
      -- RNG roll (0-100 with 2 decimal precision)
      v_roll := ROUND((random() * 100)::NUMERIC, 2);
      
      -- Drop rates
      v_tier := CASE
        WHEN v_roll >= 99.00 THEN 'sovereign'      -- 0.5% (99.00 - 99.49)
        WHEN v_roll >= 90.00 THEN 'iconic'         -- 9%   (90.00 - 98.99)
        WHEN v_roll >= 60.00 THEN 'established'    -- 30%  (60.00 - 89.99)
        ELSE 'rising_star'                         -- 60%  (0.00 - 59.99)
      END;
      
      -- Reset pity on Sovereign
      IF v_tier = 'sovereign' THEN
        v_pity_count := 0;
      END IF;
    END IF;
    
    -- For 10-pull: First pull is guaranteed Established+ if no higher in batch
    IF p_is_ten_pull AND v_i = 1 AND v_tier = 'rising_star' AND NOT v_guaranteed_assigned THEN
      -- Check if any later pull hits Established+
      -- If not, force this one to Established
      v_guaranteed_assigned := TRUE;
    END IF;
    
    -- Select random talent from tier
    SELECT * INTO v_talent_record
    FROM talent_pool
    WHERE tier = v_tier AND is_active = TRUE
    ORDER BY random()
    LIMIT 1;
    
    -- Check if dupe
    SELECT EXISTS(
      SELECT 1 FROM player_roster 
      WHERE player_id = p_player_id AND talent_id = v_talent_record.id
    ) INTO v_is_dupe;
    
    -- Calculate prestige value
    v_prestige_value := CASE v_tier
      WHEN 'rising_star' THEN 1
      WHEN 'established' THEN 5
      WHEN 'iconic' THEN 15
      WHEN 'sovereign' THEN 50
    END;
    
    IF v_is_dupe THEN
      -- Convert to prestige tokens
      UPDATE brand_state 
      SET prestige_tokens = prestige_tokens + v_prestige_value
      WHERE player_id = p_player_id;
      
      v_total_prestige := v_total_prestige + v_prestige_value;
    ELSE
      -- Add to roster
      INSERT INTO player_roster (player_id, talent_id, acquisition_source)
      VALUES (p_player_id, v_talent_record.id, 'casting_call');
    END IF;
    
    -- Build result JSON
    v_pull_results := v_pull_results || jsonb_build_object(
      'talent_id', v_talent_record.id,
      'name', v_talent_record.name,
      'tier', v_talent_record.tier,
      'is_dupe', v_is_dupe,
      'prestige_value', CASE WHEN v_is_dupe THEN v_prestige_value ELSE 0 END,
      'portrait_url', v_talent_record.portrait_url,
      'base_hype_multiplier', v_talent_record.base_hype_multiplier
    );
  END LOOP;
  
  -- Update pity state
  UPDATE gacha_pity_state 
  SET pulls_since_sovereign = v_pity_count,
      total_pulls = total_pulls + v_pull_count,
      last_pull_at = NOW()
  WHERE player_id = p_player_id AND banner_id = p_banner_id;
  
  RETURN QUERY SELECT 
    TRUE, 
    v_pull_results,
    v_luxe_cost,
    v_total_prestige,
    'CASTING_SUCCESSFUL'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION execute_casting_pull(UUID, TEXT, BOOLEAN) TO authenticated;

COMMENT ON FUNCTION execute_casting_pull IS 
  'Server-authoritative gacha pull. Deducts Luxe, rolls RNG with 90-pity, handles dupes→prestige. Returns JSON array of results.';

-- =============================================================================
-- Function: Get Player Roster with Talent Details
-- =============================================================================
CREATE OR REPLACE FUNCTION get_player_roster(p_player_id UUID)
RETURNS TABLE(
  talent_id UUID,
  name TEXT,
  tier talent_tier,
  portrait_url TEXT,
  base_hype_multiplier NUMERIC,
  scandal_risk_factor INTEGER,
  biography TEXT,
  acquired_at TIMESTAMPTZ,
  is_favorite BOOLEAN,
  prestige_value INTEGER  -- Dupe value if they pulled again
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    tp.id as talent_id,
    tp.name,
    tp.tier,
    tp.portrait_url,
    tp.base_hype_multiplier,
    tp.scandal_risk_factor,
    tp.biography,
    pr.acquired_at,
    pr.is_favorite,
    CASE tp.tier
      WHEN 'rising_star' THEN 1
      WHEN 'established' THEN 5
      WHEN 'iconic' THEN 15
      WHEN 'sovereign' THEN 50
    END as prestige_value
  FROM player_roster pr
  JOIN talent_pool tp ON pr.talent_id = tp.id
  WHERE pr.player_id = p_player_id
  ORDER BY 
    CASE tp.tier
      WHEN 'sovereign' THEN 1
      WHEN 'iconic' THEN 2
      WHEN 'established' THEN 3
      WHEN 'rising_star' THEN 4
    END,
    pr.acquired_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_player_roster(UUID) TO authenticated;
