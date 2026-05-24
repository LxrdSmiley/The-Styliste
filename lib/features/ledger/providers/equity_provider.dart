// Directive O — Equity Provider
// GDD §5.7 — Mogul Path: Corporate warfare, hostile takeovers, stock price

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionResponse, Session;

import '../../../core/services/supabase_service.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';

// =============================================================================
// Equity State
// =============================================================================

class EquityState {
  const EquityState({
    this.stockPrice = 0.0,
    this.marketShare = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.activeTakeover,
  });

  final double stockPrice; // Derived from Hype Score * 1.5
  final double marketShare; // Percentage of global market
  final bool isLoading;
  final String? errorMessage;
  final TakeoverState? activeTakeover;

  EquityState copyWith({
    double? stockPrice,
    double? marketShare,
    bool? isLoading,
    String? errorMessage,
    TakeoverState? activeTakeover,
    bool clearError = false,
    bool clearTakeover = false,
  }) {
    return EquityState(
      stockPrice: stockPrice ?? this.stockPrice,
      marketShare: marketShare ?? this.marketShare,
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

  /// Calculate stock price from brand state
  /// Stock Price = Hype Score * 1.5
  void calculateStockPrice(double hypeScore) {
    state = state.copyWith(
      stockPrice: hypeScore * 1.5,
    );
  }

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
    required double finalPct,
  }) async {
    if (finalPct != 100.0) {
      return <String, dynamic>{
        'success': false,
        'reason': 'Takeover incomplete: $finalPct%',
      };
    }

    state = state.copyWith(isLoading: true);

    try {
      final Session? session = SupabaseService.client.auth.currentSession;
      if (session == null) {
        state = state.copyWith(isLoading: false);
        return <String, dynamic>{
          'success': false,
          'error': 'Not authenticated',
        };
      }

      final FunctionResponse response =
          await SupabaseService.client.functions.invoke(
        'claim-mini-game-reward',
        body: <String, dynamic>{
          'game_key': 'hostile_takeover',
          'result_key': 'complete_takeover',
        },
        headers: <String, String>{
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      final Map<String, dynamic> result =
          Map<String, dynamic>.from(response.data as Map<String, dynamic>);

      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to inject takeover bonus: $e',
      );
      return <String, dynamic>{
        'success': false,
        'error': 'Failed to inject takeover bonus: $e',
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
  (Ref<double> ref) {
    final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
    return brandAsync.when(
      data: (Brand brand) => brand.hypeScore * 1.5,
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  },
);
