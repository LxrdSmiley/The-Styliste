-- =============================================================================
-- Migration 003: Social Graph — Follows, Follower Counts, Syndicate Feed
-- GDD §6.3 — Phase 7
-- =============================================================================
-- All RPCs and trigger functions use SECURITY DEFINER + SET search_path = public.
-- follows PRIMARY KEY (follower_id, following_id) covers follower_id lookups.
-- Explicit INDEX on following_id prevents sequential scans in the trigger's
-- reverse lookup (WHERE player_id = NEW.following_id on brand_state).
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. follows table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.follows (
  follower_id  UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- Covers follower_id queries (already indexed by PK, but explicit for clarity).
CREATE INDEX IF NOT EXISTS follows_follower_idx  ON public.follows(follower_id);
-- Critical: reverse lookup in trigger — prevents seq scan on brand_state update.
CREATE INDEX IF NOT EXISTS follows_following_idx ON public.follows(following_id);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Follows: read all"    ON public.follows FOR SELECT USING (TRUE);
CREATE POLICY "Follows: insert own"  ON public.follows FOR INSERT
  WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Follows: delete own"  ON public.follows FOR DELETE
  USING (auth.uid() = follower_id);

-- ---------------------------------------------------------------------------
-- 2. follow_player RPC — atomic follow with self-follow guard
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.follow_player(target_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Guard: cannot follow yourself.
  IF target_id = auth.uid() THEN
    RAISE EXCEPTION 'SELF_FOLLOW_NOT_ALLOWED';
  END IF;

  INSERT INTO public.follows (follower_id, following_id)
  VALUES (auth.uid(), target_id)
  ON CONFLICT DO NOTHING;
END;
$$;

-- ---------------------------------------------------------------------------
-- 3. unfollow_player RPC
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.unfollow_player(target_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.follows
  WHERE follower_id = auth.uid()
    AND following_id = target_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 4. fn_on_follow_change — trigger-driven follower count on brand_state
--    Fires AFTER INSERT OR DELETE ON follows FOR EACH ROW.
--    GREATEST(0,...) prevents negative counts on double-unfollow edge cases.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_on_follow_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.brand_state
    SET followers = followers + 1
    WHERE player_id = NEW.following_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.brand_state
    SET followers = GREATEST(0, followers - 1)
    WHERE player_id = OLD.following_id;
  END IF;
  RETURN NULL; -- AFTER trigger; return value ignored for row triggers
END;
$$;

DROP TRIGGER IF EXISTS on_follow_change ON public.follows;
CREATE TRIGGER on_follow_change
  AFTER INSERT OR DELETE ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_on_follow_change();

-- ---------------------------------------------------------------------------
-- 5. get_syndicate_feed RPC — server-side relational query for curated feed.
--    Bypasses .stream() relational limitation; called as initial SYNDICATE load.
--    Client then filters live global stream by followingIds Set<String>.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_syndicate_feed(p_limit INT DEFAULT 50)
RETURNS SETOF public.feed_posts
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT fp.*
  FROM public.feed_posts fp
  JOIN public.follows f ON f.following_id = fp.player_id
  WHERE f.follower_id = auth.uid()
  ORDER BY fp.created_at DESC
  LIMIT p_limit;
$$;
