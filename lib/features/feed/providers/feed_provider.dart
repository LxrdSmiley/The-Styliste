// GDD §6.1 — Feed Riverpod providers (Phase 6 + 7).
// feedStreamProvider: Realtime stream of global feed_posts (newest first).
// feedHypeOverrideProvider: immutable optimistic hype delta map (postId → delta).
// hyypePostProvider: fires increment_post_hype RPC.
// Phase 7 additions:
//   feedModeProvider: GLOBAL | SYNDICATE toggle state.
//   followingIdsProvider: Realtime stream of the player's follow graph → Set<String>.
//   syndicateFeedProvider: one-shot RPC batch for initial SYNDICATE load.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/mock_auth_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/feed_post.dart';

// ---------------------------------------------------------------------------
// Feed mode — GLOBAL (all players) vs. SYNDICATE (following only).
// ---------------------------------------------------------------------------

enum FeedMode { global, syndicate }

final StateProvider<FeedMode> feedModeProvider =
    StateProvider<FeedMode>((_) => FeedMode.global);

// ---------------------------------------------------------------------------
// Global feed stream — Realtime-backed, newest-first, capped at 50 posts.
// ---------------------------------------------------------------------------

final StreamProvider<List<FeedPost>> feedStreamProvider =
    StreamProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) {
  return SupabaseService.client
      .from(SupabaseConstants.tableFeedPosts)
      .stream(primaryKey: <String>['id'])
      .order('created_at')
      .limit(50)
      .map(
        (List<Map<String, dynamic>> rows) =>
            rows.map(FeedPost.fromJson).toList(),
      );
});

// ---------------------------------------------------------------------------
// Optimistic hype delta map — immutable updates trigger Riverpod rebuilds.
// Maps postId → number of hypes tapped locally since last stream sync.
// ---------------------------------------------------------------------------

final StateProvider<Map<String, int>> feedHypeOverrideProvider =
    StateProvider<Map<String, int>>((_) => <String, int>{});

// ---------------------------------------------------------------------------
// Hype RPC — atomic Postgres increment. Family-parameterised by postId.
// ---------------------------------------------------------------------------

final FutureProviderFamily<void, String> hyypePostProvider =
    FutureProvider.family<void, String>(
  (Ref<AsyncValue<void>> ref, String postId) async {
    await SupabaseService.client
        .rpc<void>(
          'increment_post_hype',
          params: <String, dynamic>{'target_post_id': postId},
        );
  },
);

// ---------------------------------------------------------------------------
// Following IDs stream — Realtime set of player_id values the current user
// follows. Tiny payload (~7KB max). O(1) lookup for SYNDICATE stream filter.
// ---------------------------------------------------------------------------

final StreamProvider<Set<String>> followingIdsProvider =
    StreamProvider<Set<String>>((Ref<AsyncValue<Set<String>>> ref) {
  final String uid = ref.watch(activeUidProvider);
  return SupabaseService.client
      .from(SupabaseConstants.tableFollows)
      .stream(primaryKey: <String>['follower_id', 'following_id'])
      .eq('follower_id', uid)
      .map(
        (List<Map<String, dynamic>> rows) =>
            rows.map((Map<String, dynamic> r) => r['following_id'] as String).toSet(),
      );
});

// ---------------------------------------------------------------------------
// Syndicate feed — one-shot RPC for initial SYNDICATE tab load.
// Client then filters live global stream by followingIdsProvider Set<String>.
// ---------------------------------------------------------------------------

final FutureProvider<List<FeedPost>> syndicateFeedProvider =
    FutureProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) async {
  final List<dynamic> rows = await SupabaseService.client
      .rpc<List<dynamic>>(
        'get_syndicate_feed',
        params: <String, dynamic>{'p_limit': 50},
      );
  return rows
      .cast<Map<String, dynamic>>()
      .map(FeedPost.fromJson)
      .toList();
});
