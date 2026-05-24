// Directive L — Supply Chain Models
// GDD §12.1.2 — Buffer Stock Engine data structures

import 'dart:math' show pow;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'supply_chain_models.freezed.dart';
part 'supply_chain_models.g.dart';

/// Supply Chain State — Warehouse inventory tracking
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SupplyChainState with _$SupplyChainState {
  const SupplyChainState._();
  const factory SupplyChainState({
    @Default(5000) int warehouseCapacity,
    @Default(0) int currentInventoryValue,
    @Default(1) int logisticsLevel,
    @Default(0.0) double idleRevenuePerHour,
    @Default(false) bool isFull,
    DateTime? lastActiveAt,
  }) = _SupplyChainState;

  factory SupplyChainState.fromJson(Map<String, dynamic> json) =>
      _$SupplyChainStateFromJson(json);

  /// Calculate fill percentage (0.0 to 100.0+)
  double get fillPercent => warehouseCapacity > 0
      ? (currentInventoryValue / warehouseCapacity) * 100
      : 0.0;

  /// Calculate upgrade cost for next level
  /// Formula: 1000 * (1.5 ^ current_level)
  static int calculateUpgradeCost(int currentLevel) {
    return (1000.0 * pow(1.5, currentLevel)).round();
  }

  /// Calculate new capacity after upgrade
  /// Multiplies by 1.5x
  static int calculateNewCapacity(int currentCapacity) {
    return (currentCapacity * 1.5).round();
  }

  /// Remaining space in warehouse
  int get remainingSpace => warehouseCapacity - currentInventoryValue;

  /// Formatted fill percentage for display
  String get formattedFillPercent => '${fillPercent.toStringAsFixed(1)}%';

  /// Check if warehouse needs liquidation
  bool get needsLiquidation => isFull || fillPercent >= 100.0;

  /// Get status text for UI
  String get statusText {
    if (isFull) return 'SUPPLY CHAIN HALTED';
    if (fillPercent >= 90.0) return 'NEARLY FULL';
    if (fillPercent >= 75.0) return 'HIGH CAPACITY';
    if (fillPercent >= 50.0) return 'MODERATE';
    return 'FLOWING';
  }

  /// Get status color for UI
  String get statusColor {
    if (isFull) return 'SOFT_ROSE';
    if (fillPercent >= 90.0) return 'ORANGE';
    if (fillPercent >= 75.0) return 'YELLOW';
    return 'CHAMPAGNE_GOLD';
  }
}

/// Liquidation Result — Inventory to Capital conversion
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class LiquidationResult with _$LiquidationResult {
  const LiquidationResult._();
  const factory LiquidationResult({
    @Default(0) int liquidatedAmount,
    @Default(0) int newInventory,
    @Default(0.0) double newRevenue,
  }) = _LiquidationResult;

  factory LiquidationResult.fromJson(Map<String, dynamic> json) =>
      _$LiquidationResultFromJson(json);

  /// Formatted liquidated amount
  String get formattedAmount => '\$$liquidatedAmount';

  /// Check if liquidation was successful
  bool get isSuccessful => liquidatedAmount > 0;
}

/// Logistics Upgrade — Warehouse expansion
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class LogisticsUpgrade with _$LogisticsUpgrade {
  const LogisticsUpgrade._();
  const factory LogisticsUpgrade({
    @Default(false) bool success,
    @Default(1) int newLevel,
    @Default(5000) int newCapacity,
    @Default(0) int cost,
    String? message,
  }) = _LogisticsUpgrade;

  factory LogisticsUpgrade.fromJson(Map<String, dynamic> json) =>
      _$LogisticsUpgradeFromJson(json);

  /// Calculate upgrade cost for next level
  /// Formula: 1000 * (1.5 ^ current_level)
  static int calculateUpgradeCost(int currentLevel) {
    return (1000.0 * pow(1.5, currentLevel)).round();
  }

  /// Calculate new capacity after upgrade
  /// Multiplies by 1.5x
  static int calculateNewCapacity(int currentCapacity) {
    return (currentCapacity * 1.5).round();
  }

  /// Formatted cost
  String get formattedCost => '\$$cost';

  /// Capacity increase amount
  int get capacityIncrease => (newCapacity / 1.5 * 0.5).round();
}
