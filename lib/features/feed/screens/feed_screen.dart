// GDD sections 2, 4.1, 6.1, 8.7.1, and 12.3.
// Portrait-first Global Live Feed: full-screen vertical fashion moments.
// Existing Supabase/Riverpod feed streams and hype RPC are preserved.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/feed_post.dart';
import '../../trends/models/trend_tsunami.dart';
import '../../trends/providers/trend_provider.dart';
import '../providers/feed_provider.dart';

Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppColors.ivory;
  }
}

String _contentString(
  Map<String, dynamic> content,
  String key,
  String fallback,
) {
  final Object? value = content[key];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  return fallback;
}

double _contentDouble(
  Map<String, dynamic> content,
  String key,
  double fallback,
) {
  final Object? value = content[key];
  if (value is num) {
    return value.toDouble();
  }
  return fallback;
}

int _contentInt(
  Map<String, dynamic> content,
  String key,
  int fallback,
) {
  final Object? value = content[key];
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

bool _isDesignerPost(FeedPost post) {
  return post.type == 'design_flex' || post.type == 'design_drop';
}

bool _isTrendBroadcast(FeedPost post) {
  return post.type == 'trend_tsunami' ||
      post.type == 'system_trend_tsunami' ||
      post.type == 'system_eclipse';
}

String _formatSignal(String value) {
  return value.replaceAll('_', ' ').toUpperCase();
}

String _timeAgo(DateTime dt) {
  final Duration diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) {
    return 'JUST NOW';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}M AGO';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}H AGO';
  }
  return '${diff.inDays}D AGO';
}

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FeedMode mode = ref.watch(feedModeProvider);
    final Map<String, int> hypeOverrides = ref.watch(feedHypeOverrideProvider);
    final AsyncValue<List<FeedPost>> globalAsync =
        ref.watch(feedStreamProvider);
    final AsyncValue<Set<String>> followingAsync =
        ref.watch(followingIdsProvider);
    final AsyncValue<List<FeedPost>> syndicateAsync =
        ref.watch(syndicateFeedProvider);
    final AsyncValue<List<TrendTsunami>> tsunamiAsync =
        ref.watch(activeTsunamiProvider);
    final PendingAlphaDrop? pendingDrop = ref.watch(pendingAlphaDropProvider);

    final List<TrendTsunami> activeTsunamis = tsunamiAsync.maybeWhen(
      data: (List<TrendTsunami> waves) => waves,
      orElse: () => <TrendTsunami>[],
    );

    List<FeedPost> syndicatePosts = <FeedPost>[];
    if (mode == FeedMode.syndicate) {
      final Set<String> followingIds = followingAsync.maybeWhen(
        data: (Set<String> ids) => ids,
        orElse: () => <String>{},
      );
      final List<FeedPost> rpcBatch = syndicateAsync.maybeWhen(
        data: (List<FeedPost> posts) => posts,
        orElse: () => <FeedPost>[],
      );
      final List<FeedPost> liveFiltered = globalAsync.maybeWhen(
        data: (List<FeedPost> posts) => posts
            .where((FeedPost post) => followingIds.contains(post.playerId))
            .toList(),
        orElse: () => <FeedPost>[],
      );

      final Map<String, FeedPost> seen = <String, FeedPost>{};
      for (final FeedPost post in <FeedPost>[...liveFiltered, ...rpcBatch]) {
        seen.putIfAbsent(post.id, () => post);
      }
      syndicatePosts = seen.values.toList();
    }

    final Widget feedBody = mode == FeedMode.global
        ? _buildGlobal(globalAsync, activeTsunamis, hypeOverrides, ref)
        : _buildSyndicate(
            syndicatePosts,
            syndicateAsync,
            activeTsunamis,
            hypeOverrides,
            ref,
          );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: feedBody),
            Positioned(
              left: 14.0,
              right: 14.0,
              top: 10.0,
              child: _FeedHeader(
                mode: mode,
                onChanged: (FeedMode nextMode) {
                  ref.read(feedModeProvider.notifier).state = nextMode;
                },
              ),
            ),
            if (pendingDrop != null)
              Positioned(
                left: 14.0,
                right: 14.0,
                top: 58.0,
                child: _LiveDropBanner(
                  drop: pendingDrop,
                  onDismissed: () {
                    ref.read(pendingAlphaDropProvider.notifier).state = null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobal(
    AsyncValue<List<FeedPost>> async,
    List<TrendTsunami> trends,
    Map<String, int> overrides,
    WidgetRef ref,
  ) {
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.gold,
          strokeWidth: 1.5,
        ),
      ),
      error: (Object e, StackTrace stackTrace) => const _SignalMessage(
        label: 'SIGNAL LOST',
        accent: AppColors.gold,
      ),
      data: (List<FeedPost> posts) {
        if (posts.isEmpty && trends.isEmpty) {
          return const _SignalMessage(
            label: 'NO SIGNALS YET',
            accent: AppColors.gold,
          );
        }
        return _postPager(posts, trends, overrides, ref);
      },
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    List<TrendTsunami> trends,
    Map<String, int> overrides,
    WidgetRef ref,
  ) {
    if (async.isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.lime,
          strokeWidth: 1.5,
        ),
      );
    }
    if (async.hasError && posts.isEmpty) {
      return const _SignalMessage(
        label: 'SYNDICATE SIGNAL LOST',
        accent: AppColors.lime,
      );
    }
    if (posts.isEmpty && trends.isEmpty) {
      return const _SignalMessage(
        label: 'FOLLOW PLAYERS TO BUILD YOUR SYNDICATE',
        accent: AppColors.lime,
      );
    }
    return _postPager(posts, trends, overrides, ref);
  }

  Widget _postPager(
    List<FeedPost> posts,
    List<TrendTsunami> trends,
    Map<String, int> overrides,
    WidgetRef ref,
  ) {
    final TrendTsunami? crestTrend = trends.isEmpty
        ? null
        : trends.firstWhere(
            (TrendTsunami t) => t.rank == 1,
            orElse: () => trends.first,
          );
    final List<_FeedPageItem> pages = <_FeedPageItem>[
      if (crestTrend != null) _FeedPageItem.trend(crestTrend),
      for (final FeedPost post in posts) _FeedPageItem.post(post),
    ];

    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      allowImplicitScrolling: true,
      itemCount: pages.length,
      itemBuilder: (BuildContext context, int index) {
        final _FeedPageItem item = pages[index];
        if (item.type == _FeedPageType.trend) {
          return _TrendTsunamiCard(trend: item.trend!);
        }

        final FeedPost post = item.post!;
        final int localDelta = overrides[post.id] ?? 0;
        final double displayHype = post.hype + localDelta;

        if (_isDesignerPost(post)) {
          return _AlphaDropCard(
            post: post,
            displayHype: displayHype,
            crestTrend: crestTrend,
            onHype: () => _onHype(ref, post.id),
          );
        }
        if (_isTrendBroadcast(post)) {
          return _TrendBroadcastCard(post: post);
        }
        return _MogulPowerMoveCard(
          post: post,
          displayHype: displayHype,
          onHype: () => _onHype(ref, post.id),
        );
      },
    );
  }

  void _onHype(WidgetRef ref, String postId) {
    unawaited(HapticFeedback.mediumImpact());
    final Map<String, int> current = ref.read(feedHypeOverrideProvider);
    ref.read(feedHypeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    ref.invalidate(hypePostProvider(postId));
    ref.read(hypePostProvider(postId));
  }
}

enum _FeedPageType { trend, post }

class _FeedPageItem {
  const _FeedPageItem.trend(TrendTsunami this.trend)
      : type = _FeedPageType.trend,
        post = null;

  const _FeedPageItem.post(FeedPost this.post)
      : type = _FeedPageType.post,
        trend = null;

  final _FeedPageType type;
  final TrendTsunami? trend;
  final FeedPost? post;
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({
    required this.mode,
    required this.onChanged,
  });

  final FeedMode mode;
  final ValueChanged<FeedMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: AppColors.obsidian.withValues(alpha: 0.72),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.public_outlined, color: AppColors.gold, size: 15.0),
              SizedBox(width: 8.0),
              Text(
                'GLOBAL LIVE',
                style: TextStyle(
                  color: AppColors.ivory,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _ModeToggle(mode: mode, onChanged: onChanged),
      ],
    );
  }
}

class _LiveDropBanner extends StatefulWidget {
  const _LiveDropBanner({
    required this.drop,
    required this.onDismissed,
  });

  final PendingAlphaDrop drop;
  final VoidCallback onDismissed;

  @override
  State<_LiveDropBanner> createState() => _LiveDropBannerState();
}

class _LiveDropBannerState extends State<_LiveDropBanner> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
    _timer = Timer(const Duration(seconds: 7), widget.onDismissed);
  }

  @override
  void didUpdateWidget(covariant _LiveDropBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drop.feedPostId != widget.drop.feedPostId) {
      _timer?.cancel();
      _visible = true;
      _timer = Timer(const Duration(seconds: 7), widget.onDismissed);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: _visible ? 1.0 : 0.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 11.0),
        decoration: BoxDecoration(
          color: AppColors.obsidian.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.58)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.18),
              blurRadius: 20.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.auto_awesome,
              color: AppColors.gold,
              size: 18.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'YOUR ALPHA DROP IS LIVE: ${widget.drop.designName.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ivory,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '${widget.drop.hypeScore.toStringAsFixed(1)} HYPE',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 9.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final FeedMode mode;
  final ValueChanged<FeedMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.ivory.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Pill(
            label: 'GLOBAL',
            selected: mode == FeedMode.global,
            selectedColor: AppColors.gold,
            onTap: () => onChanged(FeedMode.global),
          ),
          _Pill(
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

class _Pill extends StatelessWidget {
  const _Pill({
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedColor : AppColors.grey400,
            fontSize: 8.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AlphaDropCard extends StatelessWidget {
  const _AlphaDropCard({
    required this.post,
    required this.displayHype,
    required this.onHype,
    this.crestTrend,
  });

  final FeedPost post;
  final double displayHype;
  final VoidCallback onHype;
  final TrendTsunami? crestTrend;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String brandName =
        _contentString(content, 'brand_name', 'Unknown Sovereign');
    final String designName =
        _contentString(content, 'design_name', 'Untitled Alpha');
    final double hypeScore = _contentDouble(content, 'hype_score', displayHype);
    final String colorHex =
        _contentString(content, 'fabric_color_hex', 'FAF7F0');
    final Color fabricColor = _hexToColor(colorHex);
    final String rankLabel = _rankLabel(content);
    final String trendLabel = _trendLabel(content, crestTrend);
    final _VexFeedReview? vexReview = _vexReview(content);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: onHype,
      onHorizontalDragEnd: _handleHorizontalGesture,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 58.0, 10.0, 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.obsidianCard,
              border: Border.all(
                color: hypeScore >= 80.0
                    ? AppColors.gold.withValues(alpha: 0.72)
                    : AppColors.ivory.withValues(alpha: 0.12),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _GarmentStage(
                  fabricColor: fabricColor,
                  hypeScore: hypeScore,
                  tarnished: hypeScore < 40.0,
                ),
                Positioned(
                  left: 18.0,
                  right: 18.0,
                  top: 18.0,
                  child: _TopSignalRow(
                    leftLabel: '@$brandName',
                    rightLabel: rankLabel,
                    accent: AppColors.gold,
                  ),
                ),
                Positioned(
                  left: 14.0,
                  right: 14.0,
                  bottom: 14.0,
                  child: _AlphaDropOverlay(
                    brandName: brandName,
                    designName: designName,
                    hypeScore: hypeScore,
                    displayHype: displayHype,
                    likes: post.likes,
                    trendLabel: trendLabel,
                    vexReview: vexReview,
                    onHype: onHype,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _rankLabel(Map<String, dynamic> content) {
    final Object? value = content['brand_rank'] ?? content['rank'];
    if (value is num) {
      return 'RANK ${value.toInt()}';
    }
    if (value is String && value.trim().isNotEmpty) {
      return 'RANK ${value.toUpperCase()}';
    }
    return 'RANK --';
  }

  static String _trendLabel(
    Map<String, dynamic> content,
    TrendTsunami? crestTrend,
  ) {
    final String explicitTrend = _contentString(content, 'trend_alignment', '');
    if (explicitTrend.isNotEmpty) {
      return explicitTrend.toUpperCase();
    }
    final String trendTag = _contentString(content, 'trend_tag', '');
    if (trendTag.isNotEmpty) {
      return _formatSignal(trendTag);
    }
    final Object? rawTags = content['trend_tags'] ?? content['style_tags'];
    if (rawTags is List<Object?>) {
      final List<String> tags = rawTags
          .whereType<String>()
          .where((String tag) => tag.trim().isNotEmpty)
          .take(2)
          .map(_formatSignal)
          .toList();
      if (tags.isNotEmpty) {
        return tags.join(' / ');
      }
    }
    if (crestTrend != null) {
      return 'WATCHING ${_formatSignal(crestTrend.tagName)}';
    }
    return 'TREND READ PENDING';
  }

  static _VexFeedReview? _vexReview(Map<String, dynamic> content) {
    final Object? nested = content['vex_review'];
    final Map<String, dynamic>? review =
        nested is Map<String, dynamic> ? nested : null;
    final String? headline = _optionalString(content, 'vex_headline') ??
        _optionalString(review, 'headline');
    final String? quote = _optionalString(content, 'vex_quote') ??
        _optionalString(content, 'review_text') ??
        _optionalString(content, 'caption') ??
        _optionalString(review, 'body');
    final String? verdict = _optionalString(content, 'vex_verdict') ??
        _optionalString(content, 'verdict') ??
        _optionalString(review, 'verdict');

    if (headline == null && quote == null && verdict == null) {
      return null;
    }
    return _VexFeedReview(
      headline: headline,
      quote: quote,
      verdict: verdict,
    );
  }
}

String? _optionalString(Map<String, dynamic>? content, String key) {
  final Object? value = content?[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

class _VexFeedReview {
  const _VexFeedReview({
    required this.headline,
    required this.quote,
    required this.verdict,
  });

  final String? headline;
  final String? quote;
  final String? verdict;
}

class _AlphaDropOverlay extends StatelessWidget {
  const _AlphaDropOverlay({
    required this.brandName,
    required this.designName,
    required this.hypeScore,
    required this.displayHype,
    required this.likes,
    required this.trendLabel,
    required this.vexReview,
    required this.onHype,
  });

  final String brandName;
  final String designName;
  final double hypeScore;
  final double displayHype;
  final int likes;
  final String trendLabel;
  final _VexFeedReview? vexReview;
  final VoidCallback onHype;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gold
                .withValues(alpha: hypeScore >= 80.0 ? 0.25 : 0.08),
            blurRadius: hypeScore >= 80.0 ? 28.0 : 14.0,
            spreadRadius: hypeScore >= 80.0 ? 2.0 : 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ivory,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        designName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ivory.withValues(alpha: 0.72),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.0),
                _HypeScoreBadge(score: hypeScore),
              ],
            ),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: <Widget>[
                const _MiniSignal(label: 'ALPHA DROP', color: AppColors.gold),
                _MiniSignal(label: trendLabel, color: AppColors.ivory),
              ],
            ),
            if (vexReview != null) ...<Widget>[
              const SizedBox(height: 10.0),
              _VexReviewOverlay(review: vexReview!, hypeScore: hypeScore),
            ],
            const SizedBox(height: 12.0),
            _ReactionRail(
              displayHype: displayHype,
              likes: likes,
              accent: AppColors.gold,
              onHype: onHype,
            ),
          ],
        ),
      ),
    );
  }
}

class _VexReviewOverlay extends StatelessWidget {
  const _VexReviewOverlay({
    required this.review,
    required this.hypeScore,
  });

  final _VexFeedReview review;
  final double hypeScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _VexStamp(score: hypeScore),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (review.verdict != null) ...<Widget>[
                  Text(
                    'VEX ${review.verdict!.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.obsidian.withValues(alpha: 0.62),
                      fontSize: 8.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                ],
                if (review.headline != null)
                  Text(
                    review.headline!.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.obsidian,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w900,
                      height: 1.14,
                    ),
                  ),
                if (review.quote != null) ...<Widget>[
                  if (review.headline != null) const SizedBox(height: 5.0),
                  Text(
                    '"${review.quote!}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.obsidian.withValues(alpha: 0.76),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      height: 1.22,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VexStamp extends StatelessWidget {
  const _VexStamp({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final Color sealColor =
        score >= 80.0 ? AppColors.goldDark : AppColors.obsidian;
    return Container(
      width: 42.0,
      height: 42.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: sealColor, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Text(
        'VEX',
        style: TextStyle(
          color: sealColor,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MogulPowerMoveCard extends StatelessWidget {
  const _MogulPowerMoveCard({
    required this.post,
    required this.displayHype,
    required this.onHype,
  });

  final FeedPost post;
  final double displayHype;
  final VoidCallback onHype;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String brandName =
        _contentString(content, 'brand_name', 'Unknown Sovereign');
    final String city = _contentString(content, 'city', 'unclaimed');
    final String storeType = _contentString(content, 'store_type', 'retail');
    final int newTier = _contentInt(content, 'new_tier', 1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: onHype,
      onHorizontalDragEnd: _handleHorizontalGesture,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 58.0, 10.0, 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.obsidian,
              border: Border.all(color: AppColors.lime.withValues(alpha: 0.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const _MarketTheatreStage(),
                Positioned(
                  left: 18.0,
                  right: 18.0,
                  top: 18.0,
                  child: _TopSignalRow(
                    leftLabel: '@$brandName',
                    rightLabel: post.createdAt == null
                        ? 'MOGUL FLEX'
                        : _timeAgo(post.createdAt!),
                    accent: AppColors.lime,
                  ),
                ),
                Positioned(
                  left: 18.0,
                  right: 18.0,
                  bottom: 18.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'LOCKED THE BLOCK',
                        style: TextStyle(
                          color: AppColors.ivory,
                          fontSize: 35.0,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          _TickerChip(
                            label: _formatSignal(city),
                            color: AppColors.lime,
                          ),
                          _TickerChip(
                            label: _formatSignal(storeType),
                            color: AppColors.gold,
                          ),
                          _TickerChip(
                            label: 'TIER $newTier',
                            color: AppColors.ivory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      const _FinancialVerdict(
                        lineOne: 'Public dominance logged.',
                        lineTwo: 'The street now knows who can scale.',
                      ),
                      const SizedBox(height: 14.0),
                      _ReactionRail(
                        displayHype: displayHype,
                        likes: post.likes,
                        accent: AppColors.lime,
                        onHype: onHype,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendTsunamiCard extends StatelessWidget {
  const _TrendTsunamiCard({required this.trend});

  final TrendTsunami trend;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleHorizontalGesture,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 58.0, 10.0, 10.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.obsidian,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _TrendWaveStage(tagName: trend.tagName),
                Positioned(
                  left: 18.0,
                  right: 18.0,
                  top: 18.0,
                  child: _TopSignalRow(
                    leftLabel: 'LIVE SERVER BROADCAST',
                    rightLabel: trend.timeRemainingFormatted,
                    accent: AppColors.gold,
                  ),
                ),
                Positioned(
                  left: 18.0,
                  right: 18.0,
                  bottom: 22.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'BREAKING TREND TSUNAMI',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.6,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _formatSignal(trend.tagName),
                        style: const TextStyle(
                          color: AppColors.ivory,
                          fontSize: 42.0,
                          fontWeight: FontWeight.w900,
                          height: 0.96,
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: <Widget>[
                          _TickerChip(
                            label: '${trend.multiplierDisplay} HYPE WINDOW',
                            color: AppColors.gold,
                          ),
                          const _TickerChip(
                            label: '48H META SHIFT',
                            color: AppColors.ivory,
                          ),
                          _TickerChip(
                            label: 'RANK ${trend.rank}',
                            color: AppColors.lime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const _TrendBriefing(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendBroadcastCard extends StatelessWidget {
  const _TrendBroadcastCard({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String name = _contentString(content, 'name', 'Global Market Signal');
    final String description = _contentString(
      content,
      'description',
      'A live server event is changing visibility across the feed.',
    );
    final double multiplier = _contentDouble(content, 'buff_multiplier', 1.0);
    final int durationMinutes = _contentInt(content, 'duration_minutes', 60);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 58.0, 10.0, 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.obsidian,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _TrendWaveStage(tagName: name),
              Positioned(
                left: 18.0,
                right: 18.0,
                top: 18.0,
                child: _TopSignalRow(
                  leftLabel: 'SYSTEM EVENT',
                  rightLabel: post.createdAt == null
                      ? 'LIVE'
                      : _timeAgo(post.createdAt!),
                  accent: AppColors.gold,
                ),
              ),
              Positioned(
                left: 18.0,
                right: 18.0,
                bottom: 22.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _formatSignal(name),
                      style: const TextStyle(
                        color: AppColors.ivory,
                        fontSize: 38.0,
                        fontWeight: FontWeight.w900,
                        height: 0.98,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.72),
                        fontSize: 14.0,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: <Widget>[
                        _TickerChip(
                          label: '${multiplier.toStringAsFixed(1)}X',
                          color: AppColors.gold,
                        ),
                        _TickerChip(
                          label: '${durationMinutes}MIN',
                          color: AppColors.ivory,
                        ),
                      ],
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

class _TopSignalRow extends StatelessWidget {
  const _TopSignalRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.accent,
  });

  final String leftLabel;
  final String rightLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            leftLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ivory,
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        _MiniSignal(
          label: rightLabel,
          color: accent,
        ),
      ],
    );
  }
}

class _HypeScoreBadge extends StatelessWidget {
  const _HypeScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.goldLight,
              fontSize: 20.0,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3.0),
          const Text(
            'HYPE',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 8.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionRail extends StatelessWidget {
  const _ReactionRail({
    required this.displayHype,
    required this.likes,
    required this.accent,
    required this.onHype,
  });

  final double displayHype;
  final int likes;
  final Color accent;
  final VoidCallback onHype;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7.0,
      runSpacing: 7.0,
      children: <Widget>[
        _FeedAction(
          icon: Icons.local_fire_department_outlined,
          label: '${displayHype.toStringAsFixed(0)} HYPE',
          accent: accent,
          onTap: onHype,
        ),
        const _FeedAction(
          icon: Icons.comment_outlined,
          label: 'COMMENT',
          accent: AppColors.ivory,
          enabled: false,
        ),
        const _FeedAction(
          icon: Icons.auto_fix_high_outlined,
          label: 'REMIX',
          accent: AppColors.ivory,
          enabled: false,
        ),
        const _FeedAction(
          icon: Icons.call_split_outlined,
          label: 'STITCH',
          accent: AppColors.ivory,
          enabled: false,
        ),
        const _FeedAction(
          icon: Icons.bookmark_border,
          label: 'SAVE',
          accent: AppColors.ivory,
          enabled: false,
        ),
        _FeedAction(
          icon: Icons.favorite_border,
          label: '$likes LIKE',
          accent: AppColors.ivory,
          enabled: false,
        ),
        const _FeedAction(
          icon: Icons.mail_outline,
          label: 'DM',
          accent: AppColors.ivory,
          enabled: false,
        ),
        const _FeedAction(
          icon: Icons.handshake_outlined,
          label: 'COLLAB',
          accent: AppColors.ivory,
          enabled: false,
        ),
      ],
    );
  }
}

class _FeedAction extends StatelessWidget {
  const _FeedAction({
    required this.icon,
    required this.label,
    required this.accent,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        enabled ? accent : AppColors.ivory.withValues(alpha: 0.32);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: enabled
              ? accent.withValues(alpha: 0.12)
              : AppColors.ivory.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 14.0),
            const SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSignal extends StatelessWidget {
  const _MiniSignal({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 8.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  const _TickerChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _FinancialVerdict extends StatelessWidget {
  const _FinancialVerdict({
    required this.lineOne,
    required this.lineTwo,
  });

  final String lineOne;
  final String lineTwo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            lineOne.toUpperCase(),
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: 13.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            lineTwo,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.68),
              fontSize: 12.0,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBriefing extends StatelessWidget {
  const _TrendBriefing();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.bolt_outlined,
            color: AppColors.gold,
            size: 20.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'Alignment bonuses are live. Designers chasing the wave move '
              'first; Moguls can time the market before the room catches up.',
              style: TextStyle(
                color: AppColors.ivory.withValues(alpha: 0.72),
                fontSize: 13.0,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalMessage extends StatelessWidget {
  const _SignalMessage({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.ivory.withValues(alpha: 0.45),
            fontSize: 11.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _GarmentStage extends StatelessWidget {
  const _GarmentStage({
    required this.fabricColor,
    required this.hypeScore,
    required this.tarnished,
  });

  final Color fabricColor;
  final double hypeScore;
  final bool tarnished;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GarmentStagePainter(
        fabricColor: fabricColor,
        hypeScore: hypeScore,
        tarnished: tarnished,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.obsidian.withValues(alpha: 0.04),
              AppColors.obsidian.withValues(alpha: 0.18),
              AppColors.obsidian.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarmentStagePainter extends CustomPainter {
  const _GarmentStagePainter({
    required this.fabricColor,
    required this.hypeScore,
    required this.tarnished,
  });

  final Color fabricColor;
  final double hypeScore;
  final bool tarnished;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Paint background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.2),
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, background);

    final Offset center = Offset(size.width / 2.0, size.height * 0.42);
    final double width = math.min(size.width * 0.58, 260.0);
    final double height = math.min(size.height * 0.58, 420.0);
    final Path garment = Path()
      ..moveTo(center.dx - width * 0.2, center.dy - height * 0.42)
      ..cubicTo(
        center.dx - width * 0.52,
        center.dy - height * 0.32,
        center.dx - width * 0.46,
        center.dy - height * 0.08,
        center.dx - width * 0.35,
        center.dy + height * 0.35,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + height * 0.5,
        center.dx + width * 0.35,
        center.dy + height * 0.35,
      )
      ..cubicTo(
        center.dx + width * 0.46,
        center.dy - height * 0.08,
        center.dx + width * 0.52,
        center.dy - height * 0.32,
        center.dx + width * 0.2,
        center.dy - height * 0.42,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy - height * 0.28,
        center.dx - width * 0.2,
        center.dy - height * 0.42,
      )
      ..close();

    final Paint glow = Paint()
      ..color = AppColors.gold.withValues(
        alpha: hypeScore >= 80.0 ? 0.28 : 0.08,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30.0);
    canvas.drawPath(garment.shift(const Offset(0.0, 10.0)), glow);

    final Paint fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.95),
          Color.lerp(fabricColor, AppColors.obsidian, 0.35) ?? fabricColor,
          fabricColor.withValues(alpha: 0.8),
        ],
      ).createShader(garment.getBounds());
    canvas.drawPath(garment, fabric);

    final Paint edge = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(garment, edge);

    final Paint shimmer = Paint()
      ..color = AppColors.ivory.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;
    for (int index = 0; index < 11; index += 1) {
      final double x = center.dx - width * 0.28 + index * width * 0.056;
      canvas.drawLine(
        Offset(x, center.dy - height * 0.28),
        Offset(x + width * 0.08, center.dy + height * 0.32),
        shimmer,
      );
    }

    final Paint particlePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;
    for (int index = 0; index < 22; index += 1) {
      final double angle = index * 0.82;
      final double radius = width * (0.36 + (index % 5) * 0.035);
      final Offset dot = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle * 1.4) * height * 0.32,
      );
      canvas.drawCircle(dot, index.isEven ? 1.7 : 1.0, particlePaint);
    }

    if (tarnished) {
      final Paint crackPaint = Paint()
        ..color = AppColors.obsidian.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      for (int index = 0; index < 4; index += 1) {
        final double startX = center.dx - width * 0.22 + index * width * 0.14;
        final Path crack = Path()
          ..moveTo(startX, center.dy - height * 0.16)
          ..lineTo(startX + width * 0.06, center.dy - height * 0.05)
          ..lineTo(startX + width * 0.02, center.dy + height * 0.05)
          ..lineTo(startX + width * 0.1, center.dy + height * 0.18);
        canvas.drawPath(crack, crackPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GarmentStagePainter oldDelegate) {
    return oldDelegate.fabricColor != fabricColor ||
        oldDelegate.hypeScore != hypeScore ||
        oldDelegate.tarnished != tarnished;
  }
}

class _MarketTheatreStage extends StatelessWidget {
  const _MarketTheatreStage();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _MarketTheatrePainter(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.lime.withValues(alpha: 0.09),
              AppColors.obsidian,
              AppColors.obsidian,
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketTheatrePainter extends CustomPainter {
  const _MarketTheatrePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;
    for (double x = -size.width; x < size.width * 1.5; x += 36.0) {
      canvas.drawLine(
        Offset(x, 0.0),
        Offset(x + size.width, size.height),
        gridPaint,
      );
    }
    for (double y = 80.0; y < size.height; y += 54.0) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), gridPaint);
    }

    final Paint chartPaint = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final Path chart = Path()..moveTo(0.0, size.height * 0.62);
    for (int index = 1; index <= 9; index += 1) {
      final double x = size.width * index / 9.0;
      final double y = size.height * (0.66 - math.sin(index * 0.9) * 0.1) -
          index * size.height * 0.016;
      chart.lineTo(x, y);
    }
    canvas.drawPath(chart, chartPaint);

    final Paint blockPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    for (int index = 0; index < 7; index += 1) {
      final double width = 28.0 + index * 5.0;
      final Rect rect = Rect.fromLTWH(
        size.width * (0.12 + index * 0.1),
        size.height * (0.24 + (index % 3) * 0.075),
        width,
        width * 1.4,
      );
      canvas.drawRect(rect, blockPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarketTheatrePainter oldDelegate) => false;
}

class _TrendWaveStage extends StatelessWidget {
  const _TrendWaveStage({required this.tagName});

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendWavePainter(seed: tagName.hashCode),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: <Color>[
              AppColors.gold.withValues(alpha: 0.24),
              AppColors.obsidianSurface,
              AppColors.obsidian,
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendWavePainter extends CustomPainter {
  const _TrendWavePainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.gold.withValues(alpha: 0.22);
    for (int row = 0; row < 14; row += 1) {
      final double yBase = size.height * (0.12 + row * 0.055);
      final Path wave = Path()..moveTo(0.0, yBase);
      for (double x = 0.0; x <= size.width; x += 18.0) {
        final double y = yBase +
            math.sin((x + seed + row * 14.0) / 34.0) * (10.0 + row * 0.2);
        wave.lineTo(x, y);
      }
      canvas.drawPath(wave, wavePaint);
    }

    final Paint pulsePaint = Paint()
      ..color = AppColors.lime.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (int index = 0; index < 5; index += 1) {
      final Offset center = Offset(
        size.width * (0.18 + index * 0.17),
        size.height * (0.26 + (index % 2) * 0.16),
      );
      canvas.drawCircle(center, 38.0 + index * 14.0, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendWavePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

void _handleHorizontalGesture(DragEndDetails details) {
  final double velocity = details.primaryVelocity ?? 0.0;
  if (velocity.abs() > 220.0) {
    unawaited(HapticFeedback.selectionClick());
  }
}
