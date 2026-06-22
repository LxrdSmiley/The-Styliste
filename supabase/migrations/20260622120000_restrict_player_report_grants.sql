-- Restrict report Data API access to the exact client operations in use.

REVOKE ALL ON TABLE public.player_reports FROM anon;
REVOKE ALL ON TABLE public.player_reports FROM authenticated;
GRANT SELECT, INSERT ON TABLE public.player_reports TO authenticated;

REVOKE ALL ON FUNCTION private.enforce_player_report_limits() FROM PUBLIC;
