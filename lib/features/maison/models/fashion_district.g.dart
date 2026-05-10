// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fashion_district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FashionDistrictImpl _$$FashionDistrictImplFromJson(
        Map<String, dynamic> json) =>
    _$FashionDistrictImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      controllingMaisonId: json['controllingMaisonId'] as String?,
      controlledSince: json['controlledSince'] == null
          ? null
          : DateTime.parse(json['controlledSince'] as String),
      baseTakeoverCost: (json['baseTakeoverCost'] as num).toInt(),
      totalHype: (json['totalHype'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FashionDistrictImplToJson(
        _$FashionDistrictImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'controllingMaisonId': instance.controllingMaisonId,
      'controlledSince': instance.controlledSince?.toIso8601String(),
      'baseTakeoverCost': instance.baseTakeoverCost,
      'totalHype': instance.totalHype,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$DistrictWatermarkImpl _$$DistrictWatermarkImplFromJson(
        Map<String, dynamic> json) =>
    _$DistrictWatermarkImpl(
      id: json['id'] as String,
      maisonId: json['maisonId'] as String,
      districtId: json['districtId'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );

Map<String, dynamic> _$$DistrictWatermarkImplToJson(
        _$DistrictWatermarkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maisonId': instance.maisonId,
      'districtId': instance.districtId,
      'achievedAt': instance.achievedAt.toIso8601String(),
    };

_$TakeoverResultImpl _$$TakeoverResultImplFromJson(Map<String, dynamic> json) =>
    _$TakeoverResultImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      newController: json['newController'] as String?,
      defenseMultiplier: (json['defenseMultiplier'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$TakeoverResultImplToJson(
        _$TakeoverResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'newController': instance.newController,
      'defenseMultiplier': instance.defenseMultiplier,
    };
