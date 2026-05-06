// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampaignImpl _$$CampaignImplFromJson(Map<String, dynamic> json) =>
    _$CampaignImpl(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      type: $enumDecode(_$CampaignTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$CampaignStatusEnumMap, json['status']) ??
          CampaignStatus.draft,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      roiActual: (json['roiActual'] as num?)?.toDouble() ?? 0.0,
      roiForecast: (json['roiForecast'] as num?)?.toDouble() ?? 0.0,
      hypeLift: (json['hypeLift'] as num?)?.toDouble() ?? 0.0,
      salesLift: (json['salesLift'] as num?)?.toDouble() ?? 0.0,
      maisonPoolId: json['maisonPoolId'] as String?,
      launchedAt: json['launchedAt'] == null
          ? null
          : DateTime.parse(json['launchedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$CampaignImplToJson(_$CampaignImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'playerId': instance.playerId,
      'type': _$CampaignTypeEnumMap[instance.type]!,
      'status': _$CampaignStatusEnumMap[instance.status]!,
      'budget': instance.budget,
      'roiActual': instance.roiActual,
      'roiForecast': instance.roiForecast,
      'hypeLift': instance.hypeLift,
      'salesLift': instance.salesLift,
      'maisonPoolId': instance.maisonPoolId,
      'launchedAt': instance.launchedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

const _$CampaignTypeEnumMap = {
  CampaignType.socialBlast: 'social_blast',
  CampaignType.influencerDrop: 'influencer_drop',
  CampaignType.runwayEvent: 'runway_event',
  CampaignType.targetedAds: 'targeted_ads',
  CampaignType.custom: 'custom',
};

const _$CampaignStatusEnumMap = {
  CampaignStatus.draft: 'draft',
  CampaignStatus.active: 'active',
  CampaignStatus.completed: 'completed',
  CampaignStatus.failed: 'failed',
};
