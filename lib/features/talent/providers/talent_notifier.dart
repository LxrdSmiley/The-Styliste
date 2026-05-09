// Directive O — Talent Notifier
// GDD §8.10 — Staff Rally mini-game wiring

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';

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
  Future<Map<String, dynamic>> applyStaffRallyResult({required bool won}) async {
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

        // Reset talent stamina to 100%
        final Map<String, dynamic> result = await supabase.rpc(
          'reset_talent_stamina',
          params: <String, dynamic>{
            'p_player_id': userId,
            'p_talent_id': talentId,
          },
        );

        state = state.copyWith(isLoading: false);
        return result as Map<String, dynamic>;
      } else {
        // Apply 24h cooldown
        final DateTime cooldownUntil = DateTime.now().add(const Duration(hours: 24));

        // Update local state
        state = state.copyWith(
          isLoading: false,
          rallyCooldownUntil: cooldownUntil,
        );

        // Store cooldown in Supabase (using player_talent_roster)
        if (talentId != null) {
          await supabase
              .from('player_talent_roster')
              .update(<String, dynamic>{
                'gala_cooldown_until': cooldownUntil.toIso8601String(),
              })
              .eq('player_id', userId)
              .eq('talent_id', talentId);
        }

        return <String, dynamic>{
          'success': true,
          'cooldown_hours': 24,
          'cooldown_until': cooldownUntil.toIso8601String(),
          'message': 'Talent needs 24h rest before next Gala assignment',
        };
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
