import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.replace('Bearer ', '');
  const { data: userData, error: userError } = await supabase.auth.getUser(token);

  if (userError || !userData.user) {
    return json({ error: 'Unauthorized' }, 401);
  }

  const payload = await req.json();
  const { game_key: gameKey, result_key: resultKey } = payload;
  const playerId = userData.user.id;

  if (gameKey === 'staff_rally' && resultKey === 'stamina_reset') {
    const talentId = payload.talent_id as string | undefined;
    if (!talentId) {
      return json({ error: 'Missing talent_id' }, 400);
    }

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
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}
