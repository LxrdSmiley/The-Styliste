// GDD 6.1 - Global Live Feed: full-screen vertical fashion-social feed.
// Provider contract stays unchanged: Supabase feed rows flow through Riverpod,
// then render as one bounded PageView page per post.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/design.dart';
import '../../../domain/models/feed_post.dart';
import '../../ftue/providers/first_objective_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/alpha_drop_feed_card.dart';
import '../widgets/mogul_power_feed_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  Timer? _arrivalBannerTimer;
  String? _lastArrivalBannerPostId;
  bool _showArrivalBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(firstObjectiveActionsProvider.notifier).markFeedVisited();
    });
  }

  @override
  void dispose() {
    _arrivalBannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeedMode mode = ref.watch(feedModeProvider);
    final Map<String, int> hypeOverrides = ref.watch(feedHypeOverrideProvider);
    final Map<String, int> likeOverrides = ref.watch(feedLikeOverrideProvider);
    final String activeUid = ref.watch(activeUidProvider);
    final PendingAlphaDrop? pendingAlphaDrop =
        ref.watch(pendingAlphaDropProvider);
    final AsyncValue<List<FeedPost>> globalAsync =
        ref.watch(feedStreamProvider);
    final AsyncValue<Set<String>> followingAsync =
        ref.watch(followingIdsProvider);
    final AsyncValue<List<FeedPost>> syndicateAsync =
        ref.watch(syndicateFeedProvider);

    _scheduleArrivalBanner(pendingAlphaDrop);

    List<FeedPost> syndicatePosts = <FeedPost>[];
    if (mode == FeedMode.syndicate) {
      final Set<String> followingIds = followingAsync.maybeWhen(
        data: (Set<String> s) => s,
        orElse: () => <String>{},
      );
      final List<FeedPost> rpcBatch = syndicateAsync.maybeWhen(
        data: (List<FeedPost> p) => p,
        orElse: () => <FeedPost>[],
      );
      final List<FeedPost> liveFiltered = globalAsync.maybeWhen(
        data: (List<FeedPost> posts) => posts
            .where((FeedPost p) => followingIds.contains(p.playerId))
            .toList(),
        orElse: () => <FeedPost>[],
      );

      final Map<String, FeedPost> seen = <String, FeedPost>{};
      for (final FeedPost p in <FeedPost>[...liveFiltered, ...rpcBatch]) {
        seen.putIfAbsent(p.id, () => p);
      }
      syndicatePosts = seen.values.toList();
    }

    final AsyncValue<List<FeedPost>> activeAsync =
        mode == FeedMode.global ? globalAsync : syndicateAsync;

    FeedPost? ownAlpha;
    for (final FeedPost post in activeAsync.valueOrNull ?? <FeedPost>[]) {
      if (post.playerId == activeUid &&
          post.content['event']?.toString() == 'alpha_dropped') {
        ownAlpha = post;
        break;
      }
    }
    if (ownAlpha != null) {
      unawaited(
        ref.read(firstObjectiveRepositoryProvider).recordValidatedEvent(
              'first_drop_result_viewed',
              entityId: ownAlpha.id,
            ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
              child: Row(
                children: <Widget>[
                  const Text(
                    'GLOBAL FEED',
                    style: TextStyle(
                      color: AppColors.ivory,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.2,
                    ),
                  ),
                  const Spacer(),
                  _ModeToggle(
                    mode: mode,
                    onChanged: (FeedMode m) =>
                        ref.read(feedModeProvider.notifier).state = m,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  mode == FeedMode.global
                      ? _buildGlobal(
                          globalAsync,
                          hypeOverrides,
                          likeOverrides,
                          activeUid,
                        )
                      : _buildSyndicate(
                          syndicatePosts,
                          activeAsync,
                          hypeOverrides,
                          likeOverrides,
                          activeUid,
                        ),
                  _ArrivalBanner(visible: _showArrivalBanner),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleArrivalBanner(PendingAlphaDrop? pendingAlphaDrop) {
    if (pendingAlphaDrop == null ||
        pendingAlphaDrop.feedPostId == _lastArrivalBannerPostId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || pendingAlphaDrop.feedPostId == _lastArrivalBannerPostId) {
        return;
      }
      _lastArrivalBannerPostId = pendingAlphaDrop.feedPostId;
      setState(() => _showArrivalBanner = true);
      _arrivalBannerTimer?.cancel();
      _arrivalBannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showArrivalBanner = false);
      });
    });
  }

  Widget _buildGlobal(
    AsyncValue<List<FeedPost>> async,
    Map<String, int> hypeOverrides,
    Map<String, int> likeOverrides,
    String activeUid,
  ) {
    return async.when(
      loading: () => const Center(
        child:
            CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5),
      ),
      error: (Object e, _) => _statusWidget(
        _feedStatusMessage(e, 'SIGNAL LOST'),
      ),
      data: (List<FeedPost> posts) => posts.isEmpty
          ? _statusWidget('NO SIGNALS YET\nBE THE FIRST TO FLEX')
          : _postPager(posts, hypeOverrides, likeOverrides, activeUid),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    Map<String, int> hypeOverrides,
    Map<String, int> likeOverrides,
    String activeUid,
  ) {
    if (async.isLoading && posts.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(color: AppColors.lime, strokeWidth: 1.5),
      );
    }
    if (async.hasError && posts.isEmpty) {
      return _statusWidget(
        _feedStatusMessage(async.error, 'SYNDICATE SIGNAL LOST'),
      );
    }
    if (posts.isEmpty) {
      return _statusWidget('FOLLOW PLAYERS TO\nBUILD YOUR SYNDICATE');
    }
    return _postPager(posts, hypeOverrides, likeOverrides, activeUid);
  }

  Widget _postPager(
    List<FeedPost> posts,
    Map<String, int> hypeOverrides,
    Map<String, int> likeOverrides,
    String activeUid,
  ) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        final FeedPost post = posts[index];
        final int localHypeDelta = hypeOverrides[post.id] ?? 0;
        final int localLikeDelta = likeOverrides[post.id] ?? 0;
        final double displayHype = post.hype + localHypeDelta;
        final int displayLikes = post.likes + localLikeDelta;
        final bool isOwnPost = activeUid == post.playerId;

        if (_isDesignerAlphaDrop(post.type)) {
          final FeedRequestQuery query = FeedRequestQuery(
            postId: post.id,
            requestType: FeedRequestType.designInspiration,
          );
          final AsyncValue<FeedSocialRequest?> requestAsync =
              ref.watch(feedRequestStatusProvider(query));
          return AlphaDropFeedCard(
            post: post,
            displayHype: displayHype,
            displayLikes: displayLikes,
            onHype: () => _onHype(context, post.id),
            onLike: () => _onLike(context, post.id),
            onComment: () => _showCommentSheet(context, post),
            onSave: () => _onSave(context, post.id),
            inspirationLabel: _inspirationLabel(
              isOwnPost: isOwnPost,
              requestAsync: requestAsync,
            ),
            onInspiration: _inspirationAction(
              context: context,
              post: post,
              isOwnPost: isOwnPost,
              requestAsync: requestAsync,
            ),
          );
        }

        final FeedRequestQuery query = FeedRequestQuery(
          postId: post.id,
          requestType: FeedRequestType.collab,
        );
        final AsyncValue<FeedSocialRequest?> requestAsync =
            ref.watch(feedRequestStatusProvider(query));
        return MogulPowerFeedCard(
          post: post,
          displayHype: displayHype,
          displayLikes: displayLikes,
          onHype: () => _onHype(context, post.id),
          onLike: () => _onLike(context, post.id),
          onComment: () => _showCommentSheet(context, post),
          onSave: () => _onSave(context, post.id),
          collabLabel: _collabLabel(
            isOwnPost: isOwnPost,
            requestAsync: requestAsync,
          ),
          onCollab: _collabAction(
            context: context,
            post: post,
            isOwnPost: isOwnPost,
            requestAsync: requestAsync,
          ),
        );
      },
    );
  }

  static bool _isDesignerAlphaDrop(String type) {
    return type == 'design_flex' || type == 'design_drop';
  }

  static Widget _statusWidget(String label) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.ivory.withValues(alpha: 0.28),
          fontSize: 11.0,
          letterSpacing: 2.4,
          height: 1.8,
        ),
      ),
    );
  }

  String _inspirationLabel({
    required bool isOwnPost,
    required AsyncValue<FeedSocialRequest?> requestAsync,
  }) {
    if (isOwnPost) return 'REQUESTS';
    final FeedSocialRequest? request = _requestValue(requestAsync);
    if (requestAsync.isLoading) return 'WAIT';
    if (request == null) return 'INSPIRE';
    if (request.isPending) return 'PENDING';
    if (request.isAccepted) return 'LOAD';
    if (request.isDeclined) return 'DENIED';
    return 'INSPIRE';
  }

  String _collabLabel({
    required bool isOwnPost,
    required AsyncValue<FeedSocialRequest?> requestAsync,
  }) {
    if (isOwnPost) return 'REQUESTS';
    final FeedSocialRequest? request = _requestValue(requestAsync);
    if (requestAsync.isLoading) return 'WAIT';
    if (request == null) return 'COLLAB';
    if (request.isPending) return 'PENDING';
    if (request.isAccepted) return 'PARTNER';
    if (request.isDeclined) return 'DENIED';
    return 'COLLAB';
  }

  VoidCallback? _inspirationAction({
    required BuildContext context,
    required FeedPost post,
    required bool isOwnPost,
    required AsyncValue<FeedSocialRequest?> requestAsync,
  }) {
    if (isOwnPost) return () => _showRequestsSheet(context, post);
    if (requestAsync.isLoading) return null;

    final FeedSocialRequest? request = _requestValue(requestAsync);
    if (request == null) {
      return () => _requestInspiration(context, post.id);
    }
    if (request.isAccepted) {
      return () => _loadInspiration(context, request);
    }
    return null;
  }

  VoidCallback? _collabAction({
    required BuildContext context,
    required FeedPost post,
    required bool isOwnPost,
    required AsyncValue<FeedSocialRequest?> requestAsync,
  }) {
    if (isOwnPost) return () => _showRequestsSheet(context, post);
    if (requestAsync.isLoading) return null;

    final FeedSocialRequest? request = _requestValue(requestAsync);
    if (request == null) {
      return () => _requestCollab(context, post.id);
    }
    return null;
  }

  FeedSocialRequest? _requestValue(
    AsyncValue<FeedSocialRequest?> requestAsync,
  ) {
    return requestAsync.maybeWhen(
      data: (FeedSocialRequest? request) => request,
      orElse: () => null,
    );
  }

  void _onHype(BuildContext context, String postId) {
    final Map<String, int> current = ref.read(feedHypeOverrideProvider);
    ref.read(feedHypeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    unawaited(
      _react(
        context: context,
        postId: postId,
        reactionType: 'hype',
        overrideProvider: feedHypeOverrideProvider,
      ),
    );
  }

  void _onLike(BuildContext context, String postId) {
    final Map<String, int> current = ref.read(feedLikeOverrideProvider);
    ref.read(feedLikeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    unawaited(
      _react(
        context: context,
        postId: postId,
        reactionType: 'like',
        overrideProvider: feedLikeOverrideProvider,
      ),
    );
  }

  void _onSave(BuildContext context, String postId) {
    unawaited(_savePost(context, postId));
  }

  Future<void> _savePost(BuildContext context, String postId) async {
    try {
      final FeedReactionResult result =
          await ref.read(feedActionsProvider).save(postId: postId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success ? 'Saved to Lookbook.' : 'Already saved.',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(e, 'Could not save right now.'),
            ),
          ),
        );
      }
    }
  }

  void _requestInspiration(BuildContext context, String postId) {
    unawaited(_sendInspirationRequest(context, postId));
  }

  Future<void> _sendInspirationRequest(
    BuildContext context,
    String postId,
  ) async {
    try {
      await ref.read(feedActionsProvider).requestInspiration(postId: postId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspiration request sent.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(
                e,
                'Could not request inspiration right now.',
              ),
            ),
          ),
        );
      }
    }
  }

  void _requestCollab(BuildContext context, String postId) {
    unawaited(_sendCollabRequest(context, postId));
  }

  Future<void> _sendCollabRequest(BuildContext context, String postId) async {
    try {
      await ref.read(feedActionsProvider).requestCollab(postId: postId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collab request sent.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(e, 'Could not request collab right now.'),
            ),
          ),
        );
      }
    }
  }

  void _loadInspiration(BuildContext context, FeedSocialRequest request) {
    unawaited(_loadInspirationDesign(context, request));
  }

  Future<void> _loadInspirationDesign(
    BuildContext context,
    FeedSocialRequest request,
  ) async {
    try {
      final Design design =
          await ref.read(feedActionsProvider).loadApprovedInspirationDesign(
                request,
              );
      if (context.mounted) {
        unawaited(context.push(AppRouter.atelier, extra: design));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(
                e,
                'Could not load inspiration right now.',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _react({
    required BuildContext context,
    required String postId,
    required String reactionType,
    required StateProvider<Map<String, int>> overrideProvider,
  }) async {
    try {
      final FeedReactionResult result = await ref
          .read(feedActionsProvider)
          .react(postId: postId, reactionType: reactionType);
      if (result.success) {
        _clearReactionOverride(postId, overrideProvider);
        return;
      }
      _rollbackReaction(postId, overrideProvider);
      if (context.mounted && result.message == 'ALREADY_REACTED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already ${reactionType}d.')),
        );
      }
    } catch (e) {
      _rollbackReaction(postId, overrideProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(
                e,
                'Could not $reactionType right now.',
              ),
            ),
          ),
        );
      }
    }
  }

  void _rollbackReaction(
    String postId,
    StateProvider<Map<String, int>> provider,
  ) {
    final Map<String, int> current = ref.read(provider);
    final int next = (current[postId] ?? 0) - 1;
    ref.read(provider.notifier).state = <String, int>{
      ...current,
      if (next > 0) postId: next,
    };
  }

  void _clearReactionOverride(
    String postId,
    StateProvider<Map<String, int>> provider,
  ) {
    final Map<String, int> current = ref.read(provider);
    ref.read(provider.notifier).state = <String, int>{...current}
      ..remove(postId);
  }

  void _showCommentSheet(BuildContext context, FeedPost post) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.obsidianCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        ),
        builder: (_) => _CommentSheet(post: post),
      ),
    );
  }

  void _showRequestsSheet(BuildContext context, FeedPost post) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.obsidianCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        ),
        builder: (_) => _FeedRequestsSheet(post: post),
      ),
    );
  }
}

String _feedErrorMessage(Object error, String fallback) {
  return SupabaseService.playerSafeErrorMessage(error, fallback: fallback);
}

String _feedStatusMessage(Object? error, String fallback) {
  if (error == null) return fallback;
  return SupabaseService.playerSafeErrorMessage(error, fallback: fallback);
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final FeedMode mode;
  final ValueChanged<FeedMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.grey700),
      ),
      child: Row(
        children: <Widget>[
          _ModeSegment(
            label: 'GLOBAL',
            selected: mode == FeedMode.global,
            selectedColor: AppColors.gold,
            onTap: () => onChanged(FeedMode.global),
          ),
          _ModeSegment(
            label: 'SYNDICATE',
            selected: mode == FeedMode.syndicate,
            selectedColor: AppColors.lime,
            onTap: () => onChanged(FeedMode.syndicate),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        width: 92.0,
        height: 32.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected
                ? selectedColor
                : AppColors.ivory.withValues(alpha: 0.48),
            fontSize: 9.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ArrivalBanner extends StatelessWidget {
  const _ArrivalBanner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0.0, -0.3),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 220),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 0.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.obsidianSurface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.52),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      blurRadius: 22.0,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'YOUR ALPHA DROP IS LIVE',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 3.0),
                    Text(
                      'The market is reacting.',
                      style: TextStyle(
                        color: AppColors.ivory,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedRequestsSheet extends ConsumerWidget {
  const _FeedRequestsSheet({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FeedSocialRequest>> requestsAsync =
        ref.watch(feedIncomingRequestsProvider(post.id));
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.64,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 8.0, 8.0),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'REQUESTS',
                        style: TextStyle(
                          color: AppColors.ivory,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close requests',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.ivory.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: requestsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 1.5,
                    ),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      'REQUESTS UNAVAILABLE',
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.32),
                        fontSize: 10.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  data: (List<FeedSocialRequest> requests) {
                    if (requests.isEmpty) {
                      return Center(
                        child: Text(
                          'NO PENDING REQUESTS',
                          style: TextStyle(
                            color: AppColors.ivory.withValues(alpha: 0.32),
                            fontSize: 10.0,
                            letterSpacing: 2.0,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.ivory.withValues(alpha: 0.08),
                        height: 18.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final FeedSocialRequest request = requests[index];
                        final bool inspiration = request.requestType ==
                            FeedRequestType.designInspiration;
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    inspiration
                                        ? 'ATELIER INSPIRATION'
                                        : 'COLLAB REQUEST',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    _shortId(request.requesterId),
                                    style: TextStyle(
                                      color: AppColors.ivory
                                          .withValues(alpha: 0.76),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (request.message.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 4.0),
                                    Text(
                                      request.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.ivory
                                            .withValues(alpha: 0.56),
                                        fontSize: 11.0,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Deny request',
                              onPressed: () => unawaited(
                                _respond(context, ref, request, false),
                              ),
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.danger,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Approve request',
                              onPressed: () => unawaited(
                                _respond(context, ref, request, true),
                              ),
                              icon: const Icon(
                                Icons.check,
                                color: AppColors.lime,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    FeedSocialRequest request,
    bool approve,
  ) async {
    try {
      await ref.read(feedActionsProvider).respondToRequest(
            request: request,
            approve: approve,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Request approved.' : 'Request denied.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(e, 'Could not respond right now.'),
            ),
          ),
        );
      }
    }
  }

  static String _shortId(String value) {
    if (value.length <= 8) return value;
    return 'Designer ${value.substring(0, 8).toUpperCase()}';
  }
}

class _CommentSheet extends ConsumerStatefulWidget {
  const _CommentSheet({required this.post});

  final FeedPost post;

  @override
  ConsumerState<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<_CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String body = _controller.text.trim();
    if (_isSubmitting || body.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(feedActionsProvider).comment(
            postId: widget.post.id,
            body: body,
          );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _feedErrorMessage(e, 'Could not comment right now.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FeedComment>> commentsAsync =
        ref.watch(feedCommentsProvider(widget.post.id));
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 8.0, 8.0),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'COMMENTS',
                        style: TextStyle(
                          color: AppColors.ivory,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close comments',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.ivory.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: commentsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 1.5,
                    ),
                  ),
                  error: (_, __) => Center(
                    child: Text(
                      'COMMENTS UNAVAILABLE',
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.32),
                        fontSize: 10.0,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  data: (List<FeedComment> comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'START THE CONVERSATION',
                          style: TextStyle(
                            color: AppColors.ivory.withValues(alpha: 0.32),
                            fontSize: 10.0,
                            letterSpacing: 2.0,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.ivory.withValues(alpha: 0.08),
                        height: 18.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final FeedComment comment = comments[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _commentAuthorLabel(comment),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              comment.body,
                              style: TextStyle(
                                color: AppColors.ivory.withValues(alpha: 0.76),
                                fontSize: 12.0,
                                height: 1.35,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 280,
                        style: const TextStyle(color: AppColors.ivory),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Add a comment',
                          hintStyle: TextStyle(
                            color: AppColors.ivory.withValues(alpha: 0.34),
                          ),
                          filled: true,
                          fillColor: AppColors.obsidian,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: AppColors.ivory.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.gold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (
                        BuildContext context,
                        TextEditingValue value,
                        Widget? _,
                      ) {
                        final bool canSubmit =
                            !_isSubmitting && value.text.trim().isNotEmpty;
                        return IconButton(
                          tooltip: 'Post comment',
                          onPressed: canSubmit ? _submit : null,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18.0,
                                  height: 18.0,
                                  child: CircularProgressIndicator(
                                    color: AppColors.gold,
                                    strokeWidth: 1.5,
                                  ),
                                )
                              : Icon(
                                  Icons.send,
                                  color: canSubmit
                                      ? AppColors.gold
                                      : AppColors.ivory.withValues(alpha: 0.32),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _commentAuthorLabel(FeedComment comment) {
    final String? brandName = comment.brandName;
    if (brandName != null && brandName.isNotEmpty) return brandName;
    if (comment.playerId.length <= 8) return comment.playerId;
    return 'Designer ${comment.playerId.substring(0, 8).toUpperCase()}';
  }
}
