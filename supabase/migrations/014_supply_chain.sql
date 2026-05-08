-- =============================================================================
-- Directive L: Supply Chain & Buffer Stock Engine
-- GDD §12.1.2 — Constrain idle income with warehouse capacity
-- Alabaster Standard: Physical logistics cap infinite generation
-- =============================================================================

-- =============================================================================
-- Alter brand_state: Add supply chain fields
-- =============================================================================
ALTER TABLE public.brand_state
  ADD COLUMN IF NOT EXISTS warehouse_capacity BIGINT DEFAULT 5000,
  ADD COLUMN IF NOT EXISTS current_inventory_value BIGINT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS logistics_level INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS idle_revenue_per_hour NUMERIC DEFAULT 0;

-- =============================================================================
-- RPC: Execute Liquidation
-- Convert warehouse inventory to liquid Capital (The Golden Hour)
-- =============================================================================
CREATE OR REPLACE FUNCTION execute_liquidation(p_player_id UUID)
RETURNS TABLE(liquidated_amount BIGINT, new_inventory BIGINT, new_revenue NUMERIC)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_inventory BIGINT;
  v_revenue NUMERIC;
BEGIN
  -- Get current inventory
  SELECT current_inventory_value, total_revenue 
  INTO v_inventory, v_revenue
  FROM brand_state 
  WHERE player_id = p_player_id;
  
  IF v_inventory IS NULL OR v_inventory <= 0 THEN
    RETURN QUERY SELECT 0::BIGINT, 0::BIGINT, v_revenue;
    RETURN;
  END IF;
  
  -- Transfer inventory to revenue
  UPDATE brand_state
  SET total_revenue = total_revenue + v_inventory,
      current_inventory_value = 0
  WHERE player_id = p_player_id
  RETURNING total_revenue INTO v_revenue;
  
  RETURN QUERY SELECT v_inventory, 0::BIGINT, v_revenue;
END;
$$;

GRANT EXECUTE ON FUNCTION execute_liquidation(UUID) TO authenticated;

-- =============================================================================
-- RPC: Upgrade Logistics
-- Increase warehouse capacity by 50% for escalating cost
-- Cost curve: 1000 * (1.5 ^ current_level)
-- =============================================================================
CREATE OR REPLACE FUNCTION upgrade_logistics(p_player_id UUID)
RETURNS TABLE(success BOOLEAN, new_level INTEGER, new_capacity BIGINT, cost BIGINT, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_level INTEGER;
  v_current_capacity BIGINT;
  v_revenue NUMERIC;
  v_cost BIGINT;
  v_new_capacity BIGINT;
BEGIN
  -- Get current stats
  SELECT logistics_level, warehouse_capacity, total_revenue
  INTO v_current_level, v_current_capacity, v_revenue
  FROM brand_state
  WHERE player_id = p_player_id;
  
  IF v_current_level IS NULL THEN
    v_current_level := 1;
    v_current_capacity := 5000;
  END IF;
  
  -- Calculate cost: 1000 * (1.5 ^ current_level)
  -- Level 1→2: 1500, Level 2→3: 2250, Level 3→4: 3375, etc.
  v_cost := (1000.0 * POWER(1.5, v_current_level))::BIGINT;
  
  -- Check funds
  IF v_revenue < v_cost THEN
    RETURN QUERY SELECT 
      FALSE, 
      v_current_level, 
      v_current_capacity, 
      v_cost, 
      format('INSUFFICIENT_FUNDS: Need %s Capital', v_cost)::TEXT;
    RETURN;
  END IF;
  
  -- Calculate new capacity: multiply by 1.5x
  v_new_capacity := (v_current_capacity * 1.5)::BIGINT;
  
  -- Deduct cost and upgrade
  UPDATE brand_state
  SET total_revenue = total_revenue - v_cost,
      logistics_level = logistics_level + 1,
      warehouse_capacity = v_new_capacity
  WHERE player_id = p_player_id;
  
  RETURN QUERY SELECT 
    TRUE, 
    v_current_level + 1, 
    v_new_capacity, 
    v_cost, 
    'UPGRADE_SUCCESSFUL'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION upgrade_logistics(UUID) TO authenticated;

-- =============================================================================
-- RPC: Add Inventory (Called by idle engine)
-- Adds generated revenue to inventory, clamped by warehouse capacity
-- Returns actual amount added and whether warehouse is now full
-- =============================================================================
CREATE OR REPLACE FUNCTION add_inventory(p_player_id UUID, p_amount BIGINT)
RETURNS TABLE(added_amount BIGINT, new_inventory BIGINT, is_full BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current BIGINT;
  v_capacity BIGINT;
  v_new_inventory BIGINT;
  v_actual_add BIGINT;
BEGIN
  SELECT current_inventory_value, warehouse_capacity
  INTO v_current, v_capacity
  FROM brand_state
  WHERE player_id = p_player_id;
  
  -- Handle nulls
  IF v_current IS NULL THEN v_current := 0; END IF;
  IF v_capacity IS NULL THEN v_capacity := 5000; END IF;
  
  -- Calculate how much can actually be added (clamp to capacity)
  v_actual_add := LEAST(p_amount, GREATEST(0, v_capacity - v_current));
  v_new_inventory := v_current + v_actual_add;
  
  -- Update inventory
  UPDATE brand_state
  SET current_inventory_value = v_new_inventory
  WHERE player_id = p_player_id;
  
  RETURN QUERY SELECT v_actual_add, v_new_inventory, (v_new_inventory >= v_capacity);
END;
$$;

GRANT EXECUTE ON FUNCTION add_inventory(UUID, BIGINT) TO authenticated;

-- =============================================================================
-- RPC: Process Idle Income (Atomic offline catch-up)
-- 
-- Called by idle engine on tick or resume.
-- Calculates total elapsed time, converts to revenue, adds to inventory.
-- O(1) time complexity - single RPC call handles entire catch-up.
-- =============================================================================
CREATE OR REPLACE FUNCTION process_idle_income(p_player_id UUID)
RETURNS TABLE(
  added_to_inventory BIGINT,
  new_inventory BIGINT,
  is_full BOOLEAN,
  idle_revenue_per_hour NUMERIC,
  seconds_elapsed BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_active TIMESTAMPTZ;
  v_idle_rate NUMERIC;
  v_now TIMESTAMPTZ := NOW();
  v_elapsed_seconds BIGINT;
  v_generated_amount BIGINT;
  v_add_result RECORD;
BEGIN
  -- Get player's idle rate and last active time
  SELECT idle_revenue_per_hour, last_active_at
  INTO v_idle_rate, v_last_active
  FROM brand_state
  WHERE player_id = p_player_id;
  
  IF v_idle_rate IS NULL OR v_idle_rate <= 0 THEN
    -- No idle income configured
    RETURN QUERY SELECT 
      0::BIGINT, 
      bs.current_inventory_value,
      bs.current_inventory_value >= bs.warehouse_capacity,
      0::NUMERIC,
      0::BIGINT
    FROM brand_state bs
    WHERE bs.player_id = p_player_id;
    RETURN;
  END IF;
  
  -- Calculate elapsed time
  IF v_last_active IS NULL THEN
    v_elapsed_seconds := 60; -- Default to 1 minute if no last_active
  ELSE
    v_elapsed_seconds := EXTRACT(EPOCH FROM (v_now - v_last_active))::BIGINT;
  END IF;
  
  -- Cap elapsed time to prevent exploitation (max 24 hours = 86400 seconds)
  v_elapsed_seconds := LEAST(v_elapsed_seconds, 86400);
  
  -- Calculate generated amount: (rate per hour / 3600) * elapsed seconds
  v_generated_amount := ((v_idle_rate / 3600.0) * v_elapsed_seconds)::BIGINT;
  
  -- Add to inventory using atomic add_inventory function
  SELECT * INTO v_add_result
  FROM add_inventory(p_player_id, v_generated_amount);
  
  -- Update last_active timestamp
  UPDATE brand_state
  SET last_active_at = v_now
  WHERE player_id = p_player_id;
  
  RETURN QUERY SELECT 
    v_add_result.added_amount,
    v_add_result.new_inventory,
    v_add_result.is_full,
    v_idle_rate,
    v_elapsed_seconds;
END;
$$;

GRANT EXECUTE ON FUNCTION process_idle_income(UUID) TO authenticated;

-- =============================================================================
-- View: Supply Chain Status
-- Real-time warehouse status for all players
-- =============================================================================
CREATE OR REPLACE VIEW supply_chain_status AS
SELECT 
  player_id,
  warehouse_capacity,
  current_inventory_value,
  logistics_level,
  ROUND((current_inventory_value::NUMERIC / NULLIF(warehouse_capacity, 0)) * 100, 1) AS fill_percent,
  (current_inventory_value >= warehouse_capacity) AS is_full,
  GREATEST(0, warehouse_capacity - current_inventory_value) AS remaining_space,
  idle_revenue_per_hour,
  last_active_at
FROM brand_state;

-- =============================================================================
-- Comments
-- =============================================================================
COMMENT ON FUNCTION execute_liquidation IS 'Convert warehouse inventory to liquid Capital (The Golden Hour)';
COMMENT ON FUNCTION upgrade_logistics IS 'Increase warehouse capacity by 50% for escalating cost (1000 * 1.5^level)';
COMMENT ON FUNCTION add_inventory IS 'Add generated revenue to inventory (capped by warehouse capacity)';
COMMENT ON FUNCTION process_idle_income IS 'Atomic offline catch-up: calculates elapsed time, generates revenue, adds to inventory. O(1) complexity.';

COMMENT ON TABLE brand_state IS 'Extended with supply chain fields: warehouse_capacity, current_inventory_value, logistics_level';
