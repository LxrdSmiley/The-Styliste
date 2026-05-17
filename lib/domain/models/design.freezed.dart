// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'design.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Design _$DesignFromJson(Map<String, dynamic> json) {
  return _Design.fromJson(json);
}

/// @nodoc
mixin _$Design {
  String get id => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DesignSessionType get sessionType => throw _privateConstructorUsedError;
  DesignStatus get status => throw _privateConstructorUsedError;
  double get hypeScore => throw _privateConstructorUsedError;
  bool get isAlpha => throw _privateConstructorUsedError;
  bool get isDigitalTwin => throw _privateConstructorUsedError; // GDD §8.9.14
  bool get dppRegistered => throw _privateConstructorUsedError;
  Map<String, dynamic> get fabricData => throw _privateConstructorUsedError;
  double get sellPotential => throw _privateConstructorUsedError;
  double get culturalImpact => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get droppedAt => throw _privateConstructorUsedError;

  /// Serializes this Design to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Design
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DesignCopyWith<Design> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DesignCopyWith<$Res> {
  factory $DesignCopyWith(Design value, $Res Function(Design) then) =
      _$DesignCopyWithImpl<$Res, Design>;
  @useResult
  $Res call(
      {String id,
      String playerId,
      String name,
      DesignSessionType sessionType,
      DesignStatus status,
      double hypeScore,
      bool isAlpha,
      bool isDigitalTwin,
      bool dppRegistered,
      Map<String, dynamic> fabricData,
      double sellPotential,
      double culturalImpact,
      DateTime? createdAt,
      DateTime? droppedAt});
}

/// @nodoc
class _$DesignCopyWithImpl<$Res, $Val extends Design>
    implements $DesignCopyWith<$Res> {
  _$DesignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Design
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? name = null,
    Object? sessionType = null,
    Object? status = null,
    Object? hypeScore = null,
    Object? isAlpha = null,
    Object? isDigitalTwin = null,
    Object? dppRegistered = null,
    Object? fabricData = null,
    Object? sellPotential = null,
    Object? culturalImpact = null,
    Object? createdAt = freezed,
    Object? droppedAt = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as DesignSessionType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DesignStatus,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      isAlpha: null == isAlpha
          ? _value.isAlpha
          : isAlpha // ignore: cast_nullable_to_non_nullable
              as bool,
      isDigitalTwin: null == isDigitalTwin
          ? _value.isDigitalTwin
          : isDigitalTwin // ignore: cast_nullable_to_non_nullable
              as bool,
      dppRegistered: null == dppRegistered
          ? _value.dppRegistered
          : dppRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
      fabricData: null == fabricData
          ? _value.fabricData
          : fabricData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      sellPotential: null == sellPotential
          ? _value.sellPotential
          : sellPotential // ignore: cast_nullable_to_non_nullable
              as double,
      culturalImpact: null == culturalImpact
          ? _value.culturalImpact
          : culturalImpact // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      droppedAt: freezed == droppedAt
          ? _value.droppedAt
          : droppedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DesignImplCopyWith<$Res> implements $DesignCopyWith<$Res> {
  factory _$$DesignImplCopyWith(
          _$DesignImpl value, $Res Function(_$DesignImpl) then) =
      __$$DesignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String playerId,
      String name,
      DesignSessionType sessionType,
      DesignStatus status,
      double hypeScore,
      bool isAlpha,
      bool isDigitalTwin,
      bool dppRegistered,
      Map<String, dynamic> fabricData,
      double sellPotential,
      double culturalImpact,
      DateTime? createdAt,
      DateTime? droppedAt});
}

/// @nodoc
class __$$DesignImplCopyWithImpl<$Res>
    extends _$DesignCopyWithImpl<$Res, _$DesignImpl>
    implements _$$DesignImplCopyWith<$Res> {
  __$$DesignImplCopyWithImpl(
      _$DesignImpl _value, $Res Function(_$DesignImpl) _then)
      : super(_value, _then);

  /// Create a copy of Design
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? name = null,
    Object? sessionType = null,
    Object? status = null,
    Object? hypeScore = null,
    Object? isAlpha = null,
    Object? isDigitalTwin = null,
    Object? dppRegistered = null,
    Object? fabricData = null,
    Object? sellPotential = null,
    Object? culturalImpact = null,
    Object? createdAt = freezed,
    Object? droppedAt = freezed,
  }) {
    return _then(_$DesignImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as DesignSessionType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DesignStatus,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      isAlpha: null == isAlpha
          ? _value.isAlpha
          : isAlpha // ignore: cast_nullable_to_non_nullable
              as bool,
      isDigitalTwin: null == isDigitalTwin
          ? _value.isDigitalTwin
          : isDigitalTwin // ignore: cast_nullable_to_non_nullable
              as bool,
      dppRegistered: null == dppRegistered
          ? _value.dppRegistered
          : dppRegistered // ignore: cast_nullable_to_non_nullable
              as bool,
      fabricData: null == fabricData
          ? _value._fabricData
          : fabricData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      sellPotential: null == sellPotential
          ? _value.sellPotential
          : sellPotential // ignore: cast_nullable_to_non_nullable
              as double,
      culturalImpact: null == culturalImpact
          ? _value.culturalImpact
          : culturalImpact // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      droppedAt: freezed == droppedAt
          ? _value.droppedAt
          : droppedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$DesignImpl implements _Design {
  const _$DesignImpl(
      {required this.id,
      required this.playerId,
      required this.name,
      required this.sessionType,
      this.status = DesignStatus.draft,
      this.hypeScore = 0.0,
      this.isAlpha = false,
      this.isDigitalTwin = false,
      this.dppRegistered = false,
      final Map<String, dynamic> fabricData = const <String, dynamic>{},
      this.sellPotential = 0.0,
      this.culturalImpact = 0.0,
      this.createdAt,
      this.droppedAt})
      : _fabricData = fabricData;

  factory _$DesignImpl.fromJson(Map<String, dynamic> json) =>
      _$$DesignImplFromJson(json);

  @override
  final String id;
  @override
  final String playerId;
  @override
  final String name;
  @override
  final DesignSessionType sessionType;
  @override
  @JsonKey()
  final DesignStatus status;
  @override
  @JsonKey()
  final double hypeScore;
  @override
  @JsonKey()
  final bool isAlpha;
  @override
  @JsonKey()
  final bool isDigitalTwin;
// GDD §8.9.14
  @override
  @JsonKey()
  final bool dppRegistered;
  final Map<String, dynamic> _fabricData;
  @override
  @JsonKey()
  Map<String, dynamic> get fabricData {
    if (_fabricData is EqualUnmodifiableMapView) return _fabricData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fabricData);
  }

  @override
  @JsonKey()
  final double sellPotential;
  @override
  @JsonKey()
  final double culturalImpact;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? droppedAt;

  @override
  String toString() {
    return 'Design(id: $id, playerId: $playerId, name: $name, sessionType: $sessionType, status: $status, hypeScore: $hypeScore, isAlpha: $isAlpha, isDigitalTwin: $isDigitalTwin, dppRegistered: $dppRegistered, fabricData: $fabricData, sellPotential: $sellPotential, culturalImpact: $culturalImpact, createdAt: $createdAt, droppedAt: $droppedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DesignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hypeScore, hypeScore) ||
                other.hypeScore == hypeScore) &&
            (identical(other.isAlpha, isAlpha) || other.isAlpha == isAlpha) &&
            (identical(other.isDigitalTwin, isDigitalTwin) ||
                other.isDigitalTwin == isDigitalTwin) &&
            (identical(other.dppRegistered, dppRegistered) ||
                other.dppRegistered == dppRegistered) &&
            const DeepCollectionEquality()
                .equals(other._fabricData, _fabricData) &&
            (identical(other.sellPotential, sellPotential) ||
                other.sellPotential == sellPotential) &&
            (identical(other.culturalImpact, culturalImpact) ||
                other.culturalImpact == culturalImpact) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.droppedAt, droppedAt) ||
                other.droppedAt == droppedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      playerId,
      name,
      sessionType,
      status,
      hypeScore,
      isAlpha,
      isDigitalTwin,
      dppRegistered,
      const DeepCollectionEquality().hash(_fabricData),
      sellPotential,
      culturalImpact,
      createdAt,
      droppedAt);

  /// Create a copy of Design
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DesignImplCopyWith<_$DesignImpl> get copyWith =>
      __$$DesignImplCopyWithImpl<_$DesignImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DesignImplToJson(
      this,
    );
  }
}

abstract class _Design implements Design {
  const factory _Design(
      {required final String id,
      required final String playerId,
      required final String name,
      required final DesignSessionType sessionType,
      final DesignStatus status,
      final double hypeScore,
      final bool isAlpha,
      final bool isDigitalTwin,
      final bool dppRegistered,
      final Map<String, dynamic> fabricData,
      final double sellPotential,
      final double culturalImpact,
      final DateTime? createdAt,
      final DateTime? droppedAt}) = _$DesignImpl;

  factory _Design.fromJson(Map<String, dynamic> json) = _$DesignImpl.fromJson;

  @override
  String get id;
  @override
  String get playerId;
  @override
  String get name;
  @override
  DesignSessionType get sessionType;
  @override
  DesignStatus get status;
  @override
  double get hypeScore;
  @override
  bool get isAlpha;
  @override
  bool get isDigitalTwin; // GDD §8.9.14
  @override
  bool get dppRegistered;
  @override
  Map<String, dynamic> get fabricData;
  @override
  double get sellPotential;
  @override
  double get culturalImpact;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get droppedAt;

  /// Create a copy of Design
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DesignImplCopyWith<_$DesignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
