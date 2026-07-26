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

class FirstStoreState {
  const FirstStoreState({
    this.isSubmitting = false,
    this.idempotencyKey,
    this.errorMessage,
    this.result,
  });

  final bool isSubmitting;
  final String? idempotencyKey;
  final String? errorMessage;
  final Map<String, dynamic>? result;

  FirstStoreState copyWith({
    bool? isSubmitting,
    String? idempotencyKey,
    String? errorMessage,
    Map<String, dynamic>? result,
    bool clearError = false,
  }) {
    return FirstStoreState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: result ?? this.result,
    );
  }
}

class FirstStoreNotifier extends StateNotifier<FirstStoreState> {
  FirstStoreNotifier() : super(const FirstStoreState());

  Future<bool> open({
    required String storeType,
    required String priceTier,
    required int inventoryCapacity,
  }) async {
    if (state.isSubmitting) return false;
    final String idempotencyKey = state.idempotencyKey ?? const Uuid().v4();
    state = FirstStoreState(
      isSubmitting: true,
      idempotencyKey: idempotencyKey,
    );
    try {
      final Map<String, dynamic> result = await SupabaseService.invokeFunction(
        SupabaseConstants.fnOpenFirstStore,
        body: <String, dynamic>{
          'store_type': storeType,
          'price_tier': priceTier,
          'inventory_capacity': inventoryCapacity,
          'idempotency_key': idempotencyKey,
        },
      );
      if (mounted) {
        state = FirstStoreState(
          idempotencyKey: idempotencyKey,
          result: result,
        );
      }
      return result['success'] == true;
    } on Exception catch (error) {
      if (mounted) {
        final String raw = error.toString();
        state = FirstStoreState(
          idempotencyKey: idempotencyKey,
          errorMessage: raw.contains('INSUFFICIENT_CAPITAL')
              ? 'INSUFFICIENT CAPITAL'
              : raw.contains('MOGUL_ONLY')
                  ? 'THIS OPERATION IS FOR MOGULS ONLY'
                  : raw.contains('FIRST_STORE_ALREADY_OPEN')
                      ? 'YOUR FIRST STORE IS ALREADY OPEN'
                      : 'STORE OPENING FAILED — TRY AGAIN',
        );
      }
      return false;
    }
  }

  void clearError() {
    if (mounted) state = state.copyWith(clearError: true);
  }
}

final StateNotifierProvider<FirstStoreNotifier, FirstStoreState>
    firstStoreProvider =
    StateNotifierProvider<FirstStoreNotifier, FirstStoreState>(
  (Ref<FirstStoreState> _) => FirstStoreNotifier(),
);

// ---------------------------------------------------------------------------
// Store stream — Realtime-backed list of the authenticated player's stores.
// ---------------------------------------------------------------------------

Stream<List<Store>> _pollStores(String playerId) async* {
  while (true) {
    final List<Map<String, dynamic>> rows = await SupabaseService.client
        .schema('api')
        .from('store_summary')
        .select()
        .eq('player_id', playerId);
    yield rows.map(Store.fromJson).toList(growable: false);
    await Future<void>.delayed(const Duration(seconds: 30));
  }
}

final StreamProvider<List<Store>> ledgerStoresStreamProvider =
    StreamProvider<List<Store>>((Ref<AsyncValue<List<Store>>> ref) {
  final String uid = ref.watch(activeUidProvider);
  if (uid.isEmpty) return const Stream<List<Store>>.empty();
  return _pollStores(uid);
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
    state = const UpgradeStoreState(
      errorMessage: 'STORE UPGRADES ARE UNAVAILABLE IN THE KINGSTON BUILD',
    );
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
