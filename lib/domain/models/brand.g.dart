// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandImpl _$$BrandImplFromJson(Map<String, dynamic> json) => _$BrandImpl(
      playerId: json['playerId'] as String,
      heat: (json['heat'] as num?)?.toInt() ?? 50,
      hypoScore: json['hypoScore'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['hypoScore']),
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
    );

Map<String, dynamic> _$$BrandImplToJson(_$BrandImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'heat': instance.heat,
      'hypoScore': const _SafeDouble().toJson(instance.hypoScore),
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
    };
