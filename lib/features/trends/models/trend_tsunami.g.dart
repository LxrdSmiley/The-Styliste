// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_tsunami.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrendTsunamiImpl _$$TrendTsunamiImplFromJson(Map<String, dynamic> json) =>
    _$TrendTsunamiImpl(
      id: json['id'] as String,
      tagName: json['tag_name'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
      totalWeight: (json['total_weight'] as num).toDouble(),
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TrendTsunamiImplToJson(_$TrendTsunamiImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tag_name': instance.tagName,
      'multiplier': instance.multiplier,
      'rank': instance.rank,
      'total_weight': instance.totalWeight,
      'starts_at': instance.startsAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
