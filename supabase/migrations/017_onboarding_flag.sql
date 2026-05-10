-- =============================================================================
-- The Styliste — Onboarding Flag Migration
-- GDD §1.1 — Ensures onboarding_complete column exists in players table
-- Used by the router redirect guard (Option B: Riverpod cache check)
-- =============================================================================

-- Ensure onboarding_complete column exists (genesis RPC already sets it TRUE)
ALTER TABLE public.players
  ADD COLUMN IF NOT EXISTS onboarding_complete BOOL NOT NULL DEFAULT FALSE;

-- Back-fill any existing players who completed genesis without the column
-- (idempotent: only runs where column was just added with DEFAULT FALSE)
UPDATE public.players
SET onboarding_complete = TRUE
WHERE onboarding_complete = FALSE
  AND created_at IS NOT NULL;

-- =============================================================================
-- COMMENT
-- =============================================================================
COMMENT ON COLUMN public.players.onboarding_complete IS
  'Set TRUE by execute_sovereign_genesis on screen 7 completion. Used by router redirect guard to distinguish returning players from fresh anonymous sessions.';
