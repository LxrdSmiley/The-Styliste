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
      livingWageEnabled: json['livingWageEnabled'] as bool? ?? false,
      blockchainTraceable: json['blockchainTraceable'] as bool? ?? false,
      ethicalSupplierBadge: json['ethicalSupplierBadge'] as bool? ?? false,
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
      'livingWageEnabled': instance.livingWageEnabled,
      'blockchainTraceable': instance.blockchainTraceable,
      'ethicalSupplierBadge': instance.ethicalSupplierBadge,
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
      playerId: json['playerId'] as String,
      supplierId: json['supplierId'] as String,
      tier: $enumDecode(_$SupplierTierEnumMap, json['tier']),
      exclusivity: json['exclusivity'] as bool? ?? false,
      contractExpiresAt: json['contractExpiresAt'] == null
          ? null
          : DateTime.parse(json['contractExpiresAt'] as String),
    );

Map<String, dynamic> _$$SupplyChainContractImplToJson(
        _$SupplyChainContractImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'supplierId': instance.supplierId,
      'tier': _$SupplierTierEnumMap[instance.tier]!,
      'exclusivity': instance.exclusivity,
      'contractExpiresAt': instance.contractExpiresAt?.toIso8601String(),
    };
