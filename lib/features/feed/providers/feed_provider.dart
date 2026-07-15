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

import '../../../core/constants/supabase_constants.dart';
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

Map<String, dynamic>? _safeJsonObject(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
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

final StreamProvider<List<FeedPost>> feedStreamProvider =
    StreamProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  if (session.isLoading) return const Stream<List<FeedPost>>.empty();
  if (session.hasError) {
    return Stream<List<FeedPost>>.error(_safeSessionError(session.error!));
  }

  return SupabaseService.guardRealtimeStream(
    SupabaseService.client
        .from(SupabaseConstants.tableFeedPosts)
        .stream(primaryKey: <String>['id'])
        .order('created_at')
        .limit(50)
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.map(FeedPost.fromJson).toList(),
        ),
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
    await SupabaseService.ensureFreshSession();
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
    await SupabaseService.ensureFreshSession();
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFeedComment,
      body: <String, dynamic>{
        'post_id': postId,
        'body': body,
      },
    );
    final Object? comment = response['comment'];
    final FeedComment parsed =
        FeedComment.fromJson(_safeJsonObject(comment) ?? response);
    _ref.invalidate(feedCommentsProvider(postId));
    return parsed;
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
    await SupabaseService.ensureFreshSession();
    final String action =
        request.requestType == FeedRequestType.designInspiration
            ? 'respond_inspiration'
            : 'respond_collab';
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFeedInspiration,
      body: <String, dynamic>{
        'action': action,
        'request_id': request.id,
        'approve': approve,
      },
    );
    final FeedSocialRequest parsed = FeedSocialRequest.fromJson(response);
    _ref
      ..invalidate(feedIncomingRequestsProvider(request.postId))
      ..invalidate(
        feedRequestStatusProvider(
          FeedRequestQuery(
            postId: request.postId,
            requestType: request.requestType,
          ),
        ),
      );
    return parsed;
  }

  Future<Design> loadApprovedInspirationDesign(
    FeedSocialRequest request,
  ) async {
    if (!request.isAccepted || request.approvedDesignId == null) {
      throw StateError('INSPIRATION_NOT_APPROVED');
    }

    await SupabaseService.ensureFreshSession();

    final Map<String, dynamic>? row = await SupabaseService.client
        .from(SupabaseConstants.tableDesigns)
        .select()
        .eq('id', request.approvedDesignId!)
        .maybeSingle();

    if (row == null) {
      throw StateError('APPROVED_DESIGN_NOT_FOUND');
    }

    return Design.fromJson(row);
  }

  Future<FeedSocialRequest> _invokeFeedRequest({
    required String action,
    required String postId,
    required FeedRequestType requestType,
  }) async {
    await SupabaseService.ensureFreshSession();
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFeedInspiration,
      body: <String, dynamic>{
        'action': action,
        'post_id': postId,
      },
    );
    final FeedSocialRequest parsed = FeedSocialRequest.fromJson(response);
    _ref.invalidate(
      feedRequestStatusProvider(
        FeedRequestQuery(postId: postId, requestType: requestType),
      ),
    );
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
    ref.watch(supabaseAuthRevisionProvider);
    await SupabaseService.ensureFreshSession();

    final List<dynamic> rows = await SupabaseService.client
        .from(SupabaseConstants.tableFeedComments)
        .select('id, post_id, player_id, brand_name, body, created_at')
        .eq('post_id', postId)
        .order('created_at');

    return rows.map<FeedComment>((Object? row) {
      final Map<String, dynamic>? comment = _safeJsonObject(row);
      if (comment == null) {
        throw const FormatException('Invalid feed comment row.');
      }
      return FeedComment.fromJson(comment);
    }).toList(growable: false);
  },
);

final FutureProviderFamily<FeedSocialRequest?, FeedRequestQuery>
    feedRequestStatusProvider =
    FutureProvider.family<FeedSocialRequest?, FeedRequestQuery>(
  (Ref<AsyncValue<FeedSocialRequest?>> ref, FeedRequestQuery query) async {
    ref.watch(supabaseAuthRevisionProvider);
    await SupabaseService.ensureFreshSession();

    final String uid = ref.watch(activeUidProvider);
    if (uid.isEmpty) return null;

    final List<dynamic> rows = await SupabaseService.client
        .from(SupabaseConstants.tableCollabRequests)
        .select(
          'id, post_id, requester_id, recipient_id, message, status, '
          'request_type, source_design_id, approved_design_id, created_at, '
          'responded_at',
        )
        .eq('post_id', query.postId)
        .eq('requester_id', uid)
        .eq('request_type', query.requestType.apiValue)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return FeedSocialRequest.fromJson(
      Map<String, dynamic>.from(rows.first as Map<Object?, Object?>),
    );
  },
);

final FutureProviderFamily<List<FeedSocialRequest>, String>
    feedIncomingRequestsProvider =
    FutureProvider.family<List<FeedSocialRequest>, String>(
  (Ref<AsyncValue<List<FeedSocialRequest>>> ref, String postId) async {
    ref.watch(supabaseAuthRevisionProvider);
    await SupabaseService.ensureFreshSession();

    final String uid = ref.watch(activeUidProvider);
    if (uid.isEmpty) return const <FeedSocialRequest>[];

    final List<dynamic> rows = await SupabaseService.client
        .from(SupabaseConstants.tableCollabRequests)
        .select(
          'id, post_id, requester_id, recipient_id, message, status, '
          'request_type, source_design_id, approved_design_id, created_at, '
          'responded_at',
        )
        .eq('post_id', postId)
        .eq('recipient_id', uid)
        .eq('status', 'pending')
        .order('created_at');

    return rows
        .cast<Map<String, dynamic>>()
        .map(FeedSocialRequest.fromJson)
        .toList(growable: false);
  },
);

// ---------------------------------------------------------------------------
// Following IDs stream — Realtime set of player_id values the current user
// follows. Tiny payload (~7KB max). O(1) lookup for SYNDICATE stream filter.
// ---------------------------------------------------------------------------

final StreamProvider<Set<String>> followingIdsProvider =
    StreamProvider<Set<String>>((Ref<AsyncValue<Set<String>>> ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  if (session.isLoading) return const Stream<Set<String>>.empty();
  if (session.hasError) {
    return Stream<Set<String>>.error(_safeSessionError(session.error!));
  }

  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return const Stream<Set<String>>.empty();

  return SupabaseService.guardRealtimeStream(
    SupabaseService.client
        .from(SupabaseConstants.tableFollows)
        .stream(primaryKey: <String>['follower_id', 'following_id'])
        .eq('follower_id', uid)
        .map(
          (List<Map<String, dynamic>> rows) => rows
              .map((Map<String, dynamic> r) => r['following_id'] as String)
              .toSet(),
        ),
  );
});

// ---------------------------------------------------------------------------
// Syndicate feed — one-shot RPC for initial SYNDICATE tab load.
// Client then filters live global stream by followingIdsProvider Set<String>.
// ---------------------------------------------------------------------------

final FutureProvider<List<FeedPost>> syndicateFeedProvider =
    FutureProvider<List<FeedPost>>((Ref<AsyncValue<List<FeedPost>>> ref) async {
  ref.watch(supabaseAuthRevisionProvider);
  await SupabaseService.ensureFreshSession();

  final List<dynamic> rows = await SupabaseService.client.rpc<List<dynamic>>(
    'get_syndicate_feed',
    params: <String, dynamic>{'p_limit': 50},
  );
  return rows.cast<Map<String, dynamic>>().map(FeedPost.fromJson).toList();
});

Object _safeSessionError(Object error) {
  return SupabaseService.isRecoverableAuthError(error)
      ? const SupabaseSessionExpiredException()
      : error;
}
