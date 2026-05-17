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
      hypeScore: (json['hype_score'] as num?)?.toDouble() ?? 0.0,
      isAlpha: json['is_alpha'] as bool? ?? false,
      isDigitalTwin: json['is_digital_twin'] as bool? ?? false,
      dppRegistered: json['dpp_registered'] as bool? ?? false,
      fabricData: json['fabric_data'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sellPotential: (json['sell_potential'] as num?)?.toDouble() ?? 0.0,
      culturalImpact: (json['cultural_impact'] as num?)?.toDouble() ?? 0.0,
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
      'hype_score': instance.hypeScore,
      'is_alpha': instance.isAlpha,
      'is_digital_twin': instance.isDigitalTwin,
      'dpp_registered': instance.dppRegistered,
      'fabric_data': instance.fabricData,
      'sell_potential': instance.sellPotential,
      'cultural_impact': instance.culturalImpact,
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
