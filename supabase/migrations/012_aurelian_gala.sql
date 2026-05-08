-- =============================================================================
-- The Styliste — Aurelian Gala (Weekly PvP) Migration
-- GDD §6.9, §12.3.3 — The Met Gala of The Styliste
-- Auto-rotating weekly events with pg_cron
-- =============================================================================

-- =============================================================================
-- Table: gala_events (weekly themes)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.gala_events (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  theme_title         TEXT NOT NULL,  -- e.g., "Cybernetic Renaissance"
  theme_description   TEXT,
  style_tags          TEXT[],         -- Required style elements ["Futuristic", "Minimalist"]
  starts_at           TIMESTAMPTZ NOT NULL,
  ends_at             TIMESTAMPTZ NOT NULL,
  status              TEXT DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'voting', 'completed')),
  prize_pool_luxe     INTEGER DEFAULT 10000,  -- Total Luxe to distribute
  total_submissions   INTEGER DEFAULT 0,
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX gala_events_status_idx ON public.gala_events(status);
CREATE INDEX gala_events_dates_idx ON public.gala_events(starts_at, ends_at);

-- Seed 12 weeks of themes in advance
INSERT INTO gala_events (theme_title, theme_description, style_tags, starts_at, ends_at, status) VALUES
  ('Cybernetic Renaissance', 'Where classical art meets neural networks. Think marble statues with LED veins.', ARRAY['Futuristic', 'Classical', 'Neon'], NOW() + INTERVAL '7 days', NOW() + INTERVAL '14 days', 'upcoming'),
  ('Obsidian & Pearl', 'The eternal duality. Black as void, white as purity. No grey allowed.', ARRAY['Monochrome', 'Elegant', 'High Contrast'], NOW() + INTERVAL '14 days', NOW() + INTERVAL '21 days', 'upcoming'),
  ('Neo-Tokyo Midnight', 'Rain-slicked streets and holographic kanji. The city never sleeps.', ARRAY['Cyberpunk', 'Urban', 'Neon'], NOW() + INTERVAL '21 days', NOW() + INTERVAL '28 days', 'upcoming'),
  ('Aureate Ascension', 'Pure gold and blinding light. Dress for your coronation.', ARRAY['Gold', 'Luxury', 'Divine'], NOW() + INTERVAL '28 days', NOW() + INTERVAL '35 days', 'upcoming'),
  ('The Void Gardens', 'Flora from the edge of a black hole. Bioluminescent and impossible.', ARRAY['Nature', 'Surreal', 'Dark'], NOW() + INTERVAL '35 days', NOW() + INTERVAL '42 days', 'upcoming'),
  ('Velvet Revolution', 'Rich textures of uprising. Deep reds and tactical elegance.', ARRAY['Bold', 'Political', 'Texture'], NOW() + INTERVAL '42 days', NOW() + INTERVAL '49 days', 'upcoming'),
  ('Glass Cathedral', 'Transparent and refractive. Sacred geometry in crystal.', ARRAY['Transparent', 'Geometric', 'Sacred'], NOW() + INTERVAL '49 days', NOW() + INTERVAL '56 days', 'upcoming'),
  ('Wasteland Couture', 'Fashion after the fall. Patchwork luxury from the ruins.', ARRAY['Post-Apocalyptic', 'DIY', 'Gritty'], NOW() + INTERVAL '56 days', NOW() + INTERVAL '63 days', 'upcoming'),
  ('Liquid Chrome', 'Mercury flows and mirror surfaces. Reflect the future.', ARRAY['Metallic', 'Fluid', 'Reflective'], NOW() + INTERVAL '63 days', NOW() + INTERVAL '70 days', 'upcoming'),
  ('The Silent Orchestra', 'Visual music. Dresses that look like soundwaves frozen in silk.', ARRAY['Musical', 'Abstract', 'Flowing'], NOW() + INTERVAL '70 days', NOW() + INTERVAL '77 days', 'upcoming'),
  ('Arctic Noir', 'Frozen darkness. Crystalline structures in eternal night.', ARRAY['Cold', 'Dark', 'Crystalline'], NOW() + INTERVAL '77 days', NOW() + INTERVAL '84 days', 'upcoming'),
  ('The Final Gala', 'End of season spectacular. Every theme, all at once.', ARRAY['Mixed', 'Chaotic', 'Epic'], NOW() + INTERVAL '84 days', NOW() + INTERVAL '91 days', 'upcoming');

-- =============================================================================
-- Table: gala_submissions (player entries)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.gala_submissions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id            UUID NOT NULL REFERENCES public.gala_events(id) ON DELETE CASCADE,
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  design_id           UUID NOT NULL REFERENCES public.designs(id),
  talent_id           UUID REFERENCES public.talent_pool(id),  -- Optional assigned talent
  current_score       NUMERIC(14,2) DEFAULT 0,
  vote_count          INTEGER DEFAULT 0,
  adore_count         INTEGER DEFAULT 0,
  iconic_count        INTEGER DEFAULT 0,
  sovereign_count     INTEGER DEFAULT 0,
  timeless_count      INTEGER DEFAULT 0,
  submitted_at        TIMESTAMPTZ DEFAULT NOW(),
  final_rank          INTEGER,
  luxe_won            INTEGER DEFAULT 0,
  is_gala_sovereign   BOOLEAN DEFAULT FALSE,  -- Rank 1 badge
  
  UNIQUE(event_id, player_id)  -- One submission per player per event
);

CREATE INDEX gala_submissions_event_idx ON public.gala_submissions(event_id);
CREATE INDEX gala_submissions_score_idx ON public.gala_submissions(event_id, current_score DESC);
CREATE INDEX gala_submissions_player_idx ON public.gala_submissions(player_id);

ALTER TABLE public.gala_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Submissions: read all" ON public.gala_submissions FOR SELECT USING (true);
CREATE POLICY "Submissions: insert own" ON public.gala_submissions FOR INSERT WITH CHECK (player_id = auth.uid());

-- =============================================================================
-- Table: gala_votes (4-tier weighted voting)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.gala_votes (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id       UUID NOT NULL REFERENCES public.gala_submissions(id) ON DELETE CASCADE,
  voter_id            UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  vote_tier           TEXT NOT NULL CHECK (vote_tier IN ('adore', 'iconic', 'sovereign', 'timeless')),
  base_points         INTEGER NOT NULL,
  talent_multiplier   NUMERIC(3,2) DEFAULT 1.00,
  final_points        NUMERIC(6,2) NOT NULL,
  luxe_spent          INTEGER DEFAULT 0,  -- For Timeless votes (costs 10 Luxe)
  voted_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX gala_votes_submission_idx ON public.gala_votes(submission_id);
CREATE INDEX gala_votes_voter_idx ON public.gala_votes(voter_id);

ALTER TABLE public.gala_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Votes: read own" ON public.gala_votes FOR SELECT USING (voter_id = auth.uid());

-- =============================================================================
-- Table: gala_vote_limits (daily vote tracking)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.gala_vote_limits (
  player_id           UUID NOT NULL REFERENCES public.players(id) ON DELETE CASCADE,
  event_id            UUID NOT NULL REFERENCES public.gala_events(id) ON DELETE CASCADE,
  vote_date           DATE NOT NULL DEFAULT CURRENT_DATE,
  adore_used          INTEGER DEFAULT 0,   -- Soft limit at 100
  iconic_used         INTEGER DEFAULT 0,   -- Max 10/day
  sovereign_used      INTEGER DEFAULT 0,   -- Max 3/day
  timeless_used       INTEGER DEFAULT 0,   -- Max 1/day
  
  PRIMARY KEY (player_id, event_id, vote_date)
);

ALTER TABLE public.gala_vote_limits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Vote limits: read own" ON public.gala_vote_limits FOR SELECT USING (player_id = auth.uid());

-- =============================================================================
-- RPC: Submit to Gala (strict ownership validation)
-- =============================================================================
CREATE OR REPLACE FUNCTION submit_to_gala(
  p_event_id UUID,
  p_design_id UUID,
  p_talent_id UUID DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, submission_id UUID, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_player_id UUID := auth.uid();
  v_event_status TEXT;
  v_event_ends TIMESTAMPTZ;
  v_submission_id UUID;
  v_owns_design BOOLEAN;
  v_owns_talent BOOLEAN;
BEGIN
  -- Verify event exists and is accepting submissions
  SELECT status, ends_at INTO v_event_status, v_event_ends
  FROM gala_events WHERE id = p_event_id;
  
  IF v_event_status IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'EVENT_NOT_FOUND'::TEXT;
    RETURN;
  END IF;
  
  IF v_event_status NOT IN ('active', 'upcoming') THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'EVENT_NOT_ACCEPTING_SUBMISSIONS'::TEXT;
    RETURN;
  END IF;
  
  IF NOW() > v_event_ends THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'EVENT_ENDED'::TEXT;
    RETURN;
  END IF;
  
  -- Verify player owns the design
  SELECT EXISTS(
    SELECT 1 FROM designs 
    WHERE id = p_design_id AND creator_id = v_player_id
  ) INTO v_owns_design;
  
  IF NOT v_owns_design THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'DESIGN_NOT_OWNED'::TEXT;
    RETURN;
  END IF;
  
  -- Verify player owns the talent (if provided)
  IF p_talent_id IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1 FROM player_roster 
      WHERE player_id = v_player_id AND talent_id = p_talent_id
    ) INTO v_owns_talent;
    
    IF NOT v_owns_talent THEN
      RETURN QUERY SELECT FALSE, NULL::UUID, 'TALENT_NOT_OWNED'::TEXT;
      RETURN;
    END IF;
  END IF;
  
  -- Check if already submitted
  IF EXISTS(
    SELECT 1 FROM gala_submissions 
    WHERE event_id = p_event_id AND player_id = v_player_id
  ) THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 'ALREADY_SUBMITTED'::TEXT;
    RETURN;
  END IF;
  
  -- Create submission
  INSERT INTO gala_submissions (
    event_id, player_id, design_id, talent_id
  ) VALUES (
    p_event_id, v_player_id, p_design_id, p_talent_id
  )
  RETURNING gala_submissions.id INTO v_submission_id;
  
  -- Increment event submission count
  UPDATE gala_events 
  SET total_submissions = total_submissions + 1
  WHERE id = p_event_id;
  
  RETURN QUERY SELECT TRUE, v_submission_id, 'SUBMISSION_SUCCESSFUL'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION submit_to_gala(UUID, UUID, UUID) TO authenticated;

-- =============================================================================
-- RPC: Cast Vote (Kode Formula with talent multiplier)
-- =============================================================================
CREATE OR REPLACE FUNCTION cast_gala_vote(
  p_submission_id UUID,
  p_vote_tier TEXT
)
RETURNS TABLE(success BOOLEAN, final_points NUMERIC, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_voter_id UUID := auth.uid();
  v_event_id UUID;
  v_event_status TEXT;
  v_designer_id UUID;
  v_talent_multiplier NUMERIC(3,2);
  v_base_points INTEGER;
  v_final_points NUMERIC(6,2);
  v_luxe_cost INTEGER := CASE WHEN p_vote_tier = 'timeless' THEN 10 ELSE 0 END;
  v_current_luxe INTEGER;
  v_vote_date DATE := CURRENT_DATE;
  v_daily_used INTEGER;
  v_daily_limit INTEGER;
BEGIN
  -- Get submission info
  SELECT gs.event_id, gs.player_id, COALESCE(tp.base_hype_multiplier, 1.0)
  INTO v_event_id, v_designer_id, v_talent_multiplier
  FROM gala_submissions gs
  LEFT JOIN talent_pool tp ON gs.talent_id = tp.id
  WHERE gs.id = p_submission_id;
  
  IF v_event_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'SUBMISSION_NOT_FOUND'::TEXT;
    RETURN;
  END IF;
  
  -- Can't vote for yourself
  IF v_designer_id = v_voter_id THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'CANNOT_VOTE_SELF'::TEXT;
    RETURN;
  END IF;
  
  -- Check event status
  SELECT status INTO v_event_status FROM gala_events WHERE id = v_event_id;
  IF v_event_status NOT IN ('active', 'voting') THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'EVENT_NOT_VOTING'::TEXT;
    RETURN;
  END IF;
  
  -- Check if already voted
  IF EXISTS(
    SELECT 1 FROM gala_votes 
    WHERE submission_id = p_submission_id AND voter_id = v_voter_id
  ) THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'ALREADY_VOTED'::TEXT;
    RETURN;
  END IF;
  
  -- Check daily limits
  v_daily_limit := CASE p_vote_tier
    WHEN 'adore' THEN 100
    WHEN 'iconic' THEN 10
    WHEN 'sovereign' THEN 3
    WHEN 'timeless' THEN 1
  END;
  
  SELECT COALESCE(
    CASE p_vote_tier
      WHEN 'adore' THEN adore_used
      WHEN 'iconic' THEN iconic_used
      WHEN 'sovereign' THEN sovereign_used
      WHEN 'timeless' THEN timeless_used
    END, 0
  ) INTO v_daily_used
  FROM gala_vote_limits
  WHERE player_id = v_voter_id AND event_id = v_event_id AND vote_date = v_vote_date;
  
  IF v_daily_used >= v_daily_limit THEN
    RETURN QUERY SELECT FALSE, 0::NUMERIC, 'DAILY_LIMIT_REACHED'::TEXT;
    RETURN;
  END IF;
  
  -- Check Luxe for Timeless votes
  IF v_luxe_cost > 0 THEN
    SELECT luxe_tokens INTO v_current_luxe FROM brand_state WHERE player_id = v_voter_id;
    IF v_current_luxe < v_luxe_cost THEN
      RETURN QUERY SELECT FALSE, 0::NUMERIC, 'INSUFFICIENT_LUXE'::TEXT;
      RETURN;
    END IF;
    
    UPDATE brand_state SET luxe_tokens = luxe_tokens - v_luxe_cost
    WHERE player_id = v_voter_id;
  END IF;
  
  -- Calculate points (Kode Formula: base * (1 + (multiplier - 1) * 0.5))
  v_base_points := CASE p_vote_tier
    WHEN 'adore' THEN 1
    WHEN 'iconic' THEN 3
    WHEN 'sovereign' THEN 10
    WHEN 'timeless' THEN 50
  END;
  
  -- Talent bonus: 50% of hype multiplier boost applies to votes
  -- e.g., Sovereign talent (2.0 = +100%) gives +50% vote bonus
  v_final_points := v_base_points * (1.0 + (v_talent_multiplier - 1.0) * 0.5);
  
  -- Record vote
  INSERT INTO gala_votes (
    submission_id, voter_id, vote_tier, base_points, 
    talent_multiplier, final_points, luxe_spent
  ) VALUES (
    p_submission_id, v_voter_id, p_vote_tier, v_base_points,
    v_talent_multiplier, v_final_points, v_luxe_cost
  );
  
  -- Update submission score and counts
  UPDATE gala_submissions
  SET current_score = current_score + v_final_points,
      vote_count = vote_count + 1,
      adore_count = adore_count + CASE WHEN p_vote_tier = 'adore' THEN 1 ELSE 0 END,
      iconic_count = iconic_count + CASE WHEN p_vote_tier = 'iconic' THEN 1 ELSE 0 END,
      sovereign_count = sovereign_count + CASE WHEN p_vote_tier = 'sovereign' THEN 1 ELSE 0 END,
      timeless_count = timeless_count + CASE WHEN p_vote_tier = 'timeless' THEN 1 ELSE 0 END
  WHERE id = p_submission_id;
  
  -- Update daily limits
  INSERT INTO gala_vote_limits (player_id, event_id, vote_date)
  VALUES (v_voter_id, v_event_id, v_vote_date)
  ON CONFLICT (player_id, event_id, vote_date) DO NOTHING;
  
  UPDATE gala_vote_limits
  SET adore_used = adore_used + CASE WHEN p_vote_tier = 'adore' THEN 1 ELSE 0 END,
      iconic_used = iconic_used + CASE WHEN p_vote_tier = 'iconic' THEN 1 ELSE 0 END,
      sovereign_used = sovereign_used + CASE WHEN p_vote_tier = 'sovereign' THEN 1 ELSE 0 END,
      timeless_used = timeless_used + CASE WHEN p_vote_tier = 'timeless' THEN 1 ELSE 0 END
  WHERE player_id = v_voter_id AND event_id = v_event_id AND vote_date = v_vote_date;
  
  RETURN QUERY SELECT TRUE, v_final_points, 'VOTE_CAST'::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION cast_gala_vote(UUID, TEXT) TO authenticated;

-- =============================================================================
-- RPC: Get Gala Leaderboard (Ranked submissions)
-- =============================================================================
CREATE OR REPLACE FUNCTION get_gala_leaderboard(p_event_id UUID)
RETURNS TABLE(
  rank INTEGER,
  submission_id UUID,
  player_id UUID,
  design_id UUID,
  talent_id UUID,
  current_score NUMERIC,
  vote_count INTEGER,
  is_gala_sovereign BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ROW_NUMBER() OVER (ORDER BY gs.current_score DESC)::INTEGER as rank,
    gs.id as submission_id,
    gs.player_id,
    gs.design_id,
    gs.talent_id,
    gs.current_score,
    gs.vote_count,
    gs.is_gala_sovereign
  FROM gala_submissions gs
  WHERE gs.event_id = p_event_id
  ORDER BY gs.current_score DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION get_gala_leaderboard(UUID) TO authenticated;

-- =============================================================================
-- Function: Rotate Gala Event (pg_cron weekly trigger)
-- 
-- Called every Sunday at midnight UTC
-- 1. Finalize current event (set final ranks, distribute prizes)
-- 2. Archive completed event
-- 3. Activate next upcoming event
-- =============================================================================
CREATE OR REPLACE FUNCTION rotate_gala_event()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_completed_event UUID;
  v_new_event UUID;
  v_prize_pool INTEGER;
  v_rank INTEGER;
  v_submission RECORD;
  v_luxe_prize INTEGER;
BEGIN
  -- Find active/completed event ending now
  SELECT id, prize_pool_luxe INTO v_completed_event, v_prize_pool
  FROM gala_events
  WHERE status IN ('active', 'voting')
    AND ends_at <= NOW()
  ORDER BY ends_at DESC
  LIMIT 1;
  
  IF v_completed_event IS NOT NULL THEN
    -- Calculate and assign prizes
    FOR v_submission IN
      SELECT id, player_id, RANK() OVER (ORDER BY current_score DESC) as calculated_rank
      FROM gala_submissions
      WHERE event_id = v_completed_event
      ORDER BY current_score DESC
    LOOP
      v_rank := v_submission.calculated_rank::INTEGER;
      v_luxe_prize := CASE
        WHEN v_rank = 1 THEN 5000  -- The Sovereign
        WHEN v_rank = 2 THEN 2000
        WHEN v_rank = 3 THEN 1000
        WHEN v_rank <= 10 THEN GREATEST(500 - (v_rank - 4) * 50, 100)  -- 450 down to 100
        ELSE 50  -- Participation
      END;
      
      -- Update submission with rank and prize
      UPDATE gala_submissions
      SET final_rank = v_rank,
          luxe_won = v_luxe_prize,
          is_gala_sovereign = (v_rank = 1)
      WHERE id = v_submission.id;
      
      -- Award Luxe tokens
      UPDATE brand_state
      SET luxe_tokens = luxe_tokens + v_luxe_prize
      WHERE player_id = v_submission.player_id;
    END LOOP;
    
    -- Mark event completed
    UPDATE gala_events
    SET status = 'completed'
    WHERE id = v_completed_event;
  END IF;
  
  -- Activate next event
  SELECT id INTO v_new_event
  FROM gala_events
  WHERE status = 'upcoming'
    AND starts_at <= NOW() + INTERVAL '1 hour'  -- Activate up to 1 hour early
  ORDER BY starts_at
  LIMIT 1;
  
  IF v_new_event IS NOT NULL THEN
    UPDATE gala_events
    SET status = 'active'
    WHERE id = v_new_event;
  END IF;
END;
$$;

-- =============================================================================
-- pg_cron: Schedule weekly rotation (Sunday 00:00 UTC)
-- Note: Requires pg_cron extension enabled
-- =============================================================================
-- Uncomment when pg_cron is available:
-- SELECT cron.schedule('rotate-gala-weekly', '0 0 * * 0', 'SELECT rotate_gala_event()');

COMMENT ON FUNCTION rotate_gala_event IS 
  'Weekly gala rotation: finalize current event (distribute prizes), activate next event. Call via pg_cron or Edge Function.';

COMMENT ON FUNCTION cast_gala_vote IS 
  'Cast 4-tier vote (Adore/Iconic/Sovereign/Timeless) with talent multipliers. Handles daily limits and Luxe costs.';

COMMENT ON FUNCTION submit_to_gala IS 
  'Submit design+talent to gala. Strictly validates ownership of both assets.';
