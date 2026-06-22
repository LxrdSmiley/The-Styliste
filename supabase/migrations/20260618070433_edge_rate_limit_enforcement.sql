CREATE TABLE IF NOT EXISTS public.security_rate_limit_events (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_id UUID NOT NULL,
  action TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX IF NOT EXISTS security_rate_limit_actor_action_idx
  ON public.security_rate_limit_events(actor_id, action, occurred_at DESC);
ALTER TABLE public.security_rate_limit_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.security_rate_limit_events FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.security_rate_limit_events TO service_role;

CREATE OR REPLACE FUNCTION public.edge_consume_rate_limit(
  p_actor_id UUID,
  p_action TEXT,
  p_window_seconds INT,
  p_max_requests INT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_cutoff TIMESTAMPTZ;
  v_count INT;
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'SERVICE_ROLE_REQUIRED';
  END IF;
  IF p_window_seconds < 1 OR p_window_seconds > 86400
    OR p_max_requests < 1 OR p_max_requests > 1000
    OR LENGTH(TRIM(p_action)) NOT BETWEEN 1 AND 80 THEN
    RAISE EXCEPTION 'INVALID_RATE_LIMIT';
  END IF;

  PERFORM pg_advisory_xact_lock(
    hashtextextended(p_actor_id::TEXT || ':' || p_action, 0)
  );
  v_cutoff := clock_timestamp() - make_interval(secs => p_window_seconds);

  DELETE FROM public.security_rate_limit_events
  WHERE actor_id = p_actor_id AND action = p_action
    AND occurred_at < v_cutoff;

  SELECT COUNT(*) INTO v_count
  FROM public.security_rate_limit_events
  WHERE actor_id = p_actor_id AND action = p_action
    AND occurred_at >= v_cutoff;
  IF v_count >= p_max_requests THEN RETURN FALSE; END IF;

  INSERT INTO public.security_rate_limit_events(actor_id, action)
  VALUES (p_actor_id, p_action);
  RETURN TRUE;
END;
$$;
REVOKE ALL ON FUNCTION public.edge_consume_rate_limit(UUID, TEXT, INT, INT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.edge_consume_rate_limit(UUID, TEXT, INT, INT)
  TO service_role;
