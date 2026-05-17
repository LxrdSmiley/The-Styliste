-- =============================================================================
-- Rate Limiting: Post Reactions (GDD §6.1, §8.15.2)
-- Prevents hype/reaction spam and ensures authentic engagement
-- =============================================================================

-- Track who reacted to what
CREATE TABLE IF NOT EXISTS public.post_reactions (
  post_id UUID NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('hype', 'like', 'save')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (post_id, player_id, reaction_type)
);

CREATE INDEX IF NOT EXISTS post_reactions_player_idx ON public.post_reactions(player_id, created_at DESC);

ALTER TABLE public.post_reactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reactions: read all" ON public.post_reactions FOR SELECT USING (true);
CREATE POLICY "Reactions: insert own" ON public.post_reactions FOR INSERT WITH CHECK (player_id = auth.uid());
CREATE POLICY "Reactions: delete own" ON public.post_reactions FOR DELETE USING (player_id = auth.uid());

-- RPC: increment_post_hype with deduplication
CREATE OR REPLACE FUNCTION increment_post_hype(
  p_post_id UUID,
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
    RAISE EXCEPTION 'UNAUTHORIZED';
  END IF;

  -- Check for existing reaction (prevents spam)
  IF EXISTS (
    SELECT 1 FROM post_reactions
    WHERE post_id = p_post_id AND player_id = p_player_id AND reaction_type = 'hype'
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'ALREADY_HYPED');
  END IF;

  -- Record reaction
  INSERT INTO post_reactions (post_id, player_id, reaction_type)
  VALUES (p_post_id, p_player_id, 'hype');

  -- Increment hype (existing logic)
  UPDATE feed_posts SET hype_count = hype_count + 1 WHERE id = p_post_id;

  RETURN jsonb_build_object('success', true, 'hype_added', 1);
END;
$$;

GRANT EXECUTE ON FUNCTION increment_post_hype(UUID, UUID) TO authenticated;

-- Comments
COMMENT ON TABLE post_reactions IS 'Tracks player reactions to posts for rate limiting and authenticity';
COMMENT ON FUNCTION increment_post_hype(UUID, UUID) IS 'Increments post hype with deduplication to prevent spam';
