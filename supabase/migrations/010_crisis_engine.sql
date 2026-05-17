-- =============================================================================
-- The Styliste — Crisis Engine Migration (Tarnish & Kintsugi)
-- GDD §8.9.2 — Reputation fragility and golden repair
-- Alabaster Standard: Scars tell the story of survival
-- =============================================================================

-- =============================================================================
-- ALTER brand_state: Add tarnish and kintsugi tracking
-- =============================================================================
ALTER TABLE public.brand_state 
  ADD COLUMN IF NOT EXISTS current_tarnish INTEGER NOT NULL DEFAULT 0 
    CHECK (current_tarnish >= 0 AND current_tarnish <= 100),
  ADD COLUMN IF NOT EXISTS kintsugi_level INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_scandals_survived INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS prestige_tokens INTEGER NOT NULL DEFAULT 0;  -- Future Gacha system

CREATE INDEX IF NOT EXISTS brand_state_tarnish_idx ON public.brand_state(current_tarnish);

-- =============================================================================
-- scandal_events: Active crises log
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.scandal_events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  celebrity_id    UUID,  -- Nullable: future Gacha system hook
  scandal_type    TEXT NOT NULL CHECK (scandal_type IN (
    'endorser_rogue', 'trend_missed', 'supply_chain', 'pr_crisis', 'rival_sabotage', 'kintsugi_repair'
  )),
  severity_score  INTEGER NOT NULL CHECK (severity_score >= 0 AND severity_score <= 100),
  final_tarnish   INTEGER NOT NULL,  -- After resistance calculation
  description     TEXT NOT NULL,
  triggered_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at     TIMESTAMPTZ,
  resolution_type TEXT CHECK (resolution_type IN ('kintsugi', 'apology', 'ignored'))
);

CREATE INDEX IF NOT EXISTS scandal_events_player_idx ON public.scandal_events(player_id);
CREATE INDEX IF NOT EXISTS scandal_events_active_idx ON public.scandal_events(player_id) WHERE resolved_at IS NULL;

ALTER TABLE public.scandal_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Scandal events: read own" ON public.scandal_events FOR SELECT USING (player_id = auth.uid());

-- =============================================================================
-- RPC: Apply Kintsugi Repair
-- Deducts capital (30%) + prestige tokens, resets tarnish, increments kintsugi_level
-- =============================================================================
CREATE OR REPLACE FUNCTION apply_kintsugi_repair(
  p_player_id UUID,
  p_prestige_token_cost INTEGER DEFAULT 10
)
RETURNS TABLE(success BOOLEAN, message TEXT, new_kintsugi_level INTEGER, capital_spent BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_tarnish INTEGER;
  v_current_kintsugi INTEGER;
  v_current_capital NUMERIC;
  v_capital_cost NUMERIC;
  v_current_prestige INTEGER;
BEGIN
  PERFORM public.assert_self(p_player_id);
  -- Authorization check
  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Cross-player modification attempt';
  END IF;

  -- Get current state
  SELECT bs.current_tarnish, bs.kintsugi_level, bs.total_revenue, bs.prestige_tokens
  INTO v_current_tarnish, v_current_kintsugi, v_current_capital, v_current_prestige
  FROM brand_state bs WHERE bs.player_id = p_player_id;
  
  -- Check if tarnished
  IF v_current_tarnish = 0 THEN
    RETURN QUERY SELECT FALSE, 'NO_TARNISH_TO_REPAIR'::TEXT, v_current_kintsugi, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Calculate capital cost (30% of treasury)
  v_capital_cost := v_current_capital * 0.30;
  
  -- Verify sufficient capital
  IF v_current_capital < v_capital_cost THEN
    RETURN QUERY SELECT FALSE, 'INSUFFICIENT_CAPITAL'::TEXT, v_current_kintsugi, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Verify prestige tokens (future system - for now auto-pass if 0)
  IF v_current_prestige < p_prestige_token_cost AND v_current_prestige > 0 THEN
    RETURN QUERY SELECT FALSE, 'INSUFFICIENT_PRESTIGE_TOKENS'::TEXT, v_current_kintsugi, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Deduct capital and prestige
  UPDATE brand_state 
  SET total_revenue = total_revenue - v_capital_cost,
      prestige_tokens = GREATEST(0, prestige_tokens - p_prestige_token_cost)
  WHERE player_id = p_player_id;
  
  -- Apply Kintsugi: Reset tarnish, increment level, track survival
  UPDATE brand_state 
  SET current_tarnish = 0,
      kintsugi_level = kintsugi_level + 1,
      total_scandals_survived = total_scandals_survived + 1
  WHERE player_id = p_player_id
  RETURNING kintsugi_level INTO v_current_kintsugi;
  
  -- Log the repair as a resolved scandal event
  INSERT INTO scandal_events (
    player_id, scandal_type, severity_score, final_tarnish,
    description, triggered_at, resolved_at, resolution_type
  ) VALUES (
    p_player_id, 'kintsugi_repair', 0, 0,
    'Brand restored through Kintsugi ritual. Capital spent: $' || v_capital_cost::TEXT,
    NOW(), NOW(), 'kintsugi'
  );
  
  RETURN QUERY SELECT TRUE, 'KINTSUGI_SUCCESSFUL'::TEXT, v_current_kintsugi, v_capital_cost::BIGINT;
END;
$$;

-- =============================================================================
-- RPC: Apply Public Apology (cheaper, partial solution)
-- Costs 10% capital, reduces tarnish by up to 30
-- =============================================================================
CREATE OR REPLACE FUNCTION apply_public_apology(p_player_id UUID)
RETURNS TABLE(success BOOLEAN, message TEXT, tarnish_reduced INTEGER, capital_spent BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_tarnish INTEGER;
  v_current_capital NUMERIC;
  v_capital_cost NUMERIC;
  v_reduction INTEGER;
BEGIN
  PERFORM public.assert_self(p_player_id);
  -- Authorization check
  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Cross-player modification attempt';
  END IF;

  SELECT current_tarnish, total_revenue
  INTO v_current_tarnish, v_current_capital
  FROM brand_state WHERE player_id = p_player_id;
  
  IF v_current_tarnish = 0 THEN
    RETURN QUERY SELECT FALSE, 'NO_TARNISH_TO_APOLOGIZE_FOR'::TEXT, 0::INTEGER, 0::BIGINT;
    RETURN;
  END IF;
  
  -- Calculate costs
  v_capital_cost := v_current_capital * 0.10;
  v_reduction := LEAST(30, v_current_tarnish);  -- Max 30 reduction
  
  -- Deduct capital and reduce tarnish
  UPDATE brand_state 
  SET current_tarnish = GREATEST(0, current_tarnish - v_reduction),
      total_revenue = total_revenue - v_capital_cost
  WHERE player_id = p_player_id;
  
  -- Log the apology
  INSERT INTO scandal_events (
    player_id, scandal_type, severity_score, final_tarnish,
    description, triggered_at, resolved_at, resolution_type
  ) VALUES (
    p_player_id, 'pr_crisis', v_reduction, GREATEST(0, v_current_tarnish - v_reduction),
    'Public apology issued. Capital spent: $' || v_capital_cost::TEXT,
    NOW(), NOW(), 'apology'
  );
  
  RETURN QUERY SELECT TRUE, 'APOLOGY_PUBLISHED'::TEXT, v_reduction, v_capital_cost::BIGINT;
END;
$$;

-- =============================================================================
-- RPC: Trigger Scandal (for testing and automated events)
-- Calculates final tarnish using the Kode formula:
-- final_tarnish = base_severity / (1 + kintsugi*0.25 + sovereign*0.15)
-- =============================================================================
CREATE OR REPLACE FUNCTION trigger_scandal(
  p_player_id UUID,
  p_scandal_type TEXT,
  p_base_severity INTEGER,
  p_description TEXT DEFAULT 'Scandal event triggered'
)
RETURNS TABLE(success BOOLEAN, final_tarnish INTEGER, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_tarnish INTEGER;
  v_kintsugi_level INTEGER;
  v_sovereign_multipliers INTEGER;
  v_resistance NUMERIC;
  v_calculated_tarnish INTEGER;
  v_new_total INTEGER;
BEGIN
  -- Get player resilience stats
  SELECT 
    bs.current_tarnish,
    bs.kintsugi_level,
    COALESCE(p.sovereign_multipliers, 0)
  INTO 
    v_current_tarnish,
    v_kintsugi_level,
    v_sovereign_multipliers
  FROM brand_state bs
  JOIN players p ON bs.player_id = p.id
  WHERE bs.player_id = p_player_id;
  
  -- Kode Formula: resistance = 1 + kintsugi*0.25 + sovereign*0.15
  v_resistance := 1.0 + (v_kintsugi_level * 0.25) + (v_sovereign_multipliers * 0.15);
  
  -- Calculate final tarnish
  v_calculated_tarnish := CEIL(p_base_severity / v_resistance)::INTEGER;
  v_new_total := LEAST(100, v_current_tarnish + v_calculated_tarnish);
  
  -- Update tarnish
  UPDATE brand_state 
  SET current_tarnish = v_new_total
  WHERE player_id = p_player_id;
  
  -- Log scandal
  INSERT INTO scandal_events (
    player_id, scandal_type, severity_score, final_tarnish,
    description, triggered_at
  ) VALUES (
    p_player_id, p_scandal_type, p_base_severity, v_calculated_tarnish,
    p_description || ' (Resistance: ' || v_resistance::TEXT || ')',
    NOW()
  );
  
  -- Check for lockdown
  IF v_new_total >= 100 THEN
    RETURN QUERY SELECT TRUE, v_new_total, 'LOCKDOWN_TRIGGERED'::TEXT;
  ELSE
    RETURN QUERY SELECT TRUE, v_calculated_tarnish, 'SCANDAL_ABSORBED'::TEXT;
  END IF;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION apply_kintsugi_repair(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION apply_public_apology(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION trigger_scandal(UUID, TEXT, INTEGER, TEXT) TO authenticated;

-- Comments
COMMENT ON FUNCTION apply_kintsugi_repair IS 
  'Kintsugi repair ritual: Deducts 30% capital + prestige tokens, resets tarnish, increments kintsugi_level. Returns new level and capital spent.';
  
COMMENT ON FUNCTION trigger_scandal IS 
  'Triggers scandal with Kode formula: final_tarnish = base_severity / (1 + kintsugi*0.25 + sovereign*0.15). Returns final tarnish applied.';


