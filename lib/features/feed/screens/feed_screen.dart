// GDD §6.1 — Global Live Feed: full-screen fashion social heartbeat.
// Portrait-first PageView feed: Alpha drops, market events, and trend waves.
// Existing Riverpod/Supabase data flow is preserved; no new backend writes.

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

class _FeedComment {
  const _FeedComment({
    required this.body,
    required this.createdAt,
  });

  final String body;
  final DateTime? createdAt;
}

final StreamProviderFamily<List<_FeedComment>, String> _feedCommentsProvider =
    StreamProvider.family<List<_FeedComment>, String>(
  (Ref<AsyncValue<List<_FeedComment>>> ref, String postId) {
    return SupabaseService.client
        .from(SupabaseConstants.tableFeedComments)
        .stream(primaryKey: <String>['id'])
        .eq('post_id', postId)
        .map((List<Map<String, dynamic>> rows) {
          final List<_FeedComment> comments = rows
              .map(
                (Map<String, dynamic> row) => _FeedComment(
                  body: row['body'] as String? ?? '',
                  createdAt: DateTime.tryParse(
                    row['created_at'] as String? ?? '',
                  ),
                ),
              )
              .toList();
          comments.sort(
            (_FeedComment a, _FeedComment b) => (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0)),
          );
          return comments;
        });
  },
);

final FutureProviderFamily<bool, String> _postSavedProvider =
    FutureProvider.family<bool, String>(
  (Ref<AsyncValue<bool>> ref, String postId) async {
    final String uid = ref.watch(activeUidProvider);
    if (uid.isEmpty) return false;

    final Map<String, dynamic>? existing = await SupabaseService.client
        .from(SupabaseConstants.tablePostReactions)
        .select()
        .eq('post_id', postId)
        .eq('player_id', uid)
        .eq('reaction_type', 'save')
        .maybeSingle();

    return existing != null;
  },
);

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
    final AsyncValue<List<FeedPost>> globalAsync =
        ref.watch(feedStreamProvider);
    final AsyncValue<Set<String>> followingAsync =
        ref.watch(followingIdsProvider);
    final AsyncValue<List<FeedPost>> syndicateAsync =
        ref.watch(syndicateFeedProvider);
    final AsyncValue<List<TrendTsunami>> tsunamiAsync =
        ref.watch(activeTsunamiProvider);

    final List<FeedPost> syndicatePosts =
        _buildSyndicatePosts(globalAsync, followingAsync, syndicateAsync);
    final AsyncValue<List<FeedPost>> activeAsync =
        mode == FeedMode.global ? globalAsync : syndicateAsync;
    final List<TrendTsunami> waves = tsunamiAsync.maybeWhen(
      data: (List<TrendTsunami> value) => value,
      orElse: () => <TrendTsunami>[],
    );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _FeedHeader(
              mode: mode,
              onChanged: (FeedMode value) {
                HapticFeedback.selectionClick();
                ref.read(feedModeProvider.notifier).state = value;
              },
            ),
            Expanded(
              child: mode == FeedMode.global
                  ? _buildGlobal(globalAsync, hypeOverrides, waves, ref)
                  : _buildSyndicate(
                      syndicatePosts,
                      activeAsync,
                      hypeOverrides,
                      waves,
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
    Map<String, int> overrides,
    List<TrendTsunami> waves,
    WidgetRef ref,
  ) {
    return async.when(
      loading: () => const _FeedLoading(accentColor: AppColors.gold),
      error: (Object e, _) => const _FeedMessage(label: 'SIGNAL LOST'),
      data: (List<FeedPost> posts) => _FeedPager(
        items: _buildItems(posts, waves),
        overrides: overrides,
        actionBuilder: (BuildContext context, FeedPost post) =>
            _buildActions(context, ref, post),
      ),
    );
  }

  Widget _buildSyndicate(
    List<FeedPost> posts,
    AsyncValue<List<FeedPost>> async,
    Map<String, int> overrides,
    List<TrendTsunami> waves,
    WidgetRef ref,
  ) {
    if (async.isLoading && posts.isEmpty && waves.isEmpty) {
      return const _FeedLoading(accentColor: AppColors.lime);
    }
    if (async.hasError && posts.isEmpty && waves.isEmpty) {
      return const _FeedMessage(label: 'SYNDICATE SIGNAL LOST');
    }

    return _FeedPager(
      items: _buildItems(posts, waves),
      overrides: overrides,
      actionBuilder: (BuildContext context, FeedPost post) =>
          _buildActions(context, ref, post),
      emptyLabel: 'FOLLOW PLAYERS TO\nBUILD YOUR SYNDICATE',
    );
  }

  List<_FeedItem> _buildItems(
    List<FeedPost> posts,
    List<TrendTsunami> waves,
  ) {
    final List<_FeedItem> items = <_FeedItem>[];
    final TrendTsunami? crest = waves.crestTag ?? waves.activeOnly.firstOrNull;
    if (crest != null) {
      items.add(_TrendFeedItem(crest));
    }
    items.addAll(posts.map(_PostFeedItem.new));
    return items;
  }

  void _onHype(WidgetRef ref, String postId) {
    HapticFeedback.lightImpact();
    final Map<String, int> current = ref.read(feedHypeOverrideProvider);
    ref.read(feedHypeOverrideProvider.notifier).state = <String, int>{
      ...current,
      postId: (current[postId] ?? 0) + 1,
    };
    ref.read(hypePostProvider(postId));
  }

  _PostActionCallbacks _buildActions(
    BuildContext context,
    WidgetRef ref,
    FeedPost post,
  ) {
    return _PostActionCallbacks(
      onHype: () => _onHype(ref, post.id),
      onSave: () => _toggleSave(context, ref, post),
      onComment: () => _openCommentThread(context, ref, post),
      onRemix: () => _createDerivativeDraft(context, ref, post, 'remix'),
      onStitch: () => _createDerivativeDraft(context, ref, post, 'stitch'),
      onDm: () => _openTextComposer(
        context: context,
        title: 'DIRECT MESSAGE',
        hint: 'Send a private reaction.',
        submitLabel: 'SEND DM',
        onSubmit: (String body) => _sendDirectMessage(ref, post, body),
      ),
      onCollab: () => _openTextComposer(
        context: context,
        title: 'COLLAB REQUEST',
        hint: 'Pitch the capsule.',
        submitLabel: 'SEND REQUEST',
        onSubmit: (String body) => _sendCollabRequest(ref, post, body),
      ),
    );
  }

  Future<void> _toggleSave(
    BuildContext context,
    WidgetRef ref,
    FeedPost post,
  ) async {
    final String uid = ref.read(activeUidProvider);
    if (uid.isEmpty) {
      _showFeedSnack(context, 'Sign in before saving.');
      return;
    }

    try {
      final Map<String, dynamic>? existing = await SupabaseService.client
          .from(SupabaseConstants.tablePostReactions)
          .select()
          .eq('post_id', post.id)
          .eq('player_id', uid)
          .eq('reaction_type', 'save')
          .maybeSingle();

      if (existing == null) {
        await SupabaseService.client
            .from(SupabaseConstants.tablePostReactions)
            .insert(<String, dynamic>{
          'post_id': post.id,
          'player_id': uid,
          'reaction_type': 'save',
        });
        ref.invalidate(_postSavedProvider(post.id));
        if (context.mounted) _showFeedSnack(context, 'Saved to lookbook.');
      } else {
        await SupabaseService.client
            .from(SupabaseConstants.tablePostReactions)
            .delete()
            .eq('post_id', post.id)
            .eq('player_id', uid)
            .eq('reaction_type', 'save');
        ref.invalidate(_postSavedProvider(post.id));
        if (context.mounted) _showFeedSnack(context, 'Removed from lookbook.');
      }
      HapticFeedback.selectionClick();
    } catch (e) {
      if (context.mounted) _showFeedSnack(context, 'Save failed: $e');
    }
  }

  Future<void> _submitComment(
    WidgetRef ref,
    FeedPost post,
    String body,
  ) async {
    final String uid = ref.read(activeUidProvider);
    if (uid.isEmpty) throw StateError('Not authenticated');

    await SupabaseService.client
        .from(SupabaseConstants.tableFeedComments)
        .insert(<String, dynamic>{
      'post_id': post.id,
      'player_id': uid,
      'body': body,
    });
    ref.invalidate(_feedCommentsProvider(post.id));
  }

  Future<void> _createDerivativeDraft(
    BuildContext context,
    WidgetRef ref,
    FeedPost post,
    String kind,
  ) async {
    final String uid = ref.read(activeUidProvider);
    if (uid.isEmpty) {
      _showFeedSnack(context, 'Sign in before creating.');
      return;
    }

    final Map<String, dynamic> content = post.content;
    final String sourceName =
        (content['design_name'] as String?) ?? 'UNTITLED ALPHA';
    final String rawDraftName =
        '${kind == 'remix' ? 'REMIX' : 'STITCH'}: $sourceName';
    final String draftName =
        rawDraftName.length > 80 ? rawDraftName.substring(0, 80) : rawDraftName;
    final Object? rawSourceDesignId = content['design_id'];
    final String? sourceDesignId =
        rawSourceDesignId is String ? rawSourceDesignId : null;
    final Map<String, dynamic> fabricData = <String, dynamic>{
      'tier': 'standard_cotton',
      'source_post_id': post.id,
      'source_design_id': sourceDesignId,
      'source_kind': kind,
      'source_tags': _styleTags(content),
      'fabric_color_hex': content['fabric_color_hex'],
    };

    try {
      final Map<String, dynamic> design = await SupabaseService.client
          .from(SupabaseConstants.tableDesigns)
          .insert(<String, dynamic>{
            'player_id': uid,
            'name': draftName,
            'session_type': 'quick_sketch',
            'status': 'draft',
            'is_alpha': false,
            'fabric_data': fabricData,
          })
          .select('id')
          .single();

      await SupabaseService.client
          .from(SupabaseConstants.tableFeedDerivatives)
          .insert(<String, dynamic>{
        'source_post_id': post.id,
        'source_design_id': sourceDesignId,
        'derivative_design_id': design['id'],
        'player_id': uid,
        'kind': kind,
      });

      if (context.mounted) {
        _showFeedSnack(
          context,
          kind == 'remix'
              ? 'Remix draft created in Atelier.'
              : 'Stitch draft created in Atelier.',
        );
      }
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (context.mounted) _showFeedSnack(context, 'Draft failed: $e');
    }
  }

  Future<void> _sendDirectMessage(
    WidgetRef ref,
    FeedPost post,
    String body,
  ) async {
    final String uid = ref.read(activeUidProvider);
    if (uid.isEmpty) throw StateError('Not authenticated');

    await SupabaseService.client
        .from(SupabaseConstants.tableDirectMessages)
        .insert(<String, dynamic>{
      'post_id': post.id,
      'sender_id': uid,
      'recipient_id': post.playerId,
      'body': body,
    });
  }

  Future<void> _sendCollabRequest(
    WidgetRef ref,
    FeedPost post,
    String body,
  ) async {
    final String uid = ref.read(activeUidProvider);
    if (uid.isEmpty) throw StateError('Not authenticated');

    await SupabaseService.client
        .from(SupabaseConstants.tableCollabRequests)
        .insert(<String, dynamic>{
      'post_id': post.id,
      'requester_id': uid,
      'recipient_id': post.playerId,
      'message': body,
    });
  }

  Future<void> _openCommentThread(
    BuildContext context,
    WidgetRef ref,
    FeedPost post,
  ) async {
    final TextEditingController controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.obsidianCard,
      builder: (BuildContext sheetContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final AsyncValue<List<_FeedComment>> comments =
                ref.watch(_feedCommentsProvider(post.id));

            return Padding(
              padding: EdgeInsets.only(
                left: 18.0,
                right: 18.0,
                top: 18.0,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 18.0,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'COMMENTS',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Expanded(
                      child: comments.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 2.0,
                          ),
                        ),
                        error: (Object e, _) => Center(
                          child: Text(
                            'Comments failed: $e',
                            style: const TextStyle(color: AppColors.danger),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        data: (List<_FeedComment> rows) => rows.isEmpty
                            ? Center(
                                child: Text(
                                  'NO COMMENTS YET',
                                  style: TextStyle(
                                    color: AppColors.ivory.withValues(
                                      alpha: 0.34,
                                    ),
                                    fontSize: 11.0,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: rows.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8.0),
                                itemBuilder: (BuildContext context, int index) {
                                  final _FeedComment comment = rows[index];
                                  return Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.obsidian,
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.16,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          comment.body,
                                          style: const TextStyle(
                                            color: AppColors.ivory,
                                            fontSize: 13.0,
                                            height: 1.35,
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        Text(
                                          _timeAgo(comment.createdAt),
                                          style: TextStyle(
                                            color: AppColors.ivory.withValues(
                                              alpha: 0.35,
                                            ),
                                            fontSize: 9.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: controller,
                      maxLength: 280,
                      style: const TextStyle(color: AppColors.ivory),
                      decoration: InputDecoration(
                        hintText: 'Say something sharp.',
                        hintStyle: TextStyle(
                          color: AppColors.ivory.withValues(alpha: 0.34),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.28),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.gold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 46.0,
                      child: OutlinedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final String body = controller.text.trim();
                                if (body.isEmpty) return;
                                setState(() => isSubmitting = true);
                                try {
                                  await _submitComment(ref, post, body);
                                  controller.clear();
                                  setState(() => isSubmitting = false);
                                  HapticFeedback.selectionClick();
                                } catch (e) {
                                  setState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    _showFeedSnack(
                                      context,
                                      'Comment failed: $e',
                                    );
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: AppColors.gold,
                                ),
                              )
                            : const Text(
                                'POST COMMENT',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _openTextComposer({
    required BuildContext context,
    required String title,
    required String hint,
    required String submitLabel,
    required Future<void> Function(String body) onSubmit,
  }) async {
    final BuildContext rootContext = context;
    final TextEditingController controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.obsidianCard,
      builder: (BuildContext sheetContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18.0,
                right: 18.0,
                top: 18.0,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 18.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 280,
                    style: const TextStyle(color: AppColors.ivory),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: AppColors.ivory.withValues(alpha: 0.34),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.28),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: 46.0,
                    child: OutlinedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final String body = controller.text.trim();
                              if (body.isEmpty) return;
                              setState(() => isSubmitting = true);
                              try {
                                await onSubmit(body);
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                                if (rootContext.mounted) {
                                  _showFeedSnack(rootContext, '$title sent.');
                                }
                                HapticFeedback.selectionClick();
                              } catch (e) {
                                setState(() => isSubmitting = false);
                                if (rootContext.mounted) {
                                  _showFeedSnack(
                                    rootContext,
                                    '$title failed: $e',
                                  );
                                }
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 18.0,
                              height: 18.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: AppColors.gold,
                              ),
                            )
                          : Text(
                              submitLabel,
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  void _showFeedSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.obsidianCard,
        content: Text(
          message,
          style: const TextStyle(color: AppColors.ivory),
        ),
      ),
    );
  }
}

sealed class _FeedItem {
  const _FeedItem();
}

class _PostFeedItem extends _FeedItem {
  const _PostFeedItem(this.post);

  final FeedPost post;
}

class _TrendFeedItem extends _FeedItem {
  const _TrendFeedItem(this.trend);

  final TrendTsunami trend;
}

class _PostActionCallbacks {
  const _PostActionCallbacks({
    required this.onHype,
    required this.onSave,
    required this.onComment,
    required this.onRemix,
    required this.onStitch,
    required this.onDm,
    required this.onCollab,
  });

  final VoidCallback onHype;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onRemix;
  final VoidCallback onStitch;
  final VoidCallback onDm;
  final VoidCallback onCollab;
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
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
    if (items.isEmpty) {
      return _FeedMessage(label: emptyLabel);
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final _FeedItem item = items[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 16.0),
          child: switch (item) {
            _TrendFeedItem(:final TrendTsunami trend) =>
              _TrendTsunamiPage(trend: trend),
            _PostFeedItem(:final FeedPost post) => _PostPage(
                post: post,
                displayHype: post.hype + (overrides[post.id] ?? 0),
                actions: actionBuilder(context, post),
              ),
          },
        );
      },
    );
  }
}

class _PostPage extends StatelessWidget {
  const _PostPage({
    required this.post,
    required this.displayHype,
    required this.actions,
  });

  final FeedPost post;
  final double displayHype;
  final _PostActionCallbacks actions;

  @override
  Widget build(BuildContext context) {
    if (post.type == 'design_flex' || post.type == 'design_drop') {
      return _AlphaDropPage(
        post: post,
        displayHype: displayHype,
        actions: actions,
      );
    }
    if (post.type == 'system_eclipse') {
      return _SystemEventPage(post: post);
    }
    return _MogulPowerPage(
      post: post,
      displayHype: displayHype,
      actions: actions,
    );
  }
}

class _AlphaDropPage extends StatelessWidget {
  const _AlphaDropPage({
    required this.post,
    required this.displayHype,
    required this.actions,
  });

  final FeedPost post;
  final double displayHype;
  final _PostActionCallbacks actions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String brandName =
        (content['brand_name'] as String?) ?? 'Unknown Sovereign';
    final String designName =
        (content['design_name'] as String?) ?? 'UNTITLED ALPHA';
    final double hypeScore =
        ((content['hype_score'] as num?)?.toDouble()) ?? post.hype;
    final String colorHex =
        (content['fabric_color_hex'] as String?) ?? 'FAF7F0';
    final Color fabricColor = _hexToColor(colorHex);
    final String quote = (content['vex_quote'] as String?) ??
        (content['vex_headline'] as String?) ??
        'Vex is watching the silhouette.';
    final String trendLabel =
        _styleTags(content).take(2).join(' / ').toUpperCase();

    return GestureDetector(
      onDoubleTap: actions.onHype,
      child: _FullScreenCard(
        accentColor: AppColors.gold,
        background: _GarmentVisual(
          fabricColor: fabricColor,
          hypeScore: hypeScore,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _Badge(label: 'ALPHA DROP', color: AppColors.gold),
                const SizedBox(width: 8.0),
                _Badge(
                  label: trendLabel.isEmpty ? 'LIVE' : trendLabel,
                  color: AppColors.ivory.withValues(alpha: 0.78),
                ),
                const Spacer(),
                Text(
                  _timeAgo(post.createdAt),
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.55),
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '@$brandName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ivory,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        designName.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ivory.withValues(alpha: 0.68),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                    ],
                  ),
                ),
                _HypeBadge(
                  hype: displayHype > 0 ? displayHype : hypeScore,
                  color: AppColors.gold,
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            _VexOverlay(quote: quote),
            const SizedBox(height: 14.0),
            _ActionRail(
              postId: post.id,
              accentColor: AppColors.gold,
              actions: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class _MogulPowerPage extends StatelessWidget {
  const _MogulPowerPage({
    required this.post,
    required this.displayHype,
    required this.actions,
  });

  final FeedPost post;
  final double displayHype;
  final _PostActionCallbacks actions;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String brandName =
        (content['brand_name'] as String?) ?? 'Unknown Sovereign';
    final String city = ((content['city'] as String?) ?? 'global')
        .replaceAll('_', ' ')
        .toUpperCase();
    final String storeType =
        ((content['store_type'] as String?) ?? 'market').toUpperCase();
    final int tier = (content['new_tier'] as int?) ?? 1;

    return GestureDetector(
      onDoubleTap: actions.onHype,
      child: _FullScreenCard(
        accentColor: AppColors.lime,
        background: const _MogulVisual(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const _Badge(label: 'POWER MOVE', color: AppColors.lime),
                const Spacer(),
                Text(
                  _timeAgo(post.createdAt),
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.48),
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              'LOCKED THE BLOCK',
              style: TextStyle(
                color: AppColors.lime.withValues(alpha: 0.95),
                fontSize: 28.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '@$brandName deployed capital in $city',
              style: const TextStyle(
                color: AppColors.ivory,
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$storeType T$tier - cashflow velocity rising',
              style: TextStyle(
                color: AppColors.ivory.withValues(alpha: 0.62),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18.0),
            _ActionRail(
              postId: post.id,
              accentColor: AppColors.lime,
              actions: actions,
              hypeLabel: '${displayHype.toStringAsFixed(0)} HYPE',
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemEventPage extends StatelessWidget {
  const _SystemEventPage({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> content = post.content;
    final String name = (content['name'] as String?) ?? 'ECLIPSE EVENT';
    final String description =
        (content['description'] as String?) ?? 'A global market shift is live.';
    final double multiplier =
        ((content['buff_multiplier'] as num?)?.toDouble()) ?? 1.0;
    final int durationMinutes = (content['duration_minutes'] as int?) ?? 60;
    final bool isBuff = multiplier >= 1.0;
    final String multiplierLabel = isBuff
        ? '+${((multiplier - 1.0) * 100).toStringAsFixed(0)}%'
        : '-${((1.0 - multiplier) * 100).toStringAsFixed(0)}%';

    return _FullScreenCard(
      accentColor: AppColors.heat,
      background: const _MarketPulseVisual(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Badge(label: 'BREAKING MARKET SIGNAL', color: AppColors.heat),
          const SizedBox(height: 18.0),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: AppColors.ivory,
              fontSize: 28.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            description,
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.68),
              fontSize: 13.0,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18.0),
          Row(
            children: <Widget>[
              _MetricPill(label: multiplierLabel, color: AppColors.heat),
              const SizedBox(width: 8.0),
              _MetricPill(
                  label: '${durationMinutes}MIN', color: AppColors.gold),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendTsunamiPage extends StatelessWidget {
  const _TrendTsunamiPage({required this.trend});

  final TrendTsunami trend;

  @override
  Widget build(BuildContext context) {
    return _FullScreenCard(
      accentColor: AppColors.gold,
      background: _TrendVisual(tagName: trend.tagName),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Badge(label: 'BREAKING TREND TSUNAMI', color: AppColors.gold),
          const SizedBox(height: 18.0),
          Text(
            trend.tagName.toUpperCase(),
            style: const TextStyle(
              color: AppColors.ivory,
              fontSize: 34.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            '${trend.multiplierDisplay} HYPE WINDOW ACTIVE',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 14.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'The market is moving. Make the next drop answer it.',
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.64),
              fontSize: 13.0,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20.0),
          _MetricPill(
            label: '${trend.timeRemainingFormatted} LEFT',
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _FullScreenCard extends StatelessWidget {
  const _FullScreenCard({
    required this.accentColor,
    required this.background,
    required this.body,
  });

  final Color accentColor;
  final Widget background;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.obsidianCard,
          border: Border.all(color: accentColor.withValues(alpha: 0.34)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 32.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: background),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const <double>[0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18.0,
              right: 18.0,
              bottom: 18.0,
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}

class _GarmentVisual extends StatelessWidget {
  const _GarmentVisual({
    required this.fabricColor,
    required this.hypeScore,
  });

  final Color fabricColor;
  final double hypeScore;

  @override
  Widget build(BuildContext context) {
    final double glow = (hypeScore / 100.0).clamp(0.12, 0.9).toDouble();

    return CustomPaint(
      painter: _GarmentVisualPainter(
        fabricColor: fabricColor,
        glow: glow,
      ),
    );
  }
}

class _GarmentVisualPainter extends CustomPainter {
  const _GarmentVisualPainter({
    required this.fabricColor,
    required this.glow,
  });

  final Color fabricColor;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint background = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.22),
        radius: 0.92,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.46),
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final Offset center = Offset(size.width / 2.0, size.height * 0.42);
    final Paint aura = Paint()
      ..color = AppColors.gold.withValues(alpha: glow * 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38.0);
    canvas.drawCircle(center, size.width * 0.32, aura);

    for (int i = 0; i < 18; i++) {
      final double y = size.height * (0.12 + (i * 0.04));
      final double x = size.width * (0.14 + ((i * 37) % 70) / 100.0);
      final Paint particle = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.08 + glow * 0.12);
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3), particle);
    }

    final Rect cardRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.44,
      height: size.height * 0.48,
    );
    final Path silhouette = Path()
      ..moveTo(cardRect.center.dx, cardRect.top + 18.0)
      ..quadraticBezierTo(
        cardRect.left + 10.0,
        cardRect.top + 74.0,
        cardRect.left + 34.0,
        cardRect.bottom - 24.0,
      )
      ..quadraticBezierTo(
        cardRect.center.dx,
        cardRect.bottom,
        cardRect.right - 34.0,
        cardRect.bottom - 24.0,
      )
      ..quadraticBezierTo(
        cardRect.right - 10.0,
        cardRect.top + 74.0,
        cardRect.center.dx,
        cardRect.top + 18.0,
      )
      ..close();

    final Paint garment = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          AppColors.ivory.withValues(alpha: 0.95),
          fabricColor.withValues(alpha: 0.8),
          AppColors.ivory.withValues(alpha: 0.88),
        ],
      ).createShader(cardRect);
    canvas.drawPath(silhouette, garment);

    final Paint seam = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(silhouette, seam);
    canvas.drawLine(
      Offset(cardRect.center.dx, cardRect.top + 34.0),
      Offset(cardRect.center.dx, cardRect.bottom - 22.0),
      seam,
    );
  }

  @override
  bool shouldRepaint(covariant _GarmentVisualPainter oldDelegate) {
    return oldDelegate.fabricColor != fabricColor || oldDelegate.glow != glow;
  }
}

class _MogulVisual extends StatelessWidget {
  const _MogulVisual();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: const _GridVisualPainter(color: AppColors.lime));
  }
}

class _MarketPulseVisual extends StatelessWidget {
  const _MarketPulseVisual();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: const _GridVisualPainter(color: AppColors.heat));
  }
}

class _TrendVisual extends StatelessWidget {
  const _TrendVisual({required this.tagName});

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendVisualPainter(tagName: tagName),
    );
  }
}

class _GridVisualPainter extends CustomPainter {
  const _GridVisualPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          color.withValues(alpha: 0.2),
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final Paint line = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;
    for (double x = -size.width; x < size.width * 2; x += 34.0) {
      canvas.drawLine(
          Offset(x, 0.0), Offset(x + size.height, size.height), line);
    }
    for (int i = 0; i < 8; i++) {
      final double y = size.height * (0.16 + i * 0.075);
      final double width = size.width * (0.34 + (i % 4) * 0.11);
      final Paint bar = Paint()
        ..color = color.withValues(alpha: 0.16 + (i % 3) * 0.05);
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.12, y, width, 5.0),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridVisualPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TrendVisualPainter extends CustomPainter {
  const _TrendVisualPainter({required this.tagName});

  final String tagName;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint background = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.12, -0.32),
        radius: 1.05,
        colors: <Color>[
          AppColors.gold.withValues(alpha: 0.34),
          AppColors.obsidianSurface,
          AppColors.obsidian,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.2);
    final Offset center = Offset(size.width * 0.5, size.height * 0.36);
    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(center, 46.0 + i * 34.0, ring);
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: tagName.toUpperCase(),
        style: TextStyle(
          color: AppColors.ivory.withValues(alpha: 0.09),
          fontSize: 48.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 5.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 32.0);
    textPainter.paint(
      canvas,
      Offset(16.0, size.height * 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant _TrendVisualPainter oldDelegate) {
    return oldDelegate.tagName != tagName;
  }
}

class _VexOverlay extends StatelessWidget {
  const _VexOverlay({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'V',
            style: TextStyle(
              color: AppColors.obsidian,
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              '"$quote"',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.obsidian,
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.postId,
    required this.accentColor,
    required this.actions,
    this.hypeLabel = 'HYPE',
  });

  final String postId;
  final Color accentColor;
  final _PostActionCallbacks actions;
  final String hypeLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: <Widget>[
        _ActionPill(
          icon: Icons.local_fire_department,
          label: hypeLabel,
          color: accentColor,
          onTap: actions.onHype,
        ),
        _ActionPill(
          icon: Icons.bookmark_border,
          label: 'SAVE',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onSave,
          savedPostId: postId,
        ),
        _ActionPill(
          icon: Icons.chat_bubble_outline,
          label: 'COMMENT',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onComment,
        ),
        _ActionPill(
          icon: Icons.auto_fix_high,
          label: 'REMIX',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onRemix,
        ),
        _ActionPill(
          icon: Icons.call_split,
          label: 'STITCH',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onStitch,
        ),
        _ActionPill(
          icon: Icons.mail_outline,
          label: 'DM',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onDm,
        ),
        _ActionPill(
          icon: Icons.handshake_outlined,
          label: 'COLLAB',
          color: AppColors.ivory.withValues(alpha: 0.46),
          onTap: actions.onCollab,
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.savedPostId,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final String? savedPostId;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    if (savedPostId != null) {
      return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final AsyncValue<bool> isSaved =
              ref.watch(_postSavedProvider(savedPostId!));
          final bool selected = isSaved.valueOrNull ?? false;
          return _ActionPillBody(
            icon: selected ? Icons.bookmark : icon,
            label: selected ? 'SAVED' : label,
            color: selected ? AppColors.gold : color,
            enabled: enabled,
            onTap: onTap,
          );
        },
      );
    }

    return _ActionPillBody(
      icon: icon,
      label: label,
      color: color,
      enabled: enabled,
      onTap: onTap,
    );
  }
}

class _ActionPillBody extends StatelessWidget {
  const _ActionPillBody({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.54,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 14.0, color: color),
              const SizedBox(width: 5.0),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HypeBadge extends StatelessWidget {
  const _HypeBadge({
    required this.hype,
    required this.color,
  });

  final double hype;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color.withValues(alpha: 0.56)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            hype.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'HYPE',
            style: TextStyle(
              color: AppColors.ivory.withValues(alpha: 0.68),
              fontSize: 8.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: color.withValues(alpha: 0.48)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.7,
        ),
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

class _FeedLoading extends StatelessWidget {
  const _FeedLoading({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: accentColor,
        strokeWidth: 1.5,
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.ivory.withValues(alpha: 0.3),
          letterSpacing: 3.0,
          fontSize: 11.0,
          height: 1.8,
        ),
      ),
    );
  }
}

List<String> _styleTags(Map<String, dynamic> content) {
  final Object? raw = content['style_tags'];
  if (raw is List) {
    return raw.whereType<String>().toList();
  }
  return <String>[];
}

String _timeAgo(DateTime? dateTime) {
  if (dateTime == null) return 'live';
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
