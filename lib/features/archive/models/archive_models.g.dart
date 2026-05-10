// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArchiveListingImpl _$$ArchiveListingImplFromJson(Map<String, dynamic> json) =>
    _$ArchiveListingImpl(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      designId: json['designId'] as String,
      listingPrice: (json['listingPrice'] as num).toInt(),
      listedAt: json['listedAt'] == null
          ? null
          : DateTime.parse(json['listedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      status: json['status'] as String? ?? 'active',
      isGalaWinner: json['isGalaWinner'] as bool? ?? false,
      galaEventId: json['galaEventId'] as String?,
      designName: json['designName'] as String?,
      hypeScore: (json['hypeScore'] as num?)?.toInt() ?? 0,
      provenanceMultiplier:
          (json['provenanceMultiplier'] as num?)?.toDouble() ?? 1.0,
      hasSovereignProvenance: json['hasSovereignProvenance'] as bool? ?? false,
      transferCount: (json['transferCount'] as num?)?.toInt() ?? 0,
      designImageUrl: json['designImageUrl'] as String?,
      sellerName: json['sellerName'] as String?,
      sellerRank: (json['sellerRank'] as num?)?.toInt() ?? 1,
      sellerIsSovereign: json['sellerIsSovereign'] as bool? ?? false,
      galaTheme: json['galaTheme'] as String?,
    );

Map<String, dynamic> _$$ArchiveListingImplToJson(
        _$ArchiveListingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerId': instance.sellerId,
      'designId': instance.designId,
      'listingPrice': instance.listingPrice,
      'listedAt': instance.listedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'status': instance.status,
      'isGalaWinner': instance.isGalaWinner,
      'galaEventId': instance.galaEventId,
      'designName': instance.designName,
      'hypeScore': instance.hypeScore,
      'provenanceMultiplier': instance.provenanceMultiplier,
      'hasSovereignProvenance': instance.hasSovereignProvenance,
      'transferCount': instance.transferCount,
      'designImageUrl': instance.designImageUrl,
      'sellerName': instance.sellerName,
      'sellerRank': instance.sellerRank,
      'sellerIsSovereign': instance.sellerIsSovereign,
      'galaTheme': instance.galaTheme,
    };

_$ProvenanceRecordImpl _$$ProvenanceRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$ProvenanceRecordImpl(
      id: json['id'] as String,
      designId: json['designId'] as String,
      listingId: json['listingId'] as String?,
      previousOwnerId: json['previousOwnerId'] as String,
      newOwnerId: json['newOwnerId'] as String,
      salePrice: (json['salePrice'] as num).toInt(),
      platformTax: (json['platformTax'] as num).toInt(),
      sellerPayout: (json['sellerPayout'] as num).toInt(),
      transferredAt: json['transferredAt'] == null
          ? null
          : DateTime.parse(json['transferredAt'] as String),
      previousOwnerName: json['previousOwnerName'] as String?,
      previousOwnerRank: (json['previousOwnerRank'] as num?)?.toInt(),
      newOwnerName: json['newOwnerName'] as String?,
      newOwnerRank: (json['newOwnerRank'] as num?)?.toInt(),
      designName: json['designName'] as String?,
    );

Map<String, dynamic> _$$ProvenanceRecordImplToJson(
        _$ProvenanceRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'designId': instance.designId,
      'listingId': instance.listingId,
      'previousOwnerId': instance.previousOwnerId,
      'newOwnerId': instance.newOwnerId,
      'salePrice': instance.salePrice,
      'platformTax': instance.platformTax,
      'sellerPayout': instance.sellerPayout,
      'transferredAt': instance.transferredAt?.toIso8601String(),
      'previousOwnerName': instance.previousOwnerName,
      'previousOwnerRank': instance.previousOwnerRank,
      'newOwnerName': instance.newOwnerName,
      'newOwnerRank': instance.newOwnerRank,
      'designName': instance.designName,
    };

_$PurchaseResultImpl _$$PurchaseResultImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseResultImpl(
      success: json['success'] as bool,
      transactionId: json['transactionId'] as String?,
      message: json['message'] as String?,
      newProvenanceCount: (json['newProvenanceCount'] as num?)?.toInt(),
      newProvenanceMultiplier:
          (json['newProvenanceMultiplier'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PurchaseResultImplToJson(
        _$PurchaseResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'transactionId': instance.transactionId,
      'message': instance.message,
      'newProvenanceCount': instance.newProvenanceCount,
      'newProvenanceMultiplier': instance.newProvenanceMultiplier,
    };

_$ListingResultImpl _$$ListingResultImplFromJson(Map<String, dynamic> json) =>
    _$ListingResultImpl(
      success: json['success'] as bool,
      listingId: json['listingId'] as String?,
      message: json['message'] as String?,
      minimumPrice: (json['minimumPrice'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ListingResultImplToJson(_$ListingResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'listingId': instance.listingId,
      'message': instance.message,
      'minimumPrice': instance.minimumPrice,
    };

_$MarketStatsImpl _$$MarketStatsImplFromJson(Map<String, dynamic> json) =>
    _$MarketStatsImpl(
      totalActiveListings: (json['totalActiveListings'] as num?)?.toInt() ?? 0,
      totalVolume24h: (json['totalVolume24h'] as num?)?.toInt() ?? 0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble() ?? 0,
      taxBurned24h: (json['taxBurned24h'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MarketStatsImplToJson(_$MarketStatsImpl instance) =>
    <String, dynamic>{
      'totalActiveListings': instance.totalActiveListings,
      'totalVolume24h': instance.totalVolume24h,
      'averagePrice': instance.averagePrice,
      'taxBurned24h': instance.taxBurned24h,
    };
