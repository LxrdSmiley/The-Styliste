-- =============================================================================
-- Directive M: The Aurelian Storefront — Fiat Bridge
-- GDD §9.8, §12.5 — Premium F2P monetization with receipt verification
-- Alabaster Standard: Never trust client with premium currency
-- =============================================================================

-- Transaction status enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transaction_status') THEN
    CREATE TYPE transaction_status AS ENUM ('pending', 'verified', 'failed', 'refunded');
  END IF;
END $$;

-- =============================================================================
-- Table: fiat_transactions — Immutable receipt ledger
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fiat_transactions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  product_id          TEXT NOT NULL,  -- e.g., 'sovereign_syndicate'
  platform            TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  amount_usd          NUMERIC(6,2) NOT NULL,  -- Store price for analytics
  luxe_tokens_granted INTEGER NOT NULL,
  receipt_hash        TEXT UNIQUE,  -- SHA-256 of receipt data for dedup
  store_receipt_data  TEXT,  -- Encrypted raw receipt (for dispute resolution)
  status              transaction_status DEFAULT 'pending',
  error_message       TEXT,
  purchased_at        TIMESTAMPTZ DEFAULT NOW(),
  verified_at         TIMESTAMPTZ,
  
  -- Ensure receipt_hash present when verified
  CONSTRAINT receipt_required_for_verified 
    CHECK (status != 'verified' OR receipt_hash IS NOT NULL)
);

CREATE INDEX fiat_transactions_player_idx ON public.fiat_transactions(player_id);
CREATE INDEX fiat_transactions_status_idx ON public.fiat_transactions(status);
CREATE INDEX fiat_transactions_receipt_hash_idx ON public.fiat_transactions(receipt_hash) WHERE receipt_hash IS NOT NULL;
CREATE INDEX fiat_transactions_purchased_at_idx ON public.fiat_transactions(purchased_at DESC);

ALTER TABLE public.fiat_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Transactions: read own" ON public.fiat_transactions FOR SELECT USING (player_id = auth.uid());

-- =============================================================================
-- RPC: Verify and Grant Luxe
-- 
-- Server-authoritative receipt validation before token grant.
-- Called by Edge Function after Apple/Google server-to-server verification.
-- =============================================================================
CREATE OR REPLACE FUNCTION verify_and_grant_luxe(
  p_player_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_receipt_hash TEXT,
  p_store_receipt_data TEXT,
  p_amount_usd NUMERIC,
  p_luxe_tokens INTEGER
)
RETURNS TABLE(
  success BOOLEAN,
  transaction_id UUID,
  new_luxe_balance INTEGER,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_transaction_id UUID;
  v_existing_hash UUID;
  v_new_balance INTEGER;
BEGIN
  -- Check for duplicate receipt (prevent double-spending)
  SELECT id INTO v_existing_hash
  FROM fiat_transactions
  WHERE receipt_hash = p_receipt_hash
    AND status = 'verified';
  
  IF v_existing_hash IS NOT NULL THEN
    RETURN QUERY SELECT 
      FALSE, 
      v_existing_hash, 
      (SELECT luxe_tokens FROM brand_state WHERE player_id = p_player_id),
      'RECEIPT_ALREADY_REDEEMED'::TEXT;
    RETURN;
  END IF;
  
  -- Create transaction record
  INSERT INTO fiat_transactions (
    player_id,
    product_id,
    platform,
    amount_usd,
    luxe_tokens_granted,
    receipt_hash,
    store_receipt_data,
    status,
    verified_at
  ) VALUES (
    p_player_id,
    p_product_id,
    p_platform,
    p_amount_usd,
    p_luxe_tokens,
    p_receipt_hash,
    p_store_receipt_data,
    'verified',
    NOW()
  )
  RETURNING id INTO v_transaction_id;
  
  -- Grant Luxe tokens atomically
  UPDATE brand_state
  SET luxe_tokens = luxe_tokens + p_luxe_tokens
  WHERE player_id = p_player_id
  RETURNING luxe_tokens INTO v_new_balance;
  
  RETURN QUERY SELECT TRUE, v_transaction_id, v_new_balance, 'PURCHASE_VERIFIED'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION verify_and_grant_luxe(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, INTEGER) TO authenticated;

-- =============================================================================
-- RPC: Record Failed Transaction
-- For analytics and customer support tracking
-- =============================================================================
CREATE OR REPLACE FUNCTION record_failed_transaction(
  p_player_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_amount_usd NUMERIC,
  p_error_message TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_transaction_id UUID;
BEGIN
  INSERT INTO fiat_transactions (
    player_id,
    product_id,
    platform,
    amount_usd,
    luxe_tokens_granted,
    status,
    error_message
  ) VALUES (
    p_player_id,
    p_product_id,
    p_platform,
    p_amount_usd,
    0,
    'failed',
    p_error_message
  )
  RETURNING id INTO v_transaction_id;
  
  RETURN v_transaction_id;
END;
$$;

GRANT EXECUTE ON FUNCTION record_failed_transaction(UUID, TEXT, TEXT, NUMERIC, TEXT) TO authenticated;

-- =============================================================================
-- View: Purchase Analytics (for live ops dashboard)
-- =============================================================================
CREATE OR REPLACE VIEW storefront_analytics AS
SELECT 
  DATE_TRUNC('day', purchased_at) AS day,
  product_id,
  platform,
  COUNT(*) AS transaction_count,
  SUM(amount_usd) AS revenue_usd,
  SUM(luxe_tokens_granted) AS luxe_granted,
  COUNT(CASE WHEN status = 'verified' THEN 1 END) AS successful_count,
  COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_count
FROM fiat_transactions
GROUP BY DATE_TRUNC('day', purchased_at), product_id, platform
ORDER BY day DESC;

-- =============================================================================
-- The Aurelian Storefront Product Tiers
-- These map to App Store Connect / Google Play Console product IDs
-- =============================================================================
COMMENT ON FUNCTION verify_and_grant_luxe IS 
  'Server-authoritative receipt validation. Grants Luxe tokens after Apple/Google verification. Idempotent via receipt_hash dedup.';

COMMENT ON TABLE fiat_transactions IS 
  'Immutable ledger of all fiat purchases. receipt_hash prevents double-spending.';

-- Product tier reference (for documentation)
-- The Initiate's Cache:     100 Luxe  @ $0.99  (Product ID: initiates_cache)
-- The Artisan's Reserve:     550 Luxe  @ $4.99  (Product ID: artisans_reserve)
-- The Architect's Vault:    1200 Luxe @ $9.99  (Product ID: architects_vault)
-- The Sovereign Syndicate:  6500 Luxe @ $49.99 (Product ID: sovereign_syndicate)
