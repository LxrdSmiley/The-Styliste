// GDD 3.3, 12.1.2 - Idle income engine with Supply Chain constraints.
// PROJECT_RULES 3 - Server-authoritative: player_id from JWT, client clock ignored.
// Implements WidgetsBindingObserver to fire on resume plus a 60s periodic timer.
// Concurrency mutex prevents overlapping invocations.
//
// Directive L: revenue now adds to inventory, capped by warehouse_capacity.
// Atomic catch-up: one RPC call handles offline time.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/supabase_constants.dart';
import 'supabase_service.dart';

/// Result from the server-side idle income calculation.
class IdleIncomeResult {
  const IdleIncomeResult({
    required this.addedToInventory,
    required this.inventoryValue,
    required this.warehouseCapacity,
    required this.isWarehouseFull,
    required this.secondsElapsed,
    this.idleRevenuePerHour = 0.0,
  });

  factory IdleIncomeResult.fromRpcResponse(Object? response) {
    final Map<String, dynamic> row = _firstRpcRow(response);
    return IdleIncomeResult(
      addedToInventory:
          (row['added_to_inventory'] as num?)?.toDouble() ?? 0.0,
      inventoryValue: (row['new_inventory'] as num?)?.toDouble() ?? 0.0,
      warehouseCapacity:
          (row['warehouse_capacity'] as num?)?.toDouble() ?? 5000.0,
      isWarehouseFull: row['is_full'] as bool? ?? false,
      secondsElapsed: (row['seconds_elapsed'] as num?)?.toDouble() ?? 0.0,
      idleRevenuePerHour:
          (row['idle_revenue_per_hour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final double addedToInventory;
  final double inventoryValue;
  final double warehouseCapacity;
  final bool isWarehouseFull;
  final double secondsElapsed;
  final double idleRevenuePerHour;

  double get fillPercent =>
      warehouseCapacity > 0 ? (inventoryValue / warehouseCapacity) * 100 : 0.0;

  bool get needsLiquidation => isWarehouseFull;

  static Map<String, dynamic> _firstRpcRow(Object? response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response is List && response.isNotEmpty) {
      final Object? first = response.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }

    throw FormatException(
      'process_idle_income returned ${response.runtimeType}, expected row.',
    );
  }
}

typedef OnIdleIncomeResult = void Function(IdleIncomeResult result);

typedef IdleIncomeRpcInvoker = Future<Object?> Function({
  required String playerId,
});

class IdleEngineService with WidgetsBindingObserver {
  IdleEngineService({
    required this.onResult,
    IdleIncomeRpcInvoker? rpcInvoker,
  }) : _rpcInvoker = rpcInvoker ?? _invokeProcessIdleIncomeRpc {
    WidgetsBinding.instance.addObserver(this);
  }

  final OnIdleIncomeResult onResult;
  final IdleIncomeRpcInvoker _rpcInvoker;

  Timer? _periodicTimer;
  bool _isCalculating = false;

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
    _triggerIdleCalc();
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

  void _triggerIdleCalc() {
    if (_isCalculating) return;
    _isCalculating = true;
    _invokeAndNotify().whenComplete(() => _isCalculating = false);
  }

  Future<void> _invokeAndNotify() async {
    try {
      await SupabaseService.ensureFreshSession();
      final String? playerId = SupabaseService.currentUserId;
      if (playerId == null || playerId.isEmpty) {
        throw const SupabaseSessionExpiredException();
      }

      final Object? response = await _rpcInvoker(playerId: playerId);
      final IdleIncomeResult result =
          IdleIncomeResult.fromRpcResponse(response);

      onResult(result);
    } catch (e) {
      debugPrint('IdleEngineService: RPC error - $e');
    }
  }

  static Future<Object?> _invokeProcessIdleIncomeRpc({
    required String playerId,
  }) {
    return SupabaseService.client.rpc(
      SupabaseConstants.fnProcessIdleIncome,
      params: <String, dynamic>{'p_player_id': playerId},
    );
  }

  void dispose() {
    _periodicTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
