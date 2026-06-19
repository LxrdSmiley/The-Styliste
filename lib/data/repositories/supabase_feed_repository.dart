// Supabase implementation of FeedRepository
// GDD §6.1 — Real-time Global Live Feed via Supabase Realtime

import '../../core/constants/supabase_constants.dart';
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
        .from(SupabaseConstants.tableFeedPosts)
        .select()
        .order('created_at')
        .range(offset, offset + limit - 1);

    return data;
  }

  @override
  Stream<Map<String, dynamic>> watchNewPosts() {
    return SupabaseService.client
        .from(SupabaseConstants.tableFeedPosts)
        .stream(primaryKey: <String>['id'])
        .order('created_at')
        .limit(1)
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.isNotEmpty ? rows.first : <String, dynamic>{},
        );
  }


  @override
  Future<void> reactToPost(String postId, String reactionType) async {
    await SupabaseService.client.rpc<void>(
      'increment_post_reaction',
      params: <String, dynamic>{
        'post_id': postId,
        'reaction_type': reactionType,
      },
    );
  }
}
