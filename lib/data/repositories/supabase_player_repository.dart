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
  Future<void> upsertPlayer(Player player) async {
    await SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .upsert(player.toJson());
  }

  @override
  Future<void> updateLastActive(String playerId, DateTime timestamp) async {
    await SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .update(<String, dynamic>{'last_active_at': timestamp.toIso8601String()})
        .eq('id', playerId);
  }

  @override
  Stream<Player> watchPlayer(String playerId) {
    return SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .stream(primaryKey: <String>['id'])
        .eq('id', playerId)
        .map((List<Map<String, dynamic>> rows) => Player.fromJson(rows.first));
  }

  /// Phase 1b — Atomic initial state commitment.
  /// 1. Upserts the players row (idempotent — safe to retry).
  /// 2. Upserts the brand_state row with path-appropriate defaults.
  /// PROJECT_RULES §3 — Server is source of truth; client reads result back.
  @override
  Future<Player> createPlayerProfile({
    required String uid,
    required String brandName,
    required CareerPath path,
    required HqCity hqCity,
  }) async {
    final DateTime now = DateTime.now().toUtc();

    final Player newPlayer = Player(
      id: uid,
      brandName: brandName,
      path: path,
      hqCity: hqCity,
      isAnonymous: true,
      createdAt: now,
      lastActiveAt: now,
    );

    // Step 1: upsert players row (own-row RLS allows this).
    await SupabaseService.client
        .from(SupabaseConstants.tablePlayers)
        .upsert(newPlayer.toJson());

    // Step 2: initialise brand_state row with path-appropriate idle rate.
    // Designer starts with hype-weighted idle; Mogul with revenue-weighted idle.
    final double startingIdleRate =
        path == CareerPath.designer ? 0.5 : 1.0;

    await SupabaseService.client
        .from(SupabaseConstants.tableBrandState)
        .upsert(<String, dynamic>{
      'player_id': uid,
      'heat': 50,
      'hype_score': 0.0,
      'followers': 0,
      'revenue_idle': startingIdleRate,
      'total_revenue': 0.0,
      'momentum_buff_active': false,
      'sustainability_tier': 0,
      'dpp_enabled': false,
      'dpp_fully_mapped': false,
      'founder_rep': 50,
      'last_active_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return newPlayer;
  }
}
