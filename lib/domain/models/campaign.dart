// ignore_for_file: invalid_annotation_target

// GDD §5.4 — Marketing campaign entity
// Campaign Builder: presets + custom, budget sliders, ROI forecasts

import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

enum CampaignType {
  @JsonValue('social_blast')
  socialBlast,
  @JsonValue('influencer_drop')
  influencerDrop,
  @JsonValue('runway_event')
  runwayEvent,
  @JsonValue('targeted_ads')
  targetedAds,
  @JsonValue('custom')
  custom,
}

enum CampaignStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

@freezed
class Campaign with _$Campaign {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory Campaign({
    required String id,
    required String playerId,
    required CampaignType type,
    @Default(CampaignStatus.draft) CampaignStatus status,
    @Default(0.0) double budget,
    @Default(0.0) double roiActual,
    @Default(0.0) double roiForecast,
    @Default(0.0) double hypeLift, // GDD §5.4: +30–100% hype
    @Default(0.0) double salesLift,
    String? maisonPoolId, // if pooled with Maison (40% cost reduction)
    DateTime? launchedAt,
    DateTime? expiresAt,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);
}
