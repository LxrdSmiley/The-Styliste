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
      hypeScore: (json['hype_score'] as num).toDouble(),
      matchingTsunamiTag: json['matching_tsunami_tag'] as String?,
      tsunamiMultiplier: (json['tsunami_multiplier'] as num?)?.toDouble(),
      wasOptedIn: json['was_opted_in'] as bool? ?? true,
      generatedAt: json['generated_at'] == null
          ? null
          : DateTime.parse(json['generated_at'] as String),
    );

Map<String, dynamic> _$$VexReviewImplToJson(_$VexReviewImpl instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'body': instance.body,
      'verdict': _$VexVerdictEnumMap[instance.verdict]!,
      'hype_score': instance.hypeScore,
      'matching_tsunami_tag': instance.matchingTsunamiTag,
      'tsunami_multiplier': instance.tsunamiMultiplier,
      'was_opted_in': instance.wasOptedIn,
      'generated_at': instance.generatedAt?.toIso8601String(),
    };

const _$VexVerdictEnumMap = {
  VexVerdict.tarnished: 'tarnished',
  VexVerdict.derivative: 'derivative',
  VexVerdict.visionary: 'visionary',
  VexVerdict.sovereign: 'sovereign',
};
