// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'design.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DesignImpl _$$DesignImplFromJson(Map<String, dynamic> json) => _$DesignImpl(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      sessionType: $enumDecode(_$DesignSessionTypeEnumMap, json['sessionType']),
      status: $enumDecodeNullable(_$DesignStatusEnumMap, json['status']) ??
          DesignStatus.draft,
      hypoScore: (json['hypoScore'] as num?)?.toDouble() ?? 0.0,
      isAlpha: json['isAlpha'] as bool? ?? false,
      isDigitalTwin: json['isDigitalTwin'] as bool? ?? false,
      dppRegistered: json['dppRegistered'] as bool? ?? false,
      fabricData: json['fabricData'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sellPotential: (json['sellPotential'] as num?)?.toDouble() ?? 0.0,
      culturalImpact: (json['culturalImpact'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      droppedAt: json['droppedAt'] == null
          ? null
          : DateTime.parse(json['droppedAt'] as String),
    );

Map<String, dynamic> _$$DesignImplToJson(_$DesignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'name': instance.name,
      'sessionType': _$DesignSessionTypeEnumMap[instance.sessionType]!,
      'status': _$DesignStatusEnumMap[instance.status]!,
      'hypoScore': instance.hypoScore,
      'isAlpha': instance.isAlpha,
      'isDigitalTwin': instance.isDigitalTwin,
      'dppRegistered': instance.dppRegistered,
      'fabricData': instance.fabricData,
      'sellPotential': instance.sellPotential,
      'culturalImpact': instance.culturalImpact,
      'createdAt': instance.createdAt?.toIso8601String(),
      'droppedAt': instance.droppedAt?.toIso8601String(),
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
