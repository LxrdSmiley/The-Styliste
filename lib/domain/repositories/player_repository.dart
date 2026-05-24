// Abstract repository interface — player data
// PROJECT_RULES §3 — Supabase implementation lives in data/repositories/

import '../models/player.dart';

abstract interface class PlayerRepository {
  Future<Player?> fetchPlayer(String playerId);
  Future<void> upsertPlayer(Player player);
  Future<void> updateLastActive(String playerId, DateTime timestamp);
  Stream<Player> watchPlayer(String playerId);

  /// Phase 1b — Initial state commitment.
  /// Writes Player row + initialises brand_state row in a single atomic call.
  /// Uses the Supabase auth UUID established by the Firebase/Supabase bridge.
  Future<Player> createPlayerProfile({
    required String uid,
    required String brandName,
    required CareerPath path,
    required HqCity hqCity,
  });
}
