// GDD §3.3 — Idle income engine (Phase 3 — lifecycle observer + mutex)
// PROJECT_RULES §3 — Server-authoritative: player_id from JWT, client clock IGNORED.
// Implements WidgetsBindingObserver to fire on resume + 60s periodic timer.
// Concurrency mutex (_isCalculating) prevents overlapping invocations.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/supabase_constants.dart';
import 'supabase_service.dart';

/// Result from the server-side idle income calculation.
class IdleIncomeResult {
  const IdleIncomeResult({
    required this.earnedAmount,
    required this.newTotalRevenue,
    required this.multiplier,
    required this.decayFactor,
    required this.momentumBuffActive,
  });

  final double earnedAmount;
  final double newTotalRevenue;
  final double multiplier;
  final double decayFactor;
  final bool momentumBuffActive;
}

/// Callback type: invoked every time the edge function returns a result.
typedef OnIdleIncomeResult = void Function(IdleIncomeResult result);

class IdleEngineService with WidgetsBindingObserver {
  IdleEngineService({required this.onResult}) {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Called whenever a new IdleIncomeResult arrives.
  final OnIdleIncomeResult onResult;

  Timer? _periodicTimer;

  /// Concurrency mutex — prevents overlapping edge function calls.
  bool _isCalculating = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _onPaused();
      default:
        break;
    }
  }

  void _onResumed() {
    // Immediate trigger on foreground.
    _triggerIdleCalc();
    // Periodic trigger while foregrounded (keeps last_active_at fresh).
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _triggerIdleCalc(),
    );
  }

  void _onPaused() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Core invocation
  // ---------------------------------------------------------------------------

  /// Triggers the edge function. Drops the call silently if one is in flight.
  void _triggerIdleCalc() {
    if (_isCalculating) return;
    _isCalculating = true;
    // Fire-and-forget; errors are caught inside.
    _invokeAndNotify().whenComplete(() => _isCalculating = false);
  }

  Future<void> _invokeAndNotify() async {
    try {
      // No body — player_id is extracted from the JWT by the edge function.
      final Map<String, dynamic> response =
          await SupabaseService.invokeFunction(
        SupabaseConstants.fnCalculateIdleIncome,
      );

      final IdleIncomeResult result = IdleIncomeResult(
        earnedAmount: (response['earned_amount'] as num).toDouble(),
        newTotalRevenue: (response['new_total_revenue'] as num).toDouble(),
        multiplier: (response['multiplier'] as num).toDouble(),
        decayFactor: (response['decay_factor'] as num).toDouble(),
        momentumBuffActive: response['momentum_buff_active'] as bool,
      );

      onResult(result);
    } catch (e) {
      // Non-fatal: economy errors must never crash the app.
      debugPrint('IdleEngineService: edge function error — $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    _periodicTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
