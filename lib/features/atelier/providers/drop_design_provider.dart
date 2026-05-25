// GDD v6 — Drop to Feed Provider with Vex AI Critic Integration
// Two-phase flow: Mint Alpha → Preview Design → Drop to Feed with Vex Review
// Alabaster Standard: Vex opt-in toggle, procedural critique, editorial snap animation

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';
import '../../design/services/hype_calculator.dart';
import '../../design/services/vex_ai_engine.dart';
import '../../feed/providers/feed_provider.dart';
import '../../talent/models/talent.dart';
import '../../talent/providers/casting_provider.dart';
import '../../trends/models/trend_tsunami.dart';
import '../../trends/providers/trend_provider.dart';

/// State for the drop design flow
class DropDesignState {
  const DropDesignState({
    this.design,
    this.styleTags = const <String>[],
    this.vexOptedIn = true,
    this.isPreviewing = true,
    this.isDropping = false,
    this.hypeResult,
    this.vexReview,
    this.error,
  });

  final Design? design;
  final List<String> styleTags;
  final bool vexOptedIn;
  final bool isPreviewing;
  final bool isDropping;
  final HypeCalculationResult? hypeResult;
  final VexReview? vexReview;
  final String? error;

  DropDesignState copyWith({
    Design? design,
    List<String>? styleTags,
    bool? vexOptedIn,
    bool? isPreviewing,
    bool? isDropping,
    HypeCalculationResult? hypeResult,
    VexReview? vexReview,
    String? error,
    bool clearError = false,
  }) {
    return DropDesignState(
      design: design ?? this.design,
      styleTags: styleTags ?? this.styleTags,
      vexOptedIn: vexOptedIn ?? this.vexOptedIn,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      isDropping: isDropping ?? this.isDropping,
      hypeResult: hypeResult ?? this.hypeResult,
      vexReview: vexReview ?? this.vexReview,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for the drop design flow
class DropDesignNotifier extends StateNotifier<DropDesignState> {
  DropDesignNotifier(this._ref) : super(const DropDesignState());

  final Ref _ref;
  final HypeCalculator _calculator = const HypeCalculator();
  final VexAIEngine _vexEngine = vexEngine;

  /// Initialize the drop flow with a minted design
  ///
  /// [design] — The freshly minted Alpha design
  /// [styleTags] — User-selected style tags for tsunami matching
  void initDropFlow({
    required Design design,
    required List<String> styleTags,
  }) {
    // Get active tsunamis for hype calculation
    final AsyncValue<List<TrendTsunami>> tsunamisAsync =
        _ref.read(activeTsunamiProvider);

    final List<TrendTsunami> activeTsunamis = tsunamisAsync.when(
      data: (List<TrendTsunami> t) => t,
      loading: () => <TrendTsunami>[],
      error: (_, __) => <TrendTsunami>[],
    );

    // Calculate projected hype score
    final HypeCalculationInput input = HypeCalculationInput(
      styleTags: styleTags,
      materialQuality: _getMaterialQuality(design),
      aestheticAlignment:
          _getAestheticAlignment(design, styleTags, activeTsunamis),
      sovereignTalentCount: _ref.read(rosterProvider).maybeWhen(
            data: (List<RosterTalent> roster) => roster
                .where((RosterTalent t) => t.tier == TalentTier.sovereign)
                .length,
            orElse: () => 0,
          ),
      totalTalentExpertise: _ref.read(rosterProvider).maybeWhen(
            data: (List<RosterTalent> roster) => roster
                .where((RosterTalent t) => t.tier == TalentTier.sovereign)
                .fold(
                  0.0,
                  (double sum, RosterTalent t) => sum + t.expertiseScore,
                ),
                .fold(
                  0.0,
                  (double sum, RosterTalent t) => sum + t.expertiseScore,
                ),
            orElse: () => 0.0,
          ),
    );

    final HypeCalculationResult hypeResult = _calculator.calculate(
      input: input,
      activeTsunamis: activeTsunamis,
    );

    // Generate preview Vex review (only if opted in)
    final VexReview? previewReview =
        state.vexOptedIn ? _vexEngine.generateReview(result: hypeResult) : null;

    state = state.copyWith(
      design: design,
      styleTags: styleTags,
      hypeResult: hypeResult,
      vexReview: previewReview,
      isPreviewing: true,
    );
  }

  /// Toggle Vex opt-in (player can choose to face judgment or not)
  void toggleVexOptIn() {
    final bool newOptIn = !state.vexOptedIn;

    // Regenerate review if opting in, clear if opting out
    final VexReview? newReview = newOptIn && state.hypeResult != null
        ? _vexEngine.generateReview(
            result: state.hypeResult!,
          )
        : null;

    state = state.copyWith(
      vexOptedIn: newOptIn,
      vexReview: newReview,
    );
  }

  /// Execute the drop to feed
  ///
  /// 1. Create garment_drops record
  /// 2. Create feed_posts record
  /// 3. Return final VexReview (if opted in)
  Future<VexReview?> executeDrop() async {
    if (state.design == null || state.isDropping) return null;

    state = state.copyWith(isDropping: true, clearError: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String playerId = supabase.auth.currentUser!.id;
      final Design design = state.design!;
      final VexReview? review = state.vexReview;
      final double hypeScore = state.hypeResult?.totalScore ?? 0.0;
      final String? fabricColorHex = design.fabricData['color_hex'] as String?;
      Map<String, dynamic>? playerProfile;
      try {
        playerProfile = await supabase
            .from(SupabaseConstants.tablePlayers)
            .select('brand_name, brand_rank')
            .eq('id', playerId)
            .maybeSingle();
      } catch (_) {
        playerProfile = null;
      }
      final String? brandName = playerProfile?['brand_name'] as String?;
      final Object? brandRank = playerProfile?['brand_rank'];

      final Map<String, dynamic> content = <String, dynamic>{
        'event': 'alpha_dropped',
        'design_id': design.id,
        'design_name': design.name,
        'style_tags': state.styleTags,
        'trend_tags': state.styleTags,
        'hype_score': hypeScore,
        'fabric_tier': design.fabricTier,
        if (fabricColorHex != null) 'fabric_color_hex': fabricColorHex,
        if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
        if (brandRank is num) 'brand_rank': brandRank,
        if (review != null) ...<String, dynamic>{
          'vex_review': review.toJson(),
          'vex_headline': review.headline,
          'vex_quote': review.quotableLine,
          'vex_caption': review.body,
          'vex_verdict': review.verdict.name,
        },
      };

      // Step 1: Create feed post
      final Map<String, dynamic> feedPost = await supabase
          .from(SupabaseConstants.tableFeedPosts)
          .insert(<String, dynamic>{
            'player_id': playerId,
            'type': 'design_flex',
            'content': content,
            'hype': hypeScore,
          })
          .select()
          .single();
      final String feedPostId = feedPost['id'] as String;

      // Step 2: Create garment_drop record
      await supabase
          .from(SupabaseConstants.tableGarmentDrops)
          .insert(<String, dynamic>{
        'player_id': playerId,
        'design_id': design.id,
        'style_tags': state.styleTags,
        'hype_score': hypeScore,
        'feed_post_id': feedPostId,
        'dropped_at': DateTime.now().toIso8601String(),
      });

      // Step 3: Update design status to 'dropped'
      await supabase
          .from(SupabaseConstants.tableDesigns)
          .update(<String, dynamic>{
        'status': 'dropped',
        'dropped_at': DateTime.now().toIso8601String(),
      }).eq('id', design.id);

      _ref.read(pendingAlphaDropProvider.notifier).state = PendingAlphaDrop(
        feedPostId: feedPostId,
        designId: design.id,
        designName: design.name,
        hypeScore: hypeScore,
        brandName: brandName,
        fabricColorHex: fabricColorHex,
      );

      // Final state transition
      state = state.copyWith(
        isPreviewing: false,
        isDropping: false,
      );

      // Return final review for display
      return state.vexReview;
    } catch (e) {
      state = state.copyWith(
        isDropping: false,
        error: 'Failed to drop: $e',
      );
      return null;
    }
  }

  /// Regenerate Vex review (for "roll again" feature if desired)
  void regenerateReview() {
    if (state.hypeResult == null) return;

    final VexReview newReview = _vexEngine.generateReview(
      result: state.hypeResult!,
      optedIn: state.vexOptedIn,
    );

    state = state.copyWith(vexReview: newReview);
  }

  /// Reset the flow
  void reset() {
    state = const DropDesignState();
  }

  double _getMaterialQuality(Design design) {
    // Map fabric tier to quality score per GDD §4.1
    return switch (design.fabricTier) {
      'alabaster_silk' => 95.0,
      'organic_cotton' => 60.0,
      'standard_cotton' => 35.0,
      'synthetic' => 15.0,
      _ => 50.0,
    };
  }

  double _getAestheticAlignment(
    Design design,
    List<String> styleTags,
    List<TrendTsunami> tsunamis,
  ) {
    // Base alignment from tag overlap with active tsunamis
    if (tsunamis.isEmpty) return 50.0;
    final double tsunamiScore = tsunamis.getMultiplierForTags(styleTags);
    // Scale: 1.0 = 50, 1.5 = 75, 2.5 = 95
    return ((tsunamiScore - 1.0) / 1.5 * 45.0 + 50.0).clamp(0.0, 100.0);
  }
}

/// StateNotifierProvider for drop design flow
final StateNotifierProvider<DropDesignNotifier, DropDesignState>
    dropDesignProvider =
    StateNotifierProvider<DropDesignNotifier, DropDesignState>(
  (Ref<DropDesignState> ref) => DropDesignNotifier(ref),
);

/// Provider for just the Vex review (convenience)
final Provider<AsyncValue<VexReview?>> currentVexReviewProvider =
    Provider<AsyncValue<VexReview?>>((Ref<AsyncValue<VexReview?>> ref) {
  final DropDesignState state = ref.watch(dropDesignProvider);

  if (state.error != null) {
    return AsyncValue<VexReview?>.error(state.error!, StackTrace.current);
  }

  return AsyncValue<VexReview?>.data(state.vexReview);
});

/// Provider for the projected hype score (for Atelier UI preview)
final Provider<AsyncValue<double>> projectedHypeScoreProvider =
    Provider<AsyncValue<double>>((Ref<AsyncValue<double>> ref) {
  final DropDesignState state = ref.watch(dropDesignProvider);

  if (state.error != null) {
    return AsyncValue<double>.error(state.error!, StackTrace.current);
  }

  return AsyncValue<double>.data(state.hypeResult?.totalScore ?? 0.0);
});

/// Provider for tsunami multiplier (for UI badges)
final Provider<AsyncValue<double>> tsunamiMultiplierProvider =
    Provider<AsyncValue<double>>((Ref<AsyncValue<double>> ref) {
  final DropDesignState state = ref.watch(dropDesignProvider);

  return AsyncValue<double>.data(state.hypeResult?.tsunamiMultiplier ?? 1.0);
});
