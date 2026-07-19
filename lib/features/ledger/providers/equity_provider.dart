// Directive O — Equity Provider
// GDD §5.7 — Mogul Path: Corporate warfare, hostile takeovers, stock price

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/mini_game_service.dart';
import '../../../core/services/supabase_service.dart';

// =============================================================================
// Equity State
// =============================================================================

class EquityState {
  const EquityState({
    this.isLoading = false,
    this.errorMessage,
    this.activeTakeover,
  });

  final bool isLoading;
  final String? errorMessage;
  final TakeoverState? activeTakeover;

  EquityState copyWith({
    bool? isLoading,
    String? errorMessage,
    TakeoverState? activeTakeover,
    bool clearError = false,
    bool clearTakeover = false,
  }) {
    return EquityState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeTakeover:
          clearTakeover ? null : (activeTakeover ?? this.activeTakeover),
    );
  }
}

class TakeoverState {
  const TakeoverState({
    required this.targetBrandId,
    required this.targetName,
    required this.targetStockPrice,
    required this.ownershipPct,
    required this.round,
  });

  final String targetBrandId;
  final String targetName;
  final double targetStockPrice;
  final double ownershipPct; // 0-100
  final int round; // 1-5
}

// =============================================================================
// Equity Notifier
// =============================================================================

class EquityNotifier extends StateNotifier<EquityState> {
  EquityNotifier() : super(const EquityState());

  /// Initiate a hostile takeover
  void startTakeover({
    required String targetBrandId,
    required String targetName,
    required double targetStockPrice,
  }) {
    state = state.copyWith(
      activeTakeover: TakeoverState(
        targetBrandId: targetBrandId,
        targetName: targetName,
        targetStockPrice: targetStockPrice,
        ownershipPct: 50.0, // Starts at 50% (tug-of-war)
        round: 1,
      ),
    );
  }

  /// Update takeover progress
  void updateTakeoverProgress(double ownershipPct, int round) {
    if (state.activeTakeover == null) return;

    state = state.copyWith(
      activeTakeover: TakeoverState(
        targetBrandId: state.activeTakeover!.targetBrandId,
        targetName: state.activeTakeover!.targetName,
        targetStockPrice: state.activeTakeover!.targetStockPrice,
        ownershipPct: ownershipPct,
        round: round,
      ),
    );
  }

  /// End takeover and clear state
  void endTakeover() {
    state = state.copyWith(clearTakeover: true);
  }

  /// Apply Hostile Takeover result: inject 5000 Capital if 100% ownership
  Future<Map<String, dynamic>> applyTakeoverResult({
    required String attemptId,
    required int tapCount,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final Map<String, dynamic> result = await MiniGameService.claim(
        attemptId,
        <String, dynamic>{'tap_count': tapCount},
      );

      state = state.copyWith(isLoading: false);
      return result;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Takeover result could not be verified.',
      );
      return <String, dynamic>{
        'success': false,
        'error': 'Takeover result could not be verified.',
      };
    }
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

final StateNotifierProvider<EquityNotifier, EquityState> equityProvider =
    StateNotifierProvider<EquityNotifier, EquityState>(
  (Ref<EquityState> ref) => EquityNotifier(),
);

/// Computed stock price from brand hype score
final Provider<double> stockPriceProvider = Provider<double>(
  (Ref<double> ref) => ref.watch(authoritativeEquityProvider).maybeWhen(
        data: (EquitySnapshot? snapshot) => snapshot?.sharePrice ?? 0.0,
        orElse: () => 0.0,
      ),
);

class EquitySnapshot {
  const EquitySnapshot({
    required this.sharePrice,
    required this.valuation,
    required this.updatedAt,
  });

  final double sharePrice;
  final double valuation;
  final DateTime updatedAt;

  factory EquitySnapshot.fromJson(Map<String, dynamic> json) {
    return EquitySnapshot(
      sharePrice: (json['share_price'] as num?)?.toDouble() ?? 0.0,
      valuation: (json['valuation'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

final FutureProvider<EquitySnapshot?> authoritativeEquityProvider =
    FutureProvider<EquitySnapshot?>(
        (Ref<AsyncValue<EquitySnapshot?>> ref) async {
  ref.watch(supabaseAuthRevisionProvider);
  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return null;
  await SupabaseService.ensureFreshSession();
  final Map<String, dynamic>? row = await SupabaseService.client
      .from(SupabaseConstants.tableBrandsEquity)
      .select('share_price, valuation, updated_at')
      .eq('brand_id', uid)
      .maybeSingle();
  return row == null ? null : EquitySnapshot.fromJson(row);
});
