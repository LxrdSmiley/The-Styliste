import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const ACTIVE_GAME_KEYS = new Set([
  'flash_sale',
  'hostile_takeover',
  'power_move_combo',
  'price_war',
]);

<<<<<<< HEAD
function json(body: Record<string, unknown>, status = 200): Response {
=======
  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace('Bearer ', '');
  const { data: userData, error: userError } = await supabase.auth.getUser(token);

  if (userError || !userData.user) {
    return json({ error: 'Unauthorized' }, 401);
  }

  const payload = await req.json();
  const { game_key: gameKey, result_key: resultKey } = payload;
  const playerId = userData.user.id;

  if (gameKey === 'staff_rally') {
    const talentId = payload.talent_id as string | undefined;
    if (!talentId) {
      return json({ error: 'Missing talent_id' }, 400);
    }

    if (resultKey === 'stamina_reset') {
      const { error, count } = await supabase
        .from('player_roster')
        .update({
          stamina: 100,
          last_stamina_refresh: new Date().toISOString(),
        }, { count: 'exact' })
        .eq('player_id', playerId)
        .eq('talent_id', talentId);

      if (error) {
        return json({ error: error.message }, 400);
      }

      if (!count) {
        return json({ success: false, error: 'Talent not found' }, 404);
      }

      return json({ success: true, stamina: 100 }, 200);
    } else if (resultKey === 'cooldown_loss') {
      const cooldownUntil = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
      const { error, count } = await supabase
        .from('player_roster')
        .update({
          gala_cooldown_until: cooldownUntil,
        }, { count: 'exact' })
        .eq('player_id', playerId)
        .eq('talent_id', talentId);

      if (error) {
        return json({ error: error.message }, 400);
      }

      if (!count) {
        return json({ success: false, error: 'Talent not found' }, 404);
      }

      return json({
        success: true,
        cooldown_hours: 24,
        cooldown_until: cooldownUntil,
        message: 'Talent needs 24h rest before next Gala assignment',
      }, 200);
    } else {
      return json({ error: 'Invalid result_key for staff_rally' }, 400);
    }
  }

  if (gameKey === 'power_move_combo' && resultKey === 'standard_win') {
    const { data, error } = await supabase.rpc('edge_apply_power_move_combo', {
      p_player_id: playerId,
      p_result_key: resultKey,
    });

    if (error) {
      return json({ error: error.message }, 400);
    }

    return json(data as Record<string, unknown>, 200);
  }

  const rewardTable: Record<string, Record<string, { currency: number }>> = {
    supplier_raid: {
      standard_win: { currency: 250 },
      perfect_win: { currency: 500 },
    },
    flash_sale: {
      standard_win: { currency: 150 },
      perfect_win: { currency: 300 },
    },
    hostile_takeover: {
      complete_takeover: { currency: 5000 },
    },
    price_war: {
      standard_win: { currency: 200 },
      loss: { currency: 0 },
    },
  };

  const reward = rewardTable[gameKey]?.[resultKey];
  if (!reward) {
    return json({ error: 'Invalid reward' }, 400);
  }

  const { error } = await supabase.rpc('grant_mini_game_reward', {
    p_player_id: playerId,
    p_game_key: gameKey,
    p_result_key: resultKey,
    p_amount: reward.currency,
  });

  if (error) {
    return json({ error: error.message }, 400);
  }

  return json({ success: true, reward }, 200);
});

function json(body: Record<string, unknown>, status: number): Response {
>>>>>>> 813e538151b2ac74022b84c094a35a53fc1d2bb8
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function safeError(error: unknown): Response {
  const correlationId = crypto.randomUUID();
  console.error('claim-mini-game-reward', correlationId, error);
  const message = error instanceof Error ? error.message : '';
  if (message.includes('COOLDOWN')) return json({ error: 'GAME_ON_COOLDOWN' }, 409);
  if (message.includes('DAILY_ATTEMPT_LIMIT')) return json({ error: 'DAILY_LIMIT_REACHED' }, 429);
  if (message.includes('ALREADY_CLAIMED')) return json({ error: 'ATTEMPT_ALREADY_CLAIMED' }, 409);
  if (message.includes('EXPIRED')) return json({ error: 'ATTEMPT_EXPIRED' }, 409);
  if (message.includes('NOT_FOUND') || message.includes('NOT_OWNED')) {
    return json({ error: 'ATTEMPT_NOT_AVAILABLE' }, 404);
  }
  return json({ error: 'MINI_GAME_REQUEST_FAILED', correlation_id: correlationId }, 500);
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS });
  if (req.method !== 'POST') return json({ error: 'METHOD_NOT_ALLOWED' }, 405);

  try {
    const authHeader = req.headers.get('Authorization') ?? '';
    if (!authHeader.startsWith('Bearer ')) return json({ error: 'MISSING_AUTH' }, 401);

    const token = authHeader.slice('Bearer '.length);
    const verifyClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userError } = await verifyClient.auth.getUser(token);
    if (userError || !user) return json({ error: 'UNAUTHORIZED' }, 401);

    const admin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );
    const { data: allowed, error: rateError } = await admin.rpc(
      'edge_consume_rate_limit',
      {
        p_actor_id: user.id,
        p_action: 'mini_game',
        p_window_seconds: 60,
        p_max_requests: 20,
      },
    );
    if (rateError) throw rateError;
    if (!allowed) return json({ error: 'RATE_LIMITED' }, 429);
    const payload = await req.json() as Record<string, unknown>;
    const action = payload.action;

    if (action === 'start') {
      const gameKey = typeof payload.game_key === 'string' ? payload.game_key : '';
      if (!ACTIVE_GAME_KEYS.has(gameKey)) {
        return json({ error: 'GAME_RETIRED_OR_UNKNOWN' }, 410);
      }
      const { data, error } = await admin.rpc('edge_start_mini_game', {
        p_player_id: user.id,
        p_game_key: gameKey,
        p_talent_id: null,
      });
      if (error) throw error;
      return json(data as Record<string, unknown>, 201);
    }

    if (action === 'claim') {
      const attemptId = typeof payload.attempt_id === 'string' ? payload.attempt_id : '';
      const proof = payload.proof && typeof payload.proof === 'object' ? payload.proof : {};
      if (!attemptId) return json({ error: 'MISSING_ATTEMPT_ID' }, 400);
      const { data, error } = await admin.rpc('edge_claim_mini_game', {
        p_player_id: user.id,
        p_attempt_id: attemptId,
        p_proof: proof,
      });
      if (error) throw error;
      return json(data as Record<string, unknown>);
    }

    return json({ error: 'INVALID_ACTION' }, 400);
  } catch (error) {
    return safeError(error);
  }
});
