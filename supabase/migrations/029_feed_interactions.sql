-- The Styliste — Global Feed Interaction MVP
-- GDD §6.1 / §6.2 / §8.7.1: real, backend-backed feed actions.

-- ---------------------------------------------------------------------------
-- Comments
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.feed_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  body TEXT NOT NULL CHECK (char_length(trim(body)) BETWEEN 1 AND 280),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS feed_comments_post_created_idx
  ON public.feed_comments(post_id, created_at DESC);
CREATE INDEX IF NOT EXISTS feed_comments_player_idx
  ON public.feed_comments(player_id, created_at DESC);

ALTER TABLE public.feed_comments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Feed comments: read all" ON public.feed_comments;
CREATE POLICY "Feed comments: read all"
  ON public.feed_comments FOR SELECT
  TO authenticated
  USING (TRUE);

DROP POLICY IF EXISTS "Feed comments: insert own" ON public.feed_comments;
CREATE POLICY "Feed comments: insert own"
  ON public.feed_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = player_id);

DROP POLICY IF EXISTS "Feed comments: delete own" ON public.feed_comments;
CREATE POLICY "Feed comments: delete own"
  ON public.feed_comments FOR DELETE
  TO authenticated
  USING (auth.uid() = player_id);

-- ---------------------------------------------------------------------------
-- Remix / Stitch draft lineage.
-- Client creates the draft design through existing designs RLS, then records
-- lineage here for future Archive/Remix graph features.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.feed_derivatives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_post_id UUID NOT NULL REFERENCES public.feed_posts(id) ON DELETE CASCADE,
  source_design_id UUID REFERENCES public.designs(id) ON DELETE SET NULL,
  derivative_design_id UUID NOT NULL REFERENCES public.designs(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN ('remix', 'stitch')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'dropped', 'archived')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (source_post_id, derivative_design_id, kind)
);

CREATE INDEX IF NOT EXISTS feed_derivatives_player_idx
  ON public.feed_derivatives(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS feed_derivatives_source_idx
  ON public.feed_derivatives(source_post_id, created_at DESC);

ALTER TABLE public.feed_derivatives ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Feed derivatives: read own and source" ON public.feed_derivatives;
CREATE POLICY "Feed derivatives: read own and source"
  ON public.feed_derivatives FOR SELECT
  TO authenticated
  USING (
    auth.uid() = player_id
    OR EXISTS (
      SELECT 1
      FROM public.feed_posts fp
      WHERE fp.id = source_post_id
        AND fp.player_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Feed derivatives: insert own" ON public.feed_derivatives;
CREATE POLICY "Feed derivatives: insert own"
  ON public.feed_derivatives FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = player_id
    AND EXISTS (
      SELECT 1
      FROM public.designs d
      WHERE d.id = derivative_design_id
        AND d.player_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Direct Messages
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.direct_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES public.feed_posts(id) ON DELETE SET NULL,
  sender_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  body TEXT NOT NULL CHECK (char_length(trim(body)) BETWEEN 1 AND 500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS direct_messages_sender_idx
  ON public.direct_messages(sender_id, created_at DESC);
CREATE INDEX IF NOT EXISTS direct_messages_recipient_idx
  ON public.direct_messages(recipient_id, created_at DESC);

ALTER TABLE public.direct_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Direct messages: read participants" ON public.direct_messages;
CREATE POLICY "Direct messages: read participants"
  ON public.direct_messages FOR SELECT
  TO authenticated
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

DROP POLICY IF EXISTS "Direct messages: insert sender" ON public.direct_messages;
CREATE POLICY "Direct messages: insert sender"
  ON public.direct_messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = sender_id);

DROP POLICY IF EXISTS "Direct messages: recipient marks read" ON public.direct_messages;
CREATE POLICY "Direct messages: recipient marks read"
  ON public.direct_messages FOR UPDATE
  TO authenticated
  USING (auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = recipient_id);

-- ---------------------------------------------------------------------------
-- Collab Requests
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.collab_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES public.feed_posts(id) ON DELETE SET NULL,
  requester_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  message TEXT NOT NULL CHECK (char_length(trim(message)) BETWEEN 1 AND 500),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'declined', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS collab_requests_requester_idx
  ON public.collab_requests(requester_id, created_at DESC);
CREATE INDEX IF NOT EXISTS collab_requests_recipient_idx
  ON public.collab_requests(recipient_id, created_at DESC);

ALTER TABLE public.collab_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Collab requests: read participants" ON public.collab_requests;
CREATE POLICY "Collab requests: read participants"
  ON public.collab_requests FOR SELECT
  TO authenticated
  USING (auth.uid() = requester_id OR auth.uid() = recipient_id);

DROP POLICY IF EXISTS "Collab requests: insert requester" ON public.collab_requests;
CREATE POLICY "Collab requests: insert requester"
  ON public.collab_requests FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = requester_id);

DROP POLICY IF EXISTS "Collab requests: update participants" ON public.collab_requests;
CREATE POLICY "Collab requests: update participants"
  ON public.collab_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = requester_id OR auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = requester_id OR auth.uid() = recipient_id);

-- Explicit Data API access for projects where new tables are not exposed
-- automatically through grants.
GRANT SELECT, INSERT, DELETE ON public.post_reactions TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.feed_comments TO authenticated;
GRANT SELECT, INSERT ON public.feed_derivatives TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.direct_messages TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.collab_requests TO authenticated;

COMMENT ON TABLE public.feed_comments IS
  'Player comments on Global Feed posts.';
COMMENT ON TABLE public.feed_derivatives IS
  'Remix and Stitch draft lineage created from Global Feed posts.';
COMMENT ON TABLE public.direct_messages IS
  'Post-context direct messages between players.';
COMMENT ON TABLE public.collab_requests IS
  'Post-context collaboration requests between players.';
