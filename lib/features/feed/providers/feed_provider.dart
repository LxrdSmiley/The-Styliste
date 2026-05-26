// GDD §6.1 — Feed Riverpod providers (Phase 6 + 7).
// feedStreamProvider: Realtime stream of global feed_posts (newest first).
// feedHypeOverrideProvider: immutable optimistic hype delta map (postId → delta).
// hypePostProvider: compatibility shim for the feed-react Edge Function.
// Phase 7 additions:
//   feedModeProvider: GLOBAL | SYNDICATE toggle state.
//   followingIdsProvider: Realtime stream of the player's follow graph → Set<String>.
//   syndicateFeedProvider: one-shot RPC batch for initial SYNDICATE load.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/feed_post.dart';

int _safeInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _safeDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

class PendingAlphaDrop {
  const PendingAlphaDrop({
    required this.feedPostId,
    required this.designId,
    required this.designName,
    required this.hypeScore,
    this.brandName,
    this.fabricColorHex,
  });

  final String feedPostId;
  final String designId;
  final String designName;
  final double hypeScore;
  final String? brandName;
  final String? fabricColorHex;
}

final StateProvider<PendingAlphaDrop?> pendingAlphaDropProvider =
    StateProvider<PendingAlphaDrop?>((Ref<PendingAlphaDrop?> ref) => null);

class FeedReactionResult {
  const FeedReactionResult({
    required this.success,
    required this.postId,
    required this.reactionType,
    required this.hype,
    required this.likes,
    required this.message,
  });

  final bool success;
  final String postId;
  final String reactionType;
  final double hype;
  final int likes;
  final String message;

  factory FeedReactionResult.fromJson(Map<String, dynamic> json) {
    return FeedReactionResult(
      success: json['success'] == true,
      postId: json['post_id'] as String? ?? '',
      reactionType: json['reaction_type'] as String? ?? '',
      hype: _safeDouble(json['hype']),
      likes: _safeInt(json['likes']),
      message: json['message'] as String? ?? '',
    );
  }
}

class FeedComment {
  const FeedComment({
    required this.id,
    required this.postId,
    required this.playerId,
    required this.body,
    required this.createdAt,
    this.brandName,
  });

  final String id;
  final String postId;
  final String playerId;
  final String body;
  final DateTime createdAt;
  final String? brandName;

  factory FeedComment.fromJson(Map<String, dynamic> json) {
    return FeedComment(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      playerId: json['player_id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      brandName: json['brand_name'] as String?,
    );
  }
}

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

final StateProvider<Map<String, int>> feedLikeOverrideProvider =
    StateProvider<Map<String, int>>((_) => <String, int>{});

final Provider<FeedActions> feedActionsProvider =
    Provider<FeedActions>((Ref<FeedActions> ref) => FeedActions(ref));

class FeedActions {
  const FeedActions(this._ref);

  final Ref _ref;

  Future<FeedReactionResult> react({
    required String postId,
    required String reactionType,
  }) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFeedReact,
      body: <String, dynamic>{
        'post_id': postId,
        'reaction_type': reactionType,
      },
    );
    return FeedReactionResult.fromJson(response);
  }

  Future<FeedComment> comment({
    required String postId,
    required String body,
  }) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFeedComment,
      body: <String, dynamic>{
        'post_id': postId,
        'body': body,
      },
    );
    final Object? comment = response['comment'];
    final FeedComment parsed = FeedComment.fromJson(
      comment is Map<String, dynamic> ? comment : response,
    );
    _ref.invalidate(feedCommentsProvider(postId));
    return parsed;
  }
}

// ---------------------------------------------------------------------------
// Hype RPC — atomic Postgres increment. Family-parameterised by postId.
// ---------------------------------------------------------------------------

final FutureProviderFamily<void, String> hypePostProvider =
    FutureProvider.family<void, String>(
  (Ref<AsyncValue<void>> ref, String postId) async {
    await ref.read(feedActionsProvider).react(
          postId: postId,
          reactionType: 'hype',
        );
  },
);

final FutureProviderFamily<List<FeedComment>, String> feedCommentsProvider =
    FutureProvider.family<List<FeedComment>, String>(
  (Ref<AsyncValue<List<FeedComment>>> ref, String postId) async {
    final List<dynamic> rows = await SupabaseService.client
        .from(SupabaseConstants.tableFeedComments)
        .select('id, post_id, player_id, brand_name, body, created_at')
        .eq('post_id', postId)
        .order('created_at');

    return rows
        .cast<Map<String, dynamic>>()
        .map(FeedComment.fromJson)
        .toList(growable: false);
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
        (List<Map<String, dynamic>> rows) => rows
            .map((Map<String, dynamic> r) => r['following_id'] as String)
            .toSet(),
      );
});

// ---------------------------------------------------------------------------
// Syndicate feed — one-shot RPC for initial SYNDICATE tab load.
// Client then filters live global stream by followingIdsProvider Set<String>.
// ---------------------------------------------------------------------------

final FutureProvider<List<FeedPost>> syndicateFeedProvider =
    FutureProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) async {
  final List<dynamic> rows = await SupabaseService.client.rpc<List<dynamic>>(
    'get_syndicate_feed',
    params: <String, dynamic>{'p_limit': 50},
  );
  return rows.cast<Map<String, dynamic>>().map(FeedPost.fromJson).toList();
});
