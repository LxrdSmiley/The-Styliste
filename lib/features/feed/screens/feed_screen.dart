// GDD 6.1 - Global Live Feed: full-screen vertical fashion-social feed.
// Provider contract stays unchanged: Supabase feed rows flow through Riverpod,
// then render as one bounded PageView page per post.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/feed_post.dart';
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
  void dispose() {
    _arrivalBannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeedMode mode = ref.watch(feedModeProvider);
    final Map<String, int> hypeOverrides = ref.watch(feedHypeOverrideProvider);
    final Map<String, int> likeOverrides = ref.watch(feedLikeOverrideProvider);
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
                        )
                      : _buildSyndicate(
                          syndicatePosts,
                          activeAsync,
                          hypeOverrides,
                          likeOverrides,
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
  ) {
    return async.when(
      loading: () => const Center(
        child:
            CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5),
      ),
      error: (Object e, _) => _statusWidget('SIGNAL LOST'),
      data: (List<FeedPost> posts) => posts.isEmpty
          ? _statusWidget('NO SIGNALS YET\nBE THE FIRST TO FLEX')
          : _postPager(posts, hypeOverrides, likeOverrides),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    Map<String, int> hypeOverrides,
    Map<String, int> likeOverrides,
  ) {
    if (async.isLoading && posts.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(color: AppColors.lime, strokeWidth: 1.5),
      );
    }
    if (async.hasError && posts.isEmpty) {
      return _statusWidget('SYNDICATE SIGNAL LOST');
    }
    if (posts.isEmpty) {
      return _statusWidget('FOLLOW PLAYERS TO\nBUILD YOUR SYNDICATE');
    }
    return _postPager(posts, hypeOverrides, likeOverrides);
  }

  Widget _postPager(
    List<FeedPost> posts,
    Map<String, int> hypeOverrides,
    Map<String, int> likeOverrides,
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

        if (_isDesignerAlphaDrop(post.type)) {
          return AlphaDropFeedCard(
            post: post,
            displayHype: displayHype,
            displayLikes: displayLikes,
            onHype: () => _onHype(context, post.id),
            onLike: () => _onLike(context, post.id),
            onComment: () => _showCommentSheet(context, post),
          );
        }

        return MogulPowerFeedCard(
          post: post,
          displayHype: displayHype,
          displayLikes: displayLikes,
          onHype: () => _onHype(context, post.id),
          onLike: () => _onLike(context, post.id),
          onComment: () => _showCommentSheet(context, post),
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
          SnackBar(content: Text('Could not $reactionType: $e')),
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
          SnackBar(content: Text('Could not comment: $e')),
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
                              comment.brandName ?? 'Unknown Sovereign',
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
                    IconButton(
                      tooltip: 'Post comment',
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                                strokeWidth: 1.5,
                              ),
                            )
                          : const Icon(Icons.send, color: AppColors.gold),
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
}
