-- The Styliste - Permissioned Atelier inspiration and server-owned power combo.
-- GDD v6 §4.1, §5.7, §6.1: Artisans may request design inspiration from
-- another Artisan, but the requester receives a draft only after approval.

-- ---------------------------------------------------------------------------
-- Collab request hardening and inspiration metadata
-- ---------------------------------------------------------------------------
ALTER TABLE public.collab_requests
  ADD COLUMN IF NOT EXISTS request_type TEXT NOT NULL DEFAULT 'collab',
  ADD COLUMN IF NOT EXISTS source_design_id UUID REFERENCES public.designs(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS approved_design_id UUID REFERENCES public.designs(id) ON DELETE SET NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'collab_requests_request_type_check'
      AND conrelid = 'public.collab_requests'::regclass
  ) THEN
    ALTER TABLE public.collab_requests
      ADD CONSTRAINT collab_requests_request_type_check
      CHECK (request_type IN ('collab', 'design_inspiration'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS collab_requests_post_pending_idx
  ON public.collab_requests(post_id, recipient_id, created_at DESC)
  WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS collab_requests_requester_type_idx
  ON public.collab_requests(requester_id, request_type, created_at DESC);

WITH ranked_pending_requests AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY post_id, requester_id, request_type
      ORDER BY created_at ASC, id ASC
    ) AS rn
  FROM public.collab_requests
  WHERE status = 'pending'
    AND post_id IS NOT NULL
)
UPDATE public.collab_requests cr
SET status = 'cancelled',
    responded_at = NOW()
FROM ranked_pending_requests ranked
WHERE cr.id = ranked.id
  AND ranked.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS collab_requests_pending_type_unique_idx
  ON public.collab_requests(post_id, requester_id, request_type)
  WHERE status = 'pending';

-- Closed-alpha rule: clients read participant requests, but request creation and
-- response decisions go through Edge Functions so requesters cannot approve
-- their own inspiration access.
DROP POLICY IF EXISTS "Collab requests: insert requester" ON public.collab_requests;
DROP POLICY IF EXISTS "Collab requests: update participants" ON public.collab_requests;

REVOKE INSERT, UPDATE, DELETE ON public.collab_requests FROM anon, authenticated;
GRANT SELECT ON public.collab_requests TO authenticated;

-- ---------------------------------------------------------------------------
-- Service-only helpers for feed social requests
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edge_request_design_inspiration(
  p_requester_id UUID,
  p_post_id UUID,
  p_message TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_message TEXT := TRIM(COALESCE(p_message, ''));
  v_requester public.players%ROWTYPE;
  v_recipient public.players%ROWTYPE;
  v_post public.feed_posts%ROWTYPE;
  v_source_design public.designs%ROWTYPE;
  v_source_design_id UUID;
  v_existing public.collab_requests%ROWTYPE;
  v_request public.collab_requests%ROWTYPE;
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  SELECT *
  INTO v_requester
  FROM public.players
  WHERE id = p_requester_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'REQUESTER_NOT_FOUND';
  END IF;

  IF v_requester.path <> 'designer' AND NOT COALESCE(v_requester.is_joint_venture, FALSE) THEN
    RAISE EXCEPTION 'REQUESTER_NOT_ARTISAN';
  END IF;

  SELECT *
  INTO v_post
  FROM public.feed_posts
  WHERE id = p_post_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'POST_NOT_FOUND';
  END IF;

  IF v_post.player_id = p_requester_id THEN
    RAISE EXCEPTION 'CANNOT_REQUEST_OWN_DESIGN';
  END IF;

  IF v_post.type NOT IN ('design_flex', 'design_drop') THEN
    RAISE EXCEPTION 'POST_NOT_DESIGN_DROP';
  END IF;

  SELECT *
  INTO v_recipient
  FROM public.players
  WHERE id = v_post.player_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'RECIPIENT_NOT_FOUND';
  END IF;

  IF v_recipient.path <> 'designer' AND NOT COALESCE(v_recipient.is_joint_venture, FALSE) THEN
    RAISE EXCEPTION 'SOURCE_NOT_ARTISAN';
  END IF;

  v_source_design_id := NULLIF(v_post.content->>'design_id', '')::UUID;
  IF v_source_design_id IS NULL THEN
    RAISE EXCEPTION 'SOURCE_DESIGN_MISSING';
  END IF;

  SELECT *
  INTO v_source_design
  FROM public.designs
  WHERE id = v_source_design_id
    AND COALESCE(owner_id, player_id) = v_post.player_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'SOURCE_DESIGN_NOT_FOUND';
  END IF;

  SELECT *
  INTO v_existing
  FROM public.collab_requests
  WHERE post_id = p_post_id
    AND requester_id = p_requester_id
    AND request_type = 'design_inspiration'
    AND status IN ('pending', 'accepted')
  ORDER BY created_at DESC
  LIMIT 1;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'id', v_existing.id,
      'post_id', v_existing.post_id,
      'requester_id', v_existing.requester_id,
      'recipient_id', v_existing.recipient_id,
      'request_type', v_existing.request_type,
      'message', v_existing.message,
      'status', v_existing.status,
      'source_design_id', v_existing.source_design_id,
      'approved_design_id', v_existing.approved_design_id,
      'created_at', v_existing.created_at,
      'responded_at', v_existing.responded_at
    );
  END IF;

  IF v_message = '' THEN
    v_message := 'Permission request: Atelier inspiration study.';
  END IF;

  INSERT INTO public.collab_requests (
    post_id,
    requester_id,
    recipient_id,
    message,
    request_type,
    source_design_id
  )
  VALUES (
    p_post_id,
    p_requester_id,
    v_post.player_id,
    LEFT(v_message, 500),
    'design_inspiration',
    v_source_design.id
  )
  RETURNING * INTO v_request;

  RETURN jsonb_build_object(
    'id', v_request.id,
    'post_id', v_request.post_id,
    'requester_id', v_request.requester_id,
    'recipient_id', v_request.recipient_id,
    'request_type', v_request.request_type,
    'message', v_request.message,
    'status', v_request.status,
    'source_design_id', v_request.source_design_id,
    'approved_design_id', v_request.approved_design_id,
    'created_at', v_request.created_at,
    'responded_at', v_request.responded_at
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.edge_respond_design_inspiration(
  p_recipient_id UUID,
  p_request_id UUID,
  p_approve BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_request public.collab_requests%ROWTYPE;
  v_source public.designs%ROWTYPE;
  v_draft public.designs%ROWTYPE;
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  SELECT *
  INTO v_request
  FROM public.collab_requests
  WHERE id = p_request_id
    AND recipient_id = p_recipient_id
    AND request_type = 'design_inspiration'
    AND status = 'pending'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'REQUEST_NOT_FOUND';
  END IF;

  IF p_approve THEN
    SELECT *
    INTO v_source
    FROM public.designs
    WHERE id = v_request.source_design_id
      AND COALESCE(owner_id, player_id) = p_recipient_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'SOURCE_DESIGN_NOT_FOUND';
    END IF;

    INSERT INTO public.designs (
      player_id,
      owner_id,
      name,
      session_type,
      status,
      hype_score,
      is_alpha,
      is_digital_twin,
      dpp_registered,
      fabric_data,
      sell_potential,
      cultural_impact
    )
    VALUES (
      v_request.requester_id,
      v_request.requester_id,
      LEFT('INSPIRED BY ' || v_source.name, 80),
      'quick_sketch',
      'draft',
      0,
      FALSE,
      v_source.is_digital_twin,
      FALSE,
      v_source.fabric_data || jsonb_build_object(
        'inspiration_request_id', v_request.id,
        'inspiration_source_design_id', v_source.id,
        'inspiration_source_player_id', v_source.player_id,
        'inspiration_source_name', v_source.name
      ),
      0,
      0
    )
    RETURNING * INTO v_draft;

    UPDATE public.collab_requests
    SET status = 'accepted',
        responded_at = NOW(),
        approved_design_id = v_draft.id
    WHERE id = v_request.id
    RETURNING * INTO v_request;
  ELSE
    UPDATE public.collab_requests
    SET status = 'declined',
        responded_at = NOW(),
        approved_design_id = NULL
    WHERE id = v_request.id
    RETURNING * INTO v_request;
  END IF;

  RETURN jsonb_build_object(
    'id', v_request.id,
    'post_id', v_request.post_id,
    'requester_id', v_request.requester_id,
    'recipient_id', v_request.recipient_id,
    'request_type', v_request.request_type,
    'message', v_request.message,
    'status', v_request.status,
    'source_design_id', v_request.source_design_id,
    'approved_design_id', v_request.approved_design_id,
    'created_at', v_request.created_at,
    'responded_at', v_request.responded_at
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.edge_request_feed_collab(
  p_requester_id UUID,
  p_post_id UUID,
  p_message TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_message TEXT := TRIM(COALESCE(p_message, ''));
  v_post public.feed_posts%ROWTYPE;
  v_existing public.collab_requests%ROWTYPE;
  v_request public.collab_requests%ROWTYPE;
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  PERFORM 1 FROM public.players WHERE id = p_requester_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'REQUESTER_NOT_FOUND';
  END IF;

  SELECT *
  INTO v_post
  FROM public.feed_posts
  WHERE id = p_post_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'POST_NOT_FOUND';
  END IF;

  IF v_post.player_id = p_requester_id THEN
    RAISE EXCEPTION 'CANNOT_REQUEST_OWN_POST';
  END IF;

  SELECT *
  INTO v_existing
  FROM public.collab_requests
  WHERE post_id = p_post_id
    AND requester_id = p_requester_id
    AND request_type = 'collab'
    AND status IN ('pending', 'accepted')
  ORDER BY created_at DESC
  LIMIT 1;

  IF FOUND THEN
    RETURN jsonb_build_object(
      'id', v_existing.id,
      'post_id', v_existing.post_id,
      'requester_id', v_existing.requester_id,
      'recipient_id', v_existing.recipient_id,
      'request_type', v_existing.request_type,
      'message', v_existing.message,
      'status', v_existing.status,
      'source_design_id', v_existing.source_design_id,
      'approved_design_id', v_existing.approved_design_id,
      'created_at', v_existing.created_at,
      'responded_at', v_existing.responded_at
    );
  END IF;

  IF v_message = '' THEN
    v_message := 'Collaboration request from the Global Feed.';
  END IF;

  INSERT INTO public.collab_requests (
    post_id,
    requester_id,
    recipient_id,
    message,
    request_type
  )
  VALUES (
    p_post_id,
    p_requester_id,
    v_post.player_id,
    LEFT(v_message, 500),
    'collab'
  )
  RETURNING * INTO v_request;

  RETURN jsonb_build_object(
    'id', v_request.id,
    'post_id', v_request.post_id,
    'requester_id', v_request.requester_id,
    'recipient_id', v_request.recipient_id,
    'request_type', v_request.request_type,
    'message', v_request.message,
    'status', v_request.status,
    'source_design_id', v_request.source_design_id,
    'approved_design_id', v_request.approved_design_id,
    'created_at', v_request.created_at,
    'responded_at', v_request.responded_at
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.edge_respond_feed_collab(
  p_recipient_id UUID,
  p_request_id UUID,
  p_approve BOOLEAN
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_request public.collab_requests%ROWTYPE;
  v_partnership_id UUID;
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  SELECT *
  INTO v_request
  FROM public.collab_requests
  WHERE id = p_request_id
    AND recipient_id = p_recipient_id
    AND request_type = 'collab'
    AND status = 'pending'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'REQUEST_NOT_FOUND';
  END IF;

  IF p_approve THEN
    SELECT id
    INTO v_partnership_id
    FROM public.partnerships
    WHERE status = 'active'
      AND (
        (player_a_id = v_request.requester_id AND player_b_id = v_request.recipient_id)
        OR
        (player_a_id = v_request.recipient_id AND player_b_id = v_request.requester_id)
      )
    LIMIT 1;

    IF v_partnership_id IS NULL THEN
      INSERT INTO public.partnerships (
        player_a_id,
        player_b_id,
        split_ratio,
        status
      )
      VALUES (
        v_request.requester_id,
        v_request.recipient_id,
        0.5,
        'active'
      )
      RETURNING id INTO v_partnership_id;
    END IF;

    UPDATE public.collab_requests
    SET status = 'accepted',
        responded_at = NOW()
    WHERE id = v_request.id
    RETURNING * INTO v_request;
  ELSE
    UPDATE public.collab_requests
    SET status = 'declined',
        responded_at = NOW()
    WHERE id = v_request.id
    RETURNING * INTO v_request;
  END IF;

  RETURN jsonb_build_object(
    'id', v_request.id,
    'post_id', v_request.post_id,
    'requester_id', v_request.requester_id,
    'recipient_id', v_request.recipient_id,
    'request_type', v_request.request_type,
    'message', v_request.message,
    'status', v_request.status,
    'source_design_id', v_request.source_design_id,
    'approved_design_id', v_request.approved_design_id,
    'created_at', v_request.created_at,
    'responded_at', v_request.responded_at,
    'partnership_id', v_partnership_id
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Service-only Power Move Combo reward
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.edge_apply_power_move_combo(
  p_player_id UUID,
  p_result_key TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_multiplier NUMERIC := 1.5;
  v_expires_at TIMESTAMPTZ := NOW() + INTERVAL '24 hours';
BEGIN
  IF COALESCE(auth.role(), '') <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;

  IF p_result_key <> 'standard_win' THEN
    RAISE EXCEPTION 'INVALID_POWER_MOVE_RESULT';
  END IF;

  UPDATE public.brand_state
  SET pending_power_move_multiplier = v_multiplier,
      power_move_expires_at = v_expires_at,
      updated_at = NOW()
  WHERE player_id = p_player_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'BRAND_STATE_NOT_FOUND';
  END IF;

  RETURN jsonb_build_object(
    'success', TRUE,
    'reward', jsonb_build_object(
      'power_move_multiplier', v_multiplier,
      'expires_at', v_expires_at
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.edge_request_design_inspiration(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.edge_respond_design_inspiration(UUID, UUID, BOOLEAN)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.edge_request_feed_collab(UUID, UUID, TEXT)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.edge_respond_feed_collab(UUID, UUID, BOOLEAN)
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.edge_apply_power_move_combo(UUID, TEXT)
  FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.edge_request_design_inspiration(UUID, UUID, TEXT)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.edge_respond_design_inspiration(UUID, UUID, BOOLEAN)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.edge_request_feed_collab(UUID, UUID, TEXT)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.edge_respond_feed_collab(UUID, UUID, BOOLEAN)
  TO service_role;
GRANT EXECUTE ON FUNCTION public.edge_apply_power_move_combo(UUID, TEXT)
  TO service_role;

COMMENT ON FUNCTION public.edge_request_design_inspiration(UUID, UUID, TEXT) IS
  'Service-only request path for permissioned Atelier inspiration from another Artisan design.';
COMMENT ON FUNCTION public.edge_respond_design_inspiration(UUID, UUID, BOOLEAN) IS
  'Service-only approval path that creates requester-owned draft designs only after creator consent.';
COMMENT ON FUNCTION public.edge_apply_power_move_combo(UUID, TEXT) IS
  'Service-only Power Move Combo reward; client cannot choose multiplier or write brand_state.';
