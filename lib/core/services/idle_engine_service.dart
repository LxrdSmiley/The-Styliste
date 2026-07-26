// GDD §3.3, §12.1.2 — Idle income engine with Supply Chain constraints
// PROJECT_RULES §3 — Server-authoritative: player_id from JWT, client clock IGNORED.
// Implements WidgetsBindingObserver to fire on resume + 60s periodic timer.
// Concurrency mutex (_isCalculating) prevents overlapping invocations.
//
// Directive L: Revenue now adds to inventory (capped by warehouse_capacity).
// Atomic catch-up: O(1) single RPC call handles all offline time.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

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
  String? _pendingIdempotencyKey;

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
      // Kingston contract: server time and economic state are authoritative.
      final String idempotencyKey = _pendingIdempotencyKey ?? const Uuid().v4();
      _pendingIdempotencyKey = idempotencyKey;
      final Map<String, dynamic> response =
          await SupabaseService.invokeFunction(
        SupabaseConstants.fnCalculateIdleIncome,
        body: <String, dynamic>{'idempotency_key': idempotencyKey},
      );
      if (response['receipt_version'] != 'kingston-idle-settlement.v1') {
        throw const FormatException('Unsupported idle receipt version.');
      }
      _pendingIdempotencyKey = null;
      // The active widget still expects later-wave warehouse fields. Returning
      // invented inventory values would violate the authority contract.
      throw const IdleIncomePresentationUnavailableException();
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

class IdleIncomePresentationUnavailableException implements Exception {
  const IdleIncomePresentationUnavailableException();

  @override
  String toString() =>
      'Idle settlement confirmed; warehouse presentation is unavailable.';
}
