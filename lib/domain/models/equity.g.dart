// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BrandEquityImpl _$$BrandEquityImplFromJson(Map<String, dynamic> json) =>
    _$BrandEquityImpl(
      brandId: json['brandId'] as String,
      totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
      sharePrice: (json['sharePrice'] as num?)?.toDouble() ?? 0.0,
      valuation: (json['valuation'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['isPublic'] as bool? ?? false,
      dividendPayoutRatio:
          (json['dividendPayoutRatio'] as num?)?.toDouble() ?? 0.0,
      ipoAt: json['ipoAt'] == null
          ? null
          : DateTime.parse(json['ipoAt'] as String),
    );

Map<String, dynamic> _$$BrandEquityImplToJson(_$BrandEquityImpl instance) =>
    <String, dynamic>{
      'brandId': instance.brandId,
      'totalShares': instance.totalShares,
      'sharePrice': instance.sharePrice,
      'valuation': instance.valuation,
      'isPublic': instance.isPublic,
      'dividendPayoutRatio': instance.dividendPayoutRatio,
      'ipoAt': instance.ipoAt?.toIso8601String(),
    };

_$EquityPositionImpl _$$EquityPositionImplFromJson(Map<String, dynamic> json) =>
    _$EquityPositionImpl(
      id: json['id'] as String,
      holderId: json['holderId'] as String,
      brandId: json['brandId'] as String,
      shareType: $enumDecode(_$ShareTypeEnumMap, json['shareType']),
      sharesOwned: (json['sharesOwned'] as num?)?.toInt() ?? 0,
      averagePurchasePrice:
          (json['averagePurchasePrice'] as num?)?.toDouble() ?? 0.0,
      acquiredAt: json['acquiredAt'] == null
          ? null
          : DateTime.parse(json['acquiredAt'] as String),
    );

Map<String, dynamic> _$$EquityPositionImplToJson(
        _$EquityPositionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'holderId': instance.holderId,
      'brandId': instance.brandId,
      'shareType': _$ShareTypeEnumMap[instance.shareType]!,
      'sharesOwned': instance.sharesOwned,
      'averagePurchasePrice': instance.averagePurchasePrice,
      'acquiredAt': instance.acquiredAt?.toIso8601String(),
    };

const _$ShareTypeEnumMap = {
  ShareType.common: 'common',
  ShareType.preferred: 'preferred',
};
