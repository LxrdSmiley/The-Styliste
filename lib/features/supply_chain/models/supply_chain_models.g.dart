// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_chain_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupplyChainStateImpl _$$SupplyChainStateImplFromJson(
        Map<String, dynamic> json) =>
    _$SupplyChainStateImpl(
      warehouseCapacity: (json['warehouse_capacity'] as num?)?.toInt() ?? 5000,
      currentInventoryValue:
          (json['current_inventory_value'] as num?)?.toInt() ?? 0,
      logisticsLevel: (json['logistics_level'] as num?)?.toInt() ?? 1,
      idleRevenuePerHour:
          (json['idle_revenue_per_hour'] as num?)?.toDouble() ?? 0.0,
      isFull: json['is_full'] as bool? ?? false,
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
    );

Map<String, dynamic> _$$SupplyChainStateImplToJson(
        _$SupplyChainStateImpl instance) =>
    <String, dynamic>{
      'warehouse_capacity': instance.warehouseCapacity,
      'current_inventory_value': instance.currentInventoryValue,
      'logistics_level': instance.logisticsLevel,
      'idle_revenue_per_hour': instance.idleRevenuePerHour,
      'is_full': instance.isFull,
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
    };

_$LiquidationResultImpl _$$LiquidationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$LiquidationResultImpl(
      liquidatedAmount: (json['liquidated_amount'] as num?)?.toInt() ?? 0,
      newInventory: (json['new_inventory'] as num?)?.toInt() ?? 0,
      newRevenue: (json['new_revenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$LiquidationResultImplToJson(
        _$LiquidationResultImpl instance) =>
    <String, dynamic>{
      'liquidated_amount': instance.liquidatedAmount,
      'new_inventory': instance.newInventory,
      'new_revenue': instance.newRevenue,
    };

_$LogisticsUpgradeImpl _$$LogisticsUpgradeImplFromJson(
        Map<String, dynamic> json) =>
    _$LogisticsUpgradeImpl(
      success: json['success'] as bool? ?? false,
      newLevel: (json['new_level'] as num?)?.toInt() ?? 1,
      newCapacity: (json['new_capacity'] as num?)?.toInt() ?? 5000,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$LogisticsUpgradeImplToJson(
        _$LogisticsUpgradeImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'new_level': instance.newLevel,
      'new_capacity': instance.newCapacity,
      'cost': instance.cost,
      'message': instance.message,
    };
