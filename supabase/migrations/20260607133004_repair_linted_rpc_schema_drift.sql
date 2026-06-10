-- Repair schema drift and PL/pgSQL ambiguity reported by supabase db lint.
-- These changes keep the existing gameplay contracts intact.

ALTER TABLE public.maisons
ADD COLUMN IF NOT EXISTS total_hype BIGINT NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS public.brand_state_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  total_revenue NUMERIC(14,2) NOT NULL DEFAULT 0,
  last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS brand_state_history_player_active_idx
  ON public.brand_state_history(player_id, last_active_at DESC);

ALTER TABLE public.brand_state_history ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.process_idle_income(p_player_id uuid)
RETURNS TABLE(
  added_to_inventory bigint,
  new_inventory bigint,
  is_full boolean,
  idle_revenue_per_hour numeric,
  seconds_elapsed bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_active TIMESTAMPTZ;
  v_idle_rate NUMERIC;
  v_now TIMESTAMPTZ := NOW();
  v_elapsed_seconds BIGINT;
  v_generated_amount BIGINT;
  v_add_result RECORD;
BEGIN
  PERFORM public.assert_self(p_player_id);

  IF auth.uid() != p_player_id THEN
    RAISE EXCEPTION 'UNAUTHORIZED';
  END IF;

  SELECT bs.idle_revenue_per_hour, bs.last_active_at
  INTO v_idle_rate, v_last_active
  FROM public.brand_state bs
  WHERE bs.player_id = p_player_id;

  IF v_idle_rate IS NULL OR v_idle_rate <= 0 THEN
    RETURN QUERY SELECT
      0::BIGINT,
      bs.current_inventory_value,
      bs.current_inventory_value >= bs.warehouse_capacity,
      0::NUMERIC,
      0::BIGINT
    FROM public.brand_state bs
    WHERE bs.player_id = p_player_id;
    RETURN;
  END IF;

  IF v_last_active IS NULL THEN
    v_elapsed_seconds := 60;
  ELSE
    v_elapsed_seconds := EXTRACT(EPOCH FROM (v_now - v_last_active))::BIGINT;
  END IF;

  v_elapsed_seconds := LEAST(v_elapsed_seconds, 86400);
  v_generated_amount := ((v_idle_rate / 3600.0) * v_elapsed_seconds)::BIGINT;

  SELECT * INTO v_add_result
  FROM public.add_inventory(p_player_id, v_generated_amount);

  UPDATE public.brand_state bs
  SET last_active_at = v_now
  WHERE bs.player_id = p_player_id;

  RETURN QUERY SELECT
    v_add_result.added_amount,
    v_add_result.new_inventory,
    v_add_result.is_full,
    v_idle_rate,
    v_elapsed_seconds;
END;
$$;

CREATE OR REPLACE FUNCTION public.edge_react_to_feed_post(
  p_player_id uuid,
  p_post_id uuid,
  p_reaction_type text
)
RETURNS TABLE(
  success boolean,
  post_id uuid,
  reaction_type text,
  hype numeric,
  likes integer,
  message text
)
LANGUAGE plpgsql
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
  ON CONFLICT ON CONSTRAINT post_reactions_pkey DO NOTHING;

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
    UPDATE public.feed_posts fp
    SET hype = fp.hype + 1
    WHERE fp.id = p_post_id
    RETURNING fp.* INTO v_post;
  ELSIF p_reaction_type = 'like' THEN
    UPDATE public.feed_posts fp
    SET likes = fp.likes + 1
    WHERE fp.id = p_post_id
    RETURNING fp.* INTO v_post;
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

CREATE OR REPLACE FUNCTION public.edge_add_feed_comment(
  p_player_id uuid,
  p_post_id uuid,
  p_body text
)
RETURNS TABLE(
  success boolean,
  comment_id uuid,
  post_id uuid,
  comments_count integer,
  message text,
  comment jsonb
)
LANGUAGE plpgsql
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

  UPDATE public.feed_posts fp
  SET comments_count = fp.comments_count + 1
  WHERE fp.id = p_post_id
  RETURNING fp.comments_count INTO v_comments_count;

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

CREATE OR REPLACE FUNCTION public.edge_drop_design(
  p_player_id uuid,
  p_design_id uuid,
  p_style_tags text[] DEFAULT '{}'::text[],
  p_vex_review jsonb DEFAULT NULL::jsonb,
  p_vex_quote text DEFAULT NULL::text,
  p_vex_caption text DEFAULT NULL::text
)
RETURNS TABLE(
  success boolean,
  feed_post_id uuid,
  garment_drop_id uuid,
  design_id uuid,
  hype_score numeric,
  brand_name text,
  fabric_color_hex text,
  message text,
  feed_post jsonb,
  vex_verdict text,
  vex_headline text,
  vex_quote text,
  followers_delta integer,
  brand_heat_delta integer,
  xp_delta integer,
  rank_progress_delta numeric,
  idle_revenue_delta numeric,
  market_reaction text,
  next_objective text
)
LANGUAGE plpgsql
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
  v_vex_verdict TEXT;
  v_vex_headline TEXT;
  v_followers_delta INT := 0;
  v_brand_heat_delta INT := 0;
  v_xp_delta INT := 0;
  v_rank_progress_delta NUMERIC := 0;
  v_idle_revenue_delta NUMERIC := 0;
  v_effective_hype NUMERIC := 0;
  v_market_reaction TEXT;
  v_next_objective TEXT;
  v_has_tsunami_match BOOLEAN := FALSE;
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
  WHERE p.id = p_player_id
  FOR UPDATE;

  v_fabric_color_hex := NULLIF(v_design.fabric_data->>'color_hex', '');
  v_vex_verdict := p_vex_review->>'verdict';
  v_vex_headline := p_vex_review->>'headline';

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
        to_jsonb(v_existing_post),
        v_existing_post.content->>'vex_verdict',
        v_existing_post.content->>'vex_headline',
        v_existing_post.content->>'vex_quote',
        0,
        0,
        0,
        0::NUMERIC,
        0::NUMERIC,
        COALESCE(v_existing_post.content->'post_drop_result'->>'market_reaction', 'Already live'),
        COALESCE(v_existing_post.content->'post_drop_result'->>'next_objective', 'Open the Global Feed.');
      RETURN;
    END IF;

    RAISE EXCEPTION 'DESIGN_ALREADY_DROPPED';
  END IF;

  IF v_design.status <> 'complete' THEN
    RAISE EXCEPTION 'DESIGN_NOT_READY';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.trend_tsunamis tt
    WHERE tt.expires_at > NOW()
      AND LOWER(tt.tag_name) = ANY(v_style_tags)
  )
  INTO v_has_tsunami_match;

  v_effective_hype := LEAST(100, GREATEST(v_design.hype_score, 0));

  v_followers_delta := LEAST(
    60,
    GREATEST(0, FLOOR(v_effective_hype / 2.0)::INT)
  );
  v_brand_heat_delta := LEAST(
    6,
    GREATEST(0, CEIL(v_effective_hype / 18.0)::INT)
  );
  v_xp_delta := GREATEST(0, ROUND(v_effective_hype)::INT);
  v_rank_progress_delta := ROUND((v_xp_delta::NUMERIC / 1000.0) * 100.0, 1);
  v_idle_revenue_delta := ROUND(v_effective_hype * 1.25, 2);

  v_market_reaction := CASE
    WHEN v_effective_hype >= 95 THEN 'Wave Rider'
    WHEN v_effective_hype >= 80 THEN 'Trend Surge'
    WHEN v_effective_hype >= 65 THEN 'Rising'
    WHEN v_effective_hype >= 40 THEN 'Watched'
    ELSE 'Quiet'
  END;

  v_next_objective := CASE
    WHEN v_has_tsunami_match THEN 'Drop again while the trend window is active.'
    WHEN v_effective_hype >= 80 THEN 'Match the current Trend Tsunami.'
    WHEN v_effective_hype >= 50 THEN 'Raise material quality before the next Alpha.'
    ELSE 'Tune the silhouette and trend tags before the next Alpha.'
  END;

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
      'brand_rank', v_brand_rank,
      'post_drop_result', jsonb_build_object(
        'followers_delta', v_followers_delta,
        'brand_heat_delta', v_brand_heat_delta,
        'xp_delta', v_xp_delta,
        'rank_progress_delta', v_rank_progress_delta,
        'idle_revenue_delta', v_idle_revenue_delta,
        'market_reaction', v_market_reaction,
        'next_objective', v_next_objective
      )
    )
  );

  IF p_vex_review IS NOT NULL THEN
    v_content := v_content || jsonb_strip_nulls(
      jsonb_build_object(
        'vex_review', p_vex_review,
        'vex_headline', v_vex_headline,
        'vex_quote', p_vex_quote,
        'vex_caption', p_vex_caption,
        'vex_verdict', v_vex_verdict
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

  UPDATE public.designs d
  SET status = 'dropped',
      dropped_at = COALESCE(d.dropped_at, NOW())
  WHERE d.id = p_design_id;

  UPDATE public.brand_state bs
  SET followers = bs.followers + v_followers_delta,
      heat = LEAST(100, bs.heat + v_brand_heat_delta),
      hype_score = GREATEST(bs.hype_score, v_design.hype_score),
      idle_revenue_per_hour = bs.idle_revenue_per_hour + v_idle_revenue_delta,
      updated_at = NOW()
  WHERE bs.player_id = p_player_id;

  UPDATE public.players p
  SET total_xp = p.total_xp + v_xp_delta,
      last_active_at = NOW()
  WHERE p.id = p_player_id;

  RETURN QUERY SELECT
    TRUE,
    v_feed_post.id,
    v_garment_drop.id,
    v_design.id,
    v_design.hype_score,
    v_brand_name,
    v_fabric_color_hex,
    'DROP_CREATED'::TEXT,
    to_jsonb(v_feed_post),
    v_vex_verdict,
    v_vex_headline,
    p_vex_quote,
    v_followers_delta,
    v_brand_heat_delta,
    v_xp_delta,
    v_rank_progress_delta,
    v_idle_revenue_delta,
    v_market_reaction,
    v_next_objective;
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
