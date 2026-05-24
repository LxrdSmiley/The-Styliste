// GDD §5.2 — Ledger Riverpod providers (Phase 5).
// ledgerStoresStreamProvider: Realtime stream of player's stores list.
// upgradeStoreProvider: StateNotifier managing optimistic upgrade UX state.

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionResponse, Session;

import '../../../core/constants/supabase_constants.dart';
import '../../../core/providers/active_player_provider.dart';
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
  Future<Map<String, dynamic>> applyPriceWarResult({required bool won}) async {
    try {
      final Session? session = SupabaseService.client.auth.currentSession;
      if (session == null) {
        return <String, dynamic>{
          'success': false,
          'error': 'Not authenticated',
        };
      }

      final FunctionResponse response =
          await SupabaseService.client.functions.invoke(
        'claim-mini-game-reward',
        body: <String, dynamic>{
          'game_key': 'price_war',
          'result_key': won ? 'standard_win' : 'loss',
        },
        headers: <String, String>{
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': 'Failed to apply price war result: $e',
      };
    }
  }

  /// Apply Power Move Combo: store multiplier for next liquidation
<<<<<<< HEAD
  Future<Map<String, dynamic>> applyPowerMoveCombo(
      {required double multiplier}) async {
=======
  Future<Map<String, dynamic>> applyPowerMoveCombo({
    required double multiplier,
  }) async {
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
    try {
      await SupabaseService.client
          .from(SupabaseConstants.tableBrandState)
          .update(<String, dynamic>{
        'pending_power_move_multiplier': multiplier,
        'power_move_expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      }).eq('player_id', SupabaseService.client.auth.currentUser!.id);

      return <String, dynamic>{
        'success': true,
        'multiplier': multiplier,
        'expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': 'Failed to store power move combo: $e',
      };
    }
  }

  /// Apply Hostile Takeover result: inject 5000 Capital if 100% ownership
<<<<<<< HEAD
  Future<Map<String, dynamic>> applyTakeoverResult(
      {required double finalPct}) async {
=======
  Future<Map<String, dynamic>> applyTakeoverResult({
    required double finalPct,
  }) async {
>>>>>>> b82f5aa0df7cf605d44fb4b2ee0b34ca518f7b9e
    if (finalPct != 100.0) {
      return <String, dynamic>{
        'success': false,
        'reason': 'Takeover incomplete: $finalPct%',
      };
    }

    try {
      final Session? session = SupabaseService.client.auth.currentSession;
      if (session == null) {
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
      return Map<String, dynamic>.from(response.data as Map<String, dynamic>);
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': 'Failed to inject takeover bonus: $e',
      };
    }
  }
}

final StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>
    upgradeStoreProvider =
    StateNotifierProvider<UpgradeStoreNotifier, UpgradeStoreState>(
  (_) => UpgradeStoreNotifier(),
);
