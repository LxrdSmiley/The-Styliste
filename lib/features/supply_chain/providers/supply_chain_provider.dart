// Directive L — Supply Chain Providers
// GDD §12.1.2 — Buffer Stock Engine state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../models/supply_chain_models.dart';

// =============================================================================
// Supply Chain State Stream
// =============================================================================

/// Real-time warehouse status from supply_chain_status view
final StreamProvider<SupplyChainState> supplyChainProvider =
    StreamProvider<SupplyChainState>((Ref<AsyncValue<SupplyChainState>> ref) {
  final SupabaseClient supabase = Supabase.instance.client;
  final String? userId = supabase.auth.currentUser?.id;

  if (userId == null) return const Stream<SupplyChainState>.empty();

  return supabase
      .from('supply_chain_status')
      .stream(primaryKey: <String>['player_id'])
      .eq('player_id', userId)
      .map((List<Map<String, dynamic>> data) {
        if (data.isEmpty) {
          return const SupplyChainState(); // Default state
        }
        return SupplyChainState.fromJson(data.first);
      });
});

// =============================================================================
// Liquidation State Notifier
// =============================================================================

class LiquidationNotifier extends StateNotifier<AsyncValue<LiquidationResult?>> {
  LiquidationNotifier() : super(const AsyncValue.data(null));

  Future<void> liquidate() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final Map<String, dynamic> result = await supabase.rpc(
        'execute_liquidation',
        params: <String, dynamic>{'p_player_id': userId},
      );

      final LiquidationResult liquidationResult = LiquidationResult(
        liquidatedAmount: (result['liquidated_amount'] as num?)?.toInt() ?? 0,
        newInventory: (result['new_inventory'] as num?)?.toInt() ?? 0,
        newRevenue: (result['new_revenue'] as num?)?.toDouble() ?? 0.0,
      );

      state = AsyncValue.data(liquidationResult);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  // ===========================================================================
  // Directive O: Flash Sale Frenzy — Liquidation with match bonus
  // ===========================================================================

  /// Liquidate stock with Flash Sale bonus
  /// matchCount = successful tier matches, bonus = matchCount * 50 Capital
  Future<Map<String, dynamic>> liquidateStock({required int matchCount}) async {
    final int bonus = matchCount * 50;

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return <String, dynamic>{
          'success': false,
          'error': 'Not authenticated',
        };
      }

      // Execute base liquidation
      final Map<String, dynamic> result = await supabase.rpc(
        'execute_liquidation',
        params: <String, dynamic>{
          'p_player_id': userId,
        },
      );

      // Inject Flash Sale bonus
      if (bonus > 0) {
        await supabase.rpc(
          'inject_capital_bonus',
          params: <String, dynamic>{
            'p_player_id': userId,
            'p_amount': bonus,
            'p_reason': 'flash_sale_frenzy_bonus',
          },
        );
      }

      final LiquidationResult liquidationResult = LiquidationResult(
        liquidatedAmount: (result['liquidated_amount'] as num?)?.toInt() ?? 0,
        newInventory: (result['new_inventory'] as num?)?.toInt() ?? 0,
        newRevenue: ((result['new_revenue'] as num?)?.toDouble() ?? 0.0) + bonus,
      );

      state = AsyncValue.data(liquidationResult);

      return <String, dynamic>{
        'success': true,
        'liquidated_amount': liquidationResult.liquidatedAmount,
        'bonus_amount': bonus,
        'total_revenue': liquidationResult.newRevenue,
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': 'Flash sale liquidation failed: $e',
      };
    }
  }
}

final StateNotifierProvider<LiquidationNotifier, AsyncValue<LiquidationResult?>>
    liquidationProvider =
    StateNotifierProvider<LiquidationNotifier, AsyncValue<LiquidationResult?>>(
  (Ref<AsyncValue<LiquidationResult?>> ref) => LiquidationNotifier(),
);

// =============================================================================
// Logistics Upgrade State Notifier
// =============================================================================

class LogisticsNotifier extends StateNotifier<AsyncValue<LogisticsUpgrade?>> {
  LogisticsNotifier() : super(const AsyncValue.data(null));

  Future<void> upgrade() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final Map<String, dynamic> result = await supabase.rpc(
        'upgrade_logistics',
        params: <String, dynamic>{'p_player_id': userId},
      );

      final LogisticsUpgrade upgrade = LogisticsUpgrade(
        success: result['success'] as bool? ?? false,
        newLevel: (result['new_level'] as num?)?.toInt() ?? 1,
        newCapacity: (result['new_capacity'] as num?)?.toInt() ?? 5000,
        cost: (result['cost'] as num?)?.toInt() ?? 0,
        message: result['message'] as String?,
      );

      state = AsyncValue.data(upgrade);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  // ===========================================================================
  // Directive O: Supplier Raid — Logistics discount or halt
  // ===========================================================================

  /// Apply Supplier Raid result
  /// Win = 15% discount for 14 days, Loss = immediate halt
  Future<Map<String, dynamic>> applySupplierRaidResult({required bool won}) async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return <String, dynamic>{
          'success': false,
          'error': 'Not authenticated',
        };
      }

      if (won) {
        // Apply 15% discount for 14 days
        final Map<String, dynamic> result = await supabase.rpc(
          'apply_logistics_discount',
          params: <String, dynamic>{
            'p_player_id': userId,
            'p_discount_pct': 15.0,
            'p_duration_days': 14,
          },
        );
        return result as Map<String, dynamic>;
      } else {
        // Trigger supply chain halt
        final Map<String, dynamic> result = await supabase.rpc(
          'halt_supply_chain',
          params: <String, dynamic>{
            'p_player_id': userId,
          },
        );
        return result as Map<String, dynamic>;
      }
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'error': 'Supplier raid result failed: $e',
      };
    }
  }
}

final StateNotifierProvider<LogisticsNotifier, AsyncValue<LogisticsUpgrade?>>
    logisticsUpgradeProvider =
    StateNotifierProvider<LogisticsNotifier, AsyncValue<LogisticsUpgrade?>>(
  (Ref<AsyncValue<LogisticsUpgrade?>> ref) => LogisticsNotifier(),
);

// =============================================================================
// Next Upgrade Cost Provider
// =============================================================================

final ProviderFamily<int, int> nextUpgradeCostProvider =
    ProviderFamily<int, int>((Ref<int> ref, int currentLevel) {
  return LogisticsUpgrade.calculateUpgradeCost(currentLevel);
});

// =============================================================================
// Supply Chain Stats Provider
// =============================================================================

final FutureProvider<SupplyChainStats> supplyChainStatsProvider =
    FutureProvider<SupplyChainStats>((Ref<AsyncValue<SupplyChainStats>> ref) async {
  final SupabaseClient supabase = Supabase.instance.client;

  // Get total capacity across all players
  final List<Map<String, dynamic>> stats = await supabase
      .from('brand_state')
      .select('warehouse_capacity, current_inventory_value');

  int totalCapacity = 0;
  int totalInventory = 0;
  int fullWarehouses = 0;

  for (final Map<String, dynamic> row in stats) {
    final int capacity = (row['warehouse_capacity'] as num?)?.toInt() ?? 5000;
    final int inventory = (row['current_inventory_value'] as num?)?.toInt() ?? 0;

    totalCapacity += capacity;
    totalInventory += inventory;
    if (inventory >= capacity) fullWarehouses++;
  }

  return SupplyChainStats(
    totalWarehouses: stats.length,
    totalCapacity: totalCapacity,
    totalInventory: totalInventory,
    fullWarehouses: fullWarehouses,
    globalFillPercent: totalCapacity > 0 ? (totalInventory / totalCapacity) * 100 : 0.0,
  );
});

class SupplyChainStats {
  const SupplyChainStats({
    required this.totalWarehouses,
    required this.totalCapacity,
    required this.totalInventory,
    required this.fullWarehouses,
    required this.globalFillPercent,
  });

  final int totalWarehouses;
  final int totalCapacity;
  final int totalInventory;
  final int fullWarehouses;
  final double globalFillPercent;
}
