-- Post-Drop Progression + HQ Feedback Pass 1
-- Keeps Alpha Drop execution server-authoritative and applies bounded
-- first-drop progression only inside the service-only drop RPC.

DROP FUNCTION IF EXISTS public.edge_drop_design(
  UUID,
  UUID,
  TEXT[],
  JSONB,
  TEXT,
  TEXT
);

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
  feed_post JSONB,
  vex_verdict TEXT,
  vex_headline TEXT,
  vex_quote TEXT,
  followers_delta INT,
  brand_heat_delta INT,
  xp_delta INT,
  rank_progress_delta NUMERIC,
  idle_revenue_delta NUMERIC,
  market_reaction TEXT,
  next_objective TEXT
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
  v_current_xp INT;
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

  SELECT p.brand_name, p.brand_rank, p.total_xp
  INTO v_brand_name, v_brand_rank, v_current_xp
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

  UPDATE public.designs
  SET status = 'dropped',
      dropped_at = COALESCE(dropped_at, NOW())
  WHERE id = p_design_id;

  UPDATE public.brand_state
  SET followers = followers + v_followers_delta,
      heat = LEAST(100, heat + v_brand_heat_delta),
      hype_score = GREATEST(hype_score, v_design.hype_score),
      idle_revenue_per_hour = idle_revenue_per_hour + v_idle_revenue_delta,
      updated_at = NOW()
  WHERE player_id = p_player_id;

  UPDATE public.players
  SET total_xp = total_xp + v_xp_delta,
      last_active_at = NOW()
  WHERE id = p_player_id;

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

COMMENT ON FUNCTION public.edge_drop_design(UUID, UUID, TEXT[], JSONB, TEXT, TEXT) IS
  'Service-only RPC used by the drop-design Edge Function to atomically publish a completed Alpha design and apply bounded post-drop progression.';
