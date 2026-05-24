// Directive I — Casting Provider
// GDD §8.10 — Server-authoritative gacha with suspenseful UX state
// Alabaster Standard: Never trust client RNG, heavy haptics, 120fps

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../domain/models/brand.dart';
import '../../hq/providers/hq_provider.dart';
import '../models/talent.dart';

// =============================================================================
// Casting State
// =============================================================================

class CastingState {
  const CastingState({
    this.isLoading = false,
    this.lastResult,
    this.errorMessage,
    this.isRevealing = false,
    this.currentRevealIndex = 0,
  });

  final bool isLoading;
  final CastingResult? lastResult;
  final String? errorMessage;
  final bool isRevealing; // For staggered dossier animation
  final int currentRevealIndex; // Which pull is currently being revealed

  bool get hasError => errorMessage != null;
  bool get hasResult => lastResult != null;

  CastingState copyWith({
    bool? isLoading,
    CastingResult? lastResult,
    String? errorMessage,
    bool? isRevealing,
    int? currentRevealIndex,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return CastingState(
      isLoading: isLoading ?? this.isLoading,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRevealing: isRevealing ?? this.isRevealing,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
    );
  }
}

// =============================================================================
// Casting Notifier
// =============================================================================

class CastingNotifier extends StateNotifier<CastingState> {
  CastingNotifier() : super(const CastingState());

  /// Execute a casting pull (single or ten)
  ///
  /// Flow:
  /// 1. Set loading state
  /// 2. Execute server-authoritative RPC
  /// 3. Store result
  /// 4. Begin staggered reveal animation
  Future<void> executePull({bool isTenPull = false}) async {
    if (state.isLoading || state.isRevealing) return;

    // Haptic: Initial press feedback
    await HapticFeedback.mediumImpact();

    state =
        state.copyWith(isLoading: true, clearError: true, clearResult: true);

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String userId = supabase.auth.currentUser!.id;

      // Server-authoritative pull
      final Map<String, dynamic> result = await supabase.rpc(
        SupabaseConstants.fnExecuteCastingPull,
        params: <String, dynamic>{
          'p_player_id': userId,
          'p_banner_id': 'standard',
          'p_is_ten_pull': isTenPull,
        },
      );

      if (result['success'] == true) {
        final List<dynamic> pullsJson = result['pulls'] as List<dynamic>;
        final List<PullResult> pulls = pullsJson
            .map((json) => PullResult.fromJson(json as Map<String, dynamic>))
            .toList();

        final CastingResult castingResult = CastingResult(
          pulls: pulls,
          luxeSpent: result['luxe_spent'] as int,
          prestigeEarned: result['prestige_earned'] as int,
          message: result['message'] as String?,
        );

        state = state.copyWith(
          isLoading: false,
          lastResult: castingResult,
          isRevealing: true,
          currentRevealIndex: 0,
        );

        // Begin staggered reveal with haptics
        await _executeStaggeredReveal(pulls.length);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String? ?? 'Casting failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Casting error: $e',
      );
    }
  }

  /// Staggered reveal animation with heavy haptics
  Future<void> _executeStaggeredReveal(int pullCount) async {
    for (int i = 0; i < pullCount; i++) {
      // Heavy thud as dossier slides in
      await HapticFeedback.heavyImpact();

      state = state.copyWith(currentRevealIndex: i + 1);

      // Delay between reveals (longer for dramatic tension)
      final int delayMs = pullCount == 1
          ? 1500 // Single pull: dramatic pause
          : 800; // Ten-pull: faster but still weighty

      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    // Final completion haptic
    await HapticFeedback.vibrate();

    state = state.copyWith(isRevealing: false);
  }

  /// Skip reveal animation (for impatient whales)
  void skipReveal() {
    if (!state.isRevealing) return;

    state = state.copyWith(
      isRevealing: false,
      currentRevealIndex: state.lastResult?.pulls.length ?? 0,
    );
  }

  /// Reset state for next pull
  void reset() {
    state = const CastingState();
  }
}

// =============================================================================
// Riverpod Providers
// =============================================================================

final StateNotifierProvider<CastingNotifier, CastingState> castingProvider =
    StateNotifierProvider<CastingNotifier, CastingState>(
  (Ref<CastingState> ref) => CastingNotifier(),
);

/// Stream of player's roster
final StreamProvider<List<RosterTalent>> playerRosterProvider =
    StreamProvider<List<RosterTalent>>(
        (Ref<AsyncValue<List<RosterTalent>>> ref) {
  final SupabaseClient supabase = Supabase.instance.client;
  final String? userId = supabase.auth.currentUser?.id;

  if (userId == null) return const Stream<List<RosterTalent>>.empty();

  // Poll roster via RPC (no direct table stream needed for simplicity)
  return Stream<int>.periodic(const Duration(seconds: 5), (int i) => i)
      .asyncMap((int _) async {
    final List<dynamic> result = await supabase.rpc(
      'get_player_roster',
      params: <String, dynamic>{'p_player_id': userId},
    );
    return result
        .map((json) => RosterTalent.fromJson(json as Map<String, dynamic>))
        .toList();
  });
});

/// Alias for playerRosterProvider (GDD §8.10)
final StreamProvider<List<RosterTalent>> rosterProvider = playerRosterProvider;

/// Pity state provider
final FutureProvider<PityState> pityStateProvider =
    FutureProvider<PityState>((Ref<AsyncValue<PityState>> ref) async {
  final SupabaseClient supabase = Supabase.instance.client;
  final String? userId = supabase.auth.currentUser?.id;

  if (userId == null) throw Exception('Not authenticated');

  final Map<String, dynamic> result = await supabase
      .from('gacha_pity_state')
      .select()
      .eq('player_id', userId)
      .eq('banner_id', 'standard')
      .single();

  return PityState.fromJson(result);
});

/// Available Luxe tokens for casting
final Provider<AsyncValue<int>> availableLuxeProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  final AsyncValue<Brand> brandAsync = ref.watch(hqBrandStreamProvider);
  return brandAsync.when(
    data: (Brand brand) => AsyncValue.data(brand.luxeTokens),
    loading: () => const AsyncValue.loading(),
    error: (Object e, StackTrace s) => AsyncValue.error(e, s),
  );
});

/// Can afford single pull?
final Provider<bool> canAffordSinglePullProvider =
    Provider<bool>((Ref<bool> ref) {
  final AsyncValue<int> luxeAsync = ref.watch(availableLuxeProvider);
  return luxeAsync.when(
    data: (int luxe) => luxe >= TalentTierExtension.castingCost,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Can afford ten pull?
final Provider<bool> canAffordTenPullProvider = Provider<bool>((Ref<bool> ref) {
  final AsyncValue<int> luxeAsync = ref.watch(availableLuxeProvider);
  return luxeAsync.when(
    data: (int luxe) => luxe >= TalentTierExtension.castingCostTen,
    loading: () => false,
    error: (_, __) => false,
  );
});
