-- Cover report target foreign keys for moderation and player-deletion paths.

CREATE INDEX IF NOT EXISTS player_reports_reported_id_idx
  ON public.player_reports(reported_id);

CREATE INDEX IF NOT EXISTS player_reports_reported_player_id_idx
  ON public.player_reports(reported_player_id);
