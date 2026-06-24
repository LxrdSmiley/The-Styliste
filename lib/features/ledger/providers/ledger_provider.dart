// GDD §5.2 — Ledger Riverpod providers (Phase 5).
// ledgerStoresStreamProvider: Realtime stream of player's stores list.
// upgradeStoreProvider: StateNotifier managing optimistic upgrade UX state.

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
import '../../../core/services/mini_game_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/store.dart';

// ---------------------------------------------------------------------------
// Store stream — Realtime-backed list of the authenticated player's stores.
// ---------------------------------------------------------------------------

final StreamProvider<List<Store>> ledgerStoresStreamProvider =
    StreamProvider<List<Store>>((Ref<AsyncValue<List<Store>>> ref) {
  final String uid = ref.watch(activeUidProvider);
  return SupabaseService.client
      .from(SupabaseConstants.tableStores)
      .stream(primaryKey: <String>['id'])
      .eq('player_id', uid)
      .map(
        (List<Map<String, dynamic>> rows) => rows.map(Store.fromJson).toList(),
      );
});

// ---------------------------------------------------------------------------
// Upgrade state — optimistic lock + error propagation.
// ---------------------------------------------------------------------------

class UpgradeStoreState {
  const UpgradeStoreState({
    this.upgradingStoreId,
    this.optimisticBalance,
    this.errorMessage,
  });

  /// ID of the store currently being upgraded (null = idle).
  final String? upgradingStoreId;

  /// Client-side deducted balance preview while edge fn is in flight.
  final double? optimisticBalance;

  /// Set on HTTP 400 / error; cleared after SnackBar is consumed.
  final String? errorMessage;

  UpgradeStoreState copyWith({
    String? upgradingStoreId,
    double? optimisticBalance,
    String? errorMessage,
    bool clearUpgrading = false,
    bool clearError = false,
  }) =>
      UpgradeStoreState(
        upgradingStoreId:
            clearUpgrading ? null : (upgradingStoreId ?? this.upgradingStoreId),
        optimisticBalance: clearUpgrading
            ? null
            : (optimisticBalance ?? this.optimisticBalance),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class UpgradeStoreNotifier extends StateNotifier<UpgradeStoreState> {
  UpgradeStoreNotifier() : super(const UpgradeStoreState());

  static const double _baseCost = 500.0;
  static const double _costExponent = 1.5;

  /// Client-side cost mirror — must match edge function formula exactly.
  static double upgradeCost(int currentTier) =>
      _baseCost * math.pow(_costExponent, currentTier);

  Future<void> upgrade({
    required Store store,
    required double currentBalance,
  }) async {
    if (state.upgradingStoreId != null) return; // already upgrading something

    final double cost = upgradeCost(store.tier);

    // 1. Optimistic lock — show spinner on this card, preview balance deduction.
    state = UpgradeStoreState(
      upgradingStoreId: store.id,
      optimisticBalance: currentBalance - cost,
    );

    try {
      await SupabaseService.invokeFunction(
        SupabaseConstants.fnProcessTransaction,
        body: <String, dynamic>{
          'action': 'upgrade_store',
          'store_id': store.id,
          'idempotency_key': const Uuid().v4(),
        },
      );
      // 2. Success: clear optimistic state. Realtime stream provides truth.
      if (mounted) state = const UpgradeStoreState();
    } on Exception catch (e) {
      // 3. On 400 or any error: revert optimistic state, surface message.
      if (mounted) {
        state = UpgradeStoreState(
          errorMessage: e.toString().contains('INSUFFICIENT_CAPITAL')
              ? 'INSUFFICIENT CAPITAL'
              : 'UPGRADE FAILED — TRY AGAIN',
        );
      }
    }
  }

  /// Called by UI after SnackBar has displayed the error.
  void clearError() {
    if (mounted) state = state.copyWith(clearError: true);
  }

  // ===========================================================================
  // Directive O: Mini-Game Economic Wiring
  // ===========================================================================

  /// Apply Price War Blitz result: buff or debuff idle multiplier
  /// Win = +35% for 12h, Loss = -15% for 6h
  Future<Map<String, dynamic>> applyPriceWarResult({
    required String attemptId,
    required List<double> tapValues,
  }) async {
    try {
      return await MiniGameService.claim(
        attemptId,
        <String, dynamic>{'tap_values': tapValues},
      );
    } catch (_) {
      return <String, dynamic>{
        'success': false,
        'error': 'Price war result could not be verified.',
      };
    }
  }

  /// Apply Power Move Combo: store multiplier for next liquidation
  Future<Map<String, dynamic>> applyPowerMoveCombo({
    required String attemptId,
    required List<String> sequence,
  }) async {
    try {
      return await MiniGameService.claim(
        attemptId,
        <String, dynamic>{'sequence': sequence},
      );
    } catch (_) {
      return <String, dynamic>{
        'success': false,
        'error': 'Power move result could not be verified.',
      };
    }
  }

  /// Apply Hostile Takeover result: inject 5000 Capital if 100% ownership
  Future<Map<String, dynamic>> applyTakeoverResult({
    required String attemptId,
    required int tapCount,
  }) async {
    try {
      return await MiniGameService.claim(
        attemptId,
        <String, dynamic>{'tap_count': tapCount},
      );
    } catch (_) {
      return <String, dynamic>{
        'success': false,
        'error': 'Takeover result could not be verified.',
      };
    }
  }
}

final StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>
    upgradeStoreProvider =
    StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>(
  (_) => UpgradeStoreNotifier(),
);
