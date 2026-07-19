BEGIN;

SELECT plan(20);

-- Client roles cannot reach quarantined district or Gala authority.
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.attempt_district_takeover(uuid,uuid,bigint)',
    'EXECUTE'
  ),
  'authenticated cannot execute district takeover'
);
SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.attempt_district_takeover(uuid,uuid,bigint)',
    'EXECUTE'
  ),
  'anonymous cannot execute district takeover'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.cast_gala_vote(uuid,text)',
    'EXECUTE'
  ),
  'authenticated cannot execute paid Gala scoring'
);
SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.cast_gala_vote(uuid,text)',
    'EXECUTE'
  ),
  'anonymous cannot execute paid Gala scoring'
);
SELECT ok(
  NOT has_function_privilege(
    'service_role',
    'public.cast_gala_vote(uuid,text)',
    'EXECUTE'
  ),
  'service_role cannot bypass quarantined Gala scoring'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.rotate_gala_event()',
    'EXECUTE'
  ),
  'authenticated cannot settle a Gala'
);
SELECT ok(
  has_function_privilege('service_role', 'public.rotate_gala_event()', 'EXECUTE'),
  'only the scheduled service boundary can reach the settlement quarantine'
);
SELECT ok(
  has_function_privilege(
    'authenticated',
    'public.execute_casting_pull(uuid,text,boolean)',
    'EXECUTE'
  ),
  'Casting remains available to authenticated players'
);
SELECT ok(
  NOT has_function_privilege(
    'anon',
    'public.execute_casting_pull(uuid,text,boolean)',
    'EXECUTE'
  ),
  'anonymous callers cannot execute Casting'
);

-- Mini-game proof endpoints remain Edge/service-only, never direct client RPCs.
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.edge_start_mini_game(uuid,text,uuid)',
    'EXECUTE'
  ),
  'authenticated cannot start a mini-game through the service RPC'
);
SELECT ok(
  NOT has_function_privilege(
    'authenticated',
    'public.edge_claim_mini_game(uuid,uuid,jsonb)',
    'EXECUTE'
  ),
  'authenticated cannot submit mini-game proof through the service RPC'
);
SELECT ok(
  has_function_privilege(
    'service_role',
    'public.edge_start_mini_game(uuid,text,uuid)',
    'EXECUTE'
  )
    AND has_function_privilege(
      'service_role',
      'public.edge_claim_mini_game(uuid,uuid,jsonb)',
      'EXECUTE'
    ),
  'mini-game quarantine remains behind the service boundary'
);

-- Verify the Casting function contains both serialization points in the
-- documented order: balance first, then pity state.
SELECT ok(
  position(
    'FROM public.brand_state' IN
    pg_get_functiondef('public.execute_casting_pull(uuid,text,boolean)'::regprocedure)
  ) > 0
    AND position(
      'ON CONFLICT (player_id, banner_id) DO NOTHING' IN
      pg_get_functiondef('public.execute_casting_pull(uuid,text,boolean)'::regprocedure)
    ) > 0
    AND position(
      'FROM public.gacha_pity_state' IN
      pg_get_functiondef('public.execute_casting_pull(uuid,text,boolean)'::regprocedure)
    ) > 0
    AND length(
      pg_get_functiondef('public.execute_casting_pull(uuid,text,boolean)'::regprocedure)
    )
      - length(
        replace(
          pg_get_functiondef('public.execute_casting_pull(uuid,text,boolean)'::regprocedure),
          'FOR UPDATE',
          ''
        )
      ) >= length('FOR UPDATE') * 2,
  'Casting locks balance and pity state after materializing the pity row'
);

CREATE TEMP TABLE m3a1_authority_snapshot AS
SELECT
  (SELECT count(*)::bigint FROM public.mini_game_attempts) AS attempt_count,
  (SELECT count(*)::bigint FROM public.gala_events WHERE status IN ('active', 'voting'))
    AS active_gala_count,
  (SELECT COALESCE(sum(luxe_tokens), 0)::bigint FROM public.brand_state) AS total_luxe;

SELECT set_config('request.jwt.claim.role', 'service_role', true);
SET LOCAL ROLE service_role;

SELECT lives_ok(
  $test$
  DO $body$
  BEGIN
    BEGIN
      PERFORM public.edge_start_mini_game(
        '00000000-0000-4000-8000-00000000c301',
        'price_war',
        NULL
      );
      RAISE EXCEPTION 'expected mini-game start quarantine';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN
        RAISE;
      END IF;
    END;
  END;
  $body$;
  $test$,
  'service mini-game start is quarantined before any attempt mutation'
);
SELECT lives_ok(
  $test$
  DO $body$
  BEGIN
    BEGIN
      PERFORM public.edge_claim_mini_game(
        '00000000-0000-4000-8000-00000000c301',
        '00000000-0000-4000-8000-00000000c302',
        '{"outcome":"win"}'::jsonb
      );
      RAISE EXCEPTION 'expected mini-game claim quarantine';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'MINI_GAME_REWARDS_UNAVAILABLE' THEN
        RAISE;
      END IF;
    END;
  END;
  $body$;
  $test$,
  'service mini-game proof is quarantined before any reward mutation'
);
SELECT is(
  (SELECT count(*)::bigint FROM public.mini_game_attempts),
  (SELECT attempt_count FROM m3a1_authority_snapshot),
  'quarantined mini-game calls create no attempts'
);
SELECT is(
  (SELECT COALESCE(sum(luxe_tokens), 0)::bigint FROM public.brand_state),
  (SELECT total_luxe FROM m3a1_authority_snapshot),
  'quarantined mini-game calls change no Luxe balance'
);

SELECT lives_ok(
  $test$
  DO $body$
  BEGIN
    BEGIN
      PERFORM public.rotate_gala_event();
      RAISE EXCEPTION 'expected Gala settlement quarantine';
    EXCEPTION WHEN OTHERS THEN
      IF SQLERRM <> 'GALA_SETTLEMENT_QUARANTINED' THEN
        RAISE;
      END IF;
    END;
  END;
  $body$;
  $test$,
  'Gala settlement is quarantined before prize mutation'
);
SELECT is(
  (SELECT count(*)::bigint FROM public.gala_events WHERE status IN ('active', 'voting')),
  (SELECT active_gala_count FROM m3a1_authority_snapshot),
  'quarantined Gala settlement leaves event state unchanged'
);
SELECT is(
  (SELECT COALESCE(sum(luxe_tokens), 0)::bigint FROM public.brand_state),
  (SELECT total_luxe FROM m3a1_authority_snapshot),
  'quarantined Gala settlement changes no Luxe balance'
);

RESET ROLE;

SELECT * FROM finish();
ROLLBACK;
