// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandEquityImpl _$$BrandEquityImplFromJson(Map<String, dynamic> json) =>
    _$BrandEquityImpl(
      brandId: json['brand_id'] as String,
      totalShares: (json['total_shares'] as num?)?.toInt() ?? 0,
      sharePrice: (json['share_price'] as num?)?.toDouble() ?? 0.0,
      valuation: (json['valuation'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['is_public'] as bool? ?? false,
      dividendPayoutRatio:
          (json['dividend_payout_ratio'] as num?)?.toDouble() ?? 0.0,
      ipoAt: json['ipo_at'] == null
          ? null
          : DateTime.parse(json['ipo_at'] as String),
    );

Map<String, dynamic> _$$BrandEquityImplToJson(_$BrandEquityImpl instance) =>
    <String, dynamic>{
      'brand_id': instance.brandId,
      'total_shares': instance.totalShares,
      'share_price': instance.sharePrice,
      'valuation': instance.valuation,
      'is_public': instance.isPublic,
      'dividend_payout_ratio': instance.dividendPayoutRatio,
      'ipo_at': instance.ipoAt?.toIso8601String(),
    };

_$EquityPositionImpl _$$EquityPositionImplFromJson(Map<String, dynamic> json) =>
    _$EquityPositionImpl(
      id: json['id'] as String,
      holderId: json['holder_id'] as String,
      brandId: json['brand_id'] as String,
      shareType: $enumDecode(_$ShareTypeEnumMap, json['share_type']),
      sharesOwned: (json['shares_owned'] as num?)?.toInt() ?? 0,
      averagePurchasePrice:
          (json['average_purchase_price'] as num?)?.toDouble() ?? 0.0,
      acquiredAt: json['acquired_at'] == null
          ? null
          : DateTime.parse(json['acquired_at'] as String),
    );

Map<String, dynamic> _$$EquityPositionImplToJson(
        _$EquityPositionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'holder_id': instance.holderId,
      'brand_id': instance.brandId,
      'share_type': _$ShareTypeEnumMap[instance.shareType]!,
      'shares_owned': instance.sharesOwned,
      'average_purchase_price': instance.averagePurchasePrice,
      'acquired_at': instance.acquiredAt?.toIso8601String(),
    };

const _$ShareTypeEnumMap = {
  ShareType.common: 'common',
  ShareType.preferred: 'preferred',
};
