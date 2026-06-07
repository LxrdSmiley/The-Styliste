import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

abstract interface class FirstObjectiveRepository {
  Future<bool> hasServerConfirmedAlphaDrop(String playerId);
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
}
