// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brand _$BrandFromJson(Map<String, dynamic> json) => Brand(
      playerId: json['player_id'] as String,
      heat: (json['heat'] as num).toInt(),
      hypeScore: const _SafeDouble().fromJson(json['hype_score']),
      followers: (json['followers'] as num).toInt(),
      idleRevenuePerHour:
          const _SafeDouble().fromJson(json['idle_revenue_per_hour']),
      totalRevenue: const _SafeDouble().fromJson(json['total_revenue']),
      momentumBuffActive: json['momentum_buff_active'] as bool,
      momentumBuffUntil: json['momentum_buff_until'] == null
          ? null
          : DateTime.parse(json['momentum_buff_until'] as String),
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
      sustainabilityTier: (json['sustainability_tier'] as num).toInt(),
      dppEnabled: json['dpp_enabled'] as bool,
      dppFullyMapped: json['dpp_fully_mapped'] as bool,
      founderRep: (json['founder_rep'] as num).toInt(),
      luxeTokens: (json['luxe_tokens'] as num).toInt(),
      currentTarnish: (json['current_tarnish'] as num).toInt(),
      kintsugiLevel: (json['kintsugi_level'] as num).toInt(),
      totalScandalsSurvived: (json['total_scandals_survived'] as num).toInt(),
      prestigeTokens: (json['prestige_tokens'] as num).toInt(),
      marketTier: json['market_tier'] as String?,
      avatarConfiguration:
          json['avatar_configuration'] as Map<String, dynamic>?,
      warehouseCapacity: (json['warehouse_capacity'] as num).toInt(),
      currentInventoryValue: (json['current_inventory_value'] as num).toInt(),
      logisticsLevel: (json['logistics_level'] as num).toInt(),
    );

Map<String, dynamic> _$BrandToJson(Brand instance) => <String, dynamic>{
      'player_id': instance.playerId,
      'heat': instance.heat,
      'hype_score': const _SafeDouble().toJson(instance.hypeScore),
      'followers': instance.followers,
      'idle_revenue_per_hour':
          const _SafeDouble().toJson(instance.idleRevenuePerHour),
      'total_revenue': const _SafeDouble().toJson(instance.totalRevenue),
      'momentum_buff_active': instance.momentumBuffActive,
      'momentum_buff_until': instance.momentumBuffUntil?.toIso8601String(),
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
      'sustainability_tier': instance.sustainabilityTier,
      'dpp_enabled': instance.dppEnabled,
      'dpp_fully_mapped': instance.dppFullyMapped,
      'founder_rep': instance.founderRep,
      'luxe_tokens': instance.luxeTokens,
      'current_tarnish': instance.currentTarnish,
      'kintsugi_level': instance.kintsugiLevel,
      'total_scandals_survived': instance.totalScandalsSurvived,
      'prestige_tokens': instance.prestigeTokens,
      'market_tier': instance.marketTier,
      'avatar_configuration': instance.avatarConfiguration,
      'warehouse_capacity': instance.warehouseCapacity,
      'current_inventory_value': instance.currentInventoryValue,
      'logistics_level': instance.logisticsLevel,
    };

_$BrandImpl _$$BrandImplFromJson(Map<String, dynamic> json) => _$BrandImpl(
      playerId: json['playerId'] as String,
      heat: (json['heat'] as num?)?.toInt() ?? 50,
      hypeScore: json['hypeScore'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['hypeScore']),
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      idleRevenuePerHour: json['idleRevenuePerHour'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['idleRevenuePerHour']),
      totalRevenue: json['totalRevenue'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['totalRevenue']),
      momentumBuffActive: json['momentumBuffActive'] as bool? ?? false,
      momentumBuffUntil: json['momentumBuffUntil'] == null
          ? null
          : DateTime.parse(json['momentumBuffUntil'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      sustainabilityTier: (json['sustainabilityTier'] as num?)?.toInt() ?? 0,
      dppEnabled: json['dppEnabled'] as bool? ?? false,
      dppFullyMapped: json['dppFullyMapped'] as bool? ?? false,
      founderRep: (json['founderRep'] as num?)?.toInt() ?? 50,
      luxeTokens: (json['luxeTokens'] as num?)?.toInt() ?? 0,
      currentTarnish: (json['currentTarnish'] as num?)?.toInt() ?? 0,
      kintsugiLevel: (json['kintsugiLevel'] as num?)?.toInt() ?? 0,
      totalScandalsSurvived:
          (json['totalScandalsSurvived'] as num?)?.toInt() ?? 0,
      prestigeTokens: (json['prestigeTokens'] as num?)?.toInt() ?? 0,
      marketTier: json['marketTier'] as String?,
      avatarConfiguration: json['avatarConfiguration'] as Map<String, dynamic>?,
      warehouseCapacity: (json['warehouseCapacity'] as num?)?.toInt() ?? 5000,
      currentInventoryValue:
          (json['currentInventoryValue'] as num?)?.toInt() ?? 0,
      logisticsLevel: (json['logisticsLevel'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$BrandImplToJson(_$BrandImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'heat': instance.heat,
      'hypeScore': const _SafeDouble().toJson(instance.hypeScore),
      'followers': instance.followers,
      'idleRevenuePerHour':
          const _SafeDouble().toJson(instance.idleRevenuePerHour),
      'totalRevenue': const _SafeDouble().toJson(instance.totalRevenue),
      'momentumBuffActive': instance.momentumBuffActive,
      'momentumBuffUntil': instance.momentumBuffUntil?.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'sustainabilityTier': instance.sustainabilityTier,
      'dppEnabled': instance.dppEnabled,
      'dppFullyMapped': instance.dppFullyMapped,
      'founderRep': instance.founderRep,
      'luxeTokens': instance.luxeTokens,
      'currentTarnish': instance.currentTarnish,
      'kintsugiLevel': instance.kintsugiLevel,
      'totalScandalsSurvived': instance.totalScandalsSurvived,
      'prestigeTokens': instance.prestigeTokens,
      'marketTier': instance.marketTier,
      'avatarConfiguration': instance.avatarConfiguration,
      'warehouseCapacity': instance.warehouseCapacity,
      'currentInventoryValue': instance.currentInventoryValue,
      'logisticsLevel': instance.logisticsLevel,
    };
