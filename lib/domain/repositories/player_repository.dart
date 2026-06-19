// Abstract repository interface — player data
// PROJECT_RULES §3 — Supabase implementation lives in data/repositories/

import '../models/player.dart';

abstract interface class PlayerRepository {
  Future<Player?> fetchPlayer(String playerId);
  Stream<Player> watchPlayer(String playerId);
}
