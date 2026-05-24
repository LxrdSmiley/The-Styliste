// Directive J — Gala Providers
// GDD §6.9, §12.3.3 — Weekly PvP state management
// 120Hz seamless feed with 3D memory optimization

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gala_models.dart';
import '../services/gala_scoring_engine.dart';

// =============================================================================
// Active Gala Event Stream
// =============================================================================

/// Stream of currently active gala event
final StreamProvider<GalaEvent?> activeGalaProvider =
    StreamProvider<GalaEvent?>((Ref<AsyncValue<GalaEvent?>> ref) {
  final SupabaseClient supabase = Supabase.instance.client;

  return supabase
      .from('gala_events')
      .stream(primaryKey: <String>['id'])
      .eq('status', 'active')
      .order('starts_at')
      .limit(1)
      .map((List<Map<String, dynamic>> events) {
        if (events.isEmpty) return null;
        return GalaEvent.fromJson(events.first);
      });
});

/// Current/upcoming gala event (fallback to upcoming if no active)
final FutureProvider<GalaEvent?> currentGalaProvider =
    FutureProvider<GalaEvent?>((Ref<AsyncValue<GalaEvent?>> ref) async {
  final SupabaseClient supabase = Supabase.instance.client;

  // Try active first
  final List<Map<String, dynamic>> active = await supabase
      .from('gala_events')
      .select()
      .eq('status', 'active')
      .order('starts_at')
      .limit(1);

  if (active.isNotEmpty) {
    return GalaEvent.fromJson(active.first);
  }

  // Fallback to upcoming
  final List<Map<String, dynamic>> upcoming = await supabase
      .from('gala_events')
      .select()
      .eq('status', 'upcoming')
      .order('starts_at')
      .limit(1);

  if (upcoming.isNotEmpty) {
    return GalaEvent.fromJson(upcoming.first);
  }

  return null;
});

// =============================================================================
// Gala Feed State (120Hz seamless vertical swipe)
// =============================================================================

class GalaFeedState {
  const GalaFeedState({
    this.submissions = const <GalaSubmission>[],
    this.isLoading = false,
    this.hasMore = true,
    this.currentIndex = 0,
    this.errorMessage,
  });

  final List<GalaSubmission> submissions;
  final bool isLoading;
  final bool hasMore;
  final int currentIndex;
  final String? errorMessage;

  GalaFeedState copyWith({
    List<GalaSubmission>? submissions,
    bool? isLoading,
    bool? hasMore,
    int? currentIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GalaFeedState(
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Get visible submissions (current, previous, next) for 3D memory management
  List<GalaSubmission> get visibleSubmissions {
    final int start = (currentIndex - 1).clamp(0, submissions.length);
    final int end = (currentIndex + 2).clamp(0, submissions.length);
    return submissions.sublist(start, end);
  }

  /// Check if index should have active 3D controller
  bool isIndexActive(int index) {
    return (index - currentIndex).abs() <= 1;
  }
}

class GalaFeedNotifier extends StateNotifier<GalaFeedState> {
  GalaFeedNotifier() : super(const GalaFeedState());

  String? _currentEventId;
  int _offset = 0;
  static const int _pageSize = 10;

  /// Load initial feed for event
  Future<void> loadFeed(String eventId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    _currentEventId = eventId;
    _offset = 0;

    try {
      final SupabaseClient supabase = Supabase.instance.client;

      final List<Map<String, dynamic>> results = await supabase
          .from('gala_submissions')
          .select('''
            *,
            designs!inner(name, image_url),
            players!inner(display_name),
            talent_pool!inner(name, tier, base_hype_multiplier)
          ''')
          .eq('event_id', eventId)
          .order('current_score', ascending: false)
          .range(_offset, _offset + _pageSize - 1);

      final List<GalaSubmission> submissions =
          results.map((Map<String, dynamic> json) {
        // Flatten joined data
        final Map<String, dynamic> flat = Map<String, dynamic>.from(json);
        final Map<String, dynamic>? design =
            json['designs'] as Map<String, dynamic>?;
        final Map<String, dynamic>? player =
            json['players'] as Map<String, dynamic>?;
        final Map<String, dynamic>? talent =
            json['talent_pool'] as Map<String, dynamic>?;
        if (design != null) {
          flat['design_name'] = design['name'];
          flat['design_image_url'] = design['image_url'];
        }
        if (player != null) {
          flat['player_name'] = player['display_name'];
        }
        if (talent != null) {
          flat['talent'] = talent;
        }
        return GalaSubmission.fromJson(flat);
      }).toList();

      state = state.copyWith(
        submissions: submissions,
        isLoading: false,
        hasMore: submissions.length == _pageSize,
      );

      _offset += submissions.length;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load feed: $e',
      );
    }
  }

  /// Load more submissions (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || _currentEventId == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;

      final List<Map<String, dynamic>> results = await supabase
          .from('gala_submissions')
          .select('''
            *,
            designs!inner(name, image_url),
            players!inner(display_name),
            talent_pool!inner(name, tier, base_hype_multiplier)
          ''')
          .eq('event_id', _currentEventId!)
          .order('current_score', ascending: false)
          .range(_offset, _offset + _pageSize - 1);

      final List<GalaSubmission> newSubmissions =
          results.map((Map<String, dynamic> json) {
        final Map<String, dynamic> flat = Map<String, dynamic>.from(json);
        final Map<String, dynamic>? design =
            json['designs'] as Map<String, dynamic>?;
        final Map<String, dynamic>? player =
            json['players'] as Map<String, dynamic>?;
        final Map<String, dynamic>? talent =
            json['talent_pool'] as Map<String, dynamic>?;
        if (design != null) {
          flat['design_name'] = design['name'];
          flat['design_image_url'] = design['image_url'];
        }
        if (player != null) {
          flat['player_name'] = player['display_name'];
        }
        if (talent != null) {
          flat['talent'] = talent;
        }
        return GalaSubmission.fromJson(flat);
      }).toList();

      state = state.copyWith(
        submissions: <GalaSubmission>[...state.submissions, ...newSubmissions],
        isLoading: false,
        hasMore: newSubmissions.length == _pageSize,
      );

      _offset += newSubmissions.length;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load more: $e',
      );
    }
  }

  /// Update current index (for 3D memory management)
  void setCurrentIndex(int index) {
    if (index == state.currentIndex) return;
    state = state.copyWith(currentIndex: index);

    // Load more when approaching end
    if (index >= state.submissions.length - 3 &&
        state.hasMore &&
        !state.isLoading) {
<<<<<<< HEAD
      loadMore();
=======
      unawaited(loadMore());
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
    }
  }

  /// Refresh current submission scores
  Future<void> refreshScores() async {
    if (_currentEventId == null) return;

    try {
      final SupabaseClient supabase = Supabase.instance.client;

      final List<Map<String, dynamic>> results = await supabase
          .from('gala_submissions')
          .select('id, current_score, vote_count')
          .eq('event_id', _currentEventId!)
          .inFilter(
<<<<<<< HEAD
              'id', state.submissions.map((GalaSubmission s) => s.id).toList());
=======
            'id',
            state.submissions.map((GalaSubmission s) => s.id).toList(),
          );
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e

      final Map<String, Map<String, dynamic>> scoreMap =
          <String, Map<String, dynamic>>{
        for (final Map<String, dynamic> r in results) r['id'] as String: r,
      };

      final List<GalaSubmission> updated =
          state.submissions.map((GalaSubmission sub) {
        final Map<String, dynamic>? update = scoreMap[sub.id];
        if (update != null) {
          return sub.copyWith(
            currentScore: (update['current_score'] as num).toDouble(),
            voteCount: update['vote_count'] as int,
          );
        }
        return sub;
      }).toList();

      state = state.copyWith(submissions: updated);
    } catch (e) {
      // Silent refresh failure
    }
  }
}

final StateNotifierProvider<GalaFeedNotifier, GalaFeedState> galaFeedProvider =
    StateNotifierProvider<GalaFeedNotifier, GalaFeedState>(
  (Ref<GalaFeedState> ref) => GalaFeedNotifier(),
);

// =============================================================================
// Vote Limits Provider
// =============================================================================

final FutureProviderFamily<VoteLimits, String> voteLimitsProvider =
    FutureProviderFamily<VoteLimits, String>(
  (Ref<AsyncValue<VoteLimits>> ref, String eventId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final String? userId = supabase.auth.currentUser?.id;

    if (userId == null) throw Exception('Not authenticated');

    final Map<String, dynamic> result = await supabase
        .from('gala_vote_limits')
        .select()
        .eq('player_id', userId)
        .eq('event_id', eventId)
        .eq('vote_date', DateTime.now().toIso8601String().split('T').first)
        .single();

    return VoteLimits.fromJson(result);
  },
);

// =============================================================================
// Leaderboard Provider
// =============================================================================

final FutureProviderFamily<List<LeaderboardEntry>, String>
    galaLeaderboardProvider =
    FutureProviderFamily<List<LeaderboardEntry>, String>(
  (Ref<AsyncValue<List<LeaderboardEntry>>> ref, String eventId) async {
    final SupabaseClient supabase = Supabase.instance.client;

    final List<Object?> results = await supabase.rpc<List<Object?>>(
      'get_gala_leaderboard',
      params: <String, dynamic>{'p_event_id': eventId},
    );

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> json) => LeaderboardEntry.fromJson(json),
        )
        .toList();
  },
);

// =============================================================================
// Vote Casting
// =============================================================================

class VoteCastingState {
  const VoteCastingState({
    this.isCasting = false,
    this.lastResult,
    this.errorMessage,
  });

  final bool isCasting;
  final VoteResult? lastResult;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  VoteCastingState copyWith({
    bool? isCasting,
    VoteResult? lastResult,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return VoteCastingState(
      isCasting: isCasting ?? this.isCasting,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VoteCastingNotifier extends StateNotifier<VoteCastingState> {
  VoteCastingNotifier() : super(const VoteCastingState());

  Future<void> castVote(String submissionId, VoteTier tier) async {
    if (state.isCasting) return;

    // Execute haptic first (immediate feedback)
    await tier.executeHaptic();

    state =
        state.copyWith(isCasting: true, clearError: true, clearResult: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;

      final Map<String, dynamic> result = await supabase.rpc(
        'cast_gala_vote',
        params: <String, dynamic>{
          'p_submission_id': submissionId,
          'p_vote_tier': tier.name.toLowerCase(),
        },
      );

      final VoteResult voteResult = VoteResult(
        success: result['success'] as bool,
        finalPoints: (result['final_points'] as num).toDouble(),
        message: result['message'] as String?,
        submissionId: submissionId,
      );

      state = state.copyWith(
        isCasting: false,
        lastResult: voteResult,
      );
    } catch (e) {
      state = state.copyWith(
        isCasting: false,
        errorMessage: 'Failed to cast vote: $e',
      );
    }
  }
}

final StateNotifierProvider<VoteCastingNotifier, VoteCastingState>
    voteCastingProvider =
    StateNotifierProvider<VoteCastingNotifier, VoteCastingState>(
  (Ref<VoteCastingState> ref) => VoteCastingNotifier(),
);

// =============================================================================
// Submission Provider
// =============================================================================

class SubmissionState {
  const SubmissionState({
    this.isSubmitting = false,
    this.submissionId,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? submissionId;
  final String? errorMessage;

  SubmissionState copyWith({
    bool? isSubmitting,
    String? submissionId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubmissionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionId: submissionId ?? this.submissionId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SubmissionNotifier extends StateNotifier<SubmissionState> {
  SubmissionNotifier() : super(const SubmissionState());

  Future<void> submit(String eventId, String designId, String? talentId) async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String playerId = supabase.auth.currentUser!.id;

      final List<dynamic> rows = await supabase.rpc<List<dynamic>>(
        'submit_to_gala',
        params: <String, dynamic>{
          'p_player_id': playerId,
          'p_design_id': designId,
          'p_event_id': eventId,
        },
      );
      final Map<String, dynamic> result =
          (rows.first as Map<dynamic, dynamic>).cast<String, dynamic>();

      if (result['success'] == true) {
        state = state.copyWith(
          isSubmitting: false,
          submissionId: result['submission_id'] as String,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result['message'] as String? ?? 'Submission failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submission error: $e',
      );
    }
  }
}

final StateNotifierProvider<SubmissionNotifier, SubmissionState>
    submissionProvider =
    StateNotifierProvider<SubmissionNotifier, SubmissionState>(
  (Ref<SubmissionState> ref) => SubmissionNotifier(),
);
