import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/constants/supabase_constants.dart';
import 'package:the_styliste/core/services/idle_engine_service.dart';

void main() {
  group('IdleIncomeResult.fromRpcResponse', () {
    test('normalizes a direct RPC row object', () {
      final IdleIncomeResult result = IdleIncomeResult.fromRpcResponse(
        <String, Object?>{
          'added_to_inventory': 125,
          'new_inventory': 2125,
          'warehouse_capacity': 5000,
          'is_full': false,
          'idle_revenue_per_hour': 750.5,
          'seconds_elapsed': 600,
        },
      );

      expect(result.addedToInventory, 125);
      expect(result.inventoryValue, 2125);
      expect(result.warehouseCapacity, 5000);
      expect(result.isWarehouseFull, isFalse);
      expect(result.idleRevenuePerHour, 750.5);
      expect(result.secondsElapsed, 600);
    });

    test('normalizes the first row from table-shaped RPC output', () {
      final IdleIncomeResult result = IdleIncomeResult.fromRpcResponse(
        <Map<String, Object?>>[
          <String, Object?>{
            'added_to_inventory': 0,
            'new_inventory': 5000,
            'is_full': true,
            'idle_revenue_per_hour': 500,
            'seconds_elapsed': 0,
          },
        ],
      );

      expect(result.addedToInventory, 0);
      expect(result.inventoryValue, 5000);
      expect(result.warehouseCapacity, 5000);
      expect(result.isWarehouseFull, isTrue);
      expect(result.idleRevenuePerHour, 500);
      expect(result.secondsElapsed, 0);
    });

    test('rejects empty RPC output', () {
      expect(
        () => IdleIncomeResult.fromRpcResponse(<Map<String, Object?>>[]),
        throwsFormatException,
      );
    });
  });

  test('IdleEngineService uses the authoritative idle settlement function', () {
    final String source =
        File('lib/core/services/idle_engine_service.dart').readAsStringSync();

    expect(source, contains('SupabaseConstants.fnCalculateIdleIncome'));
    expect(source, contains("'idempotency_key': idempotencyKey"));
    expect(source, contains("'kingston-idle-settlement.v1'"));
    expect(source, isNot(contains('fnProcessIdleIncome')));
    expect(SupabaseConstants.fnCalculateIdleIncome, 'calculate-idle-income');
  });
}
