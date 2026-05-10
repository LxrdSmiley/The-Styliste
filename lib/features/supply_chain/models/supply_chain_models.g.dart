// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_chain_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupplyChainStateImpl _$$SupplyChainStateImplFromJson(
        Map<String, dynamic> json) =>
    _$SupplyChainStateImpl(
      warehouseCapacity: (json['warehouseCapacity'] as num?)?.toInt() ?? 5000,
      currentInventoryValue:
          (json['currentInventoryValue'] as num?)?.toInt() ?? 0,
      logisticsLevel: (json['logisticsLevel'] as num?)?.toInt() ?? 1,
      idleRevenuePerHour:
          (json['idleRevenuePerHour'] as num?)?.toDouble() ?? 0.0,
      isFull: json['isFull'] as bool? ?? false,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
    );

Map<String, dynamic> _$$SupplyChainStateImplToJson(
        _$SupplyChainStateImpl instance) =>
    <String, dynamic>{
      'warehouseCapacity': instance.warehouseCapacity,
      'currentInventoryValue': instance.currentInventoryValue,
      'logisticsLevel': instance.logisticsLevel,
      'idleRevenuePerHour': instance.idleRevenuePerHour,
      'isFull': instance.isFull,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
    };

_$LiquidationResultImpl _$$LiquidationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$LiquidationResultImpl(
      liquidatedAmount: (json['liquidatedAmount'] as num?)?.toInt() ?? 0,
      newInventory: (json['newInventory'] as num?)?.toInt() ?? 0,
      newRevenue: (json['newRevenue'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$LiquidationResultImplToJson(
        _$LiquidationResultImpl instance) =>
    <String, dynamic>{
      'liquidatedAmount': instance.liquidatedAmount,
      'newInventory': instance.newInventory,
      'newRevenue': instance.newRevenue,
    };

_$LogisticsUpgradeImpl _$$LogisticsUpgradeImplFromJson(
        Map<String, dynamic> json) =>
    _$LogisticsUpgradeImpl(
      success: json['success'] as bool? ?? false,
      newLevel: (json['newLevel'] as num?)?.toInt() ?? 1,
      newCapacity: (json['newCapacity'] as num?)?.toInt() ?? 5000,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$LogisticsUpgradeImplToJson(
        _$LogisticsUpgradeImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'newLevel': instance.newLevel,
      'newCapacity': instance.newCapacity,
      'cost': instance.cost,
      'message': instance.message,
    };
