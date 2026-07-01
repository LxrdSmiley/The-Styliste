// Supabase implementation of PlayerRepository
// PROJECT_RULES §3 — Source of Truth: Database > Local State > UI

import '../../core/constants/supabase_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/player.dart';
import '../../domain/repositories/player_repository.dart';

class SupabasePlayerRepository implements PlayerRepository {
  const SupabasePlayerRepository();

  @override
  Future<Player?> fetchPlayer(String playerId) async {
    final Map<String, dynamic>? data = await SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .select()
        .eq('id', playerId)
        .maybeSingle();

    return data != null ? Player.fromJson(data) : null;
  }

  @override
  Stream<Player> watchPlayer(String playerId) {
    return SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .stream(primaryKey: <String>['id'])
        .eq('id', playerId)
        .map((List<Map<String, dynamic>> rows) {
          if (rows.isEmpty) {
            throw PlayerProfileMissingException(playerId);
          }
          return Player.fromJson(rows.first);
        });
  }
}
