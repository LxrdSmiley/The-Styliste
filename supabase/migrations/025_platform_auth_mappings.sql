CREATE TABLE IF NOT EXISTS public.platform_auth_mappings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('play_games', 'game_center')),
  platform_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(platform, platform_user_id),
  UNIQUE(player_id, platform)
);

ALTER TABLE public.platform_auth_mappings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own platform mappings"
ON public.platform_auth_mappings
FOR SELECT
TO authenticated
USING (player_id = auth.uid());

CREATE POLICY "Users can insert own platform mappings"
ON public.platform_auth_mappings
FOR INSERT
TO authenticated
WITH CHECK (player_id = auth.uid());
