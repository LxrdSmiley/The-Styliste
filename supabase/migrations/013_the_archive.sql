-- =============================================================================
-- The Archive — Resale & Provenance Engine
-- GDD §8.9.9, §12.4.3 — P2P market with 30% tax burn
-- Alabaster Standard: FOR UPDATE locks, 48-hour FOMO, elite price floors
-- =============================================================================

-- Listing status enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'listing_status') THEN
    CREATE TYPE listing_status AS ENUM ('active', 'sold', 'cancelled', 'expired');
  END IF;
END $$;

-- =============================================================================
-- Alter designs table: Add image_url for AR Try-On and Archive display
-- =============================================================================
ALTER TABLE public.designs 
  ADD COLUMN IF NOT EXISTS image_url TEXT;

-- =============================================================================
-- Alter players table: Add display_name for Archive seller display
-- =============================================================================
ALTER TABLE public.players 
  ADD COLUMN IF NOT EXISTS display_name TEXT;

-- =============================================================================
-- Alter brand_state table: Add rank and hall of sovereigns flag
-- =============================================================================
ALTER TABLE public.brand_state 
  ADD COLUMN IF NOT EXISTS brand_rank TEXT DEFAULT 'unranked',
  ADD COLUMN IF NOT EXISTS is_in_hall_of_sovereigns BOOLEAN DEFAULT FALSE;

-- =============================================================================
-- Table: archive_listings (P2P market)
-- 48-hour FOMO listings with strict price floors
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.archive_listings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  design_id       UUID NOT NULL REFERENCES public.designs(id),
  listing_price   BIGINT NOT NULL CHECK (listing_price >= 1000),  -- Elite baseline: 1000 min
  listed_at       TIMESTAMPTZ DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '48 hours'),
  status          listing_status DEFAULT 'active',
  
  -- Gala badges (for provenance display)
  is_gala_winner  BOOLEAN DEFAULT FALSE,
  gala_event_id   UUID REFERENCES public.gala_events(id),
  
  CONSTRAINT valid_price CHECK (listing_price >= 1000)
);

CREATE INDEX IF NOT EXISTS archive_listings_status_idx ON public.archive_listings(status);
CREATE INDEX IF NOT EXISTS archive_listings_price_idx ON public.archive_listings(listing_price);
CREATE INDEX IF NOT EXISTS archive_listings_seller_idx ON public.archive_listings(seller_id);
CREATE INDEX IF NOT EXISTS archive_listings_expiry_idx ON public.archive_listings(expires_at) WHERE status = 'active';

ALTER TABLE public.archive_listings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Listings: read all" ON public.archive_listings FOR SELECT USING (true);
CREATE POLICY "Listings: create own" ON public.archive_listings FOR INSERT WITH CHECK (seller_id = auth.uid());
CREATE POLICY "Listings: cancel own" ON public.archive_listings FOR UPDATE USING (seller_id = auth.uid());

-- =============================================================================
-- Table: provenance_ledger (ownership history)
-- Every transfer adds +10% to hype (max +100%), +50% if Sovereign owner
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.provenance_ledger (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  design_id       UUID NOT NULL REFERENCES public.designs(id) ON DELETE CASCADE,
  listing_id      UUID REFERENCES public.archive_listings(id),
  previous_owner_id UUID NOT NULL REFERENCES public.players(id),
  new_owner_id    UUID NOT NULL REFERENCES public.players(id),
  sale_price      BIGINT NOT NULL,
  platform_tax    BIGINT NOT NULL,  -- 30% burned/deflationary
  seller_payout   BIGINT NOT NULL,  -- 70% received by seller
  transferred_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX provenance_ledger_design_idx ON public.provenance_ledger(design_id);
CREATE INDEX provenance_ledger_new_owner_idx ON public.provenance_ledger(new_owner_id);
CREATE INDEX provenance_ledger_prev_owner_idx ON public.provenance_ledger(previous_owner_id);

ALTER TABLE public.provenance_ledger ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Ledger: read all" ON public.provenance_ledger FOR SELECT USING (true);

-- =============================================================================
-- Alter designs table: Add provenance tracking
-- =============================================================================
ALTER TABLE public.designs 
  ADD COLUMN IF NOT EXISTS provenance_multiplier NUMERIC(4,2) DEFAULT 1.00,
  ADD COLUMN IF NOT EXISTS has_sovereign_provenance BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS transfer_count INTEGER DEFAULT 0;

-- =============================================================================
-- RPC: Execute Archive Purchase (FOR UPDATE protected)
-- 
-- CRITICAL: Uses row-level lock to prevent double-spending on hot items
-- Tax: 30% burned (deflationary sink)
-- Payout: 70% to seller
-- =============================================================================
CREATE OR REPLACE FUNCTION execute_archive_purchase(
  p_buyer_id UUID,
  p_listing_id UUID
)
RETURNS TABLE(success BOOLEAN, transaction_id UUID, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_listing RECORD;
  v_design RECORD;
  v_buyer_capital NUMERIC;
  v_seller_capital NUMERIC;
  v_tax_amount BIGINT;
  v_payout_amount BIGINT;
  v_transaction_id UUID;
  v_seller_rank INTEGER;
  v_is_sovereign BOOLEAN;
  v_provenance_multiplier NUMERIC(4,2);
  v_new_transfer_count INTEGER;
BEGIN
  -- Lock the listing row (CRITICAL: Prevents double-spending on Gala Sovereign pieces)
  SELECT * INTO v_listing
  FROM archive_listings
  WHERE id = p_listing_id
    AND status = 'active'
    AND expires_at > NOW()
  FOR UPDATE;  -- Row-level lock: blocks all other buyers until commit/rollback
  
  IF v_listing IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'LISTING_NOT_AVAILABLE'::TEXT;
    RETURN;
  END IF;
  
  -- Cannot buy your own listing
  IF v_listing.seller_id = p_buyer_id THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'CANNOT_BUY_OWN_LISTING'::TEXT;
    RETURN;
  END IF;
  
  -- Verify buyer has sufficient capital
  SELECT total_revenue INTO v_buyer_capital
  FROM brand_state WHERE player_id = p_buyer_id;
  
  IF v_buyer_capital < v_listing.listing_price THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'INSUFFICIENT_CAPITAL'::TEXT;
    RETURN;
  END IF;
  
  -- Get design info
  SELECT * INTO v_design 
  FROM designs 
  WHERE id = v_listing.design_id;
  
  IF v_design IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'DESIGN_NOT_FOUND'::TEXT;
    RETURN;
  END IF;
  
  -- Verify minimum price floor: GREATEST(1000, hype_score * 10)
  IF v_listing.listing_price < GREATEST(1000, v_design.hype_score * 10) THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 
      format('PRICE_BELOW_FLOOR: Minimum is %s Capital', GREATEST(1000, v_design.hype_score * 10))::TEXT;
    RETURN;
  END IF;
  
  -- Calculate tax and payout (30% burn, 70% to seller)
  v_tax_amount := (v_listing.listing_price * 30) / 100;  -- Integer math
  v_payout_amount := v_listing.listing_price - v_tax_amount;
  
  -- Deduct from buyer
  UPDATE brand_state
  SET total_revenue = total_revenue - v_listing.listing_price
  WHERE player_id = p_buyer_id;
  
  -- Credit seller (70% only)
  UPDATE brand_state
  SET total_revenue = total_revenue + v_payout_amount
  WHERE player_id = v_listing.seller_id;
  
  -- Check if seller is Rank 100 (Hall of Sovereigns) for provenance bump
  SELECT brand_rank INTO v_seller_rank
  FROM brand_state 
  WHERE player_id = v_listing.seller_id;
  
  v_is_sovereign := (v_seller_rank >= 100);
  
  -- Calculate new provenance values
  v_new_transfer_count := COALESCE(v_design.transfer_count, 0) + 1;
  v_provenance_multiplier := 1.0 + LEAST(v_new_transfer_count * 0.10, 1.0);  -- +10% per owner, max +100%
  
  -- Add Sovereign bump (+50%) if applicable
  IF v_is_sovereign OR COALESCE(v_design.has_sovereign_provenance, FALSE) THEN
    v_provenance_multiplier := v_provenance_multiplier + 0.50;
  END IF;
  
  -- Cap at absolute maximum +150%
  v_provenance_multiplier := LEAST(v_provenance_multiplier, 2.50);
  
  -- Transfer ownership and update provenance
  UPDATE designs
  SET owner_id = p_buyer_id,
      provenance_multiplier = v_provenance_multiplier,
      has_sovereign_provenance = (v_is_sovereign OR COALESCE(has_sovereign_provenance, FALSE)),
      transfer_count = v_new_transfer_count
  WHERE id = v_listing.design_id;
  
  -- Log provenance
  INSERT INTO provenance_ledger (
    design_id, listing_id, previous_owner_id, new_owner_id,
    sale_price, platform_tax, seller_payout
  ) VALUES (
    v_listing.design_id, p_listing_id, v_listing.seller_id, p_buyer_id,
    v_listing.listing_price, v_tax_amount, v_payout_amount
  )
  RETURNING id INTO v_transaction_id;
  
  -- Mark listing as sold
  UPDATE archive_listings
  SET status = 'sold'
  WHERE id = p_listing_id;
  
  RETURN QUERY SELECT TRUE, v_transaction_id, 'PURCHASE_SUCCESSFUL'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION execute_archive_purchase(UUID, UUID) TO authenticated;

-- =============================================================================
-- RPC: List Garment on Archive
-- =============================================================================
CREATE OR REPLACE FUNCTION list_on_archive(
  p_seller_id UUID,
  p_design_id UUID,
  p_listing_price BIGINT,
  p_is_gala_winner BOOLEAN DEFAULT FALSE,
  p_gala_event_id UUID DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, listing_id UUID, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_design_owner UUID;
  v_hype_score INTEGER;
  v_min_price BIGINT;
  v_listing_id UUID;
  v_existing_listing UUID;
BEGIN
  -- Verify ownership
  SELECT owner_id, hype_score INTO v_design_owner, v_hype_score
  FROM designs WHERE id = p_design_id;
  
  IF v_design_owner IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'DESIGN_NOT_FOUND'::TEXT;
    RETURN;
  END IF;
  
  IF v_design_owner != p_seller_id THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'NOT_OWNER'::TEXT;
    RETURN;
  END IF;
  
  -- Check minimum price: GREATEST(1000, hype_score * 10)
  v_min_price := GREATEST(1000, v_hype_score * 10);
  IF p_listing_price < v_min_price THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 
      format('PRICE_TOO_LOW: Minimum is %s Capital', v_min_price)::TEXT;
    RETURN;
  END IF;
  
  -- Check if already listed
  SELECT id INTO v_existing_listing
  FROM archive_listings
  WHERE design_id = p_design_id AND status = 'active';
  
  IF v_existing_listing IS NOT NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'ALREADY_LISTED'::TEXT;
    RETURN;
  END IF;
  
  -- Create listing with 48-hour expiry
  INSERT INTO archive_listings (
    seller_id, design_id, listing_price,
    is_gala_winner, gala_event_id, expires_at
  ) VALUES (
    p_seller_id, p_design_id, p_listing_price,
    p_is_gala_winner, p_gala_event_id,
    NOW() + INTERVAL '48 hours'
  )
  RETURNING id INTO v_listing_id;
  
  RETURN QUERY SELECT TRUE, v_listing_id, 'LISTING_CREATED'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION list_on_archive(UUID, UUID, BIGINT, BOOLEAN, UUID) TO authenticated;

-- =============================================================================
-- RPC: Cancel Own Listing
-- =============================================================================
CREATE OR REPLACE FUNCTION cancel_archive_listing(p_listing_id UUID)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE archive_listings
  SET status = 'cancelled'
  WHERE id = p_listing_id
    AND seller_id = auth.uid()
    AND status = 'active';
  
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'LISTING_CANCELLED'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'LISTING_NOT_FOUND_OR_UNAUTHORIZED'::TEXT;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION cancel_archive_listing(UUID) TO authenticated;

-- =============================================================================
-- Function: Expire Old Listings (pg_cron daily)
-- Returns count of expired listings
-- =============================================================================
CREATE OR REPLACE FUNCTION expire_archive_listings()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_expired_count INTEGER;
BEGIN
  UPDATE archive_listings
  SET status = 'expired'
  WHERE status = 'active'
    AND expires_at <= NOW();
  
  GET DIAGNOSTICS v_expired_count = ROW_COUNT;
  RETURN v_expired_count;
END;
$$;

-- Schedule: Daily at midnight UTC
-- Note: Requires pg_cron extension
-- SELECT cron.schedule('expire-archive-daily', '0 0 * * *', 'SELECT expire_archive_listings()');

-- =============================================================================
-- View: Enriched Archive Listings (market display)
-- =============================================================================
CREATE OR REPLACE VIEW archive_listings_enriched AS
SELECT 
  al.*,
  d.name AS design_name,
  d.hype_score,
  d.provenance_multiplier,
  d.has_sovereign_provenance,
  d.transfer_count,
  d.image_url AS design_image_url,
  p.display_name AS seller_name,
  bs.brand_rank AS seller_rank,
  bs.is_in_hall_of_sovereigns AS seller_is_sovereign,
  ge.theme_title AS gala_theme
FROM archive_listings al
JOIN designs d ON al.design_id = d.id
JOIN players p ON al.seller_id = p.id
LEFT JOIN brand_state bs ON al.seller_id = bs.player_id
LEFT JOIN gala_events ge ON al.gala_event_id = ge.id
WHERE al.status = 'active' AND al.expires_at > NOW();

-- =============================================================================
-- View: Provenance Ledger Enriched (ownership chain)
-- =============================================================================
CREATE OR REPLACE VIEW provenance_ledger_enriched AS
SELECT 
  pl.*,
  prev.display_name AS previous_owner_name,
  prev_bs.brand_rank AS previous_owner_rank,
  new.display_name AS new_owner_name,
  new_bs.brand_rank AS new_owner_rank,
  d.name AS design_name
FROM provenance_ledger pl
JOIN players prev ON pl.previous_owner_id = prev.id
JOIN brand_state prev_bs ON pl.previous_owner_id = prev_bs.player_id
JOIN players new ON pl.new_owner_id = new.id
JOIN brand_state new_bs ON pl.new_owner_id = new_bs.player_id
JOIN designs d ON pl.design_id = d.id
ORDER BY pl.transferred_at DESC;

-- =============================================================================
-- Comments
-- =============================================================================
COMMENT ON FUNCTION execute_archive_purchase IS 
  'P2P purchase with FOR UPDATE lock. 30% tax burn, 70% seller payout. Prevents double-spending.';

COMMENT ON FUNCTION list_on_archive IS 
  'Create 48-hour FOMO listing. Price floor: MAX(1000, hype*10). Elite baseline enforced.';

COMMENT ON FUNCTION expire_archive_listings IS 
  'Daily cron job to expire stale listings. Returns count of expired items.';

COMMENT ON TABLE provenance_ledger IS 
  'Ownership history. Each record adds +10% hype (max +100%). Sovereign owners add +50% separate.';
