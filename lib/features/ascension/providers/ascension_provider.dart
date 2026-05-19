// GDD v6 §3.5 — Ascension Provider
// Rank 50 Joint Venture & Rank 100 Memorialization
// Alabaster Standard: Permanent prestige, account-wide multipliers

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../models/sovereign_statue.dart';

part 'ascension_provider.g.dart';

/// Ascension operation state
class AscensionState {
  const AscensionState({
    this.isUnlockingJointVenture = false,
    this.isMemorializing = false,
    this.holdProgress = 0.0,
    this.lastResult,
    this.errorMessage,
  });

  final bool isUnlockingJointVenture;
  final bool isMemorializing;
  final double holdProgress; // 0.0 to 1.0 for biometric hold
  final AscensionResult? lastResult;
  final String? errorMessage;

  bool get isLoading => isUnlockingJointVenture || isMemorializing;
  bool get isHolding => holdProgress > 0.0 && holdProgress < 1.0;

  AscensionState copyWith({
    bool? isUnlockingJointVenture,
    bool? isMemorializing,
    double? holdProgress,
    AscensionResult? lastResult,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AscensionState(
      isUnlockingJointVenture:
          isUnlockingJointVenture ?? this.isUnlockingJointVenture,
      isMemorializing: isMemorializing ?? this.isMemorializing,
      holdProgress: holdProgress ?? this.holdProgress,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Result of ascension operation
class AscensionResult {
  const AscensionResult({
    required this.success,
    required this.message,
    this.sovereignCount,
    this.statueTier,
  });

  final bool success;
  final String message;
  final int? sovereignCount;
  final StatueTier? statueTier;

  factory AscensionResult.fromRpc(Map<String, dynamic> json) {
    return AscensionResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      sovereignCount: json['sovereign_count'] as int?,
      statueTier: json['statue_tier'] != null
          ? StatueTier.values.firstWhere(
              (StatueTier t) =>
                  t.name == (json['statue_tier'] as String).toLowerCase(),
              orElse: () => StatueTier.quartz,
            )
          : null,
    );
  }
}

/// Notifier for ascension operations
class AscensionNotifier extends StateNotifier<AscensionState> {
  AscensionNotifier() : super(const AscensionState());

  Timer? _holdTimer;
  static const Duration _holdDuration = Duration(milliseconds: 3000);
  static const Duration _hapticInterval = Duration(milliseconds: 1000);

  // ---------------------------------------------------------------------------
  // Rank 50: Unlock Joint Venture
  // ---------------------------------------------------------------------------

  Future<void> unlockJointVenture() async {
    if (state.isLoading) return;

    state = state.copyWith(isUnlockingJointVenture: true, clearError: true);

    try {
      final Map<String, dynamic> result = await Supabase.instance.client.rpc(
        SupabaseConstants.fnUnlockJointVenture,
        params: <String, dynamic>{
          'p_player_id': Supabase.instance.client.auth.currentUser!.id,
        },
      );

      final AscensionResult ascensionResult = AscensionResult.fromRpc(result);

      state = state.copyWith(
        isUnlockingJointVenture: false,
        lastResult: ascensionResult,
      );
    } catch (e) {
      state = state.copyWith(
        isUnlockingJointVenture: false,
        errorMessage: 'Failed to unlock Joint Venture: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Rank 100: Memorialization with Biometric Hold
  // ---------------------------------------------------------------------------

  /// Start biometric hold (like Aurelian Gate)
  void startHold() {
    if (state.isMemorializing || state.isHolding) return;

    // Initial haptic
    unawaited(HapticFeedback.heavyImpact());

    // Start progress timer
    final DateTime startTime = DateTime.now();
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (Timer timer) {
        final Duration elapsed = DateTime.now().difference(startTime);
        final double progress =
            (elapsed.inMilliseconds / _holdDuration.inMilliseconds)
                .clamp(0.0, 1.0);

        // Haptic heartbeat every second
        if (elapsed.inMilliseconds % _hapticInterval.inMilliseconds < 50) {
          unawaited(HapticFeedback.heavyImpact());
        }

        state = state.copyWith(holdProgress: progress);

        if (progress >= 1.0) {
          timer.cancel();
          unawaited(_executeMemorialization());
        }
      },
    );
  }

  /// Cancel biometric hold
  void cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    state = state.copyWith(holdProgress: 0.0);
  }

  /// Execute memorialization after successful hold
  Future<void> _executeMemorialization() async {
    state = state.copyWith(isMemorializing: true);

    try {
      // Get current player data for brand name
      final Map<String, dynamic> playerData = await Supabase.instance.client
          .from(SupabaseConstants.tablePlayers)
          .select('brand_name')
          .eq('id', Supabase.instance.client.auth.currentUser!.id)
          .single();

      final String brandName = playerData['brand_name'] as String;

      final Map<String, dynamic> result = await Supabase.instance.client.rpc(
        SupabaseConstants.fnExecuteMemorialization,
        params: <String, dynamic>{
          'p_player_id': Supabase.instance.client.auth.currentUser!.id,
          'p_brand_name': brandName,
        },
      );

      final AscensionResult ascensionResult = AscensionResult.fromRpc(result);

      state = state.copyWith(
        isMemorializing: false,
        holdProgress: 0.0,
        lastResult: ascensionResult,
      );
    } catch (e) {
      state = state.copyWith(
        isMemorializing: false,
        holdProgress: 0.0,
        errorMessage: 'Memorialization failed: $e',
      );
    }
  }

  /// Clear state after user acknowledges
  void clear() {
    _holdTimer?.cancel();
    _holdTimer = null;
    state = const AscensionState();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }
}

/// Provider for ascension operations
final StateNotifierProvider<AscensionNotifier, AscensionState>
    ascensionProvider =
    StateNotifierProvider<AscensionNotifier, AscensionState>(
  (Ref<AscensionState> ref) => AscensionNotifier(),
);

/// Stream of player's memorialized statues
@riverpod
Stream<List<SovereignStatue>> playerStatues(Ref ref, String playerId) {
  return Supabase.instance.client
      .from(SupabaseConstants.tableHallOfSovereigns)
      .stream(primaryKey: const <String>['id'])
      .eq('player_id', playerId)
      .order('ascended_at')
      .map((List<Map<String, dynamic>> data) {
        return data
            .map((Map<String, dynamic> json) => SovereignStatue.fromJson(json))
            .toList();
      });
}

/// Stream of all statues in Hall of Sovereigns (global gallery)
@riverpod
Stream<List<SovereignStatue>> hallOfSovereigns(Ref ref) {
  return Supabase.instance.client
      .from(SupabaseConstants.tableHallOfSovereigns)
      .stream(primaryKey: const <String>['id'])
      .order('ascended_at')
      .limit(100)
      .map((List<Map<String, dynamic>> data) {
        return data
            .map((Map<String, dynamic> json) => SovereignStatue.fromJson(json))
            .toList();
      });
}

/// Computed: Total sovereign multipliers for current user
final Provider<AsyncValue<int>> currentSovereignMultipliersProvider =
    Provider<AsyncValue<int>>((Ref<AsyncValue<int>> ref) {
  // This would need to be connected to player provider
  // For now return loading
  return const AsyncValue<int>.loading();
});

/// Computed: Can current user memorialize?
final Provider<AsyncValue<bool>> canMemorializeProvider =
    Provider<AsyncValue<bool>>((Ref<AsyncValue<bool>> ref) {
  // This would need to check player rank
  // For now return loading
  return const AsyncValue<bool>.loading();
});
