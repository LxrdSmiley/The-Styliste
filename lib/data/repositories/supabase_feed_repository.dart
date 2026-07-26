// Supabase implementation of FeedRepository
// GDD §6.1 — Real-time Global Live Feed via Supabase Realtime

import '../../core/services/supabase_service.dart';
import '../../domain/repositories/feed_repository.dart';

class SupabaseFeedRepository implements FeedRepository {
  const SupabaseFeedRepository();

  @override
  Future<List<Map<String, dynamic>>> fetchPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final List<Map<String, dynamic>> data = await SupabaseService.client
        .schema('api')
        .from('feed_projection')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data;
  }

  @override
  Stream<Map<String, dynamic>> watchNewPosts() async* {
    // Views cannot be subscribed to through Postgres Changes. Never bypass the
    // api schema just to obtain a Realtime subscription.
    while (true) {
      final List<Map<String, dynamic>> rows = await fetchPosts(limit: 1);
      yield rows.isNotEmpty ? rows.first : <String, dynamic>{};
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }
}
