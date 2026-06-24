// Abstract repository interface — Global Live Feed
// GDD §6.1 — Real-time Supabase subscription

abstract interface class FeedRepository {
  /// Fetch paginated feed posts (global or filtered).
  Future<List<Map<String, dynamic>>> fetchPosts({
    int limit = 20,
    int offset = 0,
  });

  /// Real-time stream of new feed posts.
  Stream<Map<String, dynamic>> watchNewPosts();
}
