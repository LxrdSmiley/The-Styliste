ALTER TABLE public.feed_posts
  ALTER COLUMN player_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS is_system BOOLEAN NOT NULL DEFAULT false;

DROP POLICY IF EXISTS "Users can create feed posts" ON public.feed_posts;
DROP POLICY IF EXISTS "Feed posts: insert own" ON public.feed_posts;

CREATE POLICY "Users can create own feed posts"
ON public.feed_posts
FOR INSERT
TO authenticated
WITH CHECK (player_id = auth.uid() AND is_system = false);
