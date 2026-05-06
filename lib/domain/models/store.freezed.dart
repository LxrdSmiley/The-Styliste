// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Store _$StoreFromJson(Map<String, dynamic> json) {
  return _Store.fromJson(json);
}

/// @nodoc
mixin _$Store {
  String get id => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  StoreType get type => throw _privateConstructorUsedError;
  StoreCity get city => throw _privateConstructorUsedError;
  int get tier => throw _privateConstructorUsedError;
  @_SafeDouble()
  double get revenuePerHour => throw _privateConstructorUsedError;
  int get loyalty => throw _privateConstructorUsedError; // 0–100
  @_SafeDouble()
  double get marketShare => throw _privateConstructorUsedError; // 0.0–1.0
  String? get maisonId =>
      throw _privateConstructorUsedError; // null if solo-owned
  DateTime? get openedAt => throw _privateConstructorUsedError;

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreCopyWith<Store> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreCopyWith<$Res> {
  factory $StoreCopyWith(Store value, $Res Function(Store) then) =
      _$StoreCopyWithImpl<$Res, Store>;
  @useResult
  $Res call(
      {String id,
      String playerId,
      StoreType type,
      StoreCity city,
      int tier,
      @_SafeDouble() double revenuePerHour,
      int loyalty,
      @_SafeDouble() double marketShare,
      String? maisonId,
      DateTime? openedAt});
}

/// @nodoc
class _$StoreCopyWithImpl<$Res, $Val extends Store>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? type = null,
    Object? city = null,
    Object? tier = null,
    Object? revenuePerHour = null,
    Object? loyalty = null,
    Object? marketShare = null,
    Object? maisonId = freezed,
    Object? openedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoreType,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as StoreCity,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      revenuePerHour: null == revenuePerHour
          ? _value.revenuePerHour
          : revenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      loyalty: null == loyalty
          ? _value.loyalty
          : loyalty // ignore: cast_nullable_to_non_nullable
              as int,
      marketShare: null == marketShare
          ? _value.marketShare
          : marketShare // ignore: cast_nullable_to_non_nullable
              as double,
      maisonId: freezed == maisonId
          ? _value.maisonId
          : maisonId // ignore: cast_nullable_to_non_nullable
              as String?,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreImplCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$$StoreImplCopyWith(
          _$StoreImpl value, $Res Function(_$StoreImpl) then) =
      __$$StoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String playerId,
      StoreType type,
      StoreCity city,
      int tier,
      @_SafeDouble() double revenuePerHour,
      int loyalty,
      @_SafeDouble() double marketShare,
      String? maisonId,
      DateTime? openedAt});
}

/// @nodoc
class __$$StoreImplCopyWithImpl<$Res>
    extends _$StoreCopyWithImpl<$Res, _$StoreImpl>
    implements _$$StoreImplCopyWith<$Res> {
  __$$StoreImplCopyWithImpl(
      _$StoreImpl _value, $Res Function(_$StoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? type = null,
    Object? city = null,
    Object? tier = null,
    Object? revenuePerHour = null,
    Object? loyalty = null,
    Object? marketShare = null,
    Object? maisonId = freezed,
    Object? openedAt = freezed,
  }) {
    return _then(_$StoreImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoreType,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as StoreCity,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      revenuePerHour: null == revenuePerHour
          ? _value.revenuePerHour
          : revenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      loyalty: null == loyalty
          ? _value.loyalty
          : loyalty // ignore: cast_nullable_to_non_nullable
              as int,
      marketShare: null == marketShare
          ? _value.marketShare
          : marketShare // ignore: cast_nullable_to_non_nullable
              as double,
      maisonId: freezed == maisonId
          ? _value.maisonId
          : maisonId // ignore: cast_nullable_to_non_nullable
              as String?,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreImpl implements _Store {
  const _$StoreImpl(
      {required this.id,
      required this.playerId,
      required this.type,
      required this.city,
      this.tier = 1,
      @_SafeDouble() this.revenuePerHour = 0.0,
      this.loyalty = 100,
      @_SafeDouble() this.marketShare = 0.0,
      this.maisonId,
      this.openedAt});

  factory _$StoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreImplFromJson(json);

  @override
  final String id;
  @override
  final String playerId;
  @override
  final StoreType type;
  @override
  final StoreCity city;
  @override
  @JsonKey()
  final int tier;
  @override
  @JsonKey()
  @_SafeDouble()
  final double revenuePerHour;
  @override
  @JsonKey()
  final int loyalty;
// 0–100
  @override
  @JsonKey()
  @_SafeDouble()
  final double marketShare;
// 0.0–1.0
  @override
  final String? maisonId;
// null if solo-owned
  @override
  final DateTime? openedAt;

  @override
  String toString() {
    return 'Store(id: $id, playerId: $playerId, type: $type, city: $city, tier: $tier, revenuePerHour: $revenuePerHour, loyalty: $loyalty, marketShare: $marketShare, maisonId: $maisonId, openedAt: $openedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.revenuePerHour, revenuePerHour) ||
                other.revenuePerHour == revenuePerHour) &&
            (identical(other.loyalty, loyalty) || other.loyalty == loyalty) &&
            (identical(other.marketShare, marketShare) ||
                other.marketShare == marketShare) &&
            (identical(other.maisonId, maisonId) ||
                other.maisonId == maisonId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, playerId, type, city, tier,
      revenuePerHour, loyalty, marketShare, maisonId, openedAt);

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      __$$StoreImplCopyWithImpl<_$StoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreImplToJson(
      this,
    );
  }
}

abstract class _Store implements Store {
  const factory _Store(
      {required final String id,
      required final String playerId,
      required final StoreType type,
      required final StoreCity city,
      final int tier,
      @_SafeDouble() final double revenuePerHour,
      final int loyalty,
      @_SafeDouble() final double marketShare,
      final String? maisonId,
      final DateTime? openedAt}) = _$StoreImpl;

  factory _Store.fromJson(Map<String, dynamic> json) = _$StoreImpl.fromJson;

  @override
  String get id;
  @override
  String get playerId;
  @override
  StoreType get type;
  @override
  StoreCity get city;
  @override
  int get tier;
  @override
  @_SafeDouble()
  double get revenuePerHour;
  @override
  int get loyalty; // 0–100
  @override
  @_SafeDouble()
  double get marketShare; // 0.0–1.0
  @override
  String? get maisonId; // null if solo-owned
  @override
  DateTime? get openedAt;

  /// Create a copy of Store
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreImplCopyWith<_$StoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
