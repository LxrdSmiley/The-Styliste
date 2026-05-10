// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'talent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Talent _$TalentFromJson(Map<String, dynamic> json) {
  return _Talent.fromJson(json);
}

/// @nodoc
mixin _$Talent {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  TalentTier get tier => throw _privateConstructorUsedError;
  String? get portraitUrl => throw _privateConstructorUsedError;
  double get baseHypeMultiplier => throw _privateConstructorUsedError;
  int get scandalRiskFactor => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  List<String> get signatureStyle => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Talent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Talent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TalentCopyWith<Talent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TalentCopyWith<$Res> {
  factory $TalentCopyWith(Talent value, $Res Function(Talent) then) =
      _$TalentCopyWithImpl<$Res, Talent>;
  @useResult
  $Res call(
      {String id,
      String name,
      TalentTier tier,
      String? portraitUrl,
      double baseHypeMultiplier,
      int scandalRiskFactor,
      String? biography,
      List<String> signatureStyle,
      bool isActive});
}

/// @nodoc
class _$TalentCopyWithImpl<$Res, $Val extends Talent>
    implements $TalentCopyWith<$Res> {
  _$TalentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Talent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? baseHypeMultiplier = null,
    Object? scandalRiskFactor = null,
    Object? biography = freezed,
    Object? signatureStyle = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      baseHypeMultiplier: null == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      scandalRiskFactor: null == scandalRiskFactor
          ? _value.scandalRiskFactor
          : scandalRiskFactor // ignore: cast_nullable_to_non_nullable
              as int,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureStyle: null == signatureStyle
          ? _value.signatureStyle
          : signatureStyle // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TalentImplCopyWith<$Res> implements $TalentCopyWith<$Res> {
  factory _$$TalentImplCopyWith(
          _$TalentImpl value, $Res Function(_$TalentImpl) then) =
      __$$TalentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      TalentTier tier,
      String? portraitUrl,
      double baseHypeMultiplier,
      int scandalRiskFactor,
      String? biography,
      List<String> signatureStyle,
      bool isActive});
}

/// @nodoc
class __$$TalentImplCopyWithImpl<$Res>
    extends _$TalentCopyWithImpl<$Res, _$TalentImpl>
    implements _$$TalentImplCopyWith<$Res> {
  __$$TalentImplCopyWithImpl(
      _$TalentImpl _value, $Res Function(_$TalentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Talent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? baseHypeMultiplier = null,
    Object? scandalRiskFactor = null,
    Object? biography = freezed,
    Object? signatureStyle = null,
    Object? isActive = null,
  }) {
    return _then(_$TalentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      baseHypeMultiplier: null == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      scandalRiskFactor: null == scandalRiskFactor
          ? _value.scandalRiskFactor
          : scandalRiskFactor // ignore: cast_nullable_to_non_nullable
              as int,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      signatureStyle: null == signatureStyle
          ? _value._signatureStyle
          : signatureStyle // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TalentImpl implements _Talent {
  const _$TalentImpl(
      {required this.id,
      required this.name,
      required this.tier,
      this.portraitUrl,
      this.baseHypeMultiplier = 1.0,
      this.scandalRiskFactor = 0,
      this.biography,
      final List<String> signatureStyle = const <String>[],
      this.isActive = true})
      : _signatureStyle = signatureStyle;

  factory _$TalentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TalentImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final TalentTier tier;
  @override
  final String? portraitUrl;
  @override
  @JsonKey()
  final double baseHypeMultiplier;
  @override
  @JsonKey()
  final int scandalRiskFactor;
  @override
  final String? biography;
  final List<String> _signatureStyle;
  @override
  @JsonKey()
  List<String> get signatureStyle {
    if (_signatureStyle is EqualUnmodifiableListView) return _signatureStyle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_signatureStyle);
  }

  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Talent(id: $id, name: $name, tier: $tier, portraitUrl: $portraitUrl, baseHypeMultiplier: $baseHypeMultiplier, scandalRiskFactor: $scandalRiskFactor, biography: $biography, signatureStyle: $signatureStyle, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TalentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.baseHypeMultiplier, baseHypeMultiplier) ||
                other.baseHypeMultiplier == baseHypeMultiplier) &&
            (identical(other.scandalRiskFactor, scandalRiskFactor) ||
                other.scandalRiskFactor == scandalRiskFactor) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            const DeepCollectionEquality()
                .equals(other._signatureStyle, _signatureStyle) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      tier,
      portraitUrl,
      baseHypeMultiplier,
      scandalRiskFactor,
      biography,
      const DeepCollectionEquality().hash(_signatureStyle),
      isActive);

  /// Create a copy of Talent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TalentImplCopyWith<_$TalentImpl> get copyWith =>
      __$$TalentImplCopyWithImpl<_$TalentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TalentImplToJson(
      this,
    );
  }
}

abstract class _Talent implements Talent {
  const factory _Talent(
      {required final String id,
      required final String name,
      required final TalentTier tier,
      final String? portraitUrl,
      final double baseHypeMultiplier,
      final int scandalRiskFactor,
      final String? biography,
      final List<String> signatureStyle,
      final bool isActive}) = _$TalentImpl;

  factory _Talent.fromJson(Map<String, dynamic> json) = _$TalentImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  TalentTier get tier;
  @override
  String? get portraitUrl;
  @override
  double get baseHypeMultiplier;
  @override
  int get scandalRiskFactor;
  @override
  String? get biography;
  @override
  List<String> get signatureStyle;
  @override
  bool get isActive;

  /// Create a copy of Talent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TalentImplCopyWith<_$TalentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RosterTalent _$RosterTalentFromJson(Map<String, dynamic> json) {
  return _RosterTalent.fromJson(json);
}

/// @nodoc
mixin _$RosterTalent {
  String get talentId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  TalentTier get tier => throw _privateConstructorUsedError;
  String? get portraitUrl => throw _privateConstructorUsedError;
  double get baseHypeMultiplier => throw _privateConstructorUsedError;
  int get scandalRiskFactor => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  DateTime? get acquiredAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int get prestigeValue => throw _privateConstructorUsedError;

  /// Serializes this RosterTalent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RosterTalent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RosterTalentCopyWith<RosterTalent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RosterTalentCopyWith<$Res> {
  factory $RosterTalentCopyWith(
          RosterTalent value, $Res Function(RosterTalent) then) =
      _$RosterTalentCopyWithImpl<$Res, RosterTalent>;
  @useResult
  $Res call(
      {String talentId,
      String name,
      TalentTier tier,
      String? portraitUrl,
      double baseHypeMultiplier,
      int scandalRiskFactor,
      String? biography,
      DateTime? acquiredAt,
      bool isFavorite,
      int prestigeValue});
}

/// @nodoc
class _$RosterTalentCopyWithImpl<$Res, $Val extends RosterTalent>
    implements $RosterTalentCopyWith<$Res> {
  _$RosterTalentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RosterTalent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? talentId = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? baseHypeMultiplier = null,
    Object? scandalRiskFactor = null,
    Object? biography = freezed,
    Object? acquiredAt = freezed,
    Object? isFavorite = null,
    Object? prestigeValue = null,
  }) {
    return _then(_value.copyWith(
      talentId: null == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      baseHypeMultiplier: null == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      scandalRiskFactor: null == scandalRiskFactor
          ? _value.scandalRiskFactor
          : scandalRiskFactor // ignore: cast_nullable_to_non_nullable
              as int,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      acquiredAt: freezed == acquiredAt
          ? _value.acquiredAt
          : acquiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      prestigeValue: null == prestigeValue
          ? _value.prestigeValue
          : prestigeValue // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RosterTalentImplCopyWith<$Res>
    implements $RosterTalentCopyWith<$Res> {
  factory _$$RosterTalentImplCopyWith(
          _$RosterTalentImpl value, $Res Function(_$RosterTalentImpl) then) =
      __$$RosterTalentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String talentId,
      String name,
      TalentTier tier,
      String? portraitUrl,
      double baseHypeMultiplier,
      int scandalRiskFactor,
      String? biography,
      DateTime? acquiredAt,
      bool isFavorite,
      int prestigeValue});
}

/// @nodoc
class __$$RosterTalentImplCopyWithImpl<$Res>
    extends _$RosterTalentCopyWithImpl<$Res, _$RosterTalentImpl>
    implements _$$RosterTalentImplCopyWith<$Res> {
  __$$RosterTalentImplCopyWithImpl(
      _$RosterTalentImpl _value, $Res Function(_$RosterTalentImpl) _then)
      : super(_value, _then);

  /// Create a copy of RosterTalent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? talentId = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? baseHypeMultiplier = null,
    Object? scandalRiskFactor = null,
    Object? biography = freezed,
    Object? acquiredAt = freezed,
    Object? isFavorite = null,
    Object? prestigeValue = null,
  }) {
    return _then(_$RosterTalentImpl(
      talentId: null == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      baseHypeMultiplier: null == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      scandalRiskFactor: null == scandalRiskFactor
          ? _value.scandalRiskFactor
          : scandalRiskFactor // ignore: cast_nullable_to_non_nullable
              as int,
      biography: freezed == biography
          ? _value.biography
          : biography // ignore: cast_nullable_to_non_nullable
              as String?,
      acquiredAt: freezed == acquiredAt
          ? _value.acquiredAt
          : acquiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      prestigeValue: null == prestigeValue
          ? _value.prestigeValue
          : prestigeValue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RosterTalentImpl implements _RosterTalent {
  const _$RosterTalentImpl(
      {required this.talentId,
      required this.name,
      required this.tier,
      this.portraitUrl,
      required this.baseHypeMultiplier,
      this.scandalRiskFactor = 0,
      this.biography,
      this.acquiredAt,
      this.isFavorite = false,
      required this.prestigeValue});

  factory _$RosterTalentImpl.fromJson(Map<String, dynamic> json) =>
      _$$RosterTalentImplFromJson(json);

  @override
  final String talentId;
  @override
  final String name;
  @override
  final TalentTier tier;
  @override
  final String? portraitUrl;
  @override
  final double baseHypeMultiplier;
  @override
  @JsonKey()
  final int scandalRiskFactor;
  @override
  final String? biography;
  @override
  final DateTime? acquiredAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final int prestigeValue;

  @override
  String toString() {
    return 'RosterTalent(talentId: $talentId, name: $name, tier: $tier, portraitUrl: $portraitUrl, baseHypeMultiplier: $baseHypeMultiplier, scandalRiskFactor: $scandalRiskFactor, biography: $biography, acquiredAt: $acquiredAt, isFavorite: $isFavorite, prestigeValue: $prestigeValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RosterTalentImpl &&
            (identical(other.talentId, talentId) ||
                other.talentId == talentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.baseHypeMultiplier, baseHypeMultiplier) ||
                other.baseHypeMultiplier == baseHypeMultiplier) &&
            (identical(other.scandalRiskFactor, scandalRiskFactor) ||
                other.scandalRiskFactor == scandalRiskFactor) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            (identical(other.acquiredAt, acquiredAt) ||
                other.acquiredAt == acquiredAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.prestigeValue, prestigeValue) ||
                other.prestigeValue == prestigeValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      talentId,
      name,
      tier,
      portraitUrl,
      baseHypeMultiplier,
      scandalRiskFactor,
      biography,
      acquiredAt,
      isFavorite,
      prestigeValue);

  /// Create a copy of RosterTalent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RosterTalentImplCopyWith<_$RosterTalentImpl> get copyWith =>
      __$$RosterTalentImplCopyWithImpl<_$RosterTalentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RosterTalentImplToJson(
      this,
    );
  }
}

abstract class _RosterTalent implements RosterTalent {
  const factory _RosterTalent(
      {required final String talentId,
      required final String name,
      required final TalentTier tier,
      final String? portraitUrl,
      required final double baseHypeMultiplier,
      final int scandalRiskFactor,
      final String? biography,
      final DateTime? acquiredAt,
      final bool isFavorite,
      required final int prestigeValue}) = _$RosterTalentImpl;

  factory _RosterTalent.fromJson(Map<String, dynamic> json) =
      _$RosterTalentImpl.fromJson;

  @override
  String get talentId;
  @override
  String get name;
  @override
  TalentTier get tier;
  @override
  String? get portraitUrl;
  @override
  double get baseHypeMultiplier;
  @override
  int get scandalRiskFactor;
  @override
  String? get biography;
  @override
  DateTime? get acquiredAt;
  @override
  bool get isFavorite;
  @override
  int get prestigeValue;

  /// Create a copy of RosterTalent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RosterTalentImplCopyWith<_$RosterTalentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PullResult _$PullResultFromJson(Map<String, dynamic> json) {
  return _PullResult.fromJson(json);
}

/// @nodoc
mixin _$PullResult {
  String get talentId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  TalentTier get tier => throw _privateConstructorUsedError;
  String? get portraitUrl => throw _privateConstructorUsedError;
  bool get isDupe => throw _privateConstructorUsedError;
  int get prestigeValue => throw _privateConstructorUsedError;
  double? get baseHypeMultiplier => throw _privateConstructorUsedError;

  /// Serializes this PullResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PullResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PullResultCopyWith<PullResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PullResultCopyWith<$Res> {
  factory $PullResultCopyWith(
          PullResult value, $Res Function(PullResult) then) =
      _$PullResultCopyWithImpl<$Res, PullResult>;
  @useResult
  $Res call(
      {String talentId,
      String name,
      TalentTier tier,
      String? portraitUrl,
      bool isDupe,
      int prestigeValue,
      double? baseHypeMultiplier});
}

/// @nodoc
class _$PullResultCopyWithImpl<$Res, $Val extends PullResult>
    implements $PullResultCopyWith<$Res> {
  _$PullResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PullResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? talentId = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? isDupe = null,
    Object? prestigeValue = null,
    Object? baseHypeMultiplier = freezed,
  }) {
    return _then(_value.copyWith(
      talentId: null == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isDupe: null == isDupe
          ? _value.isDupe
          : isDupe // ignore: cast_nullable_to_non_nullable
              as bool,
      prestigeValue: null == prestigeValue
          ? _value.prestigeValue
          : prestigeValue // ignore: cast_nullable_to_non_nullable
              as int,
      baseHypeMultiplier: freezed == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PullResultImplCopyWith<$Res>
    implements $PullResultCopyWith<$Res> {
  factory _$$PullResultImplCopyWith(
          _$PullResultImpl value, $Res Function(_$PullResultImpl) then) =
      __$$PullResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String talentId,
      String name,
      TalentTier tier,
      String? portraitUrl,
      bool isDupe,
      int prestigeValue,
      double? baseHypeMultiplier});
}

/// @nodoc
class __$$PullResultImplCopyWithImpl<$Res>
    extends _$PullResultCopyWithImpl<$Res, _$PullResultImpl>
    implements _$$PullResultImplCopyWith<$Res> {
  __$$PullResultImplCopyWithImpl(
      _$PullResultImpl _value, $Res Function(_$PullResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PullResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? talentId = null,
    Object? name = null,
    Object? tier = null,
    Object? portraitUrl = freezed,
    Object? isDupe = null,
    Object? prestigeValue = null,
    Object? baseHypeMultiplier = freezed,
  }) {
    return _then(_$PullResultImpl(
      talentId: null == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as TalentTier,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isDupe: null == isDupe
          ? _value.isDupe
          : isDupe // ignore: cast_nullable_to_non_nullable
              as bool,
      prestigeValue: null == prestigeValue
          ? _value.prestigeValue
          : prestigeValue // ignore: cast_nullable_to_non_nullable
              as int,
      baseHypeMultiplier: freezed == baseHypeMultiplier
          ? _value.baseHypeMultiplier
          : baseHypeMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PullResultImpl implements _PullResult {
  const _$PullResultImpl(
      {required this.talentId,
      required this.name,
      required this.tier,
      this.portraitUrl,
      required this.isDupe,
      this.prestigeValue = 0,
      this.baseHypeMultiplier});

  factory _$PullResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PullResultImplFromJson(json);

  @override
  final String talentId;
  @override
  final String name;
  @override
  final TalentTier tier;
  @override
  final String? portraitUrl;
  @override
  final bool isDupe;
  @override
  @JsonKey()
  final int prestigeValue;
  @override
  final double? baseHypeMultiplier;

  @override
  String toString() {
    return 'PullResult(talentId: $talentId, name: $name, tier: $tier, portraitUrl: $portraitUrl, isDupe: $isDupe, prestigeValue: $prestigeValue, baseHypeMultiplier: $baseHypeMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PullResultImpl &&
            (identical(other.talentId, talentId) ||
                other.talentId == talentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.isDupe, isDupe) || other.isDupe == isDupe) &&
            (identical(other.prestigeValue, prestigeValue) ||
                other.prestigeValue == prestigeValue) &&
            (identical(other.baseHypeMultiplier, baseHypeMultiplier) ||
                other.baseHypeMultiplier == baseHypeMultiplier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, talentId, name, tier,
      portraitUrl, isDupe, prestigeValue, baseHypeMultiplier);

  /// Create a copy of PullResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PullResultImplCopyWith<_$PullResultImpl> get copyWith =>
      __$$PullResultImplCopyWithImpl<_$PullResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PullResultImplToJson(
      this,
    );
  }
}

abstract class _PullResult implements PullResult {
  const factory _PullResult(
      {required final String talentId,
      required final String name,
      required final TalentTier tier,
      final String? portraitUrl,
      required final bool isDupe,
      final int prestigeValue,
      final double? baseHypeMultiplier}) = _$PullResultImpl;

  factory _PullResult.fromJson(Map<String, dynamic> json) =
      _$PullResultImpl.fromJson;

  @override
  String get talentId;
  @override
  String get name;
  @override
  TalentTier get tier;
  @override
  String? get portraitUrl;
  @override
  bool get isDupe;
  @override
  int get prestigeValue;
  @override
  double? get baseHypeMultiplier;

  /// Create a copy of PullResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PullResultImplCopyWith<_$PullResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CastingResult _$CastingResultFromJson(Map<String, dynamic> json) {
  return _CastingResult.fromJson(json);
}

/// @nodoc
mixin _$CastingResult {
  List<PullResult> get pulls => throw _privateConstructorUsedError;
  int get luxeSpent => throw _privateConstructorUsedError;
  int get prestigeEarned => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this CastingResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CastingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CastingResultCopyWith<CastingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CastingResultCopyWith<$Res> {
  factory $CastingResultCopyWith(
          CastingResult value, $Res Function(CastingResult) then) =
      _$CastingResultCopyWithImpl<$Res, CastingResult>;
  @useResult
  $Res call(
      {List<PullResult> pulls,
      int luxeSpent,
      int prestigeEarned,
      String? message});
}

/// @nodoc
class _$CastingResultCopyWithImpl<$Res, $Val extends CastingResult>
    implements $CastingResultCopyWith<$Res> {
  _$CastingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CastingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pulls = null,
    Object? luxeSpent = null,
    Object? prestigeEarned = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      pulls: null == pulls
          ? _value.pulls
          : pulls // ignore: cast_nullable_to_non_nullable
              as List<PullResult>,
      luxeSpent: null == luxeSpent
          ? _value.luxeSpent
          : luxeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      prestigeEarned: null == prestigeEarned
          ? _value.prestigeEarned
          : prestigeEarned // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CastingResultImplCopyWith<$Res>
    implements $CastingResultCopyWith<$Res> {
  factory _$$CastingResultImplCopyWith(
          _$CastingResultImpl value, $Res Function(_$CastingResultImpl) then) =
      __$$CastingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PullResult> pulls,
      int luxeSpent,
      int prestigeEarned,
      String? message});
}

/// @nodoc
class __$$CastingResultImplCopyWithImpl<$Res>
    extends _$CastingResultCopyWithImpl<$Res, _$CastingResultImpl>
    implements _$$CastingResultImplCopyWith<$Res> {
  __$$CastingResultImplCopyWithImpl(
      _$CastingResultImpl _value, $Res Function(_$CastingResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CastingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pulls = null,
    Object? luxeSpent = null,
    Object? prestigeEarned = null,
    Object? message = freezed,
  }) {
    return _then(_$CastingResultImpl(
      pulls: null == pulls
          ? _value._pulls
          : pulls // ignore: cast_nullable_to_non_nullable
              as List<PullResult>,
      luxeSpent: null == luxeSpent
          ? _value.luxeSpent
          : luxeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      prestigeEarned: null == prestigeEarned
          ? _value.prestigeEarned
          : prestigeEarned // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CastingResultImpl implements _CastingResult {
  const _$CastingResultImpl(
      {required final List<PullResult> pulls,
      this.luxeSpent = 0,
      this.prestigeEarned = 0,
      this.message})
      : _pulls = pulls;

  factory _$CastingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CastingResultImplFromJson(json);

  final List<PullResult> _pulls;
  @override
  List<PullResult> get pulls {
    if (_pulls is EqualUnmodifiableListView) return _pulls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pulls);
  }

  @override
  @JsonKey()
  final int luxeSpent;
  @override
  @JsonKey()
  final int prestigeEarned;
  @override
  final String? message;

  @override
  String toString() {
    return 'CastingResult(pulls: $pulls, luxeSpent: $luxeSpent, prestigeEarned: $prestigeEarned, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CastingResultImpl &&
            const DeepCollectionEquality().equals(other._pulls, _pulls) &&
            (identical(other.luxeSpent, luxeSpent) ||
                other.luxeSpent == luxeSpent) &&
            (identical(other.prestigeEarned, prestigeEarned) ||
                other.prestigeEarned == prestigeEarned) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pulls),
      luxeSpent,
      prestigeEarned,
      message);

  /// Create a copy of CastingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CastingResultImplCopyWith<_$CastingResultImpl> get copyWith =>
      __$$CastingResultImplCopyWithImpl<_$CastingResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CastingResultImplToJson(
      this,
    );
  }
}

abstract class _CastingResult implements CastingResult {
  const factory _CastingResult(
      {required final List<PullResult> pulls,
      final int luxeSpent,
      final int prestigeEarned,
      final String? message}) = _$CastingResultImpl;

  factory _CastingResult.fromJson(Map<String, dynamic> json) =
      _$CastingResultImpl.fromJson;

  @override
  List<PullResult> get pulls;
  @override
  int get luxeSpent;
  @override
  int get prestigeEarned;
  @override
  String? get message;

  /// Create a copy of CastingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CastingResultImplCopyWith<_$CastingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PityState _$PityStateFromJson(Map<String, dynamic> json) {
  return _PityState.fromJson(json);
}

/// @nodoc
mixin _$PityState {
  String get bannerId => throw _privateConstructorUsedError;
  int get pullsSinceSovereign => throw _privateConstructorUsedError;
  int get totalPulls => throw _privateConstructorUsedError;
  DateTime? get lastPullAt => throw _privateConstructorUsedError;

  /// Serializes this PityState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PityStateCopyWith<PityState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PityStateCopyWith<$Res> {
  factory $PityStateCopyWith(PityState value, $Res Function(PityState) then) =
      _$PityStateCopyWithImpl<$Res, PityState>;
  @useResult
  $Res call(
      {String bannerId,
      int pullsSinceSovereign,
      int totalPulls,
      DateTime? lastPullAt});
}

/// @nodoc
class _$PityStateCopyWithImpl<$Res, $Val extends PityState>
    implements $PityStateCopyWith<$Res> {
  _$PityStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bannerId = null,
    Object? pullsSinceSovereign = null,
    Object? totalPulls = null,
    Object? lastPullAt = freezed,
  }) {
    return _then(_value.copyWith(
      bannerId: null == bannerId
          ? _value.bannerId
          : bannerId // ignore: cast_nullable_to_non_nullable
              as String,
      pullsSinceSovereign: null == pullsSinceSovereign
          ? _value.pullsSinceSovereign
          : pullsSinceSovereign // ignore: cast_nullable_to_non_nullable
              as int,
      totalPulls: null == totalPulls
          ? _value.totalPulls
          : totalPulls // ignore: cast_nullable_to_non_nullable
              as int,
      lastPullAt: freezed == lastPullAt
          ? _value.lastPullAt
          : lastPullAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PityStateImplCopyWith<$Res>
    implements $PityStateCopyWith<$Res> {
  factory _$$PityStateImplCopyWith(
          _$PityStateImpl value, $Res Function(_$PityStateImpl) then) =
      __$$PityStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bannerId,
      int pullsSinceSovereign,
      int totalPulls,
      DateTime? lastPullAt});
}

/// @nodoc
class __$$PityStateImplCopyWithImpl<$Res>
    extends _$PityStateCopyWithImpl<$Res, _$PityStateImpl>
    implements _$$PityStateImplCopyWith<$Res> {
  __$$PityStateImplCopyWithImpl(
      _$PityStateImpl _value, $Res Function(_$PityStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PityState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bannerId = null,
    Object? pullsSinceSovereign = null,
    Object? totalPulls = null,
    Object? lastPullAt = freezed,
  }) {
    return _then(_$PityStateImpl(
      bannerId: null == bannerId
          ? _value.bannerId
          : bannerId // ignore: cast_nullable_to_non_nullable
              as String,
      pullsSinceSovereign: null == pullsSinceSovereign
          ? _value.pullsSinceSovereign
          : pullsSinceSovereign // ignore: cast_nullable_to_non_nullable
              as int,
      totalPulls: null == totalPulls
          ? _value.totalPulls
          : totalPulls // ignore: cast_nullable_to_non_nullable
              as int,
      lastPullAt: freezed == lastPullAt
          ? _value.lastPullAt
          : lastPullAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PityStateImpl extends _PityState {
  const _$PityStateImpl(
      {this.bannerId = 'standard',
      this.pullsSinceSovereign = 0,
      this.totalPulls = 0,
      this.lastPullAt})
      : super._();

  factory _$PityStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PityStateImplFromJson(json);

  @override
  @JsonKey()
  final String bannerId;
  @override
  @JsonKey()
  final int pullsSinceSovereign;
  @override
  @JsonKey()
  final int totalPulls;
  @override
  final DateTime? lastPullAt;

  @override
  String toString() {
    return 'PityState(bannerId: $bannerId, pullsSinceSovereign: $pullsSinceSovereign, totalPulls: $totalPulls, lastPullAt: $lastPullAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PityStateImpl &&
            (identical(other.bannerId, bannerId) ||
                other.bannerId == bannerId) &&
            (identical(other.pullsSinceSovereign, pullsSinceSovereign) ||
                other.pullsSinceSovereign == pullsSinceSovereign) &&
            (identical(other.totalPulls, totalPulls) ||
                other.totalPulls == totalPulls) &&
            (identical(other.lastPullAt, lastPullAt) ||
                other.lastPullAt == lastPullAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, bannerId, pullsSinceSovereign, totalPulls, lastPullAt);

  /// Create a copy of PityState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PityStateImplCopyWith<_$PityStateImpl> get copyWith =>
      __$$PityStateImplCopyWithImpl<_$PityStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PityStateImplToJson(
      this,
    );
  }
}

abstract class _PityState extends PityState {
  const factory _PityState(
      {final String bannerId,
      final int pullsSinceSovereign,
      final int totalPulls,
      final DateTime? lastPullAt}) = _$PityStateImpl;
  const _PityState._() : super._();

  factory _PityState.fromJson(Map<String, dynamic> json) =
      _$PityStateImpl.fromJson;

  @override
  String get bannerId;
  @override
  int get pullsSinceSovereign;
  @override
  int get totalPulls;
  @override
  DateTime? get lastPullAt;

  /// Create a copy of PityState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PityStateImplCopyWith<_$PityStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
