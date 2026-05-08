-- =============================================================================
-- The Styliste — Trend Tsunami Engine Migration
-- GDD v6 §3 — 48-hour live player-driven trend meta
-- Alabaster Standard: Ivory, Champagne Gold, Soft Rose aesthetic
-- =============================================================================

-- =============================================================================
-- GARMENT DROPS (Immutable ledger of completed designs to feed)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.garment_drops (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  design_id       UUID NOT NULL REFERENCES public.designs(id) ON DELETE CASCADE,
  style_tags      TEXT[] NOT NULL DEFAULT '{}',
  hype_score      NUMERIC(10,2) NOT NULL DEFAULT 0,
  dropped_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  feed_post_id    UUID REFERENCES public.feed_posts(id) ON DELETE SET NULL
);

-- Index for fast 48h window queries and tag aggregation
CREATE INDEX garment_drops_dropped_at_idx ON public.garment_drops(dropped_at DESC);
CREATE INDEX garment_drops_player_idx ON public.garment_drops(player_id);
-- GIN index for array operations (unnest, contains)
CREATE INDEX garment_drops_style_tags_idx ON public.garment_drops USING GIN(style_tags);

ALTER TABLE public.garment_drops ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Garment drops: read all" ON public.garment_drops FOR SELECT USING (TRUE);
CREATE POLICY "Garment drops: insert own" ON public.garment_drops FOR INSERT WITH CHECK (auth.uid() = player_id);

-- =============================================================================
-- TREND TSUNAMIS (Active 48-hour wave state)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.trend_tsunamis (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tag_name        TEXT NOT NULL,
  multiplier      NUMERIC(3,2) NOT NULL CHECK (multiplier IN (2.5, 1.5)),
  rank            INT NOT NULL CHECK (rank IN (1, 2, 3)), -- 1=crest, 2-3=surge
  total_weight    NUMERIC(14,2) NOT NULL DEFAULT 0, -- weighted engagement score
  starts_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '48 hours',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX trend_tsunamis_expires_at_idx ON public.trend_tsunamis(expires_at);
CREATE INDEX trend_tsunamis_tag_name_idx ON public.trend_tsunamis(tag_name);

ALTER TABLE public.trend_tsunamis ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Trend tsunamis: read all" ON public.trend_tsunamis FOR SELECT USING (TRUE);
-- No client INSERT/UPDATE — only Edge Functions/Triggers write

-- =============================================================================
-- TREND TSUNAMI ARCHIVE (Expired waves for analytics)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.trend_tsunami_archive (
  id              UUID PRIMARY KEY,
  tag_name        TEXT NOT NULL,
  multiplier      NUMERIC(3,2) NOT NULL,
  rank            INT NOT NULL,
  total_weight    NUMERIC(14,2) NOT NULL DEFAULT 0,
  starts_at       TIMESTAMPTZ NOT NULL,
  expires_at      TIMESTAMPTZ NOT NULL,
  archived_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX trend_tsunami_archive_tag_idx ON public.trend_tsunami_archive(tag_name);
CREATE INDEX trend_tsunami_archive_archived_at_idx ON public.trend_tsunami_archive(archived_at DESC);

ALTER TABLE public.trend_tsunami_archive ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tsunami archive: read all" ON public.trend_tsunami_archive FOR SELECT USING (TRUE);

-- =============================================================================
-- CALCULATE GLOBAL TREND TSUNAMI FUNCTION
-- 
-- This function:
-- 1. Archives expired tsunamis
-- 2. Aggregates garment_drops from last 48h weighted by feed engagement
-- 3. Determines top 3 style tags by weighted score
-- 4. Inserts new Crest (2.5x) and Surge (1.5x) tags
-- =============================================================================
CREATE OR REPLACE FUNCTION public.calculate_global_trend_tsunami()
RETURNS TABLE(
  crest_tag TEXT,
  crest_multiplier NUMERIC,
  surge_tags TEXT[],
  processed_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_now TIMESTAMPTZ := NOW();
  v_window_start TIMESTAMPTZ := v_now - INTERVAL '48 hours';
  v_archived_count INT;
  v_processed_count BIGINT;
BEGIN
  -- Step 1: Archive expired tsunamis
  INSERT INTO trend_tsunami_archive (
    id, tag_name, multiplier, rank, total_weight, starts_at, expires_at
  )
  SELECT 
    id, tag_name, multiplier, rank, total_weight, starts_at, expires_at
  FROM trend_tsunamis
  WHERE expires_at < v_now;

  GET DIAGNOSTICS v_archived_count = ROW_COUNT;

  -- Step 2: Delete expired active tsunamis
  DELETE FROM trend_tsunamis WHERE expires_at < v_now;

  -- Step 3: Check if we already have active tsunamis
  IF EXISTS (SELECT 1 FROM trend_tsunamis WHERE expires_at > v_now LIMIT 1) THEN
    -- Return current active state without recalculating
    RETURN QUERY
    SELECT 
      (SELECT tag_name FROM trend_tsunamis WHERE rank = 1 LIMIT 1),
      (SELECT multiplier FROM trend_tsunamis WHERE rank = 1 LIMIT 1),
      (SELECT ARRAY_AGG(tag_name) FROM trend_tsunamis WHERE rank IN (2, 3)),
      (SELECT COUNT(*) FROM garment_drops WHERE dropped_at > v_window_start);
    RETURN;
  END IF;

  -- Step 4: Calculate weighted tag scores from last 48h
  -- Weight = hype_score + (likes from feed_posts * 10)
  WITH weighted_drops AS (
    SELECT 
      gd.id,
      gd.style_tags,
      gd.hype_score,
      COALESCE(fp.likes, 0) as feed_likes
    FROM garment_drops gd
    LEFT JOIN feed_posts fp ON fp.id = gd.feed_post_id
    WHERE gd.dropped_at > v_window_start
  ),
  tag_weights AS (
    SELECT 
      UNNEST(style_tags) as tag,
      (hype_score + (feed_likes * 10)) as weight
    FROM weighted_drops
  ),
  aggregated_tags AS (
    SELECT 
      tag,
      SUM(weight) as total_weight,
      ROW_NUMBER() OVER (ORDER BY SUM(weight) DESC) as tag_rank
    FROM tag_weights
    GROUP BY tag
    HAVING SUM(weight) > 0
    ORDER BY total_weight DESC
    LIMIT 3
  )
  -- Step 5: Insert new tsunamis
  INSERT INTO trend_tsunamis (tag_name, multiplier, rank, total_weight, starts_at, expires_at)
  SELECT 
    tag,
    CASE 
      WHEN tag_rank = 1 THEN 2.5
      ELSE 1.5
    END as multiplier,
    tag_rank as rank,
    total_weight,
    v_now as starts_at,
    v_now + INTERVAL '48 hours' as expires_at
  FROM aggregated_tags
  ON CONFLICT DO NOTHING;

  -- Get count of drops processed
  SELECT COUNT(*) INTO v_processed_count
  FROM garment_drops 
  WHERE dropped_at > v_window_start;

  -- Step 6: Return the new tsunami state
  RETURN QUERY
  SELECT 
    (SELECT tag_name FROM trend_tsunamis WHERE rank = 1 AND expires_at > v_now LIMIT 1),
    (SELECT multiplier FROM trend_tsunamis WHERE rank = 1 AND expires_at > v_now LIMIT 1),
    (SELECT COALESCE(ARRAY_AGG(tag_name), '{}') FROM trend_tsunamis WHERE rank IN (2, 3) AND expires_at > v_now),
    v_processed_count;
END;
$$;

-- Grant execute to authenticated users (Edge Functions call this)
GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO authenticated;
GRANT EXECUTE ON FUNCTION public.calculate_global_trend_tsunami() TO service_role;

-- =============================================================================
-- TRIGGER: Auto-archive on expiration (optional, for safety)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.archive_expired_tsunami()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.expires_at < NOW() THEN
    INSERT INTO trend_tsunami_archive (
      id, tag_name, multiplier, rank, total_weight, starts_at, expires_at
    ) VALUES (
      NEW.id, NEW.tag_name, NEW.multiplier, NEW.rank, NEW.total_weight, NEW.starts_at, NEW.expires_at
    );
    RETURN NULL; -- Prevent the update/delete
  END IF;
  RETURN NEW;
END;
$$;

-- Note: We use application-level scheduling (pg_cron or Edge Function) 
-- rather than row-level triggers to avoid performance overhead

-- =============================================================================
-- COMMENTS for documentation
-- =============================================================================
COMMENT ON TABLE public.garment_drops IS 
  'Immutable ledger of completed designs dropped to feed. Stores style_tags as TEXT[] for fast aggregation.';
COMMENT ON TABLE public.trend_tsunamis IS 
  'Active 48-hour trend wave. Rank 1 = Crest (2.5x), Rank 2-3 = Surge (1.5x). Expires automatically.';
COMMENT ON FUNCTION public.calculate_global_trend_tsunami() IS 
  'Aggregates garment_drops from last 48h weighted by hype + feed engagement. Calculates top 3 tags as new tsunami.';
