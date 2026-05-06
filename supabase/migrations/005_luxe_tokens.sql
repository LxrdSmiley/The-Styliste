-- =============================================================================
-- Migration 005: Luxe Tokens & IAP Receipt Deduplication — Phase 9
-- GDD §9.8 — Hard currency ("Luxe Tokens") minted only by validate-iap Edge Function.
-- =============================================================================
-- Security model:
--   brand_state.luxe_tokens — service-role-only writes (no client UPDATE policy).
--   iap_receipts.receipt_hash PRIMARY KEY — B-tree index serializes concurrent
--   INSERT ON CONFLICT, eliminating TOCTOU replay window at kernel level (~0.05ms).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Add luxe_tokens column to brand_state
--    Default 0; no client write policy (inherits existing "no INSERT/UPDATE" rule).
-- ---------------------------------------------------------------------------
ALTER TABLE public.brand_state
  ADD COLUMN IF NOT EXISTS luxe_tokens INT NOT NULL DEFAULT 0;

-- ---------------------------------------------------------------------------
-- 2. iap_receipts — append-only deduplication ledger
--    receipt_hash = SHA-256(serverVerificationData) — computed before external call.
--    PRIMARY KEY enforces uniqueness; zero rows on conflict = already redeemed.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.iap_receipts (
  receipt_hash  TEXT        PRIMARY KEY,
  player_id     UUID        NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  product_id    TEXT        NOT NULL,
  platform      TEXT        NOT NULL CHECK (platform IN ('ios', 'android')),
  luxe_granted  INT         NOT NULL CHECK (luxe_granted > 0),
  validated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS iap_receipts_player_idx ON public.iap_receipts(player_id);

ALTER TABLE public.iap_receipts ENABLE ROW LEVEL SECURITY;
-- Players can read their own receipts (support / audit trail); service role writes.
CREATE POLICY "IAP receipts: read own" ON public.iap_receipts
  FOR SELECT USING (auth.uid() = player_id);
-- No INSERT/UPDATE/DELETE policy for client — Edge Function uses service role key.
