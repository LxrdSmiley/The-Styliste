class MiniGameRewardsUnavailableException implements Exception {
  const MiniGameRewardsUnavailableException();
}

class MiniGameAttempt {
  const MiniGameAttempt({
    required this.id,
    required this.challenge,
  });

  final String id;
  final Map<String, dynamic> challenge;
}

abstract final class MiniGameService {
  /// Client evidence is not sufficient to settle an economic reward.
  ///
  /// This is intentionally false until a server-verifiable game protocol is
  /// authorized. The Edge Function and database functions enforce the same
  /// containment for already-shipped clients.
  static bool get rewardsAreAvailable => false;

  static Future<MiniGameAttempt> start(String _gameKey) {
    return Future<MiniGameAttempt>.error(
      const MiniGameRewardsUnavailableException(),
    );
  }

  static Future<Map<String, dynamic>> claim(
    String _attemptId,
    Map<String, dynamic> _proof,
  ) {
    return Future<Map<String, dynamic>>.error(
      const MiniGameRewardsUnavailableException(),
    );
  }
}
