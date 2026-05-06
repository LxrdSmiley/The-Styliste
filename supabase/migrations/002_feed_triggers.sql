-- =============================================================================
-- Migration 002: Feed Triggers & Hype RPC
-- GDD §6.1 — Postgres-native event broadcasting (Phase 6)
-- =============================================================================
-- All trigger functions use SECURITY DEFINER + explicit SET search_path = public
-- to prevent privilege escalation per Postgres security best practice.
-- Triggers fire inside the originating transaction — zero network latency,
-- bypass-proof regardless of client path.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Atomic hype increment RPC
--    Called by authenticated clients via Supabase .rpc('increment_post_hype').
--    No read-modify-write — eliminates concurrent increment race conditions.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.increment_post_hype(target_post_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.feed_posts
  SET hype = hype + 1
  WHERE id = target_post_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. on_design_minted — broadcasts Alpha drops to the Global Feed.
--    Fires AFTER INSERT ON designs; guard: NEW.is_alpha = TRUE.
--    Reads players.brand_name to enrich the JSONB payload.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_on_design_minted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_brand_name TEXT;
BEGIN
  -- Only broadcast true Alpha pieces.
  IF NEW.is_alpha IS NOT TRUE THEN
    RETURN NEW;
  END IF;

  -- Enrich payload with player brand name.
  SELECT brand_name INTO v_brand_name
  FROM public.players
  WHERE id = NEW.player_id;

  INSERT INTO public.feed_posts (player_id, type, content)
  VALUES (
    NEW.player_id,
    'design_flex',
    jsonb_build_object(
      'event',            'alpha_minted',
      'design_id',        NEW.id,
      'design_name',      NEW.name,
      'hype_score',       NEW.hype_score,
      'fabric_color_hex', COALESCE(NEW.fabric_data->>'color_hex', 'FAF7F0'),
      'brand_name',       COALESCE(v_brand_name, 'Unknown Sovereign')
    )
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_design_minted ON public.designs;
CREATE TRIGGER on_design_minted
  AFTER INSERT ON public.designs
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_on_design_minted();

-- ---------------------------------------------------------------------------
-- 3. on_store_upgraded — broadcasts Mogul store tier increases.
--    Fires AFTER UPDATE ON stores; guard: NEW.tier > OLD.tier.
--    Reads players.brand_name to enrich the JSONB payload.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_on_store_upgraded()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_brand_name TEXT;
BEGIN
  -- Only broadcast genuine tier promotions.
  IF NEW.tier <= OLD.tier THEN
    RETURN NEW;
  END IF;

  SELECT brand_name INTO v_brand_name
  FROM public.players
  WHERE id = NEW.player_id;

  INSERT INTO public.feed_posts (player_id, type, content)
  VALUES (
    NEW.player_id,
    'mogul_flex',
    jsonb_build_object(
      'event',       'store_upgraded',
      'store_id',    NEW.id,
      'city',        NEW.city,
      'store_type',  NEW.type,
      'new_tier',    NEW.tier,
      'brand_name',  COALESCE(v_brand_name, 'Unknown Sovereign')
    )
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_store_upgraded ON public.stores;
CREATE TRIGGER on_store_upgraded
  AFTER UPDATE ON public.stores
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_on_store_upgraded();
