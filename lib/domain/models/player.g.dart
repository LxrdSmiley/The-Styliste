// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: json['id'] as String,
      brandName: json['brandName'] as String,
      path: $enumDecode(_$CareerPathEnumMap, json['path']),
      hqCity: $enumDecode(_$HqCityEnumMap, json['hqCity']),
      brandRank: (json['brandRank'] as num?)?.toInt() ?? 1,
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isJointVenture: json['isJointVenture'] as bool? ?? false,
      sovereignMultipliers:
          (json['sovereignMultipliers'] as num?)?.toInt() ?? 0,
      jointVentureUnlockedAt: json['jointVentureUnlockedAt'] == null
          ? null
          : DateTime.parse(json['jointVentureUnlockedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      luxeTrustScore: (json['luxeTrustScore'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandName': instance.brandName,
      'path': _$CareerPathEnumMap[instance.path]!,
      'hqCity': _$HqCityEnumMap[instance.hqCity]!,
      'brandRank': instance.brandRank,
      'totalXp': instance.totalXp,
      'onboardingComplete': instance.onboardingComplete,
      'isAnonymous': instance.isAnonymous,
      'isJointVenture': instance.isJointVenture,
      'sovereignMultipliers': instance.sovereignMultipliers,
      'jointVentureUnlockedAt':
          instance.jointVentureUnlockedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'luxeTrustScore': instance.luxeTrustScore,
    };

const _$CareerPathEnumMap = {
  CareerPath.designer: 'designer',
  CareerPath.mogul: 'mogul',
};

const _$HqCityEnumMap = {
  HqCity.newYork: 'new_york',
  HqCity.paris: 'paris',
  HqCity.tokyo: 'tokyo',
  HqCity.london: 'london',
  HqCity.milan: 'milan',
  HqCity.seoul: 'seoul',
  HqCity.nairobi: 'nairobi',
  HqCity.saoPaulo: 'sao_paulo',
};
