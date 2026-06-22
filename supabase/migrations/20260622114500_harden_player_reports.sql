-- Harden player report validation and submission frequency.

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;

UPDATE public.player_reports
SET reported_player_id = reported_id
WHERE reported_player_id IS NULL;

UPDATE public.player_reports
SET category = reason
WHERE category IS NULL;

ALTER TABLE public.player_reports
  ALTER COLUMN reported_player_id SET NOT NULL,
  ALTER COLUMN category SET NOT NULL;

ALTER TABLE public.player_reports
  DROP CONSTRAINT IF EXISTS player_reports_category_allowed,
  ADD CONSTRAINT player_reports_category_allowed CHECK (
    category IN (
      'harassment',
      'hate',
      'spam',
      'cheating',
      'inappropriate_content',
      'other'
    )
  ),
  DROP CONSTRAINT IF EXISTS player_reports_reason_allowed,
  ADD CONSTRAINT player_reports_reason_allowed CHECK (
    reason IN (
      'harassment',
      'hate',
      'spam',
      'cheating',
      'inappropriate_content',
      'other'
    )
  ),
  DROP CONSTRAINT IF EXISTS player_reports_category_matches_reason,
  ADD CONSTRAINT player_reports_category_matches_reason CHECK (
    category = reason
  ),
  DROP CONSTRAINT IF EXISTS player_reports_target_matches,
  ADD CONSTRAINT player_reports_target_matches CHECK (
    reported_player_id = reported_id
  ),
  DROP CONSTRAINT IF EXISTS player_reports_description_length,
  ADD CONSTRAINT player_reports_description_length CHECK (
    description IS NULL OR char_length(description) <= 1000
  ),
  DROP CONSTRAINT IF EXISTS player_reports_not_self,
  ADD CONSTRAINT player_reports_not_self CHECK (
    reporter_id <> reported_player_id
  );

CREATE INDEX IF NOT EXISTS player_reports_recent_target_idx
  ON public.player_reports(reporter_id, reported_player_id, created_at DESC);

CREATE OR REPLACE FUNCTION private.enforce_player_report_limits()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_actor UUID := auth.uid();
  v_daily_count INT;
BEGIN
  IF v_actor IS NULL OR v_actor IS DISTINCT FROM NEW.reporter_id THEN
    RAISE EXCEPTION 'UNAUTHORIZED_REPORTER';
  END IF;

  PERFORM pg_advisory_xact_lock(
    hashtextextended(
      NEW.reporter_id::TEXT || ':' || NEW.reported_player_id::TEXT,
      0
    )
  );

  IF EXISTS (
    SELECT 1
    FROM public.player_reports report
    WHERE report.reporter_id = NEW.reporter_id
      AND report.reported_player_id = NEW.reported_player_id
      AND report.created_at >= clock_timestamp() - INTERVAL '15 minutes'
  ) THEN
    RAISE EXCEPTION 'REPORT_RATE_LIMITED';
  END IF;

  SELECT COUNT(*)
  INTO v_daily_count
  FROM public.player_reports report
  WHERE report.reporter_id = NEW.reporter_id
    AND report.created_at >= clock_timestamp() - INTERVAL '24 hours';

  IF v_daily_count >= 10 THEN
    RAISE EXCEPTION 'REPORT_DAILY_LIMIT';
  END IF;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION private.enforce_player_report_limits() FROM PUBLIC;

DROP TRIGGER IF EXISTS player_reports_enforce_limits
  ON public.player_reports;
CREATE TRIGGER player_reports_enforce_limits
BEFORE INSERT ON public.player_reports
FOR EACH ROW
EXECUTE FUNCTION private.enforce_player_report_limits();
