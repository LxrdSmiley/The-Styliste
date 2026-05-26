-- The Styliste - Edge-backed feed/drop actions for closed alpha.
-- Client-visible buttons call Edge Functions; Edge Functions verify JWTs and
-- call these service-only RPCs so gameplay writes stay server-authoritative.

-- ---------------------------------------------------------------------------
-- Shape and indexes
-- ---------------------------------------------------------------------------
ALTER TABLE public.feed_posts
  ADD COLUMN IF NOT EXISTS comments_count INT NOT NULL DEFAULT 0
    CHECK (comments_count >= 0);

ALTER TABLE public.feed_comments
  ADD COLUMN IF NOT EXISTS brand_name TEXT;

CREATE INDEX IF NOT EXISTS feed_posts_likes_created_idx
  ON public.feed_posts(likes DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS feed_posts_comments_created_idx
  ON public.feed_posts(comments_count DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS post_reactions_post_type_idx
  ON public.post_reactions(post_id, reaction_type);

-- A design can be dropped once. Clean up accidental historical duplicates
-- before installing the unique guard.
WITH ranked_drops AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY design_id
      ORDER BY dropped_at ASC, id ASC
    ) AS rn
  FROM public.garment_drops
)
DELETE FROM public.garment_drops gd
USING ranked_drops rd
WHERE gd.id = rd.id
  AND rd.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS garment_drops_design_unique_idx
  ON public.garment_drops(design_id);

-- Backfill comment counters if comments already exist locally.
UPDATE public.feed_posts fp
SET comments_count = counts.comment_count
FROM (
  SELECT post_id, COUNT(*)::INT AS comment_count
  FROM public.feed_comments
  GROUP BY post_id
) AS counts
WHERE fp.id = counts.post_id;

UPDATE public.feed_comments fc
SET brand_name = p.brand_name
FROM public.players p
WHERE fc.player_id = p.id
  AND fc.brand_name IS NULL;

-- ---------------------------------------------------------------------------
-- Public Data API grants: reads stay public-to-authenticated, writes move to
-- Edge Functions. Policies remain as defense in depth, but table privileges
-- prevent direct client mutations in closed alpha.
-- ---------------------------------------------------------------------------
REVOKE INSERT, UPDATE, DELETE ON public.feed_posts FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.garment_drops FROM anon, authenticated;
REVOKE ALL ON public.post_reactions FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.feed_comments FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.designs FROM anon, authenticated;

GRANT SELECT ON public.feed_posts TO authenticated;
GRANT SELECT ON public.garment_drops TO authenticated;
GRANT SELECT ON public.feed_comments TO authenticated;
GRANT SELECT ON public.designs TO authenticated;

-- The old authenticated RPC path is replaced by the feed-react Edge Function.
DO $$
BEGIN
  IF to_regprocedure('public.increment_post_hype(uuid, uuid)') IS NOT NULL THEN
    REVOKE ALL ON FUNCTION public.increment_post_hype(UUID, UUID)
      FROM PUBLIC, anon, authenticated;
    ALTER FUNCTION public.increment_post_hype(UUID, UUID)
      SET search_path = public;
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Service-only drop execution
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edge_drop_design(
  p_player_id UUID,
  p_design_id UUID,
  p_style_tags TEXT[] DEFAULT '{}'::TEXT[],
  p_vex_review JSONB DEFAULT NULL,
  p_vex_quote TEXT DEFAULT NULL,
  p_vex_caption TEXT DEFAULT NULL
)
RETURNS TABLE(
  success BOOLEAN,
  feed_post_id UUID,
  garment_drop_id UUID,
  design_id UUID,
  hype_score NUMERIC,
  brand_name TEXT,
  fabric_color_hex TEXT,
  message TEXT,
  feed_post JSONB
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_design public.designs%ROWTYPE;
  v_existing_drop public.garment_drops%ROWTYPE;
  v_existing_post public.feed_posts%ROWTYPE;
  v_feed_post public.feed_posts%ROWTYPE;
  v_garment_drop public.garment_drops%ROWTYPE;
  v_brand_name TEXT;
  v_brand_rank INT;
  v_fabric_color_hex TEXT;
  v_style_tags TEXT[] := '{}'::TEXT[];
  v_content JSONB;
BEGIN
  SELECT *
  INTO v_design
  FROM public.designs d
  WHERE d.id = p_design_id
    AND COALESCE(d.owner_id, d.player_id) = p_player_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'DESIGN_NOT_FOUND_OR_NOT_OWNED';
  END IF;

  SELECT p.brand_name, p.brand_rank
  INTO v_brand_name, v_brand_rank
  FROM public.players p
  WHERE p.id = p_player_id;

  v_fabric_color_hex := NULLIF(v_design.fabric_data->>'color_hex', '');

  SELECT COALESCE(array_agg(tag), '{}'::TEXT[])
  INTO v_style_tags
  FROM (
    SELECT DISTINCT LOWER(TRIM(raw_tag)) AS tag
    FROM unnest(COALESCE(p_style_tags, '{}'::TEXT[])) AS raw_tag
    WHERE LENGTH(TRIM(raw_tag)) BETWEEN 1 AND 48
    LIMIT 8
  ) normalized_tags;

  IF v_design.status = 'dropped' THEN
    SELECT *
    INTO v_existing_drop
    FROM public.garment_drops gd
    WHERE gd.design_id = p_design_id
    ORDER BY gd.dropped_at ASC
    LIMIT 1;

    IF FOUND AND v_existing_drop.feed_post_id IS NOT NULL THEN
      SELECT *
      INTO v_existing_post
      FROM public.feed_posts fp
      WHERE fp.id = v_existing_drop.feed_post_id;

      RETURN QUERY SELECT
        TRUE,
        v_existing_post.id,
        v_existing_drop.id,
        v_design.id,
        v_design.hype_score,
        v_brand_name,
        v_fabric_color_hex,
        'ALREADY_DROPPED'::TEXT,
        to_jsonb(v_existing_post);
      RETURN;
    END IF;

    RAISE EXCEPTION 'DESIGN_ALREADY_DROPPED';
  END IF;

  IF v_design.status <> 'complete' THEN
    RAISE EXCEPTION 'DESIGN_NOT_READY';
  END IF;

  v_content := jsonb_strip_nulls(
    jsonb_build_object(
      'event', 'alpha_dropped',
      'design_id', v_design.id,
      'design_name', v_design.name,
      'style_tags', v_style_tags,
      'trend_tags', v_style_tags,
      'hype_score', v_design.hype_score,
      'fabric_tier', COALESCE(v_design.fabric_data->>'tier', 'standard_cotton'),
      'fabric_color_hex', v_fabric_color_hex,
      'brand_name', v_brand_name,
      'brand_rank', v_brand_rank
    )
  );

  IF p_vex_review IS NOT NULL THEN
    v_content := v_content || jsonb_strip_nulls(
      jsonb_build_object(
        'vex_review', p_vex_review,
        'vex_headline', p_vex_review->>'headline',
        'vex_quote', p_vex_quote,
        'vex_caption', p_vex_caption,
        'vex_verdict', p_vex_review->>'verdict'
      )
    );
  END IF;

  INSERT INTO public.feed_posts (
    player_id,
    type,
    content,
    hype,
    likes,
    comments_count
  )
  VALUES (
    p_player_id,
    'design_flex',
    v_content,
    v_design.hype_score,
    0,
    0
  )
  RETURNING * INTO v_feed_post;

  INSERT INTO public.garment_drops (
    player_id,
    design_id,
    style_tags,
    hype_score,
    feed_post_id
  )
  VALUES (
    p_player_id,
    p_design_id,
    v_style_tags,
    v_design.hype_score,
    v_feed_post.id
  )
  RETURNING * INTO v_garment_drop;

  UPDATE public.designs
  SET status = 'dropped',
      dropped_at = COALESCE(dropped_at, NOW())
  WHERE id = p_design_id;

  RETURN QUERY SELECT
    TRUE,
    v_feed_post.id,
    v_garment_drop.id,
    v_design.id,
    v_design.hype_score,
    v_brand_name,
    v_fabric_color_hex,
    'DROP_CREATED'::TEXT,
    to_jsonb(v_feed_post);
END;
$$;

REVOKE ALL ON FUNCTION public.edge_drop_design(
  UUID,
  UUID,
  TEXT[],
  JSONB,
  TEXT,
  TEXT
) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_drop_design(
  UUID,
  UUID,
  TEXT[],
  JSONB,
  TEXT,
  TEXT
) TO service_role;

COMMENT ON FUNCTION public.edge_drop_design(UUID, UUID, TEXT[], JSONB, TEXT, TEXT) IS
  'Service-only RPC used by the drop-design Edge Function to atomically publish a completed Alpha design.';

-- ---------------------------------------------------------------------------
-- Service-only feed reactions
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edge_react_to_feed_post(
  p_player_id UUID,
  p_post_id UUID,
  p_reaction_type TEXT
)
RETURNS TABLE(
  success BOOLEAN,
  post_id UUID,
  reaction_type TEXT,
  hype NUMERIC,
  likes INT,
  message TEXT
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_post public.feed_posts%ROWTYPE;
  v_rows INT;
BEGIN
  IF p_reaction_type NOT IN ('hype', 'like', 'save') THEN
    RAISE EXCEPTION 'INVALID_REACTION_TYPE';
  END IF;

  SELECT *
  INTO v_post
  FROM public.feed_posts fp
  WHERE fp.id = p_post_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'POST_NOT_FOUND';
  END IF;

  INSERT INTO public.post_reactions (post_id, player_id, reaction_type)
  VALUES (p_post_id, p_player_id, p_reaction_type)
  ON CONFLICT (post_id, player_id, reaction_type) DO NOTHING;

  GET DIAGNOSTICS v_rows = ROW_COUNT;

  IF v_rows = 0 THEN
    RETURN QUERY SELECT
      FALSE,
      v_post.id,
      p_reaction_type,
      v_post.hype,
      v_post.likes,
      'ALREADY_REACTED'::TEXT;
    RETURN;
  END IF;

  IF p_reaction_type = 'hype' THEN
    UPDATE public.feed_posts
    SET hype = hype + 1
    WHERE id = p_post_id
    RETURNING * INTO v_post;
  ELSIF p_reaction_type = 'like' THEN
    UPDATE public.feed_posts
    SET likes = likes + 1
    WHERE id = p_post_id
    RETURNING * INTO v_post;
  END IF;

  RETURN QUERY SELECT
    TRUE,
    v_post.id,
    p_reaction_type,
    v_post.hype,
    v_post.likes,
    'REACTION_ADDED'::TEXT;
END;
$$;

REVOKE ALL ON FUNCTION public.edge_react_to_feed_post(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_react_to_feed_post(UUID, UUID, TEXT)
  TO service_role;

COMMENT ON FUNCTION public.edge_react_to_feed_post(UUID, UUID, TEXT) IS
  'Service-only RPC used by the feed-react Edge Function for deduplicated feed reactions.';

-- ---------------------------------------------------------------------------
-- Service-only comments
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edge_add_feed_comment(
  p_player_id UUID,
  p_post_id UUID,
  p_body TEXT
)
RETURNS TABLE(
  success BOOLEAN,
  comment_id UUID,
  post_id UUID,
  comments_count INT,
  message TEXT,
  comment JSONB
)
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_body TEXT := TRIM(COALESCE(p_body, ''));
  v_comment public.feed_comments%ROWTYPE;
  v_comments_count INT;
  v_brand_name TEXT;
BEGIN
  IF LENGTH(v_body) < 1 OR LENGTH(v_body) > 280 THEN
    RAISE EXCEPTION 'INVALID_COMMENT_BODY';
  END IF;

  PERFORM 1
  FROM public.feed_posts fp
  WHERE fp.id = p_post_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'POST_NOT_FOUND';
  END IF;

  SELECT p.brand_name
  INTO v_brand_name
  FROM public.players p
  WHERE p.id = p_player_id;

  INSERT INTO public.feed_comments (post_id, player_id, body, brand_name)
  VALUES (p_post_id, p_player_id, v_body, v_brand_name)
  RETURNING * INTO v_comment;

  UPDATE public.feed_posts
  SET comments_count = comments_count + 1
  WHERE id = p_post_id
  RETURNING comments_count INTO v_comments_count;

  RETURN QUERY SELECT
    TRUE,
    v_comment.id,
    v_comment.post_id,
    v_comments_count,
    'COMMENT_ADDED'::TEXT,
    jsonb_build_object(
      'id', v_comment.id,
      'post_id', v_comment.post_id,
      'player_id', v_comment.player_id,
      'brand_name', v_brand_name,
      'body', v_comment.body,
      'created_at', v_comment.created_at
    );
END;
$$;

REVOKE ALL ON FUNCTION public.edge_add_feed_comment(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_add_feed_comment(UUID, UUID, TEXT)
  TO service_role;

COMMENT ON FUNCTION public.edge_add_feed_comment(UUID, UUID, TEXT) IS
  'Service-only RPC used by the feed-comment Edge Function to append player comments and maintain counters.';
