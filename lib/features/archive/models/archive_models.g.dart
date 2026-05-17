// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArchiveListingImpl _$$ArchiveListingImplFromJson(Map<String, dynamic> json) =>
    _$ArchiveListingImpl(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      designId: json['design_id'] as String,
      listingPrice: (json['listing_price'] as num).toInt(),
      listedAt: json['listed_at'] == null
          ? null
          : DateTime.parse(json['listed_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      status: json['status'] as String? ?? 'active',
      isGalaWinner: json['is_gala_winner'] as bool? ?? false,
      galaEventId: json['gala_event_id'] as String?,
      designName: json['design_name'] as String?,
      hypeScore: (json['hype_score'] as num?)?.toInt() ?? 0,
      provenanceMultiplier:
          (json['provenance_multiplier'] as num?)?.toDouble() ?? 1.0,
      hasSovereignProvenance:
          json['has_sovereign_provenance'] as bool? ?? false,
      transferCount: (json['transfer_count'] as num?)?.toInt() ?? 0,
      designImageUrl: json['design_image_url'] as String?,
      sellerName: json['seller_name'] as String?,
      sellerRank: (json['seller_rank'] as num?)?.toInt() ?? 1,
      sellerIsSovereign: json['seller_is_sovereign'] as bool? ?? false,
      galaTheme: json['gala_theme'] as String?,
    );

Map<String, dynamic> _$$ArchiveListingImplToJson(
        _$ArchiveListingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seller_id': instance.sellerId,
      'design_id': instance.designId,
      'listing_price': instance.listingPrice,
      'listed_at': instance.listedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'status': instance.status,
      'is_gala_winner': instance.isGalaWinner,
      'gala_event_id': instance.galaEventId,
      'design_name': instance.designName,
      'hype_score': instance.hypeScore,
      'provenance_multiplier': instance.provenanceMultiplier,
      'has_sovereign_provenance': instance.hasSovereignProvenance,
      'transfer_count': instance.transferCount,
      'design_image_url': instance.designImageUrl,
      'seller_name': instance.sellerName,
      'seller_rank': instance.sellerRank,
      'seller_is_sovereign': instance.sellerIsSovereign,
      'gala_theme': instance.galaTheme,
    };

_$ProvenanceRecordImpl _$$ProvenanceRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$ProvenanceRecordImpl(
      id: json['id'] as String,
      designId: json['design_id'] as String,
      previousOwnerId: json['previous_owner_id'] as String,
      newOwnerId: json['new_owner_id'] as String,
      salePrice: (json['sale_price'] as num).toInt(),
      platformTax: (json['platform_tax'] as num).toInt(),
      sellerPayout: (json['seller_payout'] as num).toInt(),
      listingId: json['listing_id'] as String?,
      transferredAt: json['transferred_at'] == null
          ? null
          : DateTime.parse(json['transferred_at'] as String),
      previousOwnerName: json['previous_owner_name'] as String?,
      previousOwnerRank: (json['previous_owner_rank'] as num?)?.toInt(),
      newOwnerName: json['new_owner_name'] as String?,
      newOwnerRank: (json['new_owner_rank'] as num?)?.toInt(),
      designName: json['design_name'] as String?,
    );

Map<String, dynamic> _$$ProvenanceRecordImplToJson(
        _$ProvenanceRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'design_id': instance.designId,
      'previous_owner_id': instance.previousOwnerId,
      'new_owner_id': instance.newOwnerId,
      'sale_price': instance.salePrice,
      'platform_tax': instance.platformTax,
      'seller_payout': instance.sellerPayout,
      'listing_id': instance.listingId,
      'transferred_at': instance.transferredAt?.toIso8601String(),
      'previous_owner_name': instance.previousOwnerName,
      'previous_owner_rank': instance.previousOwnerRank,
      'new_owner_name': instance.newOwnerName,
      'new_owner_rank': instance.newOwnerRank,
      'design_name': instance.designName,
    };

_$PurchaseResultImpl _$$PurchaseResultImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseResultImpl(
      success: json['success'] as bool,
      transactionId: json['transaction_id'] as String?,
      message: json['message'] as String?,
      newProvenanceCount: (json['new_provenance_count'] as num?)?.toInt(),
      newProvenanceMultiplier:
          (json['new_provenance_multiplier'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PurchaseResultImplToJson(
        _$PurchaseResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'transaction_id': instance.transactionId,
      'message': instance.message,
      'new_provenance_count': instance.newProvenanceCount,
      'new_provenance_multiplier': instance.newProvenanceMultiplier,
    };

_$ListingResultImpl _$$ListingResultImplFromJson(Map<String, dynamic> json) =>
    _$ListingResultImpl(
      success: json['success'] as bool,
      listingId: json['listing_id'] as String?,
      message: json['message'] as String?,
      minimumPrice: (json['minimum_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ListingResultImplToJson(_$ListingResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'listing_id': instance.listingId,
      'message': instance.message,
      'minimum_price': instance.minimumPrice,
    };

_$MarketStatsImpl _$$MarketStatsImplFromJson(Map<String, dynamic> json) =>
    _$MarketStatsImpl(
      totalActiveListings:
          (json['total_active_listings'] as num?)?.toInt() ?? 0,
      totalVolume24h: (json['total_volume24h'] as num?)?.toInt() ?? 0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0,
      taxBurned24h: (json['tax_burned24h'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MarketStatsImplToJson(_$MarketStatsImpl instance) =>
    <String, dynamic>{
      'total_active_listings': instance.totalActiveListings,
      'total_volume24h': instance.totalVolume24h,
      'average_price': instance.averagePrice,
      'tax_burned24h': instance.taxBurned24h,
    };
