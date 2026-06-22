import 'supabase_service.dart';

class MiniGameAttempt {
  const MiniGameAttempt({
    required this.id,
    required this.challenge,
  });

  final String id;
  final Map<String, dynamic> challenge;
}

abstract final class MiniGameService {
  static Future<MiniGameAttempt> start(String gameKey) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      'claim-mini-game-reward',
      body: <String, dynamic>{
        'action': 'start',
        'game_key': gameKey,
      },
    );
    final String? id = response['attempt_id'] as String?;
    final Map<String, dynamic>? challenge =
        response['challenge'] as Map<String, dynamic>?;
    if (id == null || challenge == null) {
      throw const FormatException('Mini-game attempt was not created.');
    }
    return MiniGameAttempt(id: id, challenge: challenge);
  }

  static Future<Map<String, dynamic>> claim(
    String attemptId,
    Map<String, dynamic> proof,
  ) {
    return SupabaseService.invokeFunction(
      'claim-mini-game-reward',
      body: <String, dynamic>{
        'action': 'claim',
        'attempt_id': attemptId,
        'proof': proof,
      },
    );
  }
}
