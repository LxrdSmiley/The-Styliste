// GDD v6 — Drop to Feed Provider with Vex AI Critic Integration
// Two-phase flow: Mint Alpha → Preview Design → Drop to Feed with Vex Review
// Alabaster Standard: Vex opt-in toggle, procedural critique, editorial snap animation

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';
import '../../design/services/hype_calculator.dart';
import '../../design/services/vex_ai_engine.dart';
import '../../feed/providers/feed_provider.dart';

double _safeDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

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
  final VexAIEngine _vexEngine = vexEngine;

  /// Initialize the drop flow with a minted design
  ///
  /// [design] — The freshly minted Alpha design
  /// [styleTags] — User-selected style tags for tsunami matching
  void initDropFlow({
    required Design design,
    required List<String> styleTags,
  }) {
    final HypeCalculationResult hypeResult = HypeCalculationResult(
      totalScore: design.hypeScore,
      baseScore: design.hypeScore,
      tsunamiMultiplier: 1.0,
      talentBonus: 0.0,
    );

    // Generate preview Vex review from the server-authoritative minted hype.
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
      final Design design = state.design!;
      final VexReview? review = state.vexReview;
      final Map<String, dynamic> response =
          await SupabaseService.invokeFunction(
        SupabaseConstants.fnDropDesign,
        body: <String, dynamic>{
          'design_id': design.id,
          'style_tags': state.styleTags,
          if (review != null) ...<String, dynamic>{
            'vex_review': review.toJson(),
            'vex_quote': review.quotableLine,
            'vex_caption': review.body,
          },
        },
      );
      final String feedPostId = response['feed_post_id'] as String;
      final double hypeScore = _safeDouble(
        response['hype_score'],
        fallback: design.hypeScore,
      );
      final String? brandName = response['brand_name'] as String?;
      final String? fabricColorHex = response['fabric_color_hex'] as String? ??
          design.fabricData['color_hex'] as String?;

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
