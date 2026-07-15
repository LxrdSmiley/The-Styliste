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
          .from(SupabaseConstants.tableFeedPosts)
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
  Stream<List<FirstWeekObjective>> watchObjectives(String playerId) {
    return SupabaseService.client
        .from(SupabaseConstants.tableFirstWeekObjectives)
        .stream(primaryKey: const <String>['player_id', 'objective_key'])
        .eq('player_id', playerId)
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.map(FirstWeekObjective.fromJson).toList(growable: false),
        );
  }

  @override
  Future<void> recordValidatedEvent(String eventKey, {String? entityId}) async {
    await SupabaseService.client.rpc<void>(
      'record_progression_event',
      params: <String, dynamic>{
        'p_event_key': eventKey,
        'p_entity_id': entityId,
      },
    );
  }
}
