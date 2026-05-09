// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vex_review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VexReviewImpl _$$VexReviewImplFromJson(Map<String, dynamic> json) =>
    _$VexReviewImpl(
      headline: json['headline'] as String,
      body: json['body'] as String,
      verdict: $enumDecode(_$VexVerdictEnumMap, json['verdict']),
      hypeScore: (json['hypeScore'] as num).toDouble(),
      matchingTsunamiTag: json['matchingTsunamiTag'] as String?,
      tsunamiMultiplier: (json['tsunamiMultiplier'] as num?)?.toDouble(),
      wasOptedIn: json['wasOptedIn'] as bool? ?? true,
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$VexReviewImplToJson(_$VexReviewImpl instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'body': instance.body,
      'verdict': _$VexVerdictEnumMap[instance.verdict]!,
      'hypeScore': instance.hypeScore,
      'matchingTsunamiTag': instance.matchingTsunamiTag,
      'tsunamiMultiplier': instance.tsunamiMultiplier,
      'wasOptedIn': instance.wasOptedIn,
      'generatedAt': instance.generatedAt?.toIso8601String(),
    };

const _$VexVerdictEnumMap = {
  VexVerdict.tarnished: 'tarnished',
  VexVerdict.derivative: 'derivative',
  VexVerdict.visionary: 'visionary',
  VexVerdict.sovereign: 'sovereign',
};
