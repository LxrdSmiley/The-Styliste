// GDD §5.2 — Ledger Riverpod providers (Phase 5).
// ledgerStoresStreamProvider: Realtime stream of player's stores list.
// upgradeStoreProvider: StateNotifier managing optimistic upgrade UX state.

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/mock_auth_provider.dart';
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
        (List<Map<String, dynamic>> rows) =>
            rows.map(Store.fromJson).toList(),
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
        optimisticBalance: clearUpgrading ? null : (optimisticBalance ?? this.optimisticBalance),
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
}

final StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>
    upgradeStoreProvider =
    StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>(
  (_) => UpgradeStoreNotifier(),
);
