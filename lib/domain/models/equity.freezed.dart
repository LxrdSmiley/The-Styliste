// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BrandEquity _$BrandEquityFromJson(Map<String, dynamic> json) {
  return _BrandEquity.fromJson(json);
}

/// @nodoc
mixin _$BrandEquity {
  String get brandId => throw _privateConstructorUsedError;
  int get totalShares => throw _privateConstructorUsedError;
  double get sharePrice => throw _privateConstructorUsedError;
  double get valuation => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  double get dividendPayoutRatio => throw _privateConstructorUsedError;
  DateTime? get ipoAt => throw _privateConstructorUsedError;

  /// Serializes this BrandEquity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BrandEquity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrandEquityCopyWith<BrandEquity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrandEquityCopyWith<$Res> {
  factory $BrandEquityCopyWith(
          BrandEquity value, $Res Function(BrandEquity) then) =
      _$BrandEquityCopyWithImpl<$Res, BrandEquity>;
  @useResult
  $Res call(
      {String brandId,
      int totalShares,
      double sharePrice,
      double valuation,
      bool isPublic,
      double dividendPayoutRatio,
      DateTime? ipoAt});
}

/// @nodoc
class _$BrandEquityCopyWithImpl<$Res, $Val extends BrandEquity>
    implements $BrandEquityCopyWith<$Res> {
  _$BrandEquityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrandEquity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brandId = null,
    Object? totalShares = null,
    Object? sharePrice = null,
    Object? valuation = null,
    Object? isPublic = null,
    Object? dividendPayoutRatio = null,
    Object? ipoAt = freezed,
  }) {
    return _then(_value.copyWith(
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      totalShares: null == totalShares
          ? _value.totalShares
          : totalShares // ignore: cast_nullable_to_non_nullable
              as int,
      sharePrice: null == sharePrice
          ? _value.sharePrice
          : sharePrice // ignore: cast_nullable_to_non_nullable
              as double,
      valuation: null == valuation
          ? _value.valuation
          : valuation // ignore: cast_nullable_to_non_nullable
              as double,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      dividendPayoutRatio: null == dividendPayoutRatio
          ? _value.dividendPayoutRatio
          : dividendPayoutRatio // ignore: cast_nullable_to_non_nullable
              as double,
      ipoAt: freezed == ipoAt
          ? _value.ipoAt
          : ipoAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BrandEquityImplCopyWith<$Res>
    implements $BrandEquityCopyWith<$Res> {
  factory _$$BrandEquityImplCopyWith(
          _$BrandEquityImpl value, $Res Function(_$BrandEquityImpl) then) =
      __$$BrandEquityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String brandId,
      int totalShares,
      double sharePrice,
      double valuation,
      bool isPublic,
      double dividendPayoutRatio,
      DateTime? ipoAt});
}

/// @nodoc
class __$$BrandEquityImplCopyWithImpl<$Res>
    extends _$BrandEquityCopyWithImpl<$Res, _$BrandEquityImpl>
    implements _$$BrandEquityImplCopyWith<$Res> {
  __$$BrandEquityImplCopyWithImpl(
      _$BrandEquityImpl _value, $Res Function(_$BrandEquityImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrandEquity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brandId = null,
    Object? totalShares = null,
    Object? sharePrice = null,
    Object? valuation = null,
    Object? isPublic = null,
    Object? dividendPayoutRatio = null,
    Object? ipoAt = freezed,
  }) {
    return _then(_$BrandEquityImpl(
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      totalShares: null == totalShares
          ? _value.totalShares
          : totalShares // ignore: cast_nullable_to_non_nullable
              as int,
      sharePrice: null == sharePrice
          ? _value.sharePrice
          : sharePrice // ignore: cast_nullable_to_non_nullable
              as double,
      valuation: null == valuation
          ? _value.valuation
          : valuation // ignore: cast_nullable_to_non_nullable
              as double,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      dividendPayoutRatio: null == dividendPayoutRatio
          ? _value.dividendPayoutRatio
          : dividendPayoutRatio // ignore: cast_nullable_to_non_nullable
              as double,
      ipoAt: freezed == ipoAt
          ? _value.ipoAt
          : ipoAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BrandEquityImpl implements _BrandEquity {
  const _$BrandEquityImpl(
      {required this.brandId,
      this.totalShares = 0,
      this.sharePrice = 0.0,
      this.valuation = 0.0,
      this.isPublic = false,
      this.dividendPayoutRatio = 0.0,
      this.ipoAt});

  factory _$BrandEquityImpl.fromJson(Map<String, dynamic> json) =>
      _$$BrandEquityImplFromJson(json);

  @override
  final String brandId;
  @override
  @JsonKey()
  final int totalShares;
  @override
  @JsonKey()
  final double sharePrice;
  @override
  @JsonKey()
  final double valuation;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final double dividendPayoutRatio;
  @override
  final DateTime? ipoAt;

  @override
  String toString() {
    return 'BrandEquity(brandId: $brandId, totalShares: $totalShares, sharePrice: $sharePrice, valuation: $valuation, isPublic: $isPublic, dividendPayoutRatio: $dividendPayoutRatio, ipoAt: $ipoAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrandEquityImpl &&
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.totalShares, totalShares) ||
                other.totalShares == totalShares) &&
            (identical(other.sharePrice, sharePrice) ||
                other.sharePrice == sharePrice) &&
            (identical(other.valuation, valuation) ||
                other.valuation == valuation) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.dividendPayoutRatio, dividendPayoutRatio) ||
                other.dividendPayoutRatio == dividendPayoutRatio) &&
            (identical(other.ipoAt, ipoAt) || other.ipoAt == ipoAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, brandId, totalShares, sharePrice,
      valuation, isPublic, dividendPayoutRatio, ipoAt);

  /// Create a copy of BrandEquity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrandEquityImplCopyWith<_$BrandEquityImpl> get copyWith =>
      __$$BrandEquityImplCopyWithImpl<_$BrandEquityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BrandEquityImplToJson(
      this,
    );
  }
}

abstract class _BrandEquity implements BrandEquity {
  const factory _BrandEquity(
      {required final String brandId,
      final int totalShares,
      final double sharePrice,
      final double valuation,
      final bool isPublic,
      final double dividendPayoutRatio,
      final DateTime? ipoAt}) = _$BrandEquityImpl;

  factory _BrandEquity.fromJson(Map<String, dynamic> json) =
      _$BrandEquityImpl.fromJson;

  @override
  String get brandId;
  @override
  int get totalShares;
  @override
  double get sharePrice;
  @override
  double get valuation;
  @override
  bool get isPublic;
  @override
  double get dividendPayoutRatio;
  @override
  DateTime? get ipoAt;

  /// Create a copy of BrandEquity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrandEquityImplCopyWith<_$BrandEquityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EquityPosition _$EquityPositionFromJson(Map<String, dynamic> json) {
  return _EquityPosition.fromJson(json);
}

/// @nodoc
mixin _$EquityPosition {
  String get id => throw _privateConstructorUsedError;
  String get holderId => throw _privateConstructorUsedError;
  String get brandId => throw _privateConstructorUsedError;
  ShareType get shareType => throw _privateConstructorUsedError;
  int get sharesOwned => throw _privateConstructorUsedError;
  double get averagePurchasePrice => throw _privateConstructorUsedError;
  DateTime? get acquiredAt => throw _privateConstructorUsedError;

  /// Serializes this EquityPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EquityPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquityPositionCopyWith<EquityPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquityPositionCopyWith<$Res> {
  factory $EquityPositionCopyWith(
          EquityPosition value, $Res Function(EquityPosition) then) =
      _$EquityPositionCopyWithImpl<$Res, EquityPosition>;
  @useResult
  $Res call(
      {String id,
      String holderId,
      String brandId,
      ShareType shareType,
      int sharesOwned,
      double averagePurchasePrice,
      DateTime? acquiredAt});
}

/// @nodoc
class _$EquityPositionCopyWithImpl<$Res, $Val extends EquityPosition>
    implements $EquityPositionCopyWith<$Res> {
  _$EquityPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquityPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holderId = null,
    Object? brandId = null,
    Object? shareType = null,
    Object? sharesOwned = null,
    Object? averagePurchasePrice = null,
    Object? acquiredAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holderId: null == holderId
          ? _value.holderId
          : holderId // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      shareType: null == shareType
          ? _value.shareType
          : shareType // ignore: cast_nullable_to_non_nullable
              as ShareType,
      sharesOwned: null == sharesOwned
          ? _value.sharesOwned
          : sharesOwned // ignore: cast_nullable_to_non_nullable
              as int,
      averagePurchasePrice: null == averagePurchasePrice
          ? _value.averagePurchasePrice
          : averagePurchasePrice // ignore: cast_nullable_to_non_nullable
              as double,
      acquiredAt: freezed == acquiredAt
          ? _value.acquiredAt
          : acquiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EquityPositionImplCopyWith<$Res>
    implements $EquityPositionCopyWith<$Res> {
  factory _$$EquityPositionImplCopyWith(_$EquityPositionImpl value,
          $Res Function(_$EquityPositionImpl) then) =
      __$$EquityPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String holderId,
      String brandId,
      ShareType shareType,
      int sharesOwned,
      double averagePurchasePrice,
      DateTime? acquiredAt});
}

/// @nodoc
class __$$EquityPositionImplCopyWithImpl<$Res>
    extends _$EquityPositionCopyWithImpl<$Res, _$EquityPositionImpl>
    implements _$$EquityPositionImplCopyWith<$Res> {
  __$$EquityPositionImplCopyWithImpl(
      _$EquityPositionImpl _value, $Res Function(_$EquityPositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of EquityPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? holderId = null,
    Object? brandId = null,
    Object? shareType = null,
    Object? sharesOwned = null,
    Object? averagePurchasePrice = null,
    Object? acquiredAt = freezed,
  }) {
    return _then(_$EquityPositionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      holderId: null == holderId
          ? _value.holderId
          : holderId // ignore: cast_nullable_to_non_nullable
              as String,
      brandId: null == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String,
      shareType: null == shareType
          ? _value.shareType
          : shareType // ignore: cast_nullable_to_non_nullable
              as ShareType,
      sharesOwned: null == sharesOwned
          ? _value.sharesOwned
          : sharesOwned // ignore: cast_nullable_to_non_nullable
              as int,
      averagePurchasePrice: null == averagePurchasePrice
          ? _value.averagePurchasePrice
          : averagePurchasePrice // ignore: cast_nullable_to_non_nullable
              as double,
      acquiredAt: freezed == acquiredAt
          ? _value.acquiredAt
          : acquiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EquityPositionImpl implements _EquityPosition {
  const _$EquityPositionImpl(
      {required this.id,
      required this.holderId,
      required this.brandId,
      required this.shareType,
      this.sharesOwned = 0,
      this.averagePurchasePrice = 0.0,
      this.acquiredAt});

  factory _$EquityPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquityPositionImplFromJson(json);

  @override
  final String id;
  @override
  final String holderId;
  @override
  final String brandId;
  @override
  final ShareType shareType;
  @override
  @JsonKey()
  final int sharesOwned;
  @override
  @JsonKey()
  final double averagePurchasePrice;
  @override
  final DateTime? acquiredAt;

  @override
  String toString() {
    return 'EquityPosition(id: $id, holderId: $holderId, brandId: $brandId, shareType: $shareType, sharesOwned: $sharesOwned, averagePurchasePrice: $averagePurchasePrice, acquiredAt: $acquiredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquityPositionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.holderId, holderId) ||
                other.holderId == holderId) &&
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.shareType, shareType) ||
                other.shareType == shareType) &&
            (identical(other.sharesOwned, sharesOwned) ||
                other.sharesOwned == sharesOwned) &&
            (identical(other.averagePurchasePrice, averagePurchasePrice) ||
                other.averagePurchasePrice == averagePurchasePrice) &&
            (identical(other.acquiredAt, acquiredAt) ||
                other.acquiredAt == acquiredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, holderId, brandId, shareType,
      sharesOwned, averagePurchasePrice, acquiredAt);

  /// Create a copy of EquityPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquityPositionImplCopyWith<_$EquityPositionImpl> get copyWith =>
      __$$EquityPositionImplCopyWithImpl<_$EquityPositionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EquityPositionImplToJson(
      this,
    );
  }
}

abstract class _EquityPosition implements EquityPosition {
  const factory _EquityPosition(
      {required final String id,
      required final String holderId,
      required final String brandId,
      required final ShareType shareType,
      final int sharesOwned,
      final double averagePurchasePrice,
      final DateTime? acquiredAt}) = _$EquityPositionImpl;

  factory _EquityPosition.fromJson(Map<String, dynamic> json) =
      _$EquityPositionImpl.fromJson;

  @override
  String get id;
  @override
  String get holderId;
  @override
  String get brandId;
  @override
  ShareType get shareType;
  @override
  int get sharesOwned;
  @override
  double get averagePurchasePrice;
  @override
  DateTime? get acquiredAt;

  /// Create a copy of EquityPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquityPositionImplCopyWith<_$EquityPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
