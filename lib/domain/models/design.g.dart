// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'design.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DesignImpl _$$DesignImplFromJson(Map<String, dynamic> json) => _$DesignImpl(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      name: json['name'] as String,
      sessionType:
          $enumDecode(_$DesignSessionTypeEnumMap, json['session_type']),
      status: $enumDecodeNullable(_$DesignStatusEnumMap, json['status']) ??
          DesignStatus.draft,
      hypeScore: json['hype_score'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['hype_score']),
      isAlpha: json['is_alpha'] as bool? ?? false,
      isDigitalTwin: json['is_digital_twin'] as bool? ?? false,
      dppRegistered: json['dpp_registered'] as bool? ?? false,
      fabricData: json['fabric_data'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sellPotential: json['sell_potential'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['sell_potential']),
      culturalImpact: json['cultural_impact'] == null
          ? 0.0
          : const _SafeDouble().fromJson(json['cultural_impact']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      droppedAt: json['dropped_at'] == null
          ? null
          : DateTime.parse(json['dropped_at'] as String),
    );

Map<String, dynamic> _$$DesignImplToJson(_$DesignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'name': instance.name,
      'session_type': _$DesignSessionTypeEnumMap[instance.sessionType]!,
      'status': _$DesignStatusEnumMap[instance.status]!,
      'hype_score': const _SafeDouble().toJson(instance.hypeScore),
      'is_alpha': instance.isAlpha,
      'is_digital_twin': instance.isDigitalTwin,
      'dpp_registered': instance.dppRegistered,
      'fabric_data': instance.fabricData,
      'sell_potential': const _SafeDouble().toJson(instance.sellPotential),
      'cultural_impact': const _SafeDouble().toJson(instance.culturalImpact),
      'created_at': instance.createdAt?.toIso8601String(),
      'dropped_at': instance.droppedAt?.toIso8601String(),
    };

const _$DesignSessionTypeEnumMap = {
  DesignSessionType.quickSketch: 'quick_sketch',
  DesignSessionType.deepSession: 'deep_session',
};

const _$DesignStatusEnumMap = {
  DesignStatus.draft: 'draft',
  DesignStatus.complete: 'complete',
  DesignStatus.dropped: 'dropped',
  DesignStatus.retired: 'retired',
};
