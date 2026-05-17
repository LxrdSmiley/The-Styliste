-- =============================================================================
-- Directive N: Telemetry & Analytics Engine
-- GDD §8.15, §9.9 — Retention hooks and anomaly detection
-- Alabaster Standard: Every action logged, every notification traced
-- =============================================================================

-- =============================================================================
-- Table: telemetry_events — Immutable event stream
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.telemetry_events (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  event_type      TEXT NOT NULL,  -- 'session_start', 'notification_opened', 'check_in', 'purchase', etc.
  event_name      TEXT NOT NULL,  -- 'daily_check_in_day_3', 'trend_tsunami_alert', etc.
  payload         JSONB,            -- Event-specific data
  session_id      UUID,             -- For session funnel analysis
  device_info     JSONB,            -- Platform, OS version, device model
  occurred_at     TIMESTAMPTZ DEFAULT NOW(),
  
  -- Index for common queries
  CONSTRAINT valid_event_type CHECK (event_type IN (
    'session', 'notification', 'check_in', 'purchase', 'design', 
    'feed_interaction', 'crisis', 'gala', 'archive', 'economy_anomaly'
  ))
);

CREATE INDEX telemetry_events_player_idx ON public.telemetry_events(player_id);
CREATE INDEX telemetry_events_type_idx ON public.telemetry_events(event_type);
CREATE INDEX telemetry_events_occurred_idx ON public.telemetry_events(occurred_at DESC);
CREATE INDEX telemetry_events_session_idx ON public.telemetry_events(session_id);

-- Partition by month for performance (optional, for high volume)
-- CREATE TABLE telemetry_events_2024_05 PARTITION OF telemetry_events
--   FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');

ALTER TABLE public.telemetry_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Telemetry: insert own" ON public.telemetry_events FOR INSERT WITH CHECK (player_id = auth.uid());
CREATE POLICY "Telemetry: read own" ON public.telemetry_events FOR SELECT USING (player_id = auth.uid());

-- =============================================================================
-- Table: daily_check_ins — Streak tracking with rewards
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.daily_check_ins (
  player_id       UUID PRIMARY KEY REFERENCES public.players(id) ON DELETE CASCADE,
  current_streak  INTEGER DEFAULT 0,  -- Consecutive days
  last_check_in   DATE DEFAULT CURRENT_DATE,
  total_check_ins INTEGER DEFAULT 0,
  longest_streak  INTEGER DEFAULT 0,
  rewards_claimed JSONB DEFAULT '[]', -- Array of claimed milestone rewards
  next_reward_at  INTEGER DEFAULT 1   -- Next milestone to award
);

CREATE INDEX daily_check_ins_streak_idx ON public.daily_check_ins(current_streak DESC);

ALTER TABLE public.daily_check_ins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Check-ins: read own" ON public.daily_check_ins FOR SELECT USING (player_id = auth.uid());
CREATE POLICY "Check-ins: update own" ON public.daily_check_ins FOR UPDATE USING (player_id = auth.uid());

-- =============================================================================
-- RPC: Record Check-In
-- Returns streak info and any rewards earned
-- =============================================================================
CREATE OR REPLACE FUNCTION record_check_in(p_player_id UUID)
RETURNS TABLE(
  streak INTEGER,
  is_new_day BOOLEAN,
  reward_granted TEXT,
  reward_payload JSONB,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_record RECORD;
  v_is_new_day BOOLEAN;
  v_new_streak INTEGER;
  v_reward TEXT;
  v_payload JSONB;
BEGIN
  PERFORM public.assert_self(p_player_id);
  -- Get or create check-in record
  SELECT * INTO v_record
  FROM daily_check_ins
  WHERE player_id = p_player_id;
  
  IF v_record IS NULL THEN
    INSERT INTO daily_check_ins (player_id, current_streak, last_check_in, total_check_ins)
    VALUES (p_player_id, 1, CURRENT_DATE, 1)
    RETURNING * INTO v_record;
    v_is_new_day := TRUE;
    v_new_streak := 1;
  ELSE
    -- Check if already checked in today
    IF v_record.last_check_in = CURRENT_DATE THEN
      RETURN QUERY SELECT 
        v_record.current_streak,
        FALSE,
        NULL::TEXT,
        NULL::JSONB,
        'ALREADY_CHECKED_IN'::TEXT;
      RETURN;
    END IF;
    
    -- Check if streak continues (within 48 hours to be safe)
    IF v_record.last_check_in >= CURRENT_DATE - INTERVAL '1 day' THEN
      v_new_streak := v_record.current_streak + 1;
    ELSE
      -- Streak broken
      v_new_streak := 1;
    END IF;
    
    UPDATE daily_check_ins
    SET current_streak = v_new_streak,
        last_check_in = CURRENT_DATE,
        total_check_ins = total_check_ins + 1,
        longest_streak = GREATEST(longest_streak, v_new_streak)
    WHERE player_id = p_player_id
    RETURNING * INTO v_record;
    
    v_is_new_day := TRUE;
  END IF;
  
  -- Determine reward based on streak milestone
  v_reward := CASE
    WHEN v_new_streak = 1 THEN 'IDLE_BOOST_2H'
    WHEN v_new_streak = 3 THEN 'CURRENCY_500'
    WHEN v_new_streak = 7 THEN 'RARE_FABRIC'
    WHEN v_new_streak = 14 THEN 'LUXE_ACCESSORY'
    WHEN v_new_streak = 30 THEN 'PERMANENT_IDLE_5PCT'
    WHEN v_new_streak = 60 THEN 'MAISON_BANNER'
    WHEN v_new_streak = 100 THEN 'LEGACY_BADGE'
    ELSE 'STREAK_CONTINUE'
  END;
  
  v_payload := jsonb_build_object(
    'streak_day', v_new_streak,
    'total_check_ins', v_record.total_check_ins,
    'reward_type', v_reward
  );
  
  -- Log telemetry event
  INSERT INTO telemetry_events (player_id, event_type, event_name, payload)
  VALUES (p_player_id, 'check_in', 'daily_check_in_day_' || v_new_streak, v_payload);
  
  RETURN QUERY SELECT v_new_streak, v_is_new_day, v_reward, v_payload,
    CASE v_reward
      WHEN 'IDLE_BOOST_2H' THEN 'You showed up. That is how every empire starts.'
      WHEN 'CURRENCY_500' THEN 'Three days in — rivals are already nervous.'
      WHEN 'RARE_FABRIC' THEN 'A week of consistency. The fashion world is watching.'
      WHEN 'LUXE_ACCESSORY' THEN 'Fourteen days. You are not a fluke — you are a force.'
      WHEN 'PERMANENT_IDLE_5PCT' THEN 'A month. You have graduated from hopeful to inevitable.'
      WHEN 'MAISON_BANNER' THEN 'Two months. Legends are built in moments like this.'
      WHEN 'LEGACY_BADGE' THEN 'One hundred days. I have seen empires rise and fall. Yours is rising.'
      ELSE 'Welcome back, darling.'
    END::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION record_check_in(UUID) TO authenticated;

-- =============================================================================
-- RPC: Log Telemetry Event
-- Client-side event logging
-- =============================================================================
CREATE OR REPLACE FUNCTION log_telemetry_event(
  p_player_id UUID,
  p_event_type TEXT,
  p_event_name TEXT,
  p_payload JSONB DEFAULT NULL,
  p_session_id UUID DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO telemetry_events (player_id, event_type, event_name, payload, session_id)
  VALUES (p_player_id, p_event_type, p_event_name, p_payload, p_session_id)
  RETURNING id INTO v_event_id;
  
  RETURN v_event_id;
END;
$$;

GRANT EXECUTE ON FUNCTION log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID) TO authenticated;

-- =============================================================================
-- RPC: Anomaly Detection Engine
-- Flags revenue/follower spikes >3σ from player historical trend
-- =============================================================================
CREATE OR REPLACE FUNCTION detect_economy_anomaly(p_player_id UUID)
RETURNS TABLE(
  is_anomaly BOOLEAN,
  anomaly_type TEXT,
  severity TEXT,  -- 'low', 'medium', 'high', 'critical'
  deviation_sigma NUMERIC,
  flagged_value NUMERIC,
  expected_range_low NUMERIC,
  expected_range_high NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_avg_revenue NUMERIC;
  v_stddev_revenue NUMERIC;
  v_current_revenue NUMERIC;
  v_z_score NUMERIC;
BEGIN
  -- Calculate 30-day historical stats for this player
  SELECT 
    AVG(daily_revenue),
    STDDEV(daily_revenue)
  INTO v_avg_revenue, v_stddev_revenue
  FROM (
    SELECT (total_revenue - LAG(total_revenue) OVER (ORDER BY last_active_at)) as daily_revenue
    FROM brand_state_history  -- Hypothetical history table
    WHERE player_id = p_player_id
    AND last_active_at >= NOW() - INTERVAL '30 days'
  ) daily_changes;
  
  -- Get current revenue
  SELECT total_revenue INTO v_current_revenue
  FROM brand_state WHERE player_id = p_player_id;
  
  -- Calculate Z-score (sigma deviation)
  IF v_stddev_revenue > 0 THEN
    v_z_score := ABS((v_current_revenue - v_avg_revenue) / v_stddev_revenue);
  ELSE
    v_z_score := 0;
  END IF;
  
  -- Flag if >3 sigma
  IF v_z_score > 3.0 THEN
    -- Log anomaly
    INSERT INTO telemetry_events (player_id, event_type, event_name, payload)
    VALUES (p_player_id, 'economy_anomaly', 'revenue_spike_detected', jsonb_build_object(
      'z_score', v_z_score,
      'current_revenue', v_current_revenue,
      'historical_avg', v_avg_revenue
    ));
    
    RETURN QUERY SELECT TRUE, 'REVENUE_SPIKE',
      CASE 
        WHEN v_z_score > 5.0 THEN 'critical'
        WHEN v_z_score > 4.0 THEN 'high'
        ELSE 'medium'
      END,
      v_z_score, v_current_revenue,
      v_avg_revenue - (2 * v_stddev_revenue),
      v_avg_revenue + (2 * v_stddev_revenue);
  ELSE
    RETURN QUERY SELECT FALSE, NULL::TEXT, NULL::TEXT, 0::NUMERIC, 0::NUMERIC, 0::NUMERIC, 0::NUMERIC;
  END IF;
END;
$$;

-- =============================================================================
-- Table: fcm_tokens — Device tokens for push notifications
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
  player_id       UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  token           TEXT NOT NULL,
  platform        TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  device_id       TEXT,  -- For deduplication
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  last_used_at    TIMESTAMPTZ DEFAULT NOW(),
  is_active       BOOLEAN DEFAULT TRUE,
  
  PRIMARY KEY (player_id, token)
);

CREATE INDEX fcm_tokens_player_idx ON public.fcm_tokens(player_id) WHERE is_active = TRUE;

ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "FCM tokens: manage own" ON public.fcm_tokens 
  FOR ALL USING (player_id = auth.uid());

-- =============================================================================
-- RPC: Register FCM Token
-- =============================================================================
CREATE OR REPLACE FUNCTION register_fcm_token(
  p_player_id UUID,
  p_token TEXT,
  p_platform TEXT,
  p_device_id TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.assert_self(p_player_id);
  INSERT INTO fcm_tokens (player_id, token, platform, device_id)
  VALUES (p_player_id, p_token, p_platform, p_device_id)
  ON CONFLICT (player_id, token) DO UPDATE
  SET last_used_at = NOW(), is_active = TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION register_fcm_token(UUID, TEXT, TEXT, TEXT) TO authenticated;

-- =============================================================================
-- View: Retention Analytics
-- =============================================================================
CREATE OR REPLACE VIEW retention_analytics AS
SELECT 
  DATE_TRUNC('day', occurred_at) AS day,
  event_type,
  COUNT(DISTINCT player_id) AS unique_players,
  COUNT(*) AS total_events,
  COUNT(DISTINCT session_id) AS unique_sessions
FROM telemetry_events
WHERE occurred_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', occurred_at), event_type
ORDER BY day DESC;

-- =============================================================================
-- View: Notification Effectiveness
-- =============================================================================
CREATE OR REPLACE VIEW notification_effectiveness AS
SELECT 
  te.payload->>'notification_type' AS notification_type,
  te.payload->>'notification_id' AS notification_id,
  COUNT(*) AS total_sent,
  COUNT(CASE WHEN te2.event_name = 'notification_opened' THEN 1 END) AS total_opened,
  ROUND(
    COUNT(CASE WHEN te2.event_name = 'notification_opened' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0),
    2
  ) AS open_rate_pct
FROM telemetry_events te
LEFT JOIN telemetry_events te2 ON 
  te.player_id = te2.player_id 
  AND te2.event_type = 'notification' 
  AND te2.event_name = 'notification_opened'
  AND te2.payload->>'notification_id' = te.payload->>'notification_id'
  AND te2.occurred_at > te.occurred_at
WHERE te.event_type = 'notification'
AND te.event_name = 'notification_sent'
AND te.occurred_at >= NOW() - INTERVAL '7 days'
GROUP BY te.payload->>'notification_type', te.payload->>'notification_id';

-- =============================================================================
-- Comments
-- =============================================================================
COMMENT ON TABLE telemetry_events IS 'Immutable event stream for analytics. All player actions logged here.';
COMMENT ON TABLE daily_check_ins IS 'Streak tracking with milestone rewards. Resets if >24h missed.';
COMMENT ON FUNCTION record_check_in IS 'Daily check-in with automatic streak calculation and reward granting.';
COMMENT ON FUNCTION detect_economy_anomaly IS 'Statistical anomaly detection for anti-cheat. Flags >3σ deviations.';

-- =============================================================================
-- Database Webhooks — Trigger Edge Functions on row changes
-- Note: Webhooks must be configured in Supabase Dashboard or via API
-- These are the SQL triggers that enable webhook firing
-- =============================================================================

-- Trigger: Archive listing sold → Send FCM to seller
CREATE OR REPLACE FUNCTION trigger_archive_sold_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only trigger on status change to 'sold'
  IF OLD.status = 'active' AND NEW.status = 'sold' THEN
    -- pg_net or supabase webhook extension would fire here
    -- The actual HTTP call is handled by Supabase Webhooks feature
    PERFORM pg_notify(
      'webhook:archive_sold',
      json_build_object(
        'table', 'archive_listings',
        'record', row_to_json(NEW),
        'old_record', row_to_json(OLD)
      )::text
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS archive_listing_sold_trigger ON archive_listings;
CREATE TRIGGER archive_listing_sold_trigger
  AFTER UPDATE ON archive_listings
  FOR EACH ROW
  WHEN (OLD.status = 'active' AND NEW.status = 'sold')
  EXECUTE FUNCTION trigger_archive_sold_webhook();

-- Trigger: New trend tsunami → Broadcast to all players
CREATE OR REPLACE FUNCTION trigger_trend_tsunami_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  hours_until INTEGER;
BEGIN
  -- Calculate hours until window opens
  hours_until := EXTRACT(EPOCH FROM (NEW.window_opens_at - NOW())) / 3600;
  
  -- Only trigger if within 6 hours
  IF hours_until <= 6 AND hours_until > 0 THEN
    PERFORM pg_notify(
      'webhook:trend_tsunami',
      json_build_object(
        'table', 'trend_tsunamis',
        'record', row_to_json(NEW),
        'hours_until', hours_until
      )::text
    );
  END IF;
  RETURN NEW;
END;
$$;

-- Note: trend_tsunamis table must exist for this trigger
-- CREATE TRIGGER trend_tsunami_trigger
--   AFTER INSERT ON trend_tsunamis
--   FOR EACH ROW
--   EXECUTE FUNCTION trigger_trend_tsunami_webhook();

-- =============================================================================
-- RPC: Batch Log Telemetry
-- Efficient batch insert for client-side telemetry events
-- =============================================================================
CREATE OR REPLACE FUNCTION batch_log_telemetry(p_events JSONB[])
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO telemetry_events (player_id, event_type, event_name, payload, session_id, device_info, occurred_at)
  SELECT 
    (event->>'player_id')::UUID,
    event->>'event_type',
    event->>'event_name',
    event->'payload',
    (event->>'session_id')::UUID,
    event->'device_info',
    (event->>'occurred_at')::TIMESTAMPTZ
  FROM unnest(p_events) AS event;
END;
$$;

GRANT EXECUTE ON FUNCTION batch_log_telemetry(JSONB[]) TO authenticated;

-- =============================================================================
-- RPC: Log Telemetry Event
-- Single event logging (for immediate critical events)
-- =============================================================================
CREATE OR REPLACE FUNCTION log_telemetry_event(
  p_player_id UUID,
  p_event_type TEXT,
  p_event_name TEXT,
  p_payload JSONB DEFAULT NULL,
  p_session_id UUID DEFAULT NULL,
  p_device_info JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_event_id UUID;
BEGIN
  INSERT INTO telemetry_events (player_id, event_type, event_name, payload, session_id, device_info)
  VALUES (p_player_id, p_event_type, p_event_name, p_payload, p_session_id, p_device_info)
  RETURNING id INTO v_event_id;
  
  RETURN v_event_id;
END;
$$;

GRANT EXECUTE ON FUNCTION log_telemetry_event(UUID, TEXT, TEXT, JSONB, UUID, JSONB) TO authenticated;


