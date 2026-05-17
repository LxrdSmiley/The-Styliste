-- =============================================================================
-- The Styliste — Initial Schema Migration
-- GDD v4 | PROJECT_RULES §2 | SkinTeethNerd Studios
-- All idle income and economy mutations are server-authoritative.
-- RLS enabled on all tables. No direct client writes on economy tables.
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- PLAYERS (GDD §3)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.players (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_name      TEXT NOT NULL,
  path            TEXT NOT NULL CHECK (path IN ('designer', 'mogul')),
  brand_rank      INT NOT NULL DEFAULT 1 CHECK (brand_rank BETWEEN 1 AND 100),
  total_xp        INT NOT NULL DEFAULT 0,
  hq_city         TEXT NOT NULL,
  onboarding_complete BOOLEAN NOT NULL DEFAULT FALSE,
  is_anonymous    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_active_at  TIMESTAMPTZ
);
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Players: read own" ON public.players FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Players: update own" ON public.players FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Players: insert own" ON public.players FOR INSERT WITH CHECK (auth.uid() = id);

-- =============================================================================
-- BRAND STATE (GDD §8.9.7 — Brand Heat, idle revenue, hype)
-- Server-computed. No direct client writes.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.brand_state (
  player_id           UUID PRIMARY KEY REFERENCES public.players(id) ON DELETE CASCADE,
  heat                INT NOT NULL DEFAULT 50 CHECK (heat BETWEEN 0 AND 100),
  hype_score          NUMERIC(10,2) NOT NULL DEFAULT 0,
  followers           INT NOT NULL DEFAULT 0,
  idle_revenue_per_hour        NUMERIC(14,2) NOT NULL DEFAULT 0,
  total_revenue       NUMERIC(14,2) NOT NULL DEFAULT 0,
  momentum_buff_active BOOLEAN NOT NULL DEFAULT FALSE,
  momentum_buff_until TIMESTAMPTZ,
  last_active_at      TIMESTAMPTZ,
  sustainability_tier INT NOT NULL DEFAULT 0 CHECK (sustainability_tier BETWEEN 0 AND 4),
  dpp_enabled         BOOLEAN NOT NULL DEFAULT FALSE,
  dpp_fully_mapped    BOOLEAN NOT NULL DEFAULT FALSE,
  founder_rep         INT NOT NULL DEFAULT 50 CHECK (founder_rep BETWEEN 0 AND 100),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.brand_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Brand state: read own" ON public.brand_state FOR SELECT USING (auth.uid() = player_id);
-- No INSERT/UPDATE policy for client — Edge Functions write via service role

-- =============================================================================
-- DESIGNS (GDD §4.1)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.designs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  session_type    TEXT NOT NULL CHECK (session_type IN ('quick_sketch', 'deep_session')),
  status          TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'complete', 'dropped', 'retired')),
  hype_score      NUMERIC(10,2) NOT NULL DEFAULT 0,
  is_alpha        BOOLEAN NOT NULL DEFAULT FALSE,
  is_digital_twin BOOLEAN NOT NULL DEFAULT FALSE,
  dpp_registered  BOOLEAN NOT NULL DEFAULT FALSE,
  fabric_data     JSONB NOT NULL DEFAULT '{}',
  sell_potential  NUMERIC(10,2) NOT NULL DEFAULT 0,
  cultural_impact NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  dropped_at      TIMESTAMPTZ
);
CREATE INDEX designs_player_idx ON public.designs(player_id);
ALTER TABLE public.designs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Designs: read own" ON public.designs FOR SELECT USING (auth.uid() = player_id);
CREATE POLICY "Designs: insert own" ON public.designs FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Designs: update own" ON public.designs FOR UPDATE USING (auth.uid() = player_id);

-- =============================================================================
-- STORES (GDD §5.2)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.stores (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  type            TEXT NOT NULL CHECK (type IN ('flagship', 'ecommerce')),
  city            TEXT NOT NULL,
  tier            INT NOT NULL DEFAULT 1,
  revenue_per_hour NUMERIC(14,4) NOT NULL DEFAULT 0,
  loyalty         INT NOT NULL DEFAULT 100 CHECK (loyalty BETWEEN 0 AND 100),
  market_share    NUMERIC(5,4) NOT NULL DEFAULT 0,
  maison_id       UUID,
  opened_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX stores_player_idx ON public.stores(player_id);
CREATE INDEX stores_city_idx ON public.stores(city);
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Stores: read own" ON public.stores FOR SELECT USING (auth.uid() = player_id);

-- =============================================================================
-- SUPPLIERS (GDD §5.1 — Reference data, seeded)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.suppliers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  tier            TEXT NOT NULL CHECK (tier IN ('local', 'regional', 'international', 'luxury', 'black_market')),
  category        TEXT NOT NULL CHECK (category IN ('raw_materials', 'manufacturing', 'logistics')),
  quality         INT NOT NULL DEFAULT 50 CHECK (quality BETWEEN 0 AND 100),
  cost            INT NOT NULL DEFAULT 50 CHECK (cost BETWEEN 0 AND 100),
  reliability     INT NOT NULL DEFAULT 50 CHECK (reliability BETWEEN 0 AND 100),
  prestige        INT NOT NULL DEFAULT 50 CHECK (prestige BETWEEN 0 AND 100),
  living_wage_enabled     BOOLEAN NOT NULL DEFAULT FALSE,
  blockchain_traceable    BOOLEAN NOT NULL DEFAULT FALSE,
  ethical_supplier_badge  BOOLEAN NOT NULL DEFAULT FALSE
);
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Suppliers: read all" ON public.suppliers FOR SELECT USING (TRUE);

-- =============================================================================
-- SUPPLY CHAIN CONTRACTS (GDD §5.1)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.supply_chain (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  supplier_id         UUID NOT NULL REFERENCES public.suppliers(id),
  tier                TEXT NOT NULL,
  exclusivity         BOOLEAN NOT NULL DEFAULT FALSE,
  contract_expires_at TIMESTAMPTZ
);
CREATE INDEX supply_chain_player_idx ON public.supply_chain(player_id);
ALTER TABLE public.supply_chain ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Supply chain: read own" ON public.supply_chain FOR SELECT USING (auth.uid() = player_id);

-- =============================================================================
-- BRANDS EQUITY (GDD §5.6)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.brands_equity (
  brand_id            UUID PRIMARY KEY REFERENCES public.players(id) ON DELETE CASCADE,
  total_shares        INT NOT NULL DEFAULT 0,
  share_price         NUMERIC(14,4) NOT NULL DEFAULT 0,
  valuation           NUMERIC(20,2) NOT NULL DEFAULT 0,
  is_public           BOOLEAN NOT NULL DEFAULT FALSE,
  dividend_payout_ratio NUMERIC(5,4) NOT NULL DEFAULT 0,
  ipo_at              TIMESTAMPTZ
);
ALTER TABLE public.brands_equity ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Equity: read all public" ON public.brands_equity FOR SELECT USING (TRUE);

-- =============================================================================
-- EQUITY POSITIONS (GDD §5.6)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.equity_positions (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  holder_id             UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  brand_id              UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  share_type            TEXT NOT NULL CHECK (share_type IN ('common', 'preferred')),
  shares_owned          INT NOT NULL DEFAULT 0,
  average_purchase_price NUMERIC(14,4) NOT NULL DEFAULT 0,
  acquired_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX equity_holder_idx ON public.equity_positions(holder_id);
ALTER TABLE public.equity_positions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Equity positions: read own" ON public.equity_positions FOR SELECT USING (auth.uid() = holder_id);

-- =============================================================================
-- MAISONS (GDD §6.3)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.maisons (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  founder_id      UUID NOT NULL REFERENCES public.players(id),
  treasury        NUMERIC(20,2) NOT NULL DEFAULT 0,
  is_recruiting   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.maisons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Maisons: read all" ON public.maisons FOR SELECT USING (TRUE);
CREATE POLICY "Maisons: insert by founder" ON public.maisons FOR INSERT WITH CHECK (auth.uid() = founder_id);

-- =============================================================================
-- MAISON MEMBERS (GDD §6.3.1)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.maison_members (
  maison_id   UUID NOT NULL REFERENCES public.maisons(id) ON DELETE CASCADE,
  player_id   UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  role        TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('founder', 'creative_director', 'executive_director', 'brand_director', 'member')),
  joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (maison_id, player_id)
);
CREATE INDEX maison_members_player_idx ON public.maison_members(player_id);
ALTER TABLE public.maison_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Maison members: read all" ON public.maison_members FOR SELECT USING (TRUE);
CREATE POLICY "Maison members: insert own" ON public.maison_members FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Maison members: delete own" ON public.maison_members FOR DELETE USING (auth.uid() = player_id);

-- =============================================================================
-- FEED POSTS (GDD §6.1 — Realtime)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.feed_posts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
  content     JSONB NOT NULL DEFAULT '{}',
  hype        NUMERIC(10,2) NOT NULL DEFAULT 0,
  likes       INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX feed_posts_player_idx ON public.feed_posts(player_id);
CREATE INDEX feed_posts_created_idx ON public.feed_posts(created_at DESC);
ALTER TABLE public.feed_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Feed posts: read all" ON public.feed_posts FOR SELECT USING (TRUE);
CREATE POLICY "Feed posts: insert own" ON public.feed_posts FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Feed posts: update own" ON public.feed_posts FOR UPDATE USING (auth.uid() = player_id);

-- =============================================================================
-- PARTNERSHIPS (GDD §6.2)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.partnerships (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_a_id     UUID NOT NULL REFERENCES public.players(id),
  player_b_id     UUID NOT NULL REFERENCES public.players(id),
  split_ratio     NUMERIC(5,4) NOT NULL DEFAULT 0.5 CHECK (split_ratio BETWEEN 0 AND 1),
  status          TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dissolved', 'pending')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.partnerships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Partnerships: read own" ON public.partnerships FOR SELECT
  USING (auth.uid() = player_a_id OR auth.uid() = player_b_id);

-- =============================================================================
-- CAMPAIGNS (GDD §5.4)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.campaigns (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  type            TEXT NOT NULL CHECK (type IN ('social_blast', 'influencer_drop', 'runway_event', 'targeted_ads', 'custom')),
  status          TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'failed')),
  budget          NUMERIC(14,2) NOT NULL DEFAULT 0,
  roi_actual      NUMERIC(14,2) NOT NULL DEFAULT 0,
  roi_forecast    NUMERIC(14,2) NOT NULL DEFAULT 0,
  hype_lift       NUMERIC(10,4) NOT NULL DEFAULT 0,
  sales_lift      NUMERIC(10,4) NOT NULL DEFAULT 0,
  maison_pool_id  UUID REFERENCES public.maisons(id),
  launched_at     TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ
);
CREATE INDEX campaigns_player_idx ON public.campaigns(player_id);
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Campaigns: read own" ON public.campaigns FOR SELECT USING (auth.uid() = player_id);

-- =============================================================================
-- EVENTS (GDD §7.2–7.4 — Seeded + admin-managed)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type        TEXT NOT NULL,
  theme       TEXT,
  starts_at   TIMESTAMPTZ NOT NULL,
  ends_at     TIMESTAMPTZ NOT NULL,
  rewards     JSONB NOT NULL DEFAULT '{}'
);
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Events: read all" ON public.events FOR SELECT USING (TRUE);

-- =============================================================================
-- PLAYER EVENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.player_events (
  player_id   UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  event_id    UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  status      TEXT NOT NULL DEFAULT 'entered' CHECK (status IN ('entered', 'completed', 'rewarded')),
  score       NUMERIC(14,2) NOT NULL DEFAULT 0,
  reward_tier TEXT CHECK (reward_tier IN ('bronze', 'silver', 'gold')),
  PRIMARY KEY (player_id, event_id)
);
ALTER TABLE public.player_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Player events: read own" ON public.player_events FOR SELECT USING (auth.uid() = player_id);
CREATE POLICY "Player events: insert own" ON public.player_events FOR INSERT WITH CHECK (auth.uid() = player_id);

-- =============================================================================
-- LOANS (GDD §5.5)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.loans (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  amount          NUMERIC(14,2) NOT NULL,
  interest_rate   NUMERIC(5,4) NOT NULL,
  due_at          TIMESTAMPTZ NOT NULL,
  status          TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'repaid', 'defaulted'))
);
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Loans: read own" ON public.loans FOR SELECT USING (auth.uid() = player_id);

-- =============================================================================
-- TALENT (GDD §8.10)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.talent (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id   UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  role        TEXT NOT NULL,
  expertise   INT NOT NULL DEFAULT 50 CHECK (expertise BETWEEN 0 AND 100),
  loyalty     INT NOT NULL DEFAULT 100 CHECK (loyalty BETWEEN 0 AND 100),
  morale      INT NOT NULL DEFAULT 100 CHECK (morale BETWEEN 0 AND 100),
  salary      NUMERIC(10,2) NOT NULL DEFAULT 0,
  hired_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX talent_player_idx ON public.talent(player_id);
ALTER TABLE public.talent ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Talent: read own" ON public.talent FOR SELECT USING (auth.uid() = player_id);

-- =============================================================================
-- PLAYER REPORTS (GDD §6.x)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.player_reports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id     UUID NOT NULL REFERENCES public.players(id),
  reported_id     UUID NOT NULL REFERENCES public.players(id),
  reason          TEXT NOT NULL,
  description     TEXT,
  screenshot_url  TEXT,
  status          TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.player_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reports: insert own" ON public.player_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Reports: read own" ON public.player_reports FOR SELECT USING (auth.uid() = reporter_id);

-- =============================================================================
-- IDLE INCOME LOG (GDD §3.3 — Append-only, Edge Function writes only)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.idle_income_log (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  computed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  amount          NUMERIC(14,2) NOT NULL,
  multiplier      NUMERIC(8,4) NOT NULL DEFAULT 1.0,
  decay_factor    NUMERIC(5,4) NOT NULL DEFAULT 1.0
);
CREATE INDEX idle_income_player_idx ON public.idle_income_log(player_id, computed_at DESC);
ALTER TABLE public.idle_income_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Idle log: read own" ON public.idle_income_log FOR SELECT USING (auth.uid() = player_id);
-- No INSERT/UPDATE/DELETE policy for client — Edge Function writes via service role

-- Helper function for post reactions (used by feed_repository)
CREATE OR REPLACE FUNCTION public.increment_post_reaction(post_id UUID, reaction_type TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF reaction_type = 'like' THEN
    UPDATE public.feed_posts SET likes = likes + 1 WHERE id = post_id;
  END IF;
END;
$$;

