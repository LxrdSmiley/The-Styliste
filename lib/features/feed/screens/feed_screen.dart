// GDD 6.1 - Global Live Feed: full-screen vertical fashion-social feed.
// Provider contract stays unchanged: Supabase feed rows flow through Riverpod,
// then render as one bounded PageView page per post.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_motion.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_scaffold.dart';
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

    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      applyHorizontalInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeedHeader(
            mode: mode,
            onChanged: (FeedMode next) =>
                ref.read(feedModeProvider.notifier).state = next,
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                mode == FeedMode.global
                    ? _buildGlobal(
                        globalAsync,
                        activeUid,
                      )
                    : _buildSyndicate(
                        syndicatePosts,
                        activeAsync,
                        activeUid,
                      ),
                _ArrivalBanner(visible: _showArrivalBanner),
              ],
            ),
          ),
        ],
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
    String activeUid,
  ) {
    return async.when(
      loading: () => _statusWidget(
        kind: AurelianStateKind.loading,
        title: 'Restoring editorial signals',
        message: 'Reading the server-confirmed global Feed projection.',
      ),
      error: (Object e, _) => _statusWidget(
        kind: AurelianStateKind.retryableError,
        title: 'Global signal interrupted',
        message: _feedStatusMessage(e, 'The Feed is temporarily unavailable.'),
        actionLabel: 'Retry global Feed',
        onAction: () => ref.invalidate(feedStreamProvider),
      ),
      data: (List<FeedPost> posts) => posts.isEmpty
          ? _statusWidget(
              kind: AurelianStateKind.empty,
              title: 'No confirmed signals yet',
              message:
                  'Editorial records appear only after the server confirms an implemented event.',
            )
          : _postPager(posts, activeUid),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    String activeUid,
  ) {
    if (async.isLoading && posts.isEmpty) {
      return _statusWidget(
        kind: AurelianStateKind.loading,
        title: 'Restoring your syndicate',
        message: 'Reading followed Houses and their confirmed signals.',
      );
    }
    if (async.hasError && posts.isEmpty) {
      return _statusWidget(
        kind: AurelianStateKind.retryableError,
        title: 'Syndicate signal interrupted',
        message:
            _feedStatusMessage(async.error, 'The syndicate is unavailable.'),
        actionLabel: 'Retry syndicate',
        onAction: () {
          ref
            ..invalidate(followingIdsProvider)
            ..invalidate(syndicateFeedProvider);
        },
      );
    }
    if (posts.isEmpty) {
      return _statusWidget(
        kind: AurelianStateKind.empty,
        title: 'Your syndicate is quiet',
        message:
            'Confirmed posts from followed Houses will appear here. Following mutations are not offered on this surface.',
      );
    }
    return _postPager(posts, activeUid);
  }

  Widget _postPager(
    List<FeedPost> posts,
    String activeUid,
  ) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        final FeedPost post = posts[index];
        final double displayHype = post.hype;
        final int displayLikes = post.likes;
        final bool isOwnPost = activeUid == post.playerId;

        if (_isDesignerAlphaDrop(post.type)) {
          return AlphaDropFeedCard(
            post: post,
            displayHype: displayHype,
            displayLikes: displayLikes,
            onHype: null,
            onLike: null,
            onComment: () => _showCommentSheet(context, post),
            onSave: null,
            inspirationLabel: isOwnPost ? 'REQUESTS' : 'HELD',
            onInspiration:
                isOwnPost ? () => _showRequestsSheet(context, post) : null,
          );
        }

        return MogulPowerFeedCard(
          post: post,
          displayHype: displayHype,
          displayLikes: displayLikes,
          onHype: null,
          onLike: null,
          onComment: () => _showCommentSheet(context, post),
          onSave: null,
          collabLabel: isOwnPost ? 'REQUESTS' : 'HELD',
          onCollab: isOwnPost ? () => _showRequestsSheet(context, post) : null,
        );
      },
    );
  }

  static bool _isDesignerAlphaDrop(String type) {
    return type == 'design_flex' || type == 'design_drop';
  }

  static Widget _statusWidget({
    required AurelianStateKind kind,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(StylisteSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AurelianStatePanel(
            kind: kind,
            title: title,
            message: message,
            authorityLabel: 'Authenticated Feed projection',
            preservationLabel: 'No Hype, like, or progression mutation',
            retrySafetyLabel: kind == AurelianStateKind.retryableError
                ? 'Safe read-only refresh'
                : 'No retry required',
            actionLabel: actionLabel,
            onAction: onAction,
            compact: true,
          ),
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context, FeedPost post) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: StylisteColors.obsidianRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StylisteRadii.sheet),
          ),
        ),
        builder: (_) => FeedCommentSheet(post: post),
      ),
    );
  }

  void _showRequestsSheet(BuildContext context, FeedPost post) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: StylisteColors.obsidianRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StylisteRadii.sheet),
          ),
        ),
        builder: (_) => FeedRequestsSheet(post: post),
      ),
    );
  }
}

String _feedStatusMessage(Object? error, String fallback) {
  if (error == null) return fallback;
  return SupabaseService.playerSafeErrorMessage(error, fallback: fallback);
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.mode, required this.onChanged});

  final FeedMode mode;
  final ValueChanged<FeedMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const Widget title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'HOUSE SIGNAL',
          style: StylisteText.labelCaps,
        ),
        SizedBox(height: StylisteSpacing.xxs),
        Text(
          'Fashion-industry records',
          style: StylisteText.bodySmall,
        ),
      ],
    );
    final Widget toggle = _ModeToggle(mode: mode, onChanged: onChanged);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                title,
                const SizedBox(height: StylisteSpacing.sm),
                toggle,
              ],
            );
          }
          return Row(
            children: <Widget>[
              title,
              const Spacer(),
              toggle,
            ],
          );
        },
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final FeedMode mode;
  final ValueChanged<FeedMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Feed channel',
      child: Material(
        color: StylisteColors.obsidianRaised,
        shape: const StadiumBorder(
          side: BorderSide(color: StylisteColors.outlineDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ModeSegment(
              label: 'GLOBAL',
              selected: mode == FeedMode.global,
              selectedColor: StylisteColors.champagneGold,
              onTap: () => onChanged(FeedMode.global),
            ),
            _ModeSegment(
              label: 'SYNDICATE',
              selected: mode == FeedMode.syndicate,
              selectedColor: StylisteColors.signalLime,
              onTap: () => onChanged(FeedMode.syndicate),
            ),
          ],
        ),
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
    return Semantics(
      button: true,
      selected: selected,
      label: '$label feed',
      child: SizedBox(
        width: 84.0,
        height: 48.0,
        child: InkWell(
          onTap: selected ? null : onTap,
          customBorder: const StadiumBorder(),
          focusColor: selectedColor.withValues(alpha: 0.18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 0.14)
                  : StylisteColors.transparent,
              borderRadius: BorderRadius.circular(StylisteRadii.pill),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StylisteText.labelCaps.copyWith(
                  color: selected
                      ? selectedColor
                      : StylisteColors.ivory.withValues(alpha: 0.58),
                  fontSize: 9.0,
                  letterSpacing: 1.1,
                ),
              ),
            ),
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
    final Duration slideDuration = StylisteMotion.resolve(
      context,
      StylisteMotion.microMax,
    );
    final Duration fadeDuration = StylisteMotion.resolve(
      context,
      StylisteMotion.micro,
    );
    return IgnorePointer(
      child: Semantics(
        liveRegion: visible,
        label: visible ? 'Your design record is now visible in the Feed.' : '',
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0.0, -0.3),
          duration: slideDuration,
          curve: StylisteMotion.standardCurve,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: fadeDuration,
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
                    color:
                        StylisteColors.obsidianSurface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(StylisteRadii.control),
                    border: Border.all(
                      color:
                          StylisteColors.champagneGold.withValues(alpha: 0.52),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: StylisteColors.champagneGold
                            .withValues(alpha: 0.14),
                        blurRadius: 22.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'YOUR DESIGN RECORD IS LIVE',
                        style: StylisteText.labelCaps.copyWith(
                          color: StylisteColors.champagneGold,
                        ),
                      ),
                      const SizedBox(height: StylisteSpacing.xxs),
                      Text(
                        'The Feed is showing the server-confirmed result.',
                        style: StylisteText.bodySmall.copyWith(
                          color: StylisteColors.ivory,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class FeedRequestsSheet extends ConsumerWidget {
  const FeedRequestsSheet({required this.post, super.key});

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
              const _FeedSheetHeader(
                eyebrow: 'House Feed',
                title: 'Requests',
                closeTooltip: 'Close requests',
              ),
              Expanded(
                child: requestsAsync.when(
                  loading: () => const _RequestStateList(
                    state: AurelianStatePanel(
                      kind: AurelianStateKind.loading,
                      title: 'Restoring requests',
                      message:
                          'Reading the server-owned request state for this post.',
                      authorityLabel: 'Authenticated owner-safe projection',
                      preservationLabel: 'No request response is sent',
                      retrySafetyLabel: 'Wait for this read to finish',
                      compact: true,
                    ),
                  ),
                  error: (_, __) => _RequestStateList(
                    state: AurelianStatePanel(
                      kind: AurelianStateKind.retryableError,
                      title: 'Requests are unavailable',
                      message:
                          'Nothing changed. Retry the authenticated request list.',
                      authorityLabel: 'Authenticated owner-safe projection',
                      preservationLabel: 'Request state remains unchanged',
                      retrySafetyLabel: 'Safe read-only refresh',
                      actionLabel: 'Retry',
                      onAction: () => ref.invalidate(
                        feedIncomingRequestsProvider(post.id),
                      ),
                      compact: true,
                    ),
                  ),
                  data: (List<FeedSocialRequest> requests) {
                    if (requests.isEmpty) {
                      return const _RequestStateList(
                        state: AurelianStatePanel(
                          kind: AurelianStateKind.empty,
                          title: 'No pending requests',
                          message:
                              'New authenticated requests will appear here.',
                          authorityLabel: 'Server-projected request list',
                          preservationLabel: 'No response mutation',
                          retrySafetyLabel: 'No retry required',
                          compact: true,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                      itemCount: requests.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: StylisteSpacing.sm),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) return const _RequestBoundary();
                        final FeedSocialRequest request = requests[index - 1];
                        final bool inspiration = request.requestType ==
                            FeedRequestType.designInspiration;
                        return AurelianCard(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      inspiration
                                          ? 'ATELIER INSPIRATION'
                                          : 'COLLAB REQUEST',
                                      style: StylisteText.labelCaps.copyWith(
                                        color: StylisteColors.champagneGold,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      _shortId(request.requesterId),
                                      style: StylisteText.body.copyWith(
                                        color: StylisteColors.ivory,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (request.message.isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 4.0),
                                      Text(
                                        request.message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: StylisteText.bodySmall.copyWith(
                                          color: StylisteColors.warmGrey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const IconButton(
                                tooltip: 'Deny unavailable in Gate A',
                                onPressed: null,
                                icon: Icon(
                                  Icons.close,
                                  color: StylisteColors.rivalRed,
                                ),
                              ),
                              const SizedBox(width: StylisteSpacing.sm),
                              const IconButton(
                                tooltip: 'Approve unavailable in Gate A',
                                onPressed: null,
                                icon: Icon(
                                  Icons.check,
                                  color: StylisteColors.signalLime,
                                ),
                              ),
                            ],
                          ),
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

  static String _shortId(String value) {
    if (value.length <= 8) return value;
    return 'Designer ${value.substring(0, 8).toUpperCase()}';
  }
}

class _RequestStateList extends StatelessWidget {
  const _RequestStateList({required this.state});

  final Widget state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        StylisteSpacing.md,
        StylisteSpacing.sm,
        StylisteSpacing.md,
        StylisteSpacing.md,
      ),
      children: <Widget>[
        const _RequestBoundary(),
        const SizedBox(height: StylisteSpacing.sm),
        state,
      ],
    );
  }
}

class _RequestBoundary extends StatelessWidget {
  const _RequestBoundary();

  @override
  Widget build(BuildContext context) {
    return const AurelianStatePanel(
      kind: AurelianStateKind.disabled,
      title: 'Request responses are held',
      message:
          'You can review server-projected requests. Approve, deny, collab, and inspiration mutations are unavailable in Gate A.',
      authorityLabel: 'Read-only request projection',
      preservationLabel: 'Every request and response state',
      retrySafetyLabel: 'No response action can be sent',
      compact: true,
    );
  }
}

@visibleForTesting
class FeedCommentSheet extends ConsumerStatefulWidget {
  const FeedCommentSheet({required this.post, super.key});

  final FeedPost post;

  @override
  ConsumerState<FeedCommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<FeedCommentSheet> {
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
              const _FeedSheetHeader(
                eyebrow: 'House Feed',
                title: 'Comments',
                closeTooltip: 'Close comments',
              ),
              Expanded(
                child: commentsAsync.when(
                  loading: () => const _CommentStateList(
                    state: AurelianStatePanel(
                      kind: AurelianStateKind.loading,
                      title: 'Restoring comments',
                      message: 'Reading the authenticated conversation.',
                      authorityLabel: 'Authenticated comment projection',
                      preservationLabel: 'No comment mutation is sent',
                      retrySafetyLabel: 'Wait for this read to finish',
                      compact: true,
                    ),
                  ),
                  error: (_, __) => _CommentStateList(
                    state: AurelianStatePanel(
                      kind: AurelianStateKind.retryableError,
                      title: 'Comments are unavailable',
                      message:
                          'Nothing changed. Retry the authenticated conversation.',
                      authorityLabel: 'Authenticated comment projection',
                      preservationLabel: 'Conversation remains unchanged',
                      retrySafetyLabel: 'Safe read-only refresh',
                      actionLabel: 'Retry',
                      onAction: () => ref.invalidate(
                        feedCommentsProvider(widget.post.id),
                      ),
                      compact: true,
                    ),
                  ),
                  data: (List<FeedComment> comments) {
                    if (comments.isEmpty) {
                      return const _CommentStateList(
                        state: AurelianStatePanel(
                          kind: AurelianStateKind.empty,
                          title: 'Start the conversation',
                          message:
                              'Comments appear only after the server confirms them.',
                          authorityLabel: 'Server-confirmed conversation',
                          preservationLabel: 'No local comment draft',
                          retrySafetyLabel: 'No retry required',
                          compact: true,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        StylisteSpacing.md,
                        StylisteSpacing.sm,
                        StylisteSpacing.md,
                        StylisteSpacing.md,
                      ),
                      itemCount: comments.length + 1,
                      separatorBuilder: (_, __) => Divider(
                        color: StylisteColors.ivory.withValues(alpha: 0.08),
                        height: 18.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == comments.length) {
                          return const _CommentingBoundary();
                        }
                        final FeedComment comment = comments[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _commentAuthorLabel(comment),
                              style: StylisteText.labelCaps.copyWith(
                                color: StylisteColors.champagneGold,
                                fontSize: 10.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              comment.body,
                              style: StylisteText.bodySmall.copyWith(
                                color: StylisteColors.ivory,
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

  static String _commentAuthorLabel(FeedComment comment) {
    final String? brandName = comment.brandName;
    if (brandName != null && brandName.isNotEmpty) return brandName;
    if (comment.playerId.length <= 8) return comment.playerId;
    return 'Designer ${comment.playerId.substring(0, 8).toUpperCase()}';
  }
}

class _CommentStateList extends StatelessWidget {
  const _CommentStateList({required this.state});

  final Widget state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        StylisteSpacing.md,
        StylisteSpacing.sm,
        StylisteSpacing.md,
        StylisteSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _CommentingBoundary(),
          const SizedBox(height: StylisteSpacing.sm),
          state,
        ],
      ),
    );
  }
}

class _CommentingBoundary extends StatelessWidget {
  const _CommentingBoundary();

  @override
  Widget build(BuildContext context) {
    return const AurelianStatePanel(
      kind: AurelianStateKind.disabled,
      title: 'Commenting is held',
      message:
          'The conversation is read-only in Gate A. No comment mutation is sent from this screen.',
      authorityLabel: 'Read-only comment projection',
      preservationLabel: 'Confirmed conversation',
      retrySafetyLabel: 'No comment action can be sent',
      compact: true,
    );
  }
}

class _FeedSheetHeader extends StatelessWidget {
  const _FeedSheetHeader({
    required this.eyebrow,
    required this.title,
    required this.closeTooltip,
  });

  final String eyebrow;
  final String title;
  final String closeTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        StylisteSpacing.md,
        StylisteSpacing.md,
        StylisteSpacing.sm,
        StylisteSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AurelianSectionHeader(
              eyebrow: eyebrow,
              title: title,
            ),
          ),
          IconButton(
            tooltip: closeTooltip,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
