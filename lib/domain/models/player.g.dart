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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
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
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
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
