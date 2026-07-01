// Abstract repository interface — player data
// PROJECT_RULES §3 — Supabase implementation lives in data/repositories/

import '../models/player.dart';

class PlayerProfileMissingException implements Exception {
  const PlayerProfileMissingException(this.playerId);

  final String playerId;

  static const String safeMessage =
      'No brand profile exists for this session. Start onboarding to create one.';

  @override
  String toString() => safeMessage;
}

abstract interface class PlayerRepository {
  Future<Player?> fetchPlayer(String playerId);
  Stream<Player> watchPlayer(String playerId);
}
