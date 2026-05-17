// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInState _$CheckInStateFromJson(Map<String, dynamic> json) {
  return _CheckInState.fromJson(json);
}

/// @nodoc
mixin _$CheckInState {
  int get currentStreak => throw _privateConstructorUsedError;
  DateTime? get lastCheckIn => throw _privateConstructorUsedError;
  int get totalCheckIns => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  List<String> get rewardsClaimed => throw _privateConstructorUsedError;
  int get nextRewardAt => throw _privateConstructorUsedError;

  /// Serializes this CheckInState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInStateCopyWith<CheckInState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInStateCopyWith<$Res> {
  factory $CheckInStateCopyWith(
          CheckInState value, $Res Function(CheckInState) then) =
      _$CheckInStateCopyWithImpl<$Res, CheckInState>;
  @useResult
  $Res call(
      {int currentStreak,
      DateTime? lastCheckIn,
      int totalCheckIns,
      int longestStreak,
      List<String> rewardsClaimed,
      int nextRewardAt});
}

/// @nodoc
class _$CheckInStateCopyWithImpl<$Res, $Val extends CheckInState>
    implements $CheckInStateCopyWith<$Res> {
  _$CheckInStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? lastCheckIn = freezed,
    Object? totalCheckIns = null,
    Object? longestStreak = null,
    Object? rewardsClaimed = null,
    Object? nextRewardAt = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCheckIns: null == totalCheckIns
          ? _value.totalCheckIns
          : totalCheckIns // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      rewardsClaimed: null == rewardsClaimed
          ? _value.rewardsClaimed
          : rewardsClaimed // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nextRewardAt: null == nextRewardAt
          ? _value.nextRewardAt
          : nextRewardAt // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInStateImplCopyWith<$Res>
    implements $CheckInStateCopyWith<$Res> {
  factory _$$CheckInStateImplCopyWith(
          _$CheckInStateImpl value, $Res Function(_$CheckInStateImpl) then) =
      __$$CheckInStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      DateTime? lastCheckIn,
      int totalCheckIns,
      int longestStreak,
      List<String> rewardsClaimed,
      int nextRewardAt});
}

/// @nodoc
class __$$CheckInStateImplCopyWithImpl<$Res>
    extends _$CheckInStateCopyWithImpl<$Res, _$CheckInStateImpl>
    implements _$$CheckInStateImplCopyWith<$Res> {
  __$$CheckInStateImplCopyWithImpl(
      _$CheckInStateImpl _value, $Res Function(_$CheckInStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? lastCheckIn = freezed,
    Object? totalCheckIns = null,
    Object? longestStreak = null,
    Object? rewardsClaimed = null,
    Object? nextRewardAt = null,
  }) {
    return _then(_$CheckInStateImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCheckIns: null == totalCheckIns
          ? _value.totalCheckIns
          : totalCheckIns // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      rewardsClaimed: null == rewardsClaimed
          ? _value._rewardsClaimed
          : rewardsClaimed // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nextRewardAt: null == nextRewardAt
          ? _value.nextRewardAt
          : nextRewardAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$CheckInStateImpl extends _CheckInState {
  const _$CheckInStateImpl(
      {this.currentStreak = 0,
      this.lastCheckIn,
      this.totalCheckIns = 0,
      this.longestStreak = 0,
      final List<String> rewardsClaimed = const <String>[],
      this.nextRewardAt = 1})
      : _rewardsClaimed = rewardsClaimed,
        super._();

  factory _$CheckInStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInStateImplFromJson(json);

  @override
  @JsonKey()
  final int currentStreak;
  @override
  final DateTime? lastCheckIn;
  @override
  @JsonKey()
  final int totalCheckIns;
  @override
  @JsonKey()
  final int longestStreak;
  final List<String> _rewardsClaimed;
  @override
  @JsonKey()
  List<String> get rewardsClaimed {
    if (_rewardsClaimed is EqualUnmodifiableListView) return _rewardsClaimed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewardsClaimed);
  }

  @override
  @JsonKey()
  final int nextRewardAt;

  @override
  String toString() {
    return 'CheckInState(currentStreak: $currentStreak, lastCheckIn: $lastCheckIn, totalCheckIns: $totalCheckIns, longestStreak: $longestStreak, rewardsClaimed: $rewardsClaimed, nextRewardAt: $nextRewardAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInStateImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.lastCheckIn, lastCheckIn) ||
                other.lastCheckIn == lastCheckIn) &&
            (identical(other.totalCheckIns, totalCheckIns) ||
                other.totalCheckIns == totalCheckIns) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            const DeepCollectionEquality()
                .equals(other._rewardsClaimed, _rewardsClaimed) &&
            (identical(other.nextRewardAt, nextRewardAt) ||
                other.nextRewardAt == nextRewardAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      lastCheckIn,
      totalCheckIns,
      longestStreak,
      const DeepCollectionEquality().hash(_rewardsClaimed),
      nextRewardAt);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      __$$CheckInStateImplCopyWithImpl<_$CheckInStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInStateImplToJson(
      this,
    );
  }
}

abstract class _CheckInState extends CheckInState {
  const factory _CheckInState(
      {final int currentStreak,
      final DateTime? lastCheckIn,
      final int totalCheckIns,
      final int longestStreak,
      final List<String> rewardsClaimed,
      final int nextRewardAt}) = _$CheckInStateImpl;
  const _CheckInState._() : super._();

  factory _CheckInState.fromJson(Map<String, dynamic> json) =
      _$CheckInStateImpl.fromJson;

  @override
  int get currentStreak;
  @override
  DateTime? get lastCheckIn;
  @override
  int get totalCheckIns;
  @override
  int get longestStreak;
  @override
  List<String> get rewardsClaimed;
  @override
  int get nextRewardAt;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckInReward _$CheckInRewardFromJson(Map<String, dynamic> json) {
  return _CheckInReward.fromJson(json);
}

/// @nodoc
mixin _$CheckInReward {
  int get day => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this CheckInReward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInRewardCopyWith<CheckInReward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInRewardCopyWith<$Res> {
  factory $CheckInRewardCopyWith(
          CheckInReward value, $Res Function(CheckInReward) then) =
      _$CheckInRewardCopyWithImpl<$Res, CheckInReward>;
  @useResult
  $Res call({int day, String type, String title, String description});
}

/// @nodoc
class _$CheckInRewardCopyWithImpl<$Res, $Val extends CheckInReward>
    implements $CheckInRewardCopyWith<$Res> {
  _$CheckInRewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInRewardImplCopyWith<$Res>
    implements $CheckInRewardCopyWith<$Res> {
  factory _$$CheckInRewardImplCopyWith(
          _$CheckInRewardImpl value, $Res Function(_$CheckInRewardImpl) then) =
      __$$CheckInRewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int day, String type, String title, String description});
}

/// @nodoc
class __$$CheckInRewardImplCopyWithImpl<$Res>
    extends _$CheckInRewardCopyWithImpl<$Res, _$CheckInRewardImpl>
    implements _$$CheckInRewardImplCopyWith<$Res> {
  __$$CheckInRewardImplCopyWithImpl(
      _$CheckInRewardImpl _value, $Res Function(_$CheckInRewardImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? type = null,
    Object? title = null,
    Object? description = null,
  }) {
    return _then(_$CheckInRewardImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$CheckInRewardImpl implements _CheckInReward {
  const _$CheckInRewardImpl(
      {required this.day,
      required this.type,
      required this.title,
      required this.description});

  factory _$CheckInRewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInRewardImplFromJson(json);

  @override
  final int day;
  @override
  final String type;
  @override
  final String title;
  @override
  final String description;

  @override
  String toString() {
    return 'CheckInReward(day: $day, type: $type, title: $title, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInRewardImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, day, type, title, description);

  /// Create a copy of CheckInReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInRewardImplCopyWith<_$CheckInRewardImpl> get copyWith =>
      __$$CheckInRewardImplCopyWithImpl<_$CheckInRewardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInRewardImplToJson(
      this,
    );
  }
}

abstract class _CheckInReward implements CheckInReward {
  const factory _CheckInReward(
      {required final int day,
      required final String type,
      required final String title,
      required final String description}) = _$CheckInRewardImpl;

  factory _CheckInReward.fromJson(Map<String, dynamic> json) =
      _$CheckInRewardImpl.fromJson;

  @override
  int get day;
  @override
  String get type;
  @override
  String get title;
  @override
  String get description;

  /// Create a copy of CheckInReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInRewardImplCopyWith<_$CheckInRewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
