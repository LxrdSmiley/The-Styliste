// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
mixin _$Player {
  String get id => throw _privateConstructorUsedError;
  String get brandName => throw _privateConstructorUsedError;
  CareerPath get path => throw _privateConstructorUsedError;
  HqCity get hqCity => throw _privateConstructorUsedError;
  int get brandRank => throw _privateConstructorUsedError;
  int get totalXp => throw _privateConstructorUsedError;
  bool get onboardingComplete => throw _privateConstructorUsedError;
  bool get isAnonymous =>
      throw _privateConstructorUsedError; // --- Ascension Fields (GDD v6 §3.5) ---
  bool get isJointVenture => throw _privateConstructorUsedError;
  int get sovereignMultipliers => throw _privateConstructorUsedError;
  DateTime? get jointVentureUnlockedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt =>
      throw _privateConstructorUsedError; // --- Luxe Relationship (GDD §8.12) ---
// Trust Score: relationship meter, NOT wealth meter. Default 50 = warm baseline.
// Increments: +1 daily check-in, +1 gala entry, +2 casting gold, +5 kintsugi
  int get luxeTrustScore => throw _privateConstructorUsedError;

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call(
      {String id,
      String brandName,
      CareerPath path,
      HqCity hqCity,
      int brandRank,
      int totalXp,
      bool onboardingComplete,
      bool isAnonymous,
      bool isJointVenture,
      int sovereignMultipliers,
      DateTime? jointVentureUnlockedAt,
      DateTime? createdAt,
      DateTime? lastActiveAt,
      int luxeTrustScore});
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? path = null,
    Object? hqCity = null,
    Object? brandRank = null,
    Object? totalXp = null,
    Object? onboardingComplete = null,
    Object? isAnonymous = null,
    Object? isJointVenture = null,
    Object? sovereignMultipliers = null,
    Object? jointVentureUnlockedAt = freezed,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
    Object? luxeTrustScore = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as CareerPath,
      hqCity: null == hqCity
          ? _value.hqCity
          : hqCity // ignore: cast_nullable_to_non_nullable
              as HqCity,
      brandRank: null == brandRank
          ? _value.brandRank
          : brandRank // ignore: cast_nullable_to_non_nullable
              as int,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isJointVenture: null == isJointVenture
          ? _value.isJointVenture
          : isJointVenture // ignore: cast_nullable_to_non_nullable
              as bool,
      sovereignMultipliers: null == sovereignMultipliers
          ? _value.sovereignMultipliers
          : sovereignMultipliers // ignore: cast_nullable_to_non_nullable
              as int,
      jointVentureUnlockedAt: freezed == jointVentureUnlockedAt
          ? _value.jointVentureUnlockedAt
          : jointVentureUnlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      luxeTrustScore: null == luxeTrustScore
          ? _value.luxeTrustScore
          : luxeTrustScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
          _$PlayerImpl value, $Res Function(_$PlayerImpl) then) =
      __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String brandName,
      CareerPath path,
      HqCity hqCity,
      int brandRank,
      int totalXp,
      bool onboardingComplete,
      bool isAnonymous,
      bool isJointVenture,
      int sovereignMultipliers,
      DateTime? jointVentureUnlockedAt,
      DateTime? createdAt,
      DateTime? lastActiveAt,
      int luxeTrustScore});
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
      _$PlayerImpl _value, $Res Function(_$PlayerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? path = null,
    Object? hqCity = null,
    Object? brandRank = null,
    Object? totalXp = null,
    Object? onboardingComplete = null,
    Object? isAnonymous = null,
    Object? isJointVenture = null,
    Object? sovereignMultipliers = null,
    Object? jointVentureUnlockedAt = freezed,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
    Object? luxeTrustScore = null,
  }) {
    return _then(_$PlayerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _value.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as CareerPath,
      hqCity: null == hqCity
          ? _value.hqCity
          : hqCity // ignore: cast_nullable_to_non_nullable
              as HqCity,
      brandRank: null == brandRank
          ? _value.brandRank
          : brandRank // ignore: cast_nullable_to_non_nullable
              as int,
      totalXp: null == totalXp
          ? _value.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isJointVenture: null == isJointVenture
          ? _value.isJointVenture
          : isJointVenture // ignore: cast_nullable_to_non_nullable
              as bool,
      sovereignMultipliers: null == sovereignMultipliers
          ? _value.sovereignMultipliers
          : sovereignMultipliers // ignore: cast_nullable_to_non_nullable
              as int,
      jointVentureUnlockedAt: freezed == jointVentureUnlockedAt
          ? _value.jointVentureUnlockedAt
          : jointVentureUnlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      luxeTrustScore: null == luxeTrustScore
          ? _value.luxeTrustScore
          : luxeTrustScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerImpl extends _Player {
  const _$PlayerImpl(
      {required this.id,
      required this.brandName,
      required this.path,
      required this.hqCity,
      this.brandRank = 1,
      this.totalXp = 0,
      this.onboardingComplete = false,
      this.isAnonymous = false,
      this.isJointVenture = false,
      this.sovereignMultipliers = 0,
      this.jointVentureUnlockedAt,
      this.createdAt,
      this.lastActiveAt,
      this.luxeTrustScore = 50})
      : super._();

  factory _$PlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerImplFromJson(json);

  @override
  final String id;
  @override
  final String brandName;
  @override
  final CareerPath path;
  @override
  final HqCity hqCity;
  @override
  @JsonKey()
  final int brandRank;
  @override
  @JsonKey()
  final int totalXp;
  @override
  @JsonKey()
  final bool onboardingComplete;
  @override
  @JsonKey()
  final bool isAnonymous;
// --- Ascension Fields (GDD v6 §3.5) ---
  @override
  @JsonKey()
  final bool isJointVenture;
  @override
  @JsonKey()
  final int sovereignMultipliers;
  @override
  final DateTime? jointVentureUnlockedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastActiveAt;
// --- Luxe Relationship (GDD §8.12) ---
// Trust Score: relationship meter, NOT wealth meter. Default 50 = warm baseline.
// Increments: +1 daily check-in, +1 gala entry, +2 casting gold, +5 kintsugi
  @override
  @JsonKey()
  final int luxeTrustScore;

  @override
  String toString() {
    return 'Player(id: $id, brandName: $brandName, path: $path, hqCity: $hqCity, brandRank: $brandRank, totalXp: $totalXp, onboardingComplete: $onboardingComplete, isAnonymous: $isAnonymous, isJointVenture: $isJointVenture, sovereignMultipliers: $sovereignMultipliers, jointVentureUnlockedAt: $jointVentureUnlockedAt, createdAt: $createdAt, lastActiveAt: $lastActiveAt, luxeTrustScore: $luxeTrustScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.hqCity, hqCity) || other.hqCity == hqCity) &&
            (identical(other.brandRank, brandRank) ||
                other.brandRank == brandRank) &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.isJointVenture, isJointVenture) ||
                other.isJointVenture == isJointVenture) &&
            (identical(other.sovereignMultipliers, sovereignMultipliers) ||
                other.sovereignMultipliers == sovereignMultipliers) &&
            (identical(other.jointVentureUnlockedAt, jointVentureUnlockedAt) ||
                other.jointVentureUnlockedAt == jointVentureUnlockedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.luxeTrustScore, luxeTrustScore) ||
                other.luxeTrustScore == luxeTrustScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      brandName,
      path,
      hqCity,
      brandRank,
      totalXp,
      onboardingComplete,
      isAnonymous,
      isJointVenture,
      sovereignMultipliers,
      jointVentureUnlockedAt,
      createdAt,
      lastActiveAt,
      luxeTrustScore);

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerImplToJson(
      this,
    );
  }
}

abstract class _Player extends Player {
  const factory _Player(
      {required final String id,
      required final String brandName,
      required final CareerPath path,
      required final HqCity hqCity,
      final int brandRank,
      final int totalXp,
      final bool onboardingComplete,
      final bool isAnonymous,
      final bool isJointVenture,
      final int sovereignMultipliers,
      final DateTime? jointVentureUnlockedAt,
      final DateTime? createdAt,
      final DateTime? lastActiveAt,
      final int luxeTrustScore}) = _$PlayerImpl;
  const _Player._() : super._();

  factory _Player.fromJson(Map<String, dynamic> json) = _$PlayerImpl.fromJson;

  @override
  String get id;
  @override
  String get brandName;
  @override
  CareerPath get path;
  @override
  HqCity get hqCity;
  @override
  int get brandRank;
  @override
  int get totalXp;
  @override
  bool get onboardingComplete;
  @override
  bool get isAnonymous; // --- Ascension Fields (GDD v6 §3.5) ---
  @override
  bool get isJointVenture;
  @override
  int get sovereignMultipliers;
  @override
  DateTime? get jointVentureUnlockedAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastActiveAt; // --- Luxe Relationship (GDD §8.12) ---
// Trust Score: relationship meter, NOT wealth meter. Default 50 = warm baseline.
// Increments: +1 daily check-in, +1 gala entry, +2 casting gold, +5 kintsugi
  @override
  int get luxeTrustScore;

  /// Create a copy of Player
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
