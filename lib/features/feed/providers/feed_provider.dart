// GDD §6.1 — Feed Riverpod providers (Phase 6 + 7).
// feedStreamProvider: Realtime stream of global feed_posts (newest first).
// feedHypeOverrideProvider: immutable optimistic hype delta map (postId → delta).
// hypePostProvider: compatibility shim for the feed-react Edge Function.
// Phase 7 additions:
//   feedModeProvider: GLOBAL | SYNDICATE toggle state.
//   followingIdsProvider: Realtime stream of the player's follow graph → Set<String>.
//   syndicateFeedProvider: one-shot RPC batch for initial SYNDICATE load.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';
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

String _safeString(Object? value, {String fallback = ''}) {
  if (value is String) return value;
  return fallback;
}

String? _safeOptionalString(Object? value) {
  if (value is! String) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime _safeDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

class PendingAlphaDrop {
  const PendingAlphaDrop({
    required this.feedPostId,
    required this.designId,
    required this.designName,
    required this.hypeScore,
    this.brandName,
    this.fabricColorHex,
    this.vexVerdict,
    this.vexHeadline,
    this.vexQuote,
    this.followersDelta,
    this.brandHeatDelta,
    this.xpDelta,
    this.rankProgressDelta,
    this.idleRevenueDelta,
    this.marketReaction,
    this.nextObjective,
  });

  final String feedPostId;
  final String designId;
  final String designName;
  final double hypeScore;
  final String? brandName;
  final String? fabricColorHex;
  final String? vexVerdict;
  final String? vexHeadline;
  final String? vexQuote;
  final int? followersDelta;
  final int? brandHeatDelta;
  final int? xpDelta;
  final double? rankProgressDelta;
  final double? idleRevenueDelta;
  final String? marketReaction;
  final String? nextObjective;
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
      id: _safeString(json['id'], fallback: _safeString(json['comment_id'])),
      postId: _safeString(json['post_id']),
      playerId: _safeString(json['player_id']),
      body: _safeString(json['body']),
      createdAt: _safeDateTime(json['created_at']),
      brandName: _safeOptionalString(json['brand_name']),
    );
  }
}

enum FeedRequestType {
  designInspiration,
  collab,
}

extension FeedRequestTypeApi on FeedRequestType {
  String get apiValue => switch (this) {
        FeedRequestType.designInspiration => 'design_inspiration',
        FeedRequestType.collab => 'collab',
      };
}

class FeedRequestQuery {
  const FeedRequestQuery({
    required this.postId,
    required this.requestType,
  });

  final String postId;
  final FeedRequestType requestType;

  @override
  bool operator ==(Object other) {
    return other is FeedRequestQuery &&
        other.postId == postId &&
        other.requestType == requestType;
  }

  @override
  int get hashCode => Object.hash(postId, requestType);
}

class FeedSocialRequest {
  const FeedSocialRequest({
    required this.id,
    required this.postId,
    required this.requesterId,
    required this.recipientId,
    required this.requestType,
    required this.message,
    required this.status,
    required this.createdAt,
    this.sourceDesignId,
    this.approvedDesignId,
    this.respondedAt,
  });

  final String id;
  final String postId;
  final String requesterId;
  final String recipientId;
  final FeedRequestType requestType;
  final String message;
  final String status;
  final String? sourceDesignId;
  final String? approvedDesignId;
  final DateTime createdAt;
  final DateTime? respondedAt;

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  factory FeedSocialRequest.fromJson(Map<String, dynamic> json) {
    final String requestType = json['request_type'] as String? ?? 'collab';
    return FeedSocialRequest(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      requestType: requestType == 'design_inspiration'
          ? FeedRequestType.designInspiration
          : FeedRequestType.collab,
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      sourceDesignId: json['source_design_id'] as String?,
      approvedDesignId: json['approved_design_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      respondedAt: DateTime.tryParse(json['responded_at'] as String? ?? ''),
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

Stream<List<FeedPost>> _pollFeedProjection() async* {
  while (true) {
    final List<Map<String, dynamic>> rows = await SupabaseService.client
        .schema('api')
        .from('feed_projection')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    yield rows.map(FeedPost.fromJson).toList(growable: false);
    await Future<void>.delayed(const Duration(seconds: 30));
  }
}

final StreamProvider<List<FeedPost>> feedStreamProvider =
    StreamProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  if (session.isLoading) return const Stream<List<FeedPost>>.empty();
  if (session.hasError) {
    return Stream<List<FeedPost>>.error(_safeSessionError(session.error!));
  }

  // The reviewed API relation is a security-invoker view, which Postgres
  // Changes cannot subscribe to. Keep this read inside the api boundary.
  return SupabaseService.guardRealtimeStream(_pollFeedProjection());
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
    Provider<FeedActions>((_) => const FeedActions());

class FeedActions {
  const FeedActions();

  Future<FeedReactionResult> react({
    required String postId,
    required String reactionType,
  }) async {
    throw StateError('KINGSTON_FEATURE_UNAVAILABLE');
  }

  Future<FeedComment> comment({
    required String postId,
    required String body,
  }) async {
    throw StateError('KINGSTON_FEATURE_UNAVAILABLE');
  }

  Future<FeedReactionResult> save({required String postId}) {
    return react(postId: postId, reactionType: 'save');
  }

  Future<FeedSocialRequest> requestInspiration({
    required String postId,
  }) async {
    return _invokeFeedRequest(
      action: 'request_inspiration',
      postId: postId,
      requestType: FeedRequestType.designInspiration,
    );
  }

  Future<FeedSocialRequest> requestCollab({
    required String postId,
  }) async {
    return _invokeFeedRequest(
      action: 'request_collab',
      postId: postId,
      requestType: FeedRequestType.collab,
    );
  }

  Future<FeedSocialRequest> respondToRequest({
    required FeedSocialRequest request,
    required bool approve,
  }) async {
    throw StateError('KINGSTON_FEATURE_UNAVAILABLE');
  }

  Future<Design> loadApprovedInspirationDesign(
    FeedSocialRequest request,
  ) async {
    if (!request.isAccepted || request.approvedDesignId == null) {
      throw StateError('INSPIRATION_NOT_APPROVED');
    }

    throw StateError('KINGSTON_FEATURE_UNAVAILABLE');
  }

  Future<FeedSocialRequest> _invokeFeedRequest({
    required String action,
    required String postId,
    required FeedRequestType requestType,
  }) async {
    throw StateError('KINGSTON_FEATURE_UNAVAILABLE');
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
  (Ref<AsyncValue<List<FeedComment>>> ref, String postId) async =>
      const <FeedComment>[],
);

final FutureProviderFamily<FeedSocialRequest?, FeedRequestQuery>
    feedRequestStatusProvider =
    FutureProvider.family<FeedSocialRequest?, FeedRequestQuery>(
  (Ref<AsyncValue<FeedSocialRequest?>> ref, FeedRequestQuery query) async =>
      null,
);

final FutureProviderFamily<List<FeedSocialRequest>, String>
    feedIncomingRequestsProvider =
    FutureProvider.family<List<FeedSocialRequest>, String>(
  (Ref<AsyncValue<List<FeedSocialRequest>>> ref, String postId) async =>
      const <FeedSocialRequest>[],
);

// ---------------------------------------------------------------------------
// Following IDs stream — Realtime set of player_id values the current user
// follows. Tiny payload (~7KB max). O(1) lookup for SYNDICATE stream filter.
// ---------------------------------------------------------------------------

final StreamProvider<Set<String>> followingIdsProvider =
    StreamProvider<Set<String>>((Ref<AsyncValue<Set<String>>> ref) =>
        Stream<Set<String>>.value(const <String>{}));

// ---------------------------------------------------------------------------
// Syndicate feed — one-shot RPC for initial SYNDICATE tab load.
// Client then filters live global stream by followingIdsProvider Set<String>.
// ---------------------------------------------------------------------------

final FutureProvider<List<FeedPost>> syndicateFeedProvider =
    FutureProvider<List<FeedPost>>(
        (Ref<AsyncValue<List<FeedPost>>> ref) async => const <FeedPost>[]);

Object _safeSessionError(Object error) {
  return SupabaseService.isRecoverableAuthError(error)
      ? const SupabaseSessionExpiredException()
      : error;
}
