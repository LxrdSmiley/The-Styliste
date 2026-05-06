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

  /// Post a new entry to the Global Feed.
  Future<void> createPost(Map<String, dynamic> postData);

  /// React to a post (like, AR reaction, etc.).
  Future<void> reactToPost(String postId, String reactionType);
}
