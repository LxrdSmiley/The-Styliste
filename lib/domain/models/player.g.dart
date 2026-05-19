// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: json['id'] as String,
      brandName: json['brand_name'] as String,
      path: $enumDecode(_$CareerPathEnumMap, json['path']),
      hqCity: $enumDecode(_$HqCityEnumMap, json['hq_city']),
      brandRank: (json['brand_rank'] as num?)?.toInt() ?? 1,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      isJointVenture: json['is_joint_venture'] as bool? ?? false,
      sovereignMultipliers:
          (json['sovereign_multipliers'] as num?)?.toInt() ?? 0,
      jointVentureUnlockedAt: json['joint_venture_unlocked_at'] == null
          ? null
          : DateTime.parse(json['joint_venture_unlocked_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
      luxeTrustScore: (json['luxe_trust_score'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand_name': instance.brandName,
      'path': _$CareerPathEnumMap[instance.path]!,
      'hq_city': _$HqCityEnumMap[instance.hqCity]!,
      'brand_rank': instance.brandRank,
      'total_xp': instance.totalXp,
      'onboarding_complete': instance.onboardingComplete,
      'is_anonymous': instance.isAnonymous,
      'is_joint_venture': instance.isJointVenture,
      'sovereign_multipliers': instance.sovereignMultipliers,
      'joint_venture_unlocked_at':
          instance.jointVentureUnlockedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
      'luxe_trust_score': instance.luxeTrustScore,
    };
