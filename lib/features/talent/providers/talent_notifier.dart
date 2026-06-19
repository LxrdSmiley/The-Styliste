// Directive O — Talent Notifier
// GDD §8.10 — Staff Rally mini-game wiring

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// Talent State
// =============================================================================

class TalentState {
  const TalentState({
    this.selectedTalentId,
    this.isLoading = false,
    this.errorMessage,
    this.rallyCooldownUntil,
  });

  final String? selectedTalentId;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? rallyCooldownUntil;

  bool get isOnCooldown =>
      rallyCooldownUntil != null &&
      DateTime.now().isBefore(rallyCooldownUntil!);

  TalentState copyWith({
    String? selectedTalentId,
    bool? isLoading,
    String? errorMessage,
    DateTime? rallyCooldownUntil,
    bool clearError = false,
    bool clearCooldown = false,
  }) {
    return TalentState(
      selectedTalentId: selectedTalentId ?? this.selectedTalentId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rallyCooldownUntil: clearCooldown
          ? null
          : (rallyCooldownUntil ?? this.rallyCooldownUntil),
    );
  }
}

// =============================================================================
// Talent Notifier
// =============================================================================

class TalentNotifier extends StateNotifier<TalentState> {
  TalentNotifier() : super(const TalentState());

  void selectTalent(String talentId) {
    state = state.copyWith(selectedTalentId: talentId);
  }

  /// Apply Staff Rally result
  /// Win = Reset stamina to 100%, Loss = 24h cooldown
  Future<Map<String, dynamic>> applyStaffRallyResult({
    required bool won,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;
      final String? talentId = state.selectedTalentId;

      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return <String, dynamic>{
          'success': false,
          'error': 'Not authenticated',
        };
      }

      if (won) {
        if (talentId == null) {
          state = state.copyWith(isLoading: false);
          return <String, dynamic>{
            'success': false,
            'error': 'No talent selected for rally',
          };
        }

        final Session? session = supabase.auth.currentSession;
        if (session == null) {
          state = state.copyWith(isLoading: false);
          return <String, dynamic>{
            'success': false,
            'error': 'Not authenticated',
          };
        }

        final FunctionResponse response = await supabase.functions.invoke(
          'claim-mini-game-reward',
          body: <String, dynamic>{
            'game_key': 'staff_rally',
            'result_key': 'stamina_reset',
            'talent_id': talentId,
          },
          headers: <String, String>{
            'Authorization': 'Bearer ${session.accessToken}',
          },
        );
        final Map<String, dynamic> result =
            Map<String, dynamic>.from(response.data as Map<String, dynamic>);

        state = state.copyWith(isLoading: false);
        return result;
      } else {
        if (talentId == null) {
          state = state.copyWith(isLoading: false);
          return <String, dynamic>{
            'success': false,
            'error': 'No talent selected for rally',
          };
        }

        final Session? session = supabase.auth.currentSession;
        if (session == null) {
          state = state.copyWith(isLoading: false);
          return <String, dynamic>{
            'success': false,
            'error': 'Not authenticated',
          };
        }

        final FunctionResponse response = await supabase.functions.invoke(
          'claim-mini-game-reward',
          body: <String, dynamic>{
            'game_key': 'staff_rally',
            'result_key': 'cooldown_loss',
            'talent_id': talentId,
          },
          headers: <String, String>{
            'Authorization': 'Bearer ${session.accessToken}',
          },
        );

        final Map<String, dynamic> result =
            Map<String, dynamic>.from(response.data as Map<String, dynamic>);

        if (result['success'] == true && result['cooldown_until'] != null) {
          final DateTime cooldownUntil =
              DateTime.parse(result['cooldown_until'] as String).toLocal();
          state = state.copyWith(
            isLoading: false,
            rallyCooldownUntil: cooldownUntil,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }

        return result;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Staff rally failed: $e',
      );
      return <String, dynamic>{
        'success': false,
        'error': 'Staff rally failed: $e',
      };
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearCooldown() {
    state = state.copyWith(clearCooldown: true);
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

final StateNotifierProvider<TalentNotifier, TalentState> talentProvider =
    StateNotifierProvider<TalentNotifier, TalentState>(
  (Ref<TalentState> ref) => TalentNotifier(),
);
