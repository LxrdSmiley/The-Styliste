import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

abstract interface class FirstObjectiveRepository {
  Future<bool> hasServerConfirmedAlphaDrop(String playerId);

  Stream<List<FirstWeekObjective>> watchObjectives(String playerId);

  Future<void> recordValidatedEvent(String eventKey, {String? entityId});
}

class FirstWeekObjective {
  const FirstWeekObjective({
    required this.playerId,
    required this.objectiveKey,
    required this.path,
    required this.title,
    required this.description,
    required this.status,
    this.completedAt,
  });

  final String playerId;
  final String objectiveKey;
  final String path;
  final String title;
  final String description;
  final String status;
  final DateTime? completedAt;

  bool get isComplete => status == 'completed';

  factory FirstWeekObjective.fromJson(Map<String, dynamic> json) {
    return FirstWeekObjective(
      playerId: json['player_id'] as String? ?? '',
      objectiveKey: json['objective_key'] as String? ?? '',
      path: json['path'] as String? ?? 'shared',
      title: json['title'] as String? ?? 'Next objective',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
    );
  }
}

class SupabaseFirstObjectiveRepository implements FirstObjectiveRepository {
  const SupabaseFirstObjectiveRepository();

  @override
  Future<bool> hasServerConfirmedAlphaDrop(String playerId) async {
    try {
      await SupabaseService.ensureFreshSession();
      final List<dynamic> rows = await SupabaseService.client
          .schema('api')
          .from('feed_projection')
          .select('id')
          .eq('player_id', playerId)
          .filter('content->>event', 'eq', 'alpha_dropped')
          .limit(1);
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<List<FirstWeekObjective>> watchObjectives(String playerId) async* {
    while (true) {
      final List<Map<String, dynamic>> rows = await SupabaseService.client
          .schema('api')
          .from('first_week_objectives')
          .select()
          .eq('player_id', playerId);
      yield rows.map(FirstWeekObjective.fromJson).toList(growable: false);
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Future<void> recordValidatedEvent(String eventKey, {String? entityId}) async {
    await SupabaseService.invokeFunction(
      SupabaseConstants.fnProgressionEvent,
      body: <String, dynamic>{
        'event_key': eventKey,
        if (entityId != null) 'entity_id': entityId,
        if (entityId != null) 'idempotency_key': entityId,
      },
    );
  }
}
