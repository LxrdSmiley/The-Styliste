// GDD §6.1 — Global Live Feed: real-time posts, social flex (Phase 6 + 7).
// Phase 7: GLOBAL | SYNDICATE toggle.
//   GLOBAL: Realtime .stream() (all players).
//   SYNDICATE: one-shot get_syndicate_feed RPC (initial batch) merged with
//   live global stream filtered by followingIdsProvider Set<String>.
//   Strict id-based deduplication prevents duplicates on RPC/stream race.
// Two card types: 'design_flex' (Gold) | 'mogul_flex' (Lime).
// All JSONB content values use safe ?? fallbacks — Realtime can deliver
// partial payloads; UI must never null-crash.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/feed_post.dart';
import '../providers/feed_provider.dart';

/// Parse a 6-char hex string (no #) into a Color with full opacity.
Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppColors.ivory;
  }
}

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedMode mode = ref.watch(feedModeProvider);
    final Map<String, int> hypeOverrides = ref.watch(feedHypeOverrideProvider);
    final Map<String, int> likeOverrides = ref.watch(feedLikeOverrideProvider);
    final AsyncValue<List<FeedPost>> globalAsync =
        ref.watch(feedStreamProvider);
    final AsyncValue<Set<String>> followingAsync =
        ref.watch(followingIdsProvider);
    final AsyncValue<List<FeedPost>> syndicateAsync =
        ref.watch(syndicateFeedProvider);

    // Build deduplicated SYNDICATE list: RPC batch + live filtered stream.
    // Deduplication: LinkedHashMap insertion order preserves newest-first from
    // RPC; live stream posts are prepended only if id not already present.
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

      // Merge: live-filtered first (newer), then RPC batch, deduplicate by id.
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
            // ── Header + toggle ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
              child: Row(
                children: <Widget>[
                  const Text(
                    'FEED',
                    style: TextStyle(
                      color: AppColors.ivory,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.0,
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

            // ── Feed list ─────────────────────────────────────────────────
            Expanded(
              child: mode == FeedMode.global
                  ? _buildGlobal(
                      globalAsync,
                      hypeOverrides,
                      likeOverrides,
                      ref,
                    )
                  : _buildSyndicate(
                      syndicatePosts,
                      activeAsync,
                      hypeOverrides,
                      likeOverrides,
                      ref,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobal(
    AsyncValue<List<FeedPost>> async,
    Map<String, int> overrides,
    Map<String, int> likeOverrides,
    WidgetRef ref,
  ) {
    return async.when(
      loading: () => const Center(
        child:
            CircularProgressIndicator(color: AppColors.gold, strokeWidth: 1.5),
      ),
      error: (Object e, _) => _errorWidget('SIGNAL LOST'),
      data: (List<FeedPost> posts) => posts.isEmpty
          ? _emptyWidget('NO SIGNALS YET\nBE THE FIRST TO FLEX')
          : _postList(posts, overrides, likeOverrides, ref),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    Map<String, int> overrides,
    Map<String, int> likeOverrides,
    WidgetRef ref,
  ) {
    if (async.isLoading && posts.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(color: AppColors.lime, strokeWidth: 1.5),
      );
    }
    if (async.hasError && posts.isEmpty) {
      return _errorWidget('SYNDICATE SIGNAL LOST');
    }
    if (posts.isEmpty) {
      return _emptyWidget('FOLLOW PLAYERS TO\nBUILD YOUR SYNDICATE');
    }
    return _postList(posts, overrides, likeOverrides, ref);
  }

  Widget _postList(
    List<FeedPost> posts,
    Map<String, int> overrides,
    Map<String, int> likeOverrides,
    WidgetRef ref,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (BuildContext context, int index) {
        final FeedPost post = posts[index];
        final int localDelta = overrides[post.id] ?? 0;
        final int localLikeDelta = likeOverrides[post.id] ?? 0;
        final double displayHype = post.hype + localDelta;
        final int displayLikes = post.likes + localLikeDelta;

        if (post.type == 'design_flex') {
          return _DesignFlexCard(
            post: post,
            displayHype: displayHype,
            displayLikes: displayLikes,
            onHype: () => _onHype(context, ref, post.id),
            onLike: () => _onLike(context, ref, post.id),
            onComment: () => _showCommentSheet(context, post),
          );
        }
        if (post.type == 'system_eclipse') {
          return _SystemEclipseCard(post: post);
        }
        return _MogulFlexCard(
          post: post,
          displayHype: displayHype,
          displayLikes: displayLikes,
          onHype: () => _onHype(context, ref, post.id),
          onLike: () => _onLike(context, ref, post.id),
          onComment: () => _showCommentSheet(context, post),
        );
      },
    );
  }

  static Widget _errorWidget(String label) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.ivory.withValues(alpha: 0.3),
          letterSpacing: 3.0,
          fontSize: 11.0,
        ),
      ),
    );
  }

  static Widget _emptyWidget(String label) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.ivory.withValues(alpha: 0.25),
          fontSize: 11.0,
          letterSpacing: 2.0,
          height: 2.0,
        ),
      ),
    );
  }

  void _onHype(BuildContext context, WidgetRef ref, String postId) {
    final Map<String, int> current = ref.read(feedHypeOverrideProvider);
    ref.read(feedHypeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    unawaited(
      _react(
        context: context,
        ref: ref,
        postId: postId,
        reactionType: 'hype',
        overrideProvider: feedHypeOverrideProvider,
      ),
    );
  }

  void _onLike(BuildContext context, WidgetRef ref, String postId) {
    final Map<String, int> current = ref.read(feedLikeOverrideProvider);
    ref.read(feedLikeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    unawaited(
      _react(
        context: context,
        ref: ref,
        postId: postId,
        reactionType: 'like',
        overrideProvider: feedLikeOverrideProvider,
      ),
    );
  }

  Future<void> _react({
    required BuildContext context,
    required WidgetRef ref,
    required String postId,
    required String reactionType,
    required StateProvider<Map<String, int>> overrideProvider,
  }) async {
    try {
      final FeedReactionResult result = await ref
          .read(feedActionsProvider)
          .react(
            postId: postId,
            reactionType: reactionType,
          );
      if (result.success) {
        _clearReactionOverride(ref, postId, overrideProvider);
        return;
      }
      _rollbackReaction(ref, postId, overrideProvider);
      if (context.mounted && result.message == 'ALREADY_REACTED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already ${reactionType}d.')),
        );
      }
    } catch (e) {
      _rollbackReaction(ref, postId, overrideProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not $reactionType: $e')),
        );
      }
    }
  }

  void _rollbackReaction(
    WidgetRef ref,
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
    WidgetRef ref,
    String postId,
    StateProvider<Map<String, int>> provider,
  ) {
    final Map<String, int> current = ref.read(provider);
    ref.read(provider.notifier).state = <String, int>{
      ...current,
    }..remove(postId);
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

// ---------------------------------------------------------------------------
// GLOBAL | SYNDICATE segmented toggle pill
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Designer Alpha card — Gold accents.
// ---------------------------------------------------------------------------
class _DesignFlexCard extends StatelessWidget {
  const _DesignFlexCard({
    required this.post,
    required this.displayHype,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
  });

  final FeedPost post;
  final double displayHype;
  final int displayLikes;
  final VoidCallback onHype;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> c = post.content;
    final String brandName =
        (c['brand_name'] as String?) ?? 'Unknown Sovereign';
    final String designName = (c['design_name'] as String?) ?? 'UNTITLED ALPHA';
    final double hypeScore = ((c['hype_score'] as num?)?.toDouble()) ?? 0.0;
    final String colorHex = (c['fabric_color_hex'] as String?) ?? 'FAF7F0';

    return _FeedCard(
      accentColor: AppColors.gold,
      typeLabel: 'ALPHA DROP',
      brandName: brandName,
      bodyLine: '$designName — ${hypeScore.toStringAsFixed(1)} HYPE',
      colorDot: _hexToColor(colorHex),
      displayHype: displayHype,
      displayLikes: displayLikes,
      createdAt: post.createdAt,
      onHype: onHype,
      onLike: onLike,
      onComment: onComment,
    );
  }
}

// ---------------------------------------------------------------------------
// Mogul store upgrade card — Lime accents.
// ---------------------------------------------------------------------------
class _MogulFlexCard extends StatelessWidget {
  const _MogulFlexCard({
    required this.post,
    required this.displayHype,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
  });

  final FeedPost post;
  final double displayHype;
  final int displayLikes;
  final VoidCallback onHype;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> c = post.content;
    final String brandName =
        (c['brand_name'] as String?) ?? 'Unknown Sovereign';
    final String city = (c['city'] as String?) ?? '—';
    final String storeType = (c['store_type'] as String?) ?? '—';
    final int newTier = (c['new_tier'] as int?) ?? 1;

    return _FeedCard(
      accentColor: AppColors.lime,
      typeLabel: 'MOGUL FLEX',
      brandName: brandName,
      bodyLine:
          '${city.toUpperCase().replaceAll('_', ' ')} ${storeType.toUpperCase()} → T$newTier',
      displayHype: displayHype,
      displayLikes: displayLikes,
      createdAt: post.createdAt,
      onHype: onHype,
      onLike: onLike,
      onComment: onComment,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared card shell — keeps both card types visually consistent.
// ---------------------------------------------------------------------------
class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.accentColor,
    required this.typeLabel,
    required this.brandName,
    required this.bodyLine,
    required this.displayHype,
    required this.displayLikes,
    required this.onHype,
    required this.onLike,
    required this.onComment,
    this.colorDot,
    this.createdAt,
  });

  final Color accentColor;
  final String typeLabel;
  final String brandName;
  final String bodyLine;
  final double displayHype;
  final int displayLikes;
  final VoidCallback onHype;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final Color? colorDot;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(4.0),
        border: Border(
          left: BorderSide(color: accentColor, width: 2.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Type + timestamp row
          Row(
            children: <Widget>[
              Text(
                typeLabel,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 9.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const Spacer(),
              if (createdAt != null)
                Text(
                  _timeAgo(createdAt!),
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.3),
                    fontSize: 9.0,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6.0),

          // Brand name
          Text(
            brandName,
            style: const TextStyle(
              color: AppColors.ivory,
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: 4.0),

          // Body line + optional color dot
          Row(
            children: <Widget>[
              if (colorDot != null) ...<Widget>[
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: colorDot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6.0),
              ],
              Expanded(
                child: Text(
                  bodyLine,
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.6),
                    fontSize: 11.0,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Engagement row
          Row(
            children: <Widget>[
              Text(
                '${displayHype.toStringAsFixed(0)} HYPE',
                style: TextStyle(
                  color: accentColor.withValues(alpha: 0.8),
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              _FeedActionButton(
                label: 'HYPE',
                color: accentColor,
                onTap: onHype,
              ),
              const SizedBox(width: 6.0),
              _FeedActionButton(
                label: 'LIKE $displayLikes',
                color: AppColors.ivory.withValues(alpha: 0.72),
                onTap: onLike,
              ),
              const SizedBox(width: 6.0),
              _FeedActionButton(
                label: 'COMMENT',
                color: AppColors.ivory.withValues(alpha: 0.72),
                onTap: onComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ---------------------------------------------------------------------------
// System Eclipse card — global server event broadcast.
// Palette key: crimson = deep red (#C0392B), silver = #B0BEC5, gold = existing.
// No hype button — system-originated; player_id may be null.
// ---------------------------------------------------------------------------
class _FeedActionButton extends StatelessWidget {
  const _FeedActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26.0,
        constraints: const BoxConstraints(minWidth: 54.0),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.42)),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 8.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _SystemEclipseCard extends StatelessWidget {
  const _SystemEclipseCard({required this.post});

  final FeedPost post;

  static const Color _crimson = Color(0xFFC0392B);
  static const Color _silver = Color(0xFFB0BEC5);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> c = post.content;
    final String name = (c['name'] as String?) ?? 'ECLIPSE EVENT';
    final String description =
        (c['description'] as String?) ?? 'A global market shift is underway.';
    final String paletteKey = (c['palette'] as String?) ?? 'crimson';
    final double buffMultiplier =
        ((c['buff_multiplier'] as num?)?.toDouble()) ?? 1.0;
    final int durationMinutes = (c['duration_minutes'] as int?) ?? 60;
    final String scope =
        ((c['affected_scope'] as String?) ?? 'global').toUpperCase();

    final Color accent = paletteKey == 'silver'
        ? _silver
        : paletteKey == 'gold'
            ? AppColors.gold
            : _crimson;

    final bool isBuff = buffMultiplier > 1.0;
    final String multiplierLabel = isBuff
        ? '+${((buffMultiplier - 1.0) * 100).toStringAsFixed(0)}%'
        : '-${((1.0 - buffMultiplier) * 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Type badge row
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: Text(
                  'SYSTEM EVENT',
                  style: TextStyle(
                    color: accent,
                    fontSize: 8.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
              const Spacer(),
              if (post.createdAt != null)
                Text(
                  _FeedCard._timeAgo(post.createdAt!),
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.3),
                    fontSize: 9.0,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Event name
          Text(
            name,
            style: TextStyle(
              color: accent,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 4.0),

          // Description
          Text(
            description,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.65),
              fontSize: 10.0,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 10.0),

          // Stats row: multiplier | scope | duration
          Row(
            children: <Widget>[
              _StatChip(label: multiplierLabel, color: accent),
              const SizedBox(width: 6.0),
              _StatChip(
                label: scope,
                color: AppColors.ivory.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6.0),
              _StatChip(
                label: '${durationMinutes}MIN',
                color: AppColors.ivory.withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                                color:
                                    AppColors.ivory.withValues(alpha: 0.76),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
