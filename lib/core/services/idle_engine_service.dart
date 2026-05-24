// GDD §3.3, §12.1.2 — Idle income engine with Supply Chain constraints
// PROJECT_RULES §3 — Server-authoritative: player_id from JWT, client clock IGNORED.
// Implements WidgetsBindingObserver to fire on resume + 60s periodic timer.
// Concurrency mutex (_isCalculating) prevents overlapping invocations.
//
// Directive L: Revenue now adds to inventory (capped by warehouse_capacity).
// Atomic catch-up: O(1) single RPC call handles all offline time.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/supabase_constants.dart';
import 'supabase_service.dart';

/// Result from the server-side idle income calculation.
///
/// Directive L: Now includes inventory state (not just revenue)
class IdleIncomeResult {
  const IdleIncomeResult({
    required this.addedToInventory,
    required this.inventoryValue,
    required this.warehouseCapacity,
    required this.isWarehouseFull,
    required this.secondsElapsed,
    this.idleRevenuePerHour = 0.0,
  });

  final double addedToInventory; // Amount actually added (capped)
  final double inventoryValue; // Current inventory level
  final double warehouseCapacity; // Max capacity
  final bool isWarehouseFull; // True if at capacity
  final double secondsElapsed; // Time calculated
  final double idleRevenuePerHour; // Generation rate

  /// Fill percentage (0.0 to 100.0+)
  double get fillPercent =>
      warehouseCapacity > 0 ? (inventoryValue / warehouseCapacity) * 100 : 0.0;

  bool get needsLiquidation => isWarehouseFull;
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
      // Directive L: Atomic catch-up using process_idle_income RPC
      // O(1) complexity - single call handles all offline time calculation
      // Server clamps inventory to warehouse_capacity automatically
      final Map<String, dynamic> response =
          await SupabaseService.invokeFunction(
        SupabaseConstants.fnProcessIdleIncome,
      );

      final IdleIncomeResult result = IdleIncomeResult(
        addedToInventory:
            (response['added_to_inventory'] as num?)?.toDouble() ?? 0.0,
        inventoryValue: (response['new_inventory'] as num?)?.toDouble() ?? 0.0,
        warehouseCapacity:
            (response['warehouse_capacity'] as num?)?.toDouble() ?? 5000.0,
        isWarehouseFull: response['is_full'] as bool? ?? false,
        secondsElapsed:
            (response['seconds_elapsed'] as num?)?.toDouble() ?? 0.0,
        idleRevenuePerHour:
            (response['idle_revenue_per_hour'] as num?)?.toDouble() ?? 0.0,
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
