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

// Kept explicit rather than inferred from the client: only a future
// server-verifiable protocol may re-enable reward settlement.
const REWARDS_ARE_AVAILABLE = false;

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

function safeError(error: unknown): Response {
  const correlationId = crypto.randomUUID();
  console.error('claim-mini-game-reward', correlationId, error);
  const message = error instanceof Error ? error.message : '';
  if (message.includes('MINI_GAME_REWARDS_UNAVAILABLE')) {
    return json({ error: 'MINI_GAME_REWARDS_UNAVAILABLE' }, 503);
  }
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

    // Milestone 3A1: client-supplied mini-game proofs are not an
    // authoritative basis for economy or progression rewards. Return before
    // rate-limit, attempt, proof, or reward mutations until a verified flow is
    // separately authorized.
    if (!REWARDS_ARE_AVAILABLE) {
      return json({ error: 'MINI_GAME_REWARDS_UNAVAILABLE' }, 503);
    }

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
