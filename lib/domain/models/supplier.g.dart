// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupplierImpl _$$SupplierImplFromJson(Map<String, dynamic> json) =>
    _$SupplierImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: $enumDecode(_$SupplierTierEnumMap, json['tier']),
      category: $enumDecode(_$SupplierCategoryEnumMap, json['category']),
      quality: (json['quality'] as num?)?.toInt() ?? 50,
      cost: (json['cost'] as num?)?.toInt() ?? 50,
      reliability: (json['reliability'] as num?)?.toInt() ?? 50,
      prestige: (json['prestige'] as num?)?.toInt() ?? 50,
      livingWageEnabled: json['living_wage_enabled'] as bool? ?? false,
      blockchainTraceable: json['blockchain_traceable'] as bool? ?? false,
      ethicalSupplierBadge: json['ethical_supplier_badge'] as bool? ?? false,
    );

Map<String, dynamic> _$$SupplierImplToJson(_$SupplierImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tier': _$SupplierTierEnumMap[instance.tier]!,
      'category': _$SupplierCategoryEnumMap[instance.category]!,
      'quality': instance.quality,
      'cost': instance.cost,
      'reliability': instance.reliability,
      'prestige': instance.prestige,
      'living_wage_enabled': instance.livingWageEnabled,
      'blockchain_traceable': instance.blockchainTraceable,
      'ethical_supplier_badge': instance.ethicalSupplierBadge,
    };

const _$SupplierTierEnumMap = {
  SupplierTier.local: 'local',
  SupplierTier.regional: 'regional',
  SupplierTier.international: 'international',
  SupplierTier.luxury: 'luxury',
  SupplierTier.blackMarket: 'black_market',
};

const _$SupplierCategoryEnumMap = {
  SupplierCategory.rawMaterials: 'raw_materials',
  SupplierCategory.manufacturing: 'manufacturing',
  SupplierCategory.logistics: 'logistics',
};

_$SupplyChainContractImpl _$$SupplyChainContractImplFromJson(
        Map<String, dynamic> json) =>
    _$SupplyChainContractImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      supplierId: json['supplier_id'] as String,
      tier: $enumDecode(_$SupplierTierEnumMap, json['tier']),
      exclusivity: json['exclusivity'] as bool? ?? false,
      contractExpiresAt: json['contract_expires_at'] == null
          ? null
          : DateTime.parse(json['contract_expires_at'] as String),
    );

Map<String, dynamic> _$$SupplyChainContractImplToJson(
        _$SupplyChainContractImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'supplier_id': instance.supplierId,
      'tier': _$SupplierTierEnumMap[instance.tier]!,
      'exclusivity': instance.exclusivity,
      'contract_expires_at': instance.contractExpiresAt?.toIso8601String(),
    };
