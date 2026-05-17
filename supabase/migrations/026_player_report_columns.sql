ALTER TABLE public.player_reports
  ADD COLUMN IF NOT EXISTS reported_player_id UUID REFERENCES public.players(id),
  ADD COLUMN IF NOT EXISTS category TEXT;

UPDATE public.player_reports
SET reported_player_id = COALESCE(reported_player_id, reported_id),
    category = COALESCE(category, reason);
