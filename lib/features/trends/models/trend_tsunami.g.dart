// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_tsunami.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrendTsunamiImpl _$$TrendTsunamiImplFromJson(Map<String, dynamic> json) =>
    _$TrendTsunamiImpl(
      id: json['id'] as String,
      tagName: json['tagName'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
      totalWeight: (json['totalWeight'] as num).toDouble(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TrendTsunamiImplToJson(_$TrendTsunamiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tagName': instance.tagName,
      'multiplier': instance.multiplier,
      'rank': instance.rank,
      'totalWeight': instance.totalWeight,
      'startsAt': instance.startsAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
