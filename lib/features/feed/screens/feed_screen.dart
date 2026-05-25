// GDD §6.1 — Global Live Feed: real-time posts, social flex (Phase 6 + 7).
// Phase 7: GLOBAL | SYNDICATE toggle.
//   GLOBAL: Realtime .stream() (all players).
//   SYNDICATE: one-shot get_syndicate_feed RPC (initial batch) merged with
//   live global stream filtered by followingIdsProvider Set<String>.
//   Strict id-based deduplication prevents duplicates on RPC/stream race.
// Two card types: 'design_flex' (Gold) | 'mogul_flex' (Lime).
// All JSONB content values use safe ?? fallbacks — Realtime can deliver
// partial payloads; UI must never null-crash.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/feed_post.dart';
import '../../trends/models/trend_tsunami.dart';
import '../../trends/providers/trend_provider.dart';
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

    // Build deduplicated SYNDICATE list: RPC batch + live filtered stream.
    // Deduplication: LinkedHashMap insertion order preserves newest-first from
    // RPC; live stream posts are prepended only if id not already present.
    List<FeedPost> syndicatePosts = <FeedPost>[];
    if (mode == FeedMode.syndicate) {
      final Set<String> followingIds = followingAsync.maybeWhen(
          data: (Set<String> s) => s, orElse: () => <String>{});
      final List<FeedPost> rpcBatch = syndicateAsync.maybeWhen(
          data: (List<FeedPost> p) => p, orElse: () => <FeedPost>[]);
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
                  ? _buildGlobal(globalAsync, hyypeOverrides, ref)
                  : _buildSyndicate(
                      syndicatePosts,
                      activeAsync,
                      hyypeOverrides,
                      ref,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FeedPost> _buildSyndicatePosts(
    AsyncValue<List<FeedPost>> globalAsync,
    AsyncValue<Set<String>> followingAsync,
    AsyncValue<List<FeedPost>> syndicateAsync,
  ) {
    final Set<String> followingIds = followingAsync.maybeWhen(
      data: (Set<String> value) => value,
      orElse: () => <String>{},
    );
    final List<FeedPost> rpcBatch = syndicateAsync.maybeWhen(
      data: (List<FeedPost> value) => value,
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
    return seen.values.toList();
  }

  Widget _buildGlobal(
    AsyncValue<List<FeedPost>> async,
    List<TrendTsunami> trends,
    Map<String, int> overrides,
    List<TrendTsunami> waves,
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
          : _postList(posts, overrides, ref),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    List<TrendTsunami> trends,
    Map<String, int> overrides,
    List<TrendTsunami> waves,
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
    return _postList(posts, overrides, ref);
  }

  Widget _postList(
    List<FeedPost> posts,
    Map<String, int> overrides,
    WidgetRef ref,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (BuildContext context, int index) {
        final FeedPost post = posts[index];
        final int localDelta = overrides[post.id] ?? 0;
        final double displayHype = post.hype + localDelta;

        if (post.type == 'design_flex') {
          return _DesignFlexCard(
            post: post,
            displayHype: displayHype,
            onHype: () => _onHype(ref, post.id),
          );
        }
        if (post.type == 'system_eclipse') {
          return _SystemEclipseCard(post: post);
        }
        return _MogulFlexCard(
          post: post,
          displayHype: displayHype,
          onHype: () => _onHype(ref, post.id),
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

  void _onHype(WidgetRef ref, String postId) {
    final Map<String, int> current = ref.read(feedHypeOverrideProvider);
    ref.read(feedHypeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    ref.read(hypePostProvider(postId));
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
          const Text(
            'GLOBAL FEED',
            style: TextStyle(
              color: AppColors.ivory,
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
            ),
          ),
          const Spacer(),
          _ModeToggle(mode: mode, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _FeedPager extends StatelessWidget {
  const _FeedPager({
    required this.items,
    required this.overrides,
    required this.actionBuilder,
    this.emptyLabel = 'NO SIGNALS YET\nBE THE FIRST TO FLEX',
  });

  final List<_FeedItem> items;
  final Map<String, int> overrides;
  final _PostActionCallbacks Function(BuildContext context, FeedPost post)
      actionBuilder;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedColor : AppColors.grey600,
            fontSize: 8.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
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
    required this.onHype,
  });

  final FeedPost post;
  final double displayHype;
  final VoidCallback onHype;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> c = post.content;
    final String brandName =
        (c['brand_name'] as String?) ?? 'Unknown Sovereign';
    final String designName = (c['design_name'] as String?) ?? 'UNTITLED ALPHA';
    final double hyypeScore = ((c['hype_score'] as num?)?.toDouble()) ?? 0.0;
    final String colorHex = (c['fabric_color_hex'] as String?) ?? 'FAF7F0';

    return _FeedCard(
      accentColor: AppColors.gold,
      typeLabel: 'ALPHA DROP',
      brandName: brandName,
      bodyLine: '$designName — ${hyypeScore.toStringAsFixed(1)} HYPE',
      colorDot: _hexToColor(colorHex),
      displayHype: displayHype,
      createdAt: post.createdAt,
      onHype: onHype,
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
    required this.onHype,
  });

  final FeedPost post;
  final double displayHype;
  final VoidCallback onHype;

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
      createdAt: post.createdAt,
      onHype: onHype,
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
    required this.onHype,
    this.colorDot,
    this.createdAt,
  });

  final Color accentColor;
  final String typeLabel;
  final String brandName;
  final String bodyLine;
  final double displayHype;
  final VoidCallback onHype;
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

          // Hype row
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
              GestureDetector(
                onTap: onHype,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: accentColor.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Text(
                    'HYPE',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
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
                  label: scope, color: AppColors.ivory.withValues(alpha: 0.4)),
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
