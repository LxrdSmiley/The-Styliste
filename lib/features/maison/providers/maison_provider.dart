// GDD §7.2 — Maison Treasury Riverpod providers (Phase 8).
// MaisonDonateState: optimistic balance deduction + spinner + error propagation.
// MaisonDonateNotifier: calls maison-donate Edge Function, applies haptic
//   feedback (mediumImpact on submit, heavyImpact on error — matching Ledger).
// Realtime brand_state stream (hqBrandStreamProvider) reconciles balance on success.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

// ---------------------------------------------------------------------------
// Donate state — mirrors UpgradeStoreState pattern from Phase 5 Ledger.
// ---------------------------------------------------------------------------

class MaisonDonateState {
  const MaisonDonateState({
    this.isDonating = false,
    this.optimisticDeduction = 0.0,
    this.errorMessage,
  });

  final bool isDonating;

  /// Optimistic balance reduction shown locally before stream reconciles.
  final double optimisticDeduction;

  /// Set on error; cleared after SnackBar consumed via clearError().
  final String? errorMessage;

  MaisonDonateState copyWith({
    bool? isDonating,
    double? optimisticDeduction,
    String? errorMessage,
    bool clearError = false,
    bool clearDonating = false,
  }) =>
      MaisonDonateState(
        isDonating: clearDonating ? false : (isDonating ?? this.isDonating),
        optimisticDeduction:
            clearDonating ? 0.0 : (optimisticDeduction ?? this.optimisticDeduction),
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

// ---------------------------------------------------------------------------
// MaisonDonateNotifier
// ---------------------------------------------------------------------------

class MaisonDonateNotifier extends StateNotifier<MaisonDonateState> {
  MaisonDonateNotifier() : super(const MaisonDonateState());

  /// Donate [amount] to the player's Maison treasury.
  /// Slider enforces whole-number rounding — floor here as server-side guard.
  Future<void> donate(double amount) async {
    final double roundedAmount = amount.floorToDouble();
    if (roundedAmount <= 0) return;

    // 1. Optimistic deduction + spinner.
    state = MaisonDonateState(
      isDonating: true,
      optimisticDeduction: roundedAmount,
    );
    await HapticFeedback.mediumImpact();

    try {
      final FunctionResponse result = await SupabaseService.client.functions.invoke(
        SupabaseConstants.fnMaisonDonate,
        body: <String, dynamic>{'amount': roundedAmount},
      );

      // Edge Function returns FunctionResponse — check for error payload.
      final Map<String, dynamic>? data =
          result.data as Map<String, dynamic>?;
      if (data != null && data['error'] != null) {
        throw Exception(data['error'] as String);
      }

      // 2. Success: clear optimistic state. Realtime stream reconciles balance.
      if (mounted) state = const MaisonDonateState();
    } on Exception catch (e) {
      await HapticFeedback.heavyImpact();
      if (mounted) {
        final String msg = e.toString();
        state = MaisonDonateState(
          errorMessage: msg.contains('INSUFFICIENT_CAPITAL')
              ? 'INSUFFICIENT CAPITAL'
              : msg.contains('NOT_A_MEMBER')
                  ? 'NO MAISON AFFILIATION'
                  : 'CONTRIBUTION FAILED — TRY AGAIN',
        );
      }
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final StateNotifierProvider<MaisonDonateNotifier, MaisonDonateState>
    maisonDonateProvider =
    StateNotifierProvider<MaisonDonateNotifier, MaisonDonateState>(
  (_) => MaisonDonateNotifier(),
);
