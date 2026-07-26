// Supabase implementation of PlayerRepository
// PROJECT_RULES §3 — Source of Truth: Database > Local State > UI

import '../../core/services/supabase_service.dart';
import '../../domain/models/player.dart';
import '../../domain/repositories/player_repository.dart';

class SupabasePlayerRepository implements PlayerRepository {
  const SupabasePlayerRepository();

  @override
  Future<Player?> fetchPlayer(String playerId) async {
    final Map<String, dynamic>? data = await SupabaseService.client
        .schema('api')
        .from('player_summary')
        .select()
        .eq('id', playerId)
        .maybeSingle();

    return data != null ? Player.fromJson(data) : null;
  }

  @override
  Stream<Player> watchPlayer(String playerId) async* {
    // Postgres Changes cannot subscribe to a view in the restricted api schema.
    // Poll only the reviewed owner projection instead of falling back to public.
    while (true) {
      final Player? player = await fetchPlayer(playerId);
      if (player == null) throw PlayerProfileMissingException(playerId);
      yield player;
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }
}
