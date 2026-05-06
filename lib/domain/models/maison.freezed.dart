// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maison.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Maison _$MaisonFromJson(Map<String, dynamic> json) {
  return _Maison.fromJson(json);
}

/// @nodoc
mixin _$Maison {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get founderId => throw _privateConstructorUsedError;
  double get treasury => throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  List<String> get dominatedCities => throw _privateConstructorUsedError;
  bool get isRecruiting => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Maison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Maison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaisonCopyWith<Maison> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaisonCopyWith<$Res> {
  factory $MaisonCopyWith(Maison value, $Res Function(Maison) then) =
      _$MaisonCopyWithImpl<$Res, Maison>;
  @useResult
  $Res call(
      {String id,
      String name,
      String founderId,
      double treasury,
      List<String> memberIds,
      List<String> dominatedCities,
      bool isRecruiting,
      DateTime? createdAt});
}

/// @nodoc
class _$MaisonCopyWithImpl<$Res, $Val extends Maison>
    implements $MaisonCopyWith<$Res> {
  _$MaisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Maison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? founderId = null,
    Object? treasury = null,
    Object? memberIds = null,
    Object? dominatedCities = null,
    Object? isRecruiting = null,
    Object? createdAt = freezed,
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
      founderId: null == founderId
          ? _value.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as String,
      treasury: null == treasury
          ? _value.treasury
          : treasury // ignore: cast_nullable_to_non_nullable
              as double,
      memberIds: null == memberIds
          ? _value.memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dominatedCities: null == dominatedCities
          ? _value.dominatedCities
          : dominatedCities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isRecruiting: null == isRecruiting
          ? _value.isRecruiting
          : isRecruiting // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MaisonImplCopyWith<$Res> implements $MaisonCopyWith<$Res> {
  factory _$$MaisonImplCopyWith(
          _$MaisonImpl value, $Res Function(_$MaisonImpl) then) =
      __$$MaisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String founderId,
      double treasury,
      List<String> memberIds,
      List<String> dominatedCities,
      bool isRecruiting,
      DateTime? createdAt});
}

/// @nodoc
class __$$MaisonImplCopyWithImpl<$Res>
    extends _$MaisonCopyWithImpl<$Res, _$MaisonImpl>
    implements _$$MaisonImplCopyWith<$Res> {
  __$$MaisonImplCopyWithImpl(
      _$MaisonImpl _value, $Res Function(_$MaisonImpl) _then)
      : super(_value, _then);

  /// Create a copy of Maison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? founderId = null,
    Object? treasury = null,
    Object? memberIds = null,
    Object? dominatedCities = null,
    Object? isRecruiting = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$MaisonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      founderId: null == founderId
          ? _value.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as String,
      treasury: null == treasury
          ? _value.treasury
          : treasury // ignore: cast_nullable_to_non_nullable
              as double,
      memberIds: null == memberIds
          ? _value._memberIds
          : memberIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      dominatedCities: null == dominatedCities
          ? _value._dominatedCities
          : dominatedCities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isRecruiting: null == isRecruiting
          ? _value.isRecruiting
          : isRecruiting // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MaisonImpl implements _Maison {
  const _$MaisonImpl(
      {required this.id,
      required this.name,
      required this.founderId,
      this.treasury = 0.0,
      final List<String> memberIds = const <String>[],
      final List<String> dominatedCities = const <String>[],
      this.isRecruiting = false,
      this.createdAt})
      : _memberIds = memberIds,
        _dominatedCities = dominatedCities;

  factory _$MaisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaisonImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String founderId;
  @override
  @JsonKey()
  final double treasury;
  final List<String> _memberIds;
  @override
  @JsonKey()
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  final List<String> _dominatedCities;
  @override
  @JsonKey()
  List<String> get dominatedCities {
    if (_dominatedCities is EqualUnmodifiableListView) return _dominatedCities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dominatedCities);
  }

  @override
  @JsonKey()
  final bool isRecruiting;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Maison(id: $id, name: $name, founderId: $founderId, treasury: $treasury, memberIds: $memberIds, dominatedCities: $dominatedCities, isRecruiting: $isRecruiting, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaisonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.founderId, founderId) ||
                other.founderId == founderId) &&
            (identical(other.treasury, treasury) ||
                other.treasury == treasury) &&
            const DeepCollectionEquality()
                .equals(other._memberIds, _memberIds) &&
            const DeepCollectionEquality()
                .equals(other._dominatedCities, _dominatedCities) &&
            (identical(other.isRecruiting, isRecruiting) ||
                other.isRecruiting == isRecruiting) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      founderId,
      treasury,
      const DeepCollectionEquality().hash(_memberIds),
      const DeepCollectionEquality().hash(_dominatedCities),
      isRecruiting,
      createdAt);

  /// Create a copy of Maison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaisonImplCopyWith<_$MaisonImpl> get copyWith =>
      __$$MaisonImplCopyWithImpl<_$MaisonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaisonImplToJson(
      this,
    );
  }
}

abstract class _Maison implements Maison {
  const factory _Maison(
      {required final String id,
      required final String name,
      required final String founderId,
      final double treasury,
      final List<String> memberIds,
      final List<String> dominatedCities,
      final bool isRecruiting,
      final DateTime? createdAt}) = _$MaisonImpl;

  factory _Maison.fromJson(Map<String, dynamic> json) = _$MaisonImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get founderId;
  @override
  double get treasury;
  @override
  List<String> get memberIds;
  @override
  List<String> get dominatedCities;
  @override
  bool get isRecruiting;
  @override
  DateTime? get createdAt;

  /// Create a copy of Maison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaisonImplCopyWith<_$MaisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MaisonMember _$MaisonMemberFromJson(Map<String, dynamic> json) {
  return _MaisonMember.fromJson(json);
}

/// @nodoc
mixin _$MaisonMember {
  String get maisonId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  MaisonRole get role => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this MaisonMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaisonMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaisonMemberCopyWith<MaisonMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaisonMemberCopyWith<$Res> {
  factory $MaisonMemberCopyWith(
          MaisonMember value, $Res Function(MaisonMember) then) =
      _$MaisonMemberCopyWithImpl<$Res, MaisonMember>;
  @useResult
  $Res call(
      {String maisonId, String playerId, MaisonRole role, DateTime? joinedAt});
}

/// @nodoc
class _$MaisonMemberCopyWithImpl<$Res, $Val extends MaisonMember>
    implements $MaisonMemberCopyWith<$Res> {
  _$MaisonMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaisonMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maisonId = null,
    Object? playerId = null,
    Object? role = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_value.copyWith(
      maisonId: null == maisonId
          ? _value.maisonId
          : maisonId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MaisonRole,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MaisonMemberImplCopyWith<$Res>
    implements $MaisonMemberCopyWith<$Res> {
  factory _$$MaisonMemberImplCopyWith(
          _$MaisonMemberImpl value, $Res Function(_$MaisonMemberImpl) then) =
      __$$MaisonMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String maisonId, String playerId, MaisonRole role, DateTime? joinedAt});
}

/// @nodoc
class __$$MaisonMemberImplCopyWithImpl<$Res>
    extends _$MaisonMemberCopyWithImpl<$Res, _$MaisonMemberImpl>
    implements _$$MaisonMemberImplCopyWith<$Res> {
  __$$MaisonMemberImplCopyWithImpl(
      _$MaisonMemberImpl _value, $Res Function(_$MaisonMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of MaisonMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maisonId = null,
    Object? playerId = null,
    Object? role = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_$MaisonMemberImpl(
      maisonId: null == maisonId
          ? _value.maisonId
          : maisonId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MaisonRole,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MaisonMemberImpl implements _MaisonMember {
  const _$MaisonMemberImpl(
      {required this.maisonId,
      required this.playerId,
      required this.role,
      this.joinedAt});

  factory _$MaisonMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaisonMemberImplFromJson(json);

  @override
  final String maisonId;
  @override
  final String playerId;
  @override
  final MaisonRole role;
  @override
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'MaisonMember(maisonId: $maisonId, playerId: $playerId, role: $role, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaisonMemberImpl &&
            (identical(other.maisonId, maisonId) ||
                other.maisonId == maisonId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, maisonId, playerId, role, joinedAt);

  /// Create a copy of MaisonMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaisonMemberImplCopyWith<_$MaisonMemberImpl> get copyWith =>
      __$$MaisonMemberImplCopyWithImpl<_$MaisonMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaisonMemberImplToJson(
      this,
    );
  }
}

abstract class _MaisonMember implements MaisonMember {
  const factory _MaisonMember(
      {required final String maisonId,
      required final String playerId,
      required final MaisonRole role,
      final DateTime? joinedAt}) = _$MaisonMemberImpl;

  factory _MaisonMember.fromJson(Map<String, dynamic> json) =
      _$MaisonMemberImpl.fromJson;

  @override
  String get maisonId;
  @override
  String get playerId;
  @override
  MaisonRole get role;
  @override
  DateTime? get joinedAt;

  /// Create a copy of MaisonMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaisonMemberImplCopyWith<_$MaisonMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
