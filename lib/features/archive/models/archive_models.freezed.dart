// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ArchiveListing _$ArchiveListingFromJson(Map<String, dynamic> json) {
  return _ArchiveListing.fromJson(json);
}

/// @nodoc
mixin _$ArchiveListing {
  String get id => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  String get designId => throw _privateConstructorUsedError;
  int get listingPrice => throw _privateConstructorUsedError;
  DateTime? get listedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isGalaWinner => throw _privateConstructorUsedError;
  String? get galaEventId =>
      throw _privateConstructorUsedError; // Enriched fields from view
  String? get designName => throw _privateConstructorUsedError;
  int get hypeScore => throw _privateConstructorUsedError;
  double get provenanceMultiplier => throw _privateConstructorUsedError;
  bool get hasSovereignProvenance => throw _privateConstructorUsedError;
  int get transferCount => throw _privateConstructorUsedError;
  String? get designImageUrl => throw _privateConstructorUsedError;
  String? get sellerName => throw _privateConstructorUsedError;
  int get sellerRank => throw _privateConstructorUsedError;
  bool get sellerIsSovereign => throw _privateConstructorUsedError;
  String? get galaTheme => throw _privateConstructorUsedError;

  /// Serializes this ArchiveListing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArchiveListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArchiveListingCopyWith<ArchiveListing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArchiveListingCopyWith<$Res> {
  factory $ArchiveListingCopyWith(
          ArchiveListing value, $Res Function(ArchiveListing) then) =
      _$ArchiveListingCopyWithImpl<$Res, ArchiveListing>;
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String designId,
      int listingPrice,
      DateTime? listedAt,
      DateTime? expiresAt,
      String status,
      bool isGalaWinner,
      String? galaEventId,
      String? designName,
      int hypeScore,
      double provenanceMultiplier,
      bool hasSovereignProvenance,
      int transferCount,
      String? designImageUrl,
      String? sellerName,
      int sellerRank,
      bool sellerIsSovereign,
      String? galaTheme});
}

/// @nodoc
class _$ArchiveListingCopyWithImpl<$Res, $Val extends ArchiveListing>
    implements $ArchiveListingCopyWith<$Res> {
  _$ArchiveListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArchiveListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? designId = null,
    Object? listingPrice = null,
    Object? listedAt = freezed,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? isGalaWinner = null,
    Object? galaEventId = freezed,
    Object? designName = freezed,
    Object? hypeScore = null,
    Object? provenanceMultiplier = null,
    Object? hasSovereignProvenance = null,
    Object? transferCount = null,
    Object? designImageUrl = freezed,
    Object? sellerName = freezed,
    Object? sellerRank = null,
    Object? sellerIsSovereign = null,
    Object? galaTheme = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      listingPrice: null == listingPrice
          ? _value.listingPrice
          : listingPrice // ignore: cast_nullable_to_non_nullable
              as int,
      listedAt: freezed == listedAt
          ? _value.listedAt
          : listedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isGalaWinner: null == isGalaWinner
          ? _value.isGalaWinner
          : isGalaWinner // ignore: cast_nullable_to_non_nullable
              as bool,
      galaEventId: freezed == galaEventId
          ? _value.galaEventId
          : galaEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as int,
      provenanceMultiplier: null == provenanceMultiplier
          ? _value.provenanceMultiplier
          : provenanceMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      hasSovereignProvenance: null == hasSovereignProvenance
          ? _value.hasSovereignProvenance
          : hasSovereignProvenance // ignore: cast_nullable_to_non_nullable
              as bool,
      transferCount: null == transferCount
          ? _value.transferCount
          : transferCount // ignore: cast_nullable_to_non_nullable
              as int,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerRank: null == sellerRank
          ? _value.sellerRank
          : sellerRank // ignore: cast_nullable_to_non_nullable
              as int,
      sellerIsSovereign: null == sellerIsSovereign
          ? _value.sellerIsSovereign
          : sellerIsSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      galaTheme: freezed == galaTheme
          ? _value.galaTheme
          : galaTheme // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArchiveListingImplCopyWith<$Res>
    implements $ArchiveListingCopyWith<$Res> {
  factory _$$ArchiveListingImplCopyWith(_$ArchiveListingImpl value,
          $Res Function(_$ArchiveListingImpl) then) =
      __$$ArchiveListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sellerId,
      String designId,
      int listingPrice,
      DateTime? listedAt,
      DateTime? expiresAt,
      String status,
      bool isGalaWinner,
      String? galaEventId,
      String? designName,
      int hypeScore,
      double provenanceMultiplier,
      bool hasSovereignProvenance,
      int transferCount,
      String? designImageUrl,
      String? sellerName,
      int sellerRank,
      bool sellerIsSovereign,
      String? galaTheme});
}

/// @nodoc
class __$$ArchiveListingImplCopyWithImpl<$Res>
    extends _$ArchiveListingCopyWithImpl<$Res, _$ArchiveListingImpl>
    implements _$$ArchiveListingImplCopyWith<$Res> {
  __$$ArchiveListingImplCopyWithImpl(
      _$ArchiveListingImpl _value, $Res Function(_$ArchiveListingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveListing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sellerId = null,
    Object? designId = null,
    Object? listingPrice = null,
    Object? listedAt = freezed,
    Object? expiresAt = freezed,
    Object? status = null,
    Object? isGalaWinner = null,
    Object? galaEventId = freezed,
    Object? designName = freezed,
    Object? hypeScore = null,
    Object? provenanceMultiplier = null,
    Object? hasSovereignProvenance = null,
    Object? transferCount = null,
    Object? designImageUrl = freezed,
    Object? sellerName = freezed,
    Object? sellerRank = null,
    Object? sellerIsSovereign = null,
    Object? galaTheme = freezed,
  }) {
    return _then(_$ArchiveListingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      listingPrice: null == listingPrice
          ? _value.listingPrice
          : listingPrice // ignore: cast_nullable_to_non_nullable
              as int,
      listedAt: freezed == listedAt
          ? _value.listedAt
          : listedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isGalaWinner: null == isGalaWinner
          ? _value.isGalaWinner
          : isGalaWinner // ignore: cast_nullable_to_non_nullable
              as bool,
      galaEventId: freezed == galaEventId
          ? _value.galaEventId
          : galaEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as int,
      provenanceMultiplier: null == provenanceMultiplier
          ? _value.provenanceMultiplier
          : provenanceMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      hasSovereignProvenance: null == hasSovereignProvenance
          ? _value.hasSovereignProvenance
          : hasSovereignProvenance // ignore: cast_nullable_to_non_nullable
              as bool,
      transferCount: null == transferCount
          ? _value.transferCount
          : transferCount // ignore: cast_nullable_to_non_nullable
              as int,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerName: freezed == sellerName
          ? _value.sellerName
          : sellerName // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerRank: null == sellerRank
          ? _value.sellerRank
          : sellerRank // ignore: cast_nullable_to_non_nullable
              as int,
      sellerIsSovereign: null == sellerIsSovereign
          ? _value.sellerIsSovereign
          : sellerIsSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      galaTheme: freezed == galaTheme
          ? _value.galaTheme
          : galaTheme // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ArchiveListingImpl extends _ArchiveListing {
  const _$ArchiveListingImpl(
      {required this.id,
      required this.sellerId,
      required this.designId,
      required this.listingPrice,
      this.listedAt,
      this.expiresAt,
      this.status = 'active',
      this.isGalaWinner = false,
      this.galaEventId,
      this.designName,
      this.hypeScore = 0,
      this.provenanceMultiplier = 1.0,
      this.hasSovereignProvenance = false,
      this.transferCount = 0,
      this.designImageUrl,
      this.sellerName,
      this.sellerRank = 1,
      this.sellerIsSovereign = false,
      this.galaTheme})
      : super._();

  factory _$ArchiveListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArchiveListingImplFromJson(json);

  @override
  final String id;
  @override
  final String sellerId;
  @override
  final String designId;
  @override
  final int listingPrice;
  @override
  final DateTime? listedAt;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool isGalaWinner;
  @override
  final String? galaEventId;
// Enriched fields from view
  @override
  final String? designName;
  @override
  @JsonKey()
  final int hypeScore;
  @override
  @JsonKey()
  final double provenanceMultiplier;
  @override
  @JsonKey()
  final bool hasSovereignProvenance;
  @override
  @JsonKey()
  final int transferCount;
  @override
  final String? designImageUrl;
  @override
  final String? sellerName;
  @override
  @JsonKey()
  final int sellerRank;
  @override
  @JsonKey()
  final bool sellerIsSovereign;
  @override
  final String? galaTheme;

  @override
  String toString() {
    return 'ArchiveListing(id: $id, sellerId: $sellerId, designId: $designId, listingPrice: $listingPrice, listedAt: $listedAt, expiresAt: $expiresAt, status: $status, isGalaWinner: $isGalaWinner, galaEventId: $galaEventId, designName: $designName, hypeScore: $hypeScore, provenanceMultiplier: $provenanceMultiplier, hasSovereignProvenance: $hasSovereignProvenance, transferCount: $transferCount, designImageUrl: $designImageUrl, sellerName: $sellerName, sellerRank: $sellerRank, sellerIsSovereign: $sellerIsSovereign, galaTheme: $galaTheme)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArchiveListingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.designId, designId) ||
                other.designId == designId) &&
            (identical(other.listingPrice, listingPrice) ||
                other.listingPrice == listingPrice) &&
            (identical(other.listedAt, listedAt) ||
                other.listedAt == listedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isGalaWinner, isGalaWinner) ||
                other.isGalaWinner == isGalaWinner) &&
            (identical(other.galaEventId, galaEventId) ||
                other.galaEventId == galaEventId) &&
            (identical(other.designName, designName) ||
                other.designName == designName) &&
            (identical(other.hypeScore, hypeScore) ||
                other.hypeScore == hypeScore) &&
            (identical(other.provenanceMultiplier, provenanceMultiplier) ||
                other.provenanceMultiplier == provenanceMultiplier) &&
            (identical(other.hasSovereignProvenance, hasSovereignProvenance) ||
                other.hasSovereignProvenance == hasSovereignProvenance) &&
            (identical(other.transferCount, transferCount) ||
                other.transferCount == transferCount) &&
            (identical(other.designImageUrl, designImageUrl) ||
                other.designImageUrl == designImageUrl) &&
            (identical(other.sellerName, sellerName) ||
                other.sellerName == sellerName) &&
            (identical(other.sellerRank, sellerRank) ||
                other.sellerRank == sellerRank) &&
            (identical(other.sellerIsSovereign, sellerIsSovereign) ||
                other.sellerIsSovereign == sellerIsSovereign) &&
            (identical(other.galaTheme, galaTheme) ||
                other.galaTheme == galaTheme));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        sellerId,
        designId,
        listingPrice,
        listedAt,
        expiresAt,
        status,
        isGalaWinner,
        galaEventId,
        designName,
        hypeScore,
        provenanceMultiplier,
        hasSovereignProvenance,
        transferCount,
        designImageUrl,
        sellerName,
        sellerRank,
        sellerIsSovereign,
        galaTheme
      ]);

  /// Create a copy of ArchiveListing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArchiveListingImplCopyWith<_$ArchiveListingImpl> get copyWith =>
      __$$ArchiveListingImplCopyWithImpl<_$ArchiveListingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArchiveListingImplToJson(
      this,
    );
  }
}

abstract class _ArchiveListing extends ArchiveListing {
  const factory _ArchiveListing(
      {required final String id,
      required final String sellerId,
      required final String designId,
      required final int listingPrice,
      final DateTime? listedAt,
      final DateTime? expiresAt,
      final String status,
      final bool isGalaWinner,
      final String? galaEventId,
      final String? designName,
      final int hypeScore,
      final double provenanceMultiplier,
      final bool hasSovereignProvenance,
      final int transferCount,
      final String? designImageUrl,
      final String? sellerName,
      final int sellerRank,
      final bool sellerIsSovereign,
      final String? galaTheme}) = _$ArchiveListingImpl;
  const _ArchiveListing._() : super._();

  factory _ArchiveListing.fromJson(Map<String, dynamic> json) =
      _$ArchiveListingImpl.fromJson;

  @override
  String get id;
  @override
  String get sellerId;
  @override
  String get designId;
  @override
  int get listingPrice;
  @override
  DateTime? get listedAt;
  @override
  DateTime? get expiresAt;
  @override
  String get status;
  @override
  bool get isGalaWinner;
  @override
  String? get galaEventId; // Enriched fields from view
  @override
  String? get designName;
  @override
  int get hypeScore;
  @override
  double get provenanceMultiplier;
  @override
  bool get hasSovereignProvenance;
  @override
  int get transferCount;
  @override
  String? get designImageUrl;
  @override
  String? get sellerName;
  @override
  int get sellerRank;
  @override
  bool get sellerIsSovereign;
  @override
  String? get galaTheme;

  /// Create a copy of ArchiveListing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArchiveListingImplCopyWith<_$ArchiveListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProvenanceRecord _$ProvenanceRecordFromJson(Map<String, dynamic> json) {
  return _ProvenanceRecord.fromJson(json);
}

/// @nodoc
mixin _$ProvenanceRecord {
  String get id => throw _privateConstructorUsedError;
  String get designId => throw _privateConstructorUsedError;
  String? get listingId => throw _privateConstructorUsedError;
  String get previousOwnerId => throw _privateConstructorUsedError;
  String get newOwnerId => throw _privateConstructorUsedError;
  int get salePrice => throw _privateConstructorUsedError;
  int get platformTax => throw _privateConstructorUsedError;
  int get sellerPayout => throw _privateConstructorUsedError;
  DateTime? get transferredAt =>
      throw _privateConstructorUsedError; // Enriched fields
  String? get previousOwnerName => throw _privateConstructorUsedError;
  int? get previousOwnerRank => throw _privateConstructorUsedError;
  String? get newOwnerName => throw _privateConstructorUsedError;
  int? get newOwnerRank => throw _privateConstructorUsedError;
  String? get designName => throw _privateConstructorUsedError;

  /// Serializes this ProvenanceRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProvenanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProvenanceRecordCopyWith<ProvenanceRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProvenanceRecordCopyWith<$Res> {
  factory $ProvenanceRecordCopyWith(
          ProvenanceRecord value, $Res Function(ProvenanceRecord) then) =
      _$ProvenanceRecordCopyWithImpl<$Res, ProvenanceRecord>;
  @useResult
  $Res call(
      {String id,
      String designId,
      String? listingId,
      String previousOwnerId,
      String newOwnerId,
      int salePrice,
      int platformTax,
      int sellerPayout,
      DateTime? transferredAt,
      String? previousOwnerName,
      int? previousOwnerRank,
      String? newOwnerName,
      int? newOwnerRank,
      String? designName});
}

/// @nodoc
class _$ProvenanceRecordCopyWithImpl<$Res, $Val extends ProvenanceRecord>
    implements $ProvenanceRecordCopyWith<$Res> {
  _$ProvenanceRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProvenanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? designId = null,
    Object? listingId = freezed,
    Object? previousOwnerId = null,
    Object? newOwnerId = null,
    Object? salePrice = null,
    Object? platformTax = null,
    Object? sellerPayout = null,
    Object? transferredAt = freezed,
    Object? previousOwnerName = freezed,
    Object? previousOwnerRank = freezed,
    Object? newOwnerName = freezed,
    Object? newOwnerRank = freezed,
    Object? designName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      previousOwnerId: null == previousOwnerId
          ? _value.previousOwnerId
          : previousOwnerId // ignore: cast_nullable_to_non_nullable
              as String,
      newOwnerId: null == newOwnerId
          ? _value.newOwnerId
          : newOwnerId // ignore: cast_nullable_to_non_nullable
              as String,
      salePrice: null == salePrice
          ? _value.salePrice
          : salePrice // ignore: cast_nullable_to_non_nullable
              as int,
      platformTax: null == platformTax
          ? _value.platformTax
          : platformTax // ignore: cast_nullable_to_non_nullable
              as int,
      sellerPayout: null == sellerPayout
          ? _value.sellerPayout
          : sellerPayout // ignore: cast_nullable_to_non_nullable
              as int,
      transferredAt: freezed == transferredAt
          ? _value.transferredAt
          : transferredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      previousOwnerName: freezed == previousOwnerName
          ? _value.previousOwnerName
          : previousOwnerName // ignore: cast_nullable_to_non_nullable
              as String?,
      previousOwnerRank: freezed == previousOwnerRank
          ? _value.previousOwnerRank
          : previousOwnerRank // ignore: cast_nullable_to_non_nullable
              as int?,
      newOwnerName: freezed == newOwnerName
          ? _value.newOwnerName
          : newOwnerName // ignore: cast_nullable_to_non_nullable
              as String?,
      newOwnerRank: freezed == newOwnerRank
          ? _value.newOwnerRank
          : newOwnerRank // ignore: cast_nullable_to_non_nullable
              as int?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProvenanceRecordImplCopyWith<$Res>
    implements $ProvenanceRecordCopyWith<$Res> {
  factory _$$ProvenanceRecordImplCopyWith(_$ProvenanceRecordImpl value,
          $Res Function(_$ProvenanceRecordImpl) then) =
      __$$ProvenanceRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String designId,
      String? listingId,
      String previousOwnerId,
      String newOwnerId,
      int salePrice,
      int platformTax,
      int sellerPayout,
      DateTime? transferredAt,
      String? previousOwnerName,
      int? previousOwnerRank,
      String? newOwnerName,
      int? newOwnerRank,
      String? designName});
}

/// @nodoc
class __$$ProvenanceRecordImplCopyWithImpl<$Res>
    extends _$ProvenanceRecordCopyWithImpl<$Res, _$ProvenanceRecordImpl>
    implements _$$ProvenanceRecordImplCopyWith<$Res> {
  __$$ProvenanceRecordImplCopyWithImpl(_$ProvenanceRecordImpl _value,
      $Res Function(_$ProvenanceRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProvenanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? designId = null,
    Object? listingId = freezed,
    Object? previousOwnerId = null,
    Object? newOwnerId = null,
    Object? salePrice = null,
    Object? platformTax = null,
    Object? sellerPayout = null,
    Object? transferredAt = freezed,
    Object? previousOwnerName = freezed,
    Object? previousOwnerRank = freezed,
    Object? newOwnerName = freezed,
    Object? newOwnerRank = freezed,
    Object? designName = freezed,
  }) {
    return _then(_$ProvenanceRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      previousOwnerId: null == previousOwnerId
          ? _value.previousOwnerId
          : previousOwnerId // ignore: cast_nullable_to_non_nullable
              as String,
      newOwnerId: null == newOwnerId
          ? _value.newOwnerId
          : newOwnerId // ignore: cast_nullable_to_non_nullable
              as String,
      salePrice: null == salePrice
          ? _value.salePrice
          : salePrice // ignore: cast_nullable_to_non_nullable
              as int,
      platformTax: null == platformTax
          ? _value.platformTax
          : platformTax // ignore: cast_nullable_to_non_nullable
              as int,
      sellerPayout: null == sellerPayout
          ? _value.sellerPayout
          : sellerPayout // ignore: cast_nullable_to_non_nullable
              as int,
      transferredAt: freezed == transferredAt
          ? _value.transferredAt
          : transferredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      previousOwnerName: freezed == previousOwnerName
          ? _value.previousOwnerName
          : previousOwnerName // ignore: cast_nullable_to_non_nullable
              as String?,
      previousOwnerRank: freezed == previousOwnerRank
          ? _value.previousOwnerRank
          : previousOwnerRank // ignore: cast_nullable_to_non_nullable
              as int?,
      newOwnerName: freezed == newOwnerName
          ? _value.newOwnerName
          : newOwnerName // ignore: cast_nullable_to_non_nullable
              as String?,
      newOwnerRank: freezed == newOwnerRank
          ? _value.newOwnerRank
          : newOwnerRank // ignore: cast_nullable_to_non_nullable
              as int?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProvenanceRecordImpl extends _ProvenanceRecord {
  const _$ProvenanceRecordImpl(
      {required this.id,
      required this.designId,
      this.listingId,
      required this.previousOwnerId,
      required this.newOwnerId,
      required this.salePrice,
      required this.platformTax,
      required this.sellerPayout,
      this.transferredAt,
      this.previousOwnerName,
      this.previousOwnerRank,
      this.newOwnerName,
      this.newOwnerRank,
      this.designName})
      : super._();

  factory _$ProvenanceRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProvenanceRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String designId;
  @override
  final String? listingId;
  @override
  final String previousOwnerId;
  @override
  final String newOwnerId;
  @override
  final int salePrice;
  @override
  final int platformTax;
  @override
  final int sellerPayout;
  @override
  final DateTime? transferredAt;
// Enriched fields
  @override
  final String? previousOwnerName;
  @override
  final int? previousOwnerRank;
  @override
  final String? newOwnerName;
  @override
  final int? newOwnerRank;
  @override
  final String? designName;

  @override
  String toString() {
    return 'ProvenanceRecord(id: $id, designId: $designId, listingId: $listingId, previousOwnerId: $previousOwnerId, newOwnerId: $newOwnerId, salePrice: $salePrice, platformTax: $platformTax, sellerPayout: $sellerPayout, transferredAt: $transferredAt, previousOwnerName: $previousOwnerName, previousOwnerRank: $previousOwnerRank, newOwnerName: $newOwnerName, newOwnerRank: $newOwnerRank, designName: $designName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProvenanceRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.designId, designId) ||
                other.designId == designId) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.previousOwnerId, previousOwnerId) ||
                other.previousOwnerId == previousOwnerId) &&
            (identical(other.newOwnerId, newOwnerId) ||
                other.newOwnerId == newOwnerId) &&
            (identical(other.salePrice, salePrice) ||
                other.salePrice == salePrice) &&
            (identical(other.platformTax, platformTax) ||
                other.platformTax == platformTax) &&
            (identical(other.sellerPayout, sellerPayout) ||
                other.sellerPayout == sellerPayout) &&
            (identical(other.transferredAt, transferredAt) ||
                other.transferredAt == transferredAt) &&
            (identical(other.previousOwnerName, previousOwnerName) ||
                other.previousOwnerName == previousOwnerName) &&
            (identical(other.previousOwnerRank, previousOwnerRank) ||
                other.previousOwnerRank == previousOwnerRank) &&
            (identical(other.newOwnerName, newOwnerName) ||
                other.newOwnerName == newOwnerName) &&
            (identical(other.newOwnerRank, newOwnerRank) ||
                other.newOwnerRank == newOwnerRank) &&
            (identical(other.designName, designName) ||
                other.designName == designName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      designId,
      listingId,
      previousOwnerId,
      newOwnerId,
      salePrice,
      platformTax,
      sellerPayout,
      transferredAt,
      previousOwnerName,
      previousOwnerRank,
      newOwnerName,
      newOwnerRank,
      designName);

  /// Create a copy of ProvenanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProvenanceRecordImplCopyWith<_$ProvenanceRecordImpl> get copyWith =>
      __$$ProvenanceRecordImplCopyWithImpl<_$ProvenanceRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProvenanceRecordImplToJson(
      this,
    );
  }
}

abstract class _ProvenanceRecord extends ProvenanceRecord {
  const factory _ProvenanceRecord(
      {required final String id,
      required final String designId,
      final String? listingId,
      required final String previousOwnerId,
      required final String newOwnerId,
      required final int salePrice,
      required final int platformTax,
      required final int sellerPayout,
      final DateTime? transferredAt,
      final String? previousOwnerName,
      final int? previousOwnerRank,
      final String? newOwnerName,
      final int? newOwnerRank,
      final String? designName}) = _$ProvenanceRecordImpl;
  const _ProvenanceRecord._() : super._();

  factory _ProvenanceRecord.fromJson(Map<String, dynamic> json) =
      _$ProvenanceRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get designId;
  @override
  String? get listingId;
  @override
  String get previousOwnerId;
  @override
  String get newOwnerId;
  @override
  int get salePrice;
  @override
  int get platformTax;
  @override
  int get sellerPayout;
  @override
  DateTime? get transferredAt; // Enriched fields
  @override
  String? get previousOwnerName;
  @override
  int? get previousOwnerRank;
  @override
  String? get newOwnerName;
  @override
  int? get newOwnerRank;
  @override
  String? get designName;

  /// Create a copy of ProvenanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProvenanceRecordImplCopyWith<_$ProvenanceRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) {
  return _PurchaseResult.fromJson(json);
}

/// @nodoc
mixin _$PurchaseResult {
  bool get success => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  int? get newProvenanceCount => throw _privateConstructorUsedError;
  double? get newProvenanceMultiplier => throw _privateConstructorUsedError;

  /// Serializes this PurchaseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseResultCopyWith<PurchaseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseResultCopyWith<$Res> {
  factory $PurchaseResultCopyWith(
          PurchaseResult value, $Res Function(PurchaseResult) then) =
      _$PurchaseResultCopyWithImpl<$Res, PurchaseResult>;
  @useResult
  $Res call(
      {bool success,
      String? transactionId,
      String? message,
      int? newProvenanceCount,
      double? newProvenanceMultiplier});
}

/// @nodoc
class _$PurchaseResultCopyWithImpl<$Res, $Val extends PurchaseResult>
    implements $PurchaseResultCopyWith<$Res> {
  _$PurchaseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? transactionId = freezed,
    Object? message = freezed,
    Object? newProvenanceCount = freezed,
    Object? newProvenanceMultiplier = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      newProvenanceCount: freezed == newProvenanceCount
          ? _value.newProvenanceCount
          : newProvenanceCount // ignore: cast_nullable_to_non_nullable
              as int?,
      newProvenanceMultiplier: freezed == newProvenanceMultiplier
          ? _value.newProvenanceMultiplier
          : newProvenanceMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseResultImplCopyWith<$Res>
    implements $PurchaseResultCopyWith<$Res> {
  factory _$$PurchaseResultImplCopyWith(_$PurchaseResultImpl value,
          $Res Function(_$PurchaseResultImpl) then) =
      __$$PurchaseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      String? transactionId,
      String? message,
      int? newProvenanceCount,
      double? newProvenanceMultiplier});
}

/// @nodoc
class __$$PurchaseResultImplCopyWithImpl<$Res>
    extends _$PurchaseResultCopyWithImpl<$Res, _$PurchaseResultImpl>
    implements _$$PurchaseResultImplCopyWith<$Res> {
  __$$PurchaseResultImplCopyWithImpl(
      _$PurchaseResultImpl _value, $Res Function(_$PurchaseResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? transactionId = freezed,
    Object? message = freezed,
    Object? newProvenanceCount = freezed,
    Object? newProvenanceMultiplier = freezed,
  }) {
    return _then(_$PurchaseResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      newProvenanceCount: freezed == newProvenanceCount
          ? _value.newProvenanceCount
          : newProvenanceCount // ignore: cast_nullable_to_non_nullable
              as int?,
      newProvenanceMultiplier: freezed == newProvenanceMultiplier
          ? _value.newProvenanceMultiplier
          : newProvenanceMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseResultImpl implements _PurchaseResult {
  const _$PurchaseResultImpl(
      {required this.success,
      this.transactionId,
      this.message,
      this.newProvenanceCount,
      this.newProvenanceMultiplier});

  factory _$PurchaseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseResultImplFromJson(json);

  @override
  final bool success;
  @override
  final String? transactionId;
  @override
  final String? message;
  @override
  final int? newProvenanceCount;
  @override
  final double? newProvenanceMultiplier;

  @override
  String toString() {
    return 'PurchaseResult(success: $success, transactionId: $transactionId, message: $message, newProvenanceCount: $newProvenanceCount, newProvenanceMultiplier: $newProvenanceMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.newProvenanceCount, newProvenanceCount) ||
                other.newProvenanceCount == newProvenanceCount) &&
            (identical(
                    other.newProvenanceMultiplier, newProvenanceMultiplier) ||
                other.newProvenanceMultiplier == newProvenanceMultiplier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, transactionId, message,
      newProvenanceCount, newProvenanceMultiplier);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      __$$PurchaseResultImplCopyWithImpl<_$PurchaseResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseResultImplToJson(
      this,
    );
  }
}

abstract class _PurchaseResult implements PurchaseResult {
  const factory _PurchaseResult(
      {required final bool success,
      final String? transactionId,
      final String? message,
      final int? newProvenanceCount,
      final double? newProvenanceMultiplier}) = _$PurchaseResultImpl;

  factory _PurchaseResult.fromJson(Map<String, dynamic> json) =
      _$PurchaseResultImpl.fromJson;

  @override
  bool get success;
  @override
  String? get transactionId;
  @override
  String? get message;
  @override
  int? get newProvenanceCount;
  @override
  double? get newProvenanceMultiplier;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingResult _$ListingResultFromJson(Map<String, dynamic> json) {
  return _ListingResult.fromJson(json);
}

/// @nodoc
mixin _$ListingResult {
  bool get success => throw _privateConstructorUsedError;
  String? get listingId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  int? get minimumPrice => throw _privateConstructorUsedError;

  /// Serializes this ListingResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingResultCopyWith<ListingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingResultCopyWith<$Res> {
  factory $ListingResultCopyWith(
          ListingResult value, $Res Function(ListingResult) then) =
      _$ListingResultCopyWithImpl<$Res, ListingResult>;
  @useResult
  $Res call(
      {bool success, String? listingId, String? message, int? minimumPrice});
}

/// @nodoc
class _$ListingResultCopyWithImpl<$Res, $Val extends ListingResult>
    implements $ListingResultCopyWith<$Res> {
  _$ListingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? listingId = freezed,
    Object? message = freezed,
    Object? minimumPrice = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumPrice: freezed == minimumPrice
          ? _value.minimumPrice
          : minimumPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingResultImplCopyWith<$Res>
    implements $ListingResultCopyWith<$Res> {
  factory _$$ListingResultImplCopyWith(
          _$ListingResultImpl value, $Res Function(_$ListingResultImpl) then) =
      __$$ListingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success, String? listingId, String? message, int? minimumPrice});
}

/// @nodoc
class __$$ListingResultImplCopyWithImpl<$Res>
    extends _$ListingResultCopyWithImpl<$Res, _$ListingResultImpl>
    implements _$$ListingResultImplCopyWith<$Res> {
  __$$ListingResultImplCopyWithImpl(
      _$ListingResultImpl _value, $Res Function(_$ListingResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? listingId = freezed,
    Object? message = freezed,
    Object? minimumPrice = freezed,
  }) {
    return _then(_$ListingResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      minimumPrice: freezed == minimumPrice
          ? _value.minimumPrice
          : minimumPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingResultImpl implements _ListingResult {
  const _$ListingResultImpl(
      {required this.success, this.listingId, this.message, this.minimumPrice});

  factory _$ListingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingResultImplFromJson(json);

  @override
  final bool success;
  @override
  final String? listingId;
  @override
  final String? message;
  @override
  final int? minimumPrice;

  @override
  String toString() {
    return 'ListingResult(success: $success, listingId: $listingId, message: $message, minimumPrice: $minimumPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.minimumPrice, minimumPrice) ||
                other.minimumPrice == minimumPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, listingId, message, minimumPrice);

  /// Create a copy of ListingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingResultImplCopyWith<_$ListingResultImpl> get copyWith =>
      __$$ListingResultImplCopyWithImpl<_$ListingResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingResultImplToJson(
      this,
    );
  }
}

abstract class _ListingResult implements ListingResult {
  const factory _ListingResult(
      {required final bool success,
      final String? listingId,
      final String? message,
      final int? minimumPrice}) = _$ListingResultImpl;

  factory _ListingResult.fromJson(Map<String, dynamic> json) =
      _$ListingResultImpl.fromJson;

  @override
  bool get success;
  @override
  String? get listingId;
  @override
  String? get message;
  @override
  int? get minimumPrice;

  /// Create a copy of ListingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingResultImplCopyWith<_$ListingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MarketStats _$MarketStatsFromJson(Map<String, dynamic> json) {
  return _MarketStats.fromJson(json);
}

/// @nodoc
mixin _$MarketStats {
  int get totalActiveListings => throw _privateConstructorUsedError;
  int get totalVolume24h => throw _privateConstructorUsedError;
  double get averagePrice => throw _privateConstructorUsedError;
  int get taxBurned24h => throw _privateConstructorUsedError;

  /// Serializes this MarketStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MarketStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketStatsCopyWith<MarketStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketStatsCopyWith<$Res> {
  factory $MarketStatsCopyWith(
          MarketStats value, $Res Function(MarketStats) then) =
      _$MarketStatsCopyWithImpl<$Res, MarketStats>;
  @useResult
  $Res call(
      {int totalActiveListings,
      int totalVolume24h,
      double averagePrice,
      int taxBurned24h});
}

/// @nodoc
class _$MarketStatsCopyWithImpl<$Res, $Val extends MarketStats>
    implements $MarketStatsCopyWith<$Res> {
  _$MarketStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveListings = null,
    Object? totalVolume24h = null,
    Object? averagePrice = null,
    Object? taxBurned24h = null,
  }) {
    return _then(_value.copyWith(
      totalActiveListings: null == totalActiveListings
          ? _value.totalActiveListings
          : totalActiveListings // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume24h: null == totalVolume24h
          ? _value.totalVolume24h
          : totalVolume24h // ignore: cast_nullable_to_non_nullable
              as int,
      averagePrice: null == averagePrice
          ? _value.averagePrice
          : averagePrice // ignore: cast_nullable_to_non_nullable
              as double,
      taxBurned24h: null == taxBurned24h
          ? _value.taxBurned24h
          : taxBurned24h // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketStatsImplCopyWith<$Res>
    implements $MarketStatsCopyWith<$Res> {
  factory _$$MarketStatsImplCopyWith(
          _$MarketStatsImpl value, $Res Function(_$MarketStatsImpl) then) =
      __$$MarketStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalActiveListings,
      int totalVolume24h,
      double averagePrice,
      int taxBurned24h});
}

/// @nodoc
class __$$MarketStatsImplCopyWithImpl<$Res>
    extends _$MarketStatsCopyWithImpl<$Res, _$MarketStatsImpl>
    implements _$$MarketStatsImplCopyWith<$Res> {
  __$$MarketStatsImplCopyWithImpl(
      _$MarketStatsImpl _value, $Res Function(_$MarketStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveListings = null,
    Object? totalVolume24h = null,
    Object? averagePrice = null,
    Object? taxBurned24h = null,
  }) {
    return _then(_$MarketStatsImpl(
      totalActiveListings: null == totalActiveListings
          ? _value.totalActiveListings
          : totalActiveListings // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume24h: null == totalVolume24h
          ? _value.totalVolume24h
          : totalVolume24h // ignore: cast_nullable_to_non_nullable
              as int,
      averagePrice: null == averagePrice
          ? _value.averagePrice
          : averagePrice // ignore: cast_nullable_to_non_nullable
              as double,
      taxBurned24h: null == taxBurned24h
          ? _value.taxBurned24h
          : taxBurned24h // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MarketStatsImpl implements _MarketStats {
  const _$MarketStatsImpl(
      {this.totalActiveListings = 0,
      this.totalVolume24h = 0,
      this.averagePrice = 0,
      this.taxBurned24h = 0});

  factory _$MarketStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarketStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalActiveListings;
  @override
  @JsonKey()
  final int totalVolume24h;
  @override
  @JsonKey()
  final double averagePrice;
  @override
  @JsonKey()
  final int taxBurned24h;

  @override
  String toString() {
    return 'MarketStats(totalActiveListings: $totalActiveListings, totalVolume24h: $totalVolume24h, averagePrice: $averagePrice, taxBurned24h: $taxBurned24h)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketStatsImpl &&
            (identical(other.totalActiveListings, totalActiveListings) ||
                other.totalActiveListings == totalActiveListings) &&
            (identical(other.totalVolume24h, totalVolume24h) ||
                other.totalVolume24h == totalVolume24h) &&
            (identical(other.averagePrice, averagePrice) ||
                other.averagePrice == averagePrice) &&
            (identical(other.taxBurned24h, taxBurned24h) ||
                other.taxBurned24h == taxBurned24h));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalActiveListings,
      totalVolume24h, averagePrice, taxBurned24h);

  /// Create a copy of MarketStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketStatsImplCopyWith<_$MarketStatsImpl> get copyWith =>
      __$$MarketStatsImplCopyWithImpl<_$MarketStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarketStatsImplToJson(
      this,
    );
  }
}

abstract class _MarketStats implements MarketStats {
  const factory _MarketStats(
      {final int totalActiveListings,
      final int totalVolume24h,
      final double averagePrice,
      final int taxBurned24h}) = _$MarketStatsImpl;

  factory _MarketStats.fromJson(Map<String, dynamic> json) =
      _$MarketStatsImpl.fromJson;

  @override
  int get totalActiveListings;
  @override
  int get totalVolume24h;
  @override
  double get averagePrice;
  @override
  int get taxBurned24h;

  /// Create a copy of MarketStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketStatsImplCopyWith<_$MarketStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
