// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sovereign_statue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SovereignStatueImpl _$$SovereignStatueImplFromJson(
        Map<String, dynamic> json) =>
    _$SovereignStatueImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      brandName: json['brand_name'] as String,
      ascendedAt: DateTime.parse(json['ascended_at'] as String),
      finalMarketCap: (json['final_market_cap'] as num).toInt(),
      statueTier: $enumDecode(_$StatueTierEnumMap, json['statue_tier']),
      careerPath: $enumDecode(_$CareerPathEnumMap, json['career_path']),
      finalHypeScore: (json['final_hype_score'] as num?)?.toDouble() ?? 0.0,
      jointVentureFlag: json['joint_venture_flag'] as bool? ?? false,
    );

Map<String, dynamic> _$$SovereignStatueImplToJson(
        _$SovereignStatueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'brand_name': instance.brandName,
      'ascended_at': instance.ascendedAt.toIso8601String(),
      'final_market_cap': instance.finalMarketCap,
      'statue_tier': _$StatueTierEnumMap[instance.statueTier]!,
      'career_path': _$CareerPathEnumMap[instance.careerPath]!,
      'final_hype_score': instance.finalHypeScore,
      'joint_venture_flag': instance.jointVentureFlag,
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
