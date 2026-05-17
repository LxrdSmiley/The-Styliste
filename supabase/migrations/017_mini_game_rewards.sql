-- =============================================================================
-- Directive O: Mini-Game Reward RPCs
-- The Zero-Stub Mandate — Server-authoritative economy wiring
-- =============================================================================

-- =============================================================================
-- RPC: inject_capital_bonus
-- Injects a one-time Capital bonus (e.g., 5000 for successful takeover)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.inject_capital_bonus(
    p_player_id UUID,
    p_amount INT,
    p_reason TEXT DEFAULT 'mini_game_reward'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_old_capital NUMERIC;
    v_new_capital NUMERIC;
BEGIN
    -- Authorization check
    IF auth.uid() != p_player_id THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Reward injection blocked';
    END IF;

    -- Validate player exists
    IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_player_id) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Player not found'
        );
    END IF;

    -- Get current capital
    SELECT total_revenue INTO v_old_capital
    FROM public.brand_state
    WHERE player_id = p_player_id;

    -- Apply bonus
    UPDATE public.brand_state
    SET total_revenue = total_revenue + p_amount
    WHERE player_id = p_player_id;

    -- Get new capital
    SELECT total_revenue INTO v_new_capital
    FROM public.brand_state
    WHERE player_id = p_player_id;

    -- Log the bonus injection
    INSERT INTO public.provenance_ledger (
        design_id,
        seller_id,
        buyer_id,
        sale_price,
        platform_fee,
        seller_net,
        provenance_note
    )
    VALUES (
        NULL,  -- No design for pure capital injection
        '00000000-0000-0000-0000-000000000000'::UUID,  -- System
        p_player_id,
        p_amount,
        0,
        p_amount,
        'Capital bonus: ' || p_reason
    );

    RETURN jsonb_build_object(
        'success', true,
        'old_capital', v_old_capital,
        'new_capital', v_new_capital,
        'bonus_amount', p_amount,
        'reason', p_reason
    );
END;
$$;

-- RLS: Only authenticated users can call for themselves
GRANT EXECUTE ON FUNCTION public.inject_capital_bonus(UUID, INT, TEXT) TO authenticated;

-- =============================================================================
-- RPC: apply_idle_multiplier
-- Applies a temporary idle income multiplier buff/debuff
-- =============================================================================
CREATE OR REPLACE FUNCTION public.apply_idle_multiplier(
    p_player_id UUID,
    p_multiplier NUMERIC,  -- e.g., 1.35 for +35%, 0.85 for -15%
    p_duration_hours INT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Authorization check
    IF auth.uid() != p_player_id THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Reward injection blocked';
    END IF;

    -- Validate player exists
    IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_player_id) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Player not found'
        );
    END IF;

    -- Calculate expiry
    v_expires_at := NOW() + (p_duration_hours || ' hours')::INTERVAL;

    -- Add multiplier buff to brand_state (stored as JSONB in a new column)
    -- First, ensure the column exists
    ALTER TABLE public.brand_state
        ADD COLUMN IF NOT EXISTS active_buffs JSONB DEFAULT '[]'::JSONB;

    -- Add the buff
    UPDATE public.brand_state
    SET active_buffs = active_buffs || jsonb_build_array(
        jsonb_build_object(
            'type', 'idle_multiplier',
            'multiplier', p_multiplier,
            'expires_at', v_expires_at,
            'applied_at', NOW()
        )
    )
    WHERE player_id = p_player_id;

    RETURN jsonb_build_object(
        'success', true,
        'multiplier', p_multiplier,
        'duration_hours', p_duration_hours,
        'expires_at', v_expires_at
    );
END;
$$;

-- RLS: Only authenticated users can call for themselves
GRANT EXECUTE ON FUNCTION public.apply_idle_multiplier(UUID, NUMERIC, INT) TO authenticated;

-- =============================================================================
-- RPC: reset_talent_stamina
-- Resets a talent's stamina/morale to 100%
-- =============================================================================
DROP FUNCTION IF EXISTS public.reset_talent_stamina(UUID, UUID);
CREATE OR REPLACE FUNCTION public.reset_talent_stamina(
    p_player_id UUID,
    p_talent_id TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    PERFORM public.assert_self(p_player_id);

    UPDATE public.player_roster
    SET stamina = 100,
        last_stamina_refresh = NOW()
    WHERE player_id = p_player_id
      AND talent_id::TEXT = p_talent_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        RETURN json_build_object('success', false, 'error', 'Talent not found');
    END IF;

    RETURN json_build_object('success', true, 'stamina', 100);
END;
$$;

-- RLS: Only authenticated users can call for themselves
GRANT EXECUTE ON FUNCTION public.reset_talent_stamina(UUID, TEXT) TO authenticated;

-- =============================================================================
-- RPC: apply_logistics_discount
-- Applies a temporary logistics upgrade cost discount
-- =============================================================================
CREATE OR REPLACE FUNCTION public.apply_logistics_discount(
    p_player_id UUID,
    p_discount_pct NUMERIC,  -- e.g., 15 for 15%
    p_duration_days INT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Authorization check
    IF auth.uid() != p_player_id THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Reward injection blocked';
    END IF;

    -- Validate player exists
    IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_player_id) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Player not found'
        );
    END IF;

    -- Calculate expiry
    v_expires_at := NOW() + (p_duration_days || ' days')::INTERVAL;

    -- Add discount buff to brand_state
    UPDATE public.brand_state
    SET active_buffs = COALESCE(active_buffs, '[]'::JSONB) || jsonb_build_array(
        jsonb_build_object(
            'type', 'logistics_discount',
            'discount_pct', p_discount_pct,
            'expires_at', v_expires_at,
            'applied_at', NOW()
        )
    )
    WHERE player_id = p_player_id;

    RETURN jsonb_build_object(
        'success', true,
        'discount_pct', p_discount_pct,
        'duration_days', p_duration_days,
        'expires_at', v_expires_at
    );
END;
$$;

-- RLS: Only authenticated users can call for themselves
GRANT EXECUTE ON FUNCTION public.apply_logistics_discount(UUID, NUMERIC, INT) TO authenticated;

-- =============================================================================
-- RPC: halt_supply_chain
-- Triggers the isSupplyChainHalted flag (loss condition for Supplier Raid)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.halt_supply_chain(
    p_player_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Authorization check
    IF auth.uid() != p_player_id THEN
        RAISE EXCEPTION 'UNAUTHORIZED: Reward injection blocked';
    END IF;

    -- Validate player exists
    IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_player_id) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Player not found'
        );
    END IF;

    -- Set halt flag and timestamp
    UPDATE public.brand_state
    SET is_supply_chain_halted = TRUE,
        supply_chain_halted_at = NOW()
    WHERE player_id = p_player_id;

    RETURN jsonb_build_object(
        'success', true,
        'halted_at', NOW(),
        'message', 'Supply chain operations halted. Manual reset required.'
    );
END;
$$;

-- RLS: Only authenticated users can call for themselves
GRANT EXECUTE ON FUNCTION public.halt_supply_chain(UUID) TO authenticated;

-- =============================================================================
-- Table Alterations for Buff System
-- =============================================================================

-- Add active_buffs column if not exists
ALTER TABLE public.brand_state
    ADD COLUMN IF NOT EXISTS active_buffs JSONB DEFAULT '[]'::JSONB;

-- Add supply chain halt tracking
ALTER TABLE public.brand_state
    ADD COLUMN IF NOT EXISTS is_supply_chain_halted BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS supply_chain_halted_at TIMESTAMPTZ;

-- Add power move combo multiplier storage (for next liquidation)
ALTER TABLE public.brand_state
    ADD COLUMN IF NOT EXISTS pending_power_move_multiplier NUMERIC DEFAULT 1.0,
    ADD COLUMN IF NOT EXISTS power_move_expires_at TIMESTAMPTZ;

-- =============================================================================
-- View: Active Buffs (for client display)
-- =============================================================================
CREATE OR REPLACE VIEW public.player_active_buffs AS
SELECT
    bs.player_id,
    jsonb_array_elements(bs.active_buffs) as buff,
    (jsonb_array_elements(bs.active_buffs)->>'expires_at')::TIMESTAMPTZ as expires_at
FROM public.brand_state bs
WHERE bs.active_buffs IS NOT NULL
  AND jsonb_array_length(bs.active_buffs) > 0;

-- =============================================================================
-- Comments
-- =============================================================================
COMMENT ON FUNCTION public.inject_capital_bonus IS 'Injects a one-time Capital bonus with audit trail in provenance_ledger';
COMMENT ON FUNCTION public.apply_idle_multiplier IS 'Applies temporary idle income multiplier buff/debuff';
COMMENT ON FUNCTION public.reset_talent_stamina IS 'Resets a talent stamina to 100% for successful Staff Rally';
COMMENT ON FUNCTION public.apply_logistics_discount IS 'Applies temporary logistics upgrade discount for successful Supplier Raid';
COMMENT ON FUNCTION public.halt_supply_chain IS 'Halts supply chain operations for failed Supplier Raid';
