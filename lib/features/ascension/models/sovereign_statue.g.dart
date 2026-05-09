// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sovereign_statue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SovereignStatueImpl _$$SovereignStatueImplFromJson(
        Map<String, dynamic> json) =>
    _$SovereignStatueImpl(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      brandName: json['brandName'] as String,
      ascendedAt: DateTime.parse(json['ascendedAt'] as String),
      finalMarketCap: (json['finalMarketCap'] as num).toInt(),
      finalHypeScore: (json['finalHypeScore'] as num?)?.toDouble() ?? 0.0,
      statueTier: $enumDecode(_$StatueTierEnumMap, json['statueTier']),
      careerPath: $enumDecode(_$CareerPathEnumMap, json['careerPath']),
      jointVentureFlag: json['jointVentureFlag'] as bool? ?? false,
    );

Map<String, dynamic> _$$SovereignStatueImplToJson(
        _$SovereignStatueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'brandName': instance.brandName,
      'ascendedAt': instance.ascendedAt.toIso8601String(),
      'finalMarketCap': instance.finalMarketCap,
      'finalHypeScore': instance.finalHypeScore,
      'statueTier': _$StatueTierEnumMap[instance.statueTier]!,
      'careerPath': _$CareerPathEnumMap[instance.careerPath]!,
      'jointVentureFlag': instance.jointVentureFlag,
    };

const _$StatueTierEnumMap = {
  StatueTier.quartz: 'Quartz',
  StatueTier.gold: 'Gold',
  StatueTier.alabaster: 'Alabaster',
};

const _$CareerPathEnumMap = {
  CareerPath.designer: 'designer',
  CareerPath.mogul: 'mogul',
};
