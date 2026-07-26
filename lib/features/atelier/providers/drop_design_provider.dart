// GDD v7 §§5, 11, 19 — preview intent is local; release authority is server-owned.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';
import '../../design/models/vex_review.dart';
import '../../design/services/hype_calculator.dart';
import '../../feed/providers/feed_provider.dart';
import '../models/design_blueprint.dart';

int? _safeInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _safeDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _safeString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

class DropDesignState {
  const DropDesignState({
    this.design,
    this.blueprint,
    this.vexOptedIn = false,
    this.isPreviewing = true,
    this.isDropping = false,
    this.hypeResult,
    this.vexReview,
    this.releaseIdempotencyKey,
    this.error,
  });

  final Design? design;
  final DesignBlueprint? blueprint;
  final bool vexOptedIn;
  final bool isPreviewing;
  final bool isDropping;
  final HypeCalculationResult? hypeResult;
  final VexReview? vexReview;
  final String? releaseIdempotencyKey;
  final String? error;

  DropDesignState copyWith({
    Design? design,
    DesignBlueprint? blueprint,
    bool? vexOptedIn,
    bool? isPreviewing,
    bool? isDropping,
    HypeCalculationResult? hypeResult,
    VexReview? vexReview,
    String? releaseIdempotencyKey,
    String? error,
    bool clearError = false,
  }) {
    return DropDesignState(
      design: design ?? this.design,
      blueprint: blueprint ?? this.blueprint,
      vexOptedIn: vexOptedIn ?? this.vexOptedIn,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      isDropping: isDropping ?? this.isDropping,
      hypeResult: hypeResult ?? this.hypeResult,
      vexReview: vexReview ?? this.vexReview,
      releaseIdempotencyKey:
          releaseIdempotencyKey ?? this.releaseIdempotencyKey,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DropDesignNotifier extends StateNotifier<DropDesignState> {
  DropDesignNotifier(this._ref) : super(const DropDesignState());

  final Ref _ref;

  void initDropFlow({
    required Design design,
    required List<String> styleTags,
  }) {
    final DesignBlueprint blueprint = DesignBlueprint.starter(
      materials: styleTags,
      palette: <String>[design.fabricData['color_hex'] as String? ?? 'FAF7F0'],
    );
    state = state.copyWith(
      design: design,
      blueprint: blueprint,
      hypeResult: HypeCalculationResult(
        totalScore: design.hypeScore,
        baseScore: design.hypeScore,
        tsunamiMultiplier: 1.0,
        talentBonus: 0.0,
      ),
      releaseIdempotencyKey: const Uuid().v4(),
      isPreviewing: true,
    );
  }

  void replaceBlueprint(DesignBlueprint blueprint) {
    if (blueprint.isReleaseValid) state = state.copyWith(blueprint: blueprint);
  }

  void setVexOptIn(bool value) {
    state = state.copyWith(vexOptedIn: value);
  }

  void toggleVexOptIn() => setVexOptIn(!state.vexOptedIn);

  Future<VexReview?> executeDrop() async {
    final Design? design = state.design;
    final DesignBlueprint? blueprint = state.blueprint;
    if (design == null ||
        blueprint == null ||
        !blueprint.isReleaseValid ||
        state.isDropping) {
      return null;
    }

    state = state.copyWith(isDropping: true, clearError: true);
    try {
      final String idempotencyKey =
          state.releaseIdempotencyKey ?? const Uuid().v4();
      final Map<String, dynamic> response =
          await SupabaseService.invokeFunction(
        SupabaseConstants.fnDropDesign,
        body: <String, dynamic>{
          'action': 'release',
          'design_id': design.id,
          'release_intent': 'publish_first_drop',
          'blueprint': blueprint.toJson(),
          'vex_opt_in': state.vexOptedIn,
          'idempotency_key': idempotencyKey,
        },
      );
      final double hypeScore = _requiredDouble(response, 'hype_score');
      final String feedPostId = _requiredString(response, 'feed_post_id');
      final VexReview? review =
          state.vexOptedIn ? _serverVexReview(response, hypeScore) : null;
      _ref.read(pendingAlphaDropProvider.notifier).state = PendingAlphaDrop(
        feedPostId: feedPostId,
        designId: design.id,
        designName: design.name,
        hypeScore: hypeScore,
        vexVerdict: _safeString(response['vex_verdict']),
        vexHeadline: _safeString(response['vex_headline']),
        vexQuote: _safeString(response['vex_quote']),
        followersDelta: _safeInt(response['followers_delta']),
        brandHeatDelta: _safeInt(response['brand_heat_delta']),
        xpDelta: _safeInt(response['xp_delta']),
        rankProgressDelta: _safeDouble(response['rank_progress_delta']),
        currentRank: _safeInt(response['current_rank']),
        rankProgressPercent: _safeDouble(response['rank_progress_percent']),
        rankUpOccurred: response['rank_up_occurred'] as bool?,
        idleRevenueDelta: _safeDouble(response['idle_revenue_delta']),
        marketReaction: _safeString(response['market_reaction']),
        nextObjective: _safeString(response['next_objective']),
      );
      state = state.copyWith(
          isPreviewing: false, isDropping: false, vexReview: review);
      return review;
    } catch (_) {
      state = state.copyWith(
        isDropping: false,
        error: 'The Feed missed that drop. Your design is safe.',
      );
      return null;
    }
  }

  void reset() => state = const DropDesignState();
}

VexReview _serverVexReview(Map<String, dynamic> result, double hypeScore) {
  final VexVerdict verdict = switch (_requiredString(result, 'vex_verdict')) {
    'Alpha' => VexVerdict.sovereign,
    'Noticed' => VexVerdict.visionary,
    'Developing' => VexVerdict.derivative,
    _ => throw const FormatException('Unsupported Vex verdict.'),
  };
  return VexReview(
    headline: _requiredString(result, 'vex_headline'),
    body: _requiredString(result, 'vex_quote'),
    verdict: verdict,
    hypeScore: hypeScore,
    generatedAt: _requiredDateTime(result, 'settled_at'),
  );
}

double _requiredDouble(Map<String, dynamic> result, String key) {
  final Object? value = result[key];
  if (value is num) return value.toDouble();
  if (value is String) {
    final double? parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Release receipt is missing $key.');
}

String _requiredString(Map<String, dynamic> result, String key) {
  final Object? value = result[key];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  throw FormatException('Release receipt is missing $key.');
}

DateTime _requiredDateTime(Map<String, dynamic> result, String key) {
  final String value = _requiredString(result, key);
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Release receipt contains an invalid $key.');
  }
  return parsed;
}

final StateNotifierProvider<DropDesignNotifier, DropDesignState>
    dropDesignProvider =
    StateNotifierProvider<DropDesignNotifier, DropDesignState>(
  (Ref<DropDesignState> ref) => DropDesignNotifier(ref),
);

final Provider<AsyncValue<VexReview?>> currentVexReviewProvider =
    Provider<AsyncValue<VexReview?>>((Ref<AsyncValue<VexReview?>> ref) {
  final DropDesignState state = ref.watch(dropDesignProvider);
  return state.error == null
      ? AsyncValue<VexReview?>.data(state.vexReview)
      : AsyncValue<VexReview?>.error(state.error!, StackTrace.current);
});

final Provider<AsyncValue<double>> projectedHypeScoreProvider =
    Provider<AsyncValue<double>>((Ref<AsyncValue<double>> ref) {
  final DropDesignState state = ref.watch(dropDesignProvider);
  return state.error == null
      ? AsyncValue<double>.data(state.hypeResult?.totalScore ?? 0.0)
      : AsyncValue<double>.error(state.error!, StackTrace.current);
});

final Provider<AsyncValue<double>> tsunamiMultiplierProvider =
    Provider<AsyncValue<double>>((Ref<AsyncValue<double>> ref) {
  return AsyncValue<double>.data(
      ref.watch(dropDesignProvider).hypeResult?.tsunamiMultiplier ?? 1.0);
});
