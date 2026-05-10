// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gala_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GalaEvent _$GalaEventFromJson(Map<String, dynamic> json) {
  return _GalaEvent.fromJson(json);
}

/// @nodoc
mixin _$GalaEvent {
  String get id => throw _privateConstructorUsedError;
  String get themeTitle => throw _privateConstructorUsedError;
  String? get themeDescription => throw _privateConstructorUsedError;
  List<String> get styleTags => throw _privateConstructorUsedError;
  DateTime get startsAt => throw _privateConstructorUsedError;
  DateTime get endsAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get prizePoolLuxe => throw _privateConstructorUsedError;
  int get totalSubmissions => throw _privateConstructorUsedError;

  /// Serializes this GalaEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalaEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalaEventCopyWith<GalaEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalaEventCopyWith<$Res> {
  factory $GalaEventCopyWith(GalaEvent value, $Res Function(GalaEvent) then) =
      _$GalaEventCopyWithImpl<$Res, GalaEvent>;
  @useResult
  $Res call(
      {String id,
      String themeTitle,
      String? themeDescription,
      List<String> styleTags,
      DateTime startsAt,
      DateTime endsAt,
      String status,
      int prizePoolLuxe,
      int totalSubmissions});
}

/// @nodoc
class _$GalaEventCopyWithImpl<$Res, $Val extends GalaEvent>
    implements $GalaEventCopyWith<$Res> {
  _$GalaEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalaEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? themeTitle = null,
    Object? themeDescription = freezed,
    Object? styleTags = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? status = null,
    Object? prizePoolLuxe = null,
    Object? totalSubmissions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      themeTitle: null == themeTitle
          ? _value.themeTitle
          : themeTitle // ignore: cast_nullable_to_non_nullable
              as String,
      themeDescription: freezed == themeDescription
          ? _value.themeDescription
          : themeDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      styleTags: null == styleTags
          ? _value.styleTags
          : styleTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      prizePoolLuxe: null == prizePoolLuxe
          ? _value.prizePoolLuxe
          : prizePoolLuxe // ignore: cast_nullable_to_non_nullable
              as int,
      totalSubmissions: null == totalSubmissions
          ? _value.totalSubmissions
          : totalSubmissions // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GalaEventImplCopyWith<$Res>
    implements $GalaEventCopyWith<$Res> {
  factory _$$GalaEventImplCopyWith(
          _$GalaEventImpl value, $Res Function(_$GalaEventImpl) then) =
      __$$GalaEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String themeTitle,
      String? themeDescription,
      List<String> styleTags,
      DateTime startsAt,
      DateTime endsAt,
      String status,
      int prizePoolLuxe,
      int totalSubmissions});
}

/// @nodoc
class __$$GalaEventImplCopyWithImpl<$Res>
    extends _$GalaEventCopyWithImpl<$Res, _$GalaEventImpl>
    implements _$$GalaEventImplCopyWith<$Res> {
  __$$GalaEventImplCopyWithImpl(
      _$GalaEventImpl _value, $Res Function(_$GalaEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of GalaEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? themeTitle = null,
    Object? themeDescription = freezed,
    Object? styleTags = null,
    Object? startsAt = null,
    Object? endsAt = null,
    Object? status = null,
    Object? prizePoolLuxe = null,
    Object? totalSubmissions = null,
  }) {
    return _then(_$GalaEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      themeTitle: null == themeTitle
          ? _value.themeTitle
          : themeTitle // ignore: cast_nullable_to_non_nullable
              as String,
      themeDescription: freezed == themeDescription
          ? _value.themeDescription
          : themeDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      styleTags: null == styleTags
          ? _value._styleTags
          : styleTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endsAt: null == endsAt
          ? _value.endsAt
          : endsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      prizePoolLuxe: null == prizePoolLuxe
          ? _value.prizePoolLuxe
          : prizePoolLuxe // ignore: cast_nullable_to_non_nullable
              as int,
      totalSubmissions: null == totalSubmissions
          ? _value.totalSubmissions
          : totalSubmissions // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GalaEventImpl extends _GalaEvent {
  const _$GalaEventImpl(
      {required this.id,
      required this.themeTitle,
      this.themeDescription,
      final List<String> styleTags = const <String>[],
      required this.startsAt,
      required this.endsAt,
      this.status = 'upcoming',
      this.prizePoolLuxe = 10000,
      this.totalSubmissions = 0})
      : _styleTags = styleTags,
        super._();

  factory _$GalaEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalaEventImplFromJson(json);

  @override
  final String id;
  @override
  final String themeTitle;
  @override
  final String? themeDescription;
  final List<String> _styleTags;
  @override
  @JsonKey()
  List<String> get styleTags {
    if (_styleTags is EqualUnmodifiableListView) return _styleTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_styleTags);
  }

  @override
  final DateTime startsAt;
  @override
  final DateTime endsAt;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final int prizePoolLuxe;
  @override
  @JsonKey()
  final int totalSubmissions;

  @override
  String toString() {
    return 'GalaEvent(id: $id, themeTitle: $themeTitle, themeDescription: $themeDescription, styleTags: $styleTags, startsAt: $startsAt, endsAt: $endsAt, status: $status, prizePoolLuxe: $prizePoolLuxe, totalSubmissions: $totalSubmissions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalaEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.themeTitle, themeTitle) ||
                other.themeTitle == themeTitle) &&
            (identical(other.themeDescription, themeDescription) ||
                other.themeDescription == themeDescription) &&
            const DeepCollectionEquality()
                .equals(other._styleTags, _styleTags) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.endsAt, endsAt) || other.endsAt == endsAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.prizePoolLuxe, prizePoolLuxe) ||
                other.prizePoolLuxe == prizePoolLuxe) &&
            (identical(other.totalSubmissions, totalSubmissions) ||
                other.totalSubmissions == totalSubmissions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      themeTitle,
      themeDescription,
      const DeepCollectionEquality().hash(_styleTags),
      startsAt,
      endsAt,
      status,
      prizePoolLuxe,
      totalSubmissions);

  /// Create a copy of GalaEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalaEventImplCopyWith<_$GalaEventImpl> get copyWith =>
      __$$GalaEventImplCopyWithImpl<_$GalaEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalaEventImplToJson(
      this,
    );
  }
}

abstract class _GalaEvent extends GalaEvent {
  const factory _GalaEvent(
      {required final String id,
      required final String themeTitle,
      final String? themeDescription,
      final List<String> styleTags,
      required final DateTime startsAt,
      required final DateTime endsAt,
      final String status,
      final int prizePoolLuxe,
      final int totalSubmissions}) = _$GalaEventImpl;
  const _GalaEvent._() : super._();

  factory _GalaEvent.fromJson(Map<String, dynamic> json) =
      _$GalaEventImpl.fromJson;

  @override
  String get id;
  @override
  String get themeTitle;
  @override
  String? get themeDescription;
  @override
  List<String> get styleTags;
  @override
  DateTime get startsAt;
  @override
  DateTime get endsAt;
  @override
  String get status;
  @override
  int get prizePoolLuxe;
  @override
  int get totalSubmissions;

  /// Create a copy of GalaEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalaEventImplCopyWith<_$GalaEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GalaSubmission _$GalaSubmissionFromJson(Map<String, dynamic> json) {
  return _GalaSubmission.fromJson(json);
}

/// @nodoc
mixin _$GalaSubmission {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  String get designId => throw _privateConstructorUsedError;
  String? get talentId => throw _privateConstructorUsedError;
  double get currentScore => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError;
  int get adoreCount => throw _privateConstructorUsedError;
  int get iconicCount => throw _privateConstructorUsedError;
  int get sovereignCount => throw _privateConstructorUsedError;
  int get timelessCount => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  int? get finalRank => throw _privateConstructorUsedError;
  int get luxeWon => throw _privateConstructorUsedError;
  bool get isGalaSovereign =>
      throw _privateConstructorUsedError; // Populated via join
  String? get designName => throw _privateConstructorUsedError;
  String? get designImageUrl => throw _privateConstructorUsedError;
  String? get playerName => throw _privateConstructorUsedError;
  Talent? get talent => throw _privateConstructorUsedError;

  /// Serializes this GalaSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalaSubmissionCopyWith<GalaSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalaSubmissionCopyWith<$Res> {
  factory $GalaSubmissionCopyWith(
          GalaSubmission value, $Res Function(GalaSubmission) then) =
      _$GalaSubmissionCopyWithImpl<$Res, GalaSubmission>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String playerId,
      String designId,
      String? talentId,
      double currentScore,
      int voteCount,
      int adoreCount,
      int iconicCount,
      int sovereignCount,
      int timelessCount,
      DateTime? submittedAt,
      int? finalRank,
      int luxeWon,
      bool isGalaSovereign,
      String? designName,
      String? designImageUrl,
      String? playerName,
      Talent? talent});

  $TalentCopyWith<$Res>? get talent;
}

/// @nodoc
class _$GalaSubmissionCopyWithImpl<$Res, $Val extends GalaSubmission>
    implements $GalaSubmissionCopyWith<$Res> {
  _$GalaSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? playerId = null,
    Object? designId = null,
    Object? talentId = freezed,
    Object? currentScore = null,
    Object? voteCount = null,
    Object? adoreCount = null,
    Object? iconicCount = null,
    Object? sovereignCount = null,
    Object? timelessCount = null,
    Object? submittedAt = freezed,
    Object? finalRank = freezed,
    Object? luxeWon = null,
    Object? isGalaSovereign = null,
    Object? designName = freezed,
    Object? designImageUrl = freezed,
    Object? playerName = freezed,
    Object? talent = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      talentId: freezed == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentScore: null == currentScore
          ? _value.currentScore
          : currentScore // ignore: cast_nullable_to_non_nullable
              as double,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      adoreCount: null == adoreCount
          ? _value.adoreCount
          : adoreCount // ignore: cast_nullable_to_non_nullable
              as int,
      iconicCount: null == iconicCount
          ? _value.iconicCount
          : iconicCount // ignore: cast_nullable_to_non_nullable
              as int,
      sovereignCount: null == sovereignCount
          ? _value.sovereignCount
          : sovereignCount // ignore: cast_nullable_to_non_nullable
              as int,
      timelessCount: null == timelessCount
          ? _value.timelessCount
          : timelessCount // ignore: cast_nullable_to_non_nullable
              as int,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finalRank: freezed == finalRank
          ? _value.finalRank
          : finalRank // ignore: cast_nullable_to_non_nullable
              as int?,
      luxeWon: null == luxeWon
          ? _value.luxeWon
          : luxeWon // ignore: cast_nullable_to_non_nullable
              as int,
      isGalaSovereign: null == isGalaSovereign
          ? _value.isGalaSovereign
          : isGalaSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      playerName: freezed == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String?,
      talent: freezed == talent
          ? _value.talent
          : talent // ignore: cast_nullable_to_non_nullable
              as Talent?,
    ) as $Val);
  }

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TalentCopyWith<$Res>? get talent {
    if (_value.talent == null) {
      return null;
    }

    return $TalentCopyWith<$Res>(_value.talent!, (value) {
      return _then(_value.copyWith(talent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GalaSubmissionImplCopyWith<$Res>
    implements $GalaSubmissionCopyWith<$Res> {
  factory _$$GalaSubmissionImplCopyWith(_$GalaSubmissionImpl value,
          $Res Function(_$GalaSubmissionImpl) then) =
      __$$GalaSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String playerId,
      String designId,
      String? talentId,
      double currentScore,
      int voteCount,
      int adoreCount,
      int iconicCount,
      int sovereignCount,
      int timelessCount,
      DateTime? submittedAt,
      int? finalRank,
      int luxeWon,
      bool isGalaSovereign,
      String? designName,
      String? designImageUrl,
      String? playerName,
      Talent? talent});

  @override
  $TalentCopyWith<$Res>? get talent;
}

/// @nodoc
class __$$GalaSubmissionImplCopyWithImpl<$Res>
    extends _$GalaSubmissionCopyWithImpl<$Res, _$GalaSubmissionImpl>
    implements _$$GalaSubmissionImplCopyWith<$Res> {
  __$$GalaSubmissionImplCopyWithImpl(
      _$GalaSubmissionImpl _value, $Res Function(_$GalaSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? playerId = null,
    Object? designId = null,
    Object? talentId = freezed,
    Object? currentScore = null,
    Object? voteCount = null,
    Object? adoreCount = null,
    Object? iconicCount = null,
    Object? sovereignCount = null,
    Object? timelessCount = null,
    Object? submittedAt = freezed,
    Object? finalRank = freezed,
    Object? luxeWon = null,
    Object? isGalaSovereign = null,
    Object? designName = freezed,
    Object? designImageUrl = freezed,
    Object? playerName = freezed,
    Object? talent = freezed,
  }) {
    return _then(_$GalaSubmissionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      talentId: freezed == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentScore: null == currentScore
          ? _value.currentScore
          : currentScore // ignore: cast_nullable_to_non_nullable
              as double,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      adoreCount: null == adoreCount
          ? _value.adoreCount
          : adoreCount // ignore: cast_nullable_to_non_nullable
              as int,
      iconicCount: null == iconicCount
          ? _value.iconicCount
          : iconicCount // ignore: cast_nullable_to_non_nullable
              as int,
      sovereignCount: null == sovereignCount
          ? _value.sovereignCount
          : sovereignCount // ignore: cast_nullable_to_non_nullable
              as int,
      timelessCount: null == timelessCount
          ? _value.timelessCount
          : timelessCount // ignore: cast_nullable_to_non_nullable
              as int,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finalRank: freezed == finalRank
          ? _value.finalRank
          : finalRank // ignore: cast_nullable_to_non_nullable
              as int?,
      luxeWon: null == luxeWon
          ? _value.luxeWon
          : luxeWon // ignore: cast_nullable_to_non_nullable
              as int,
      isGalaSovereign: null == isGalaSovereign
          ? _value.isGalaSovereign
          : isGalaSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      playerName: freezed == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String?,
      talent: freezed == talent
          ? _value.talent
          : talent // ignore: cast_nullable_to_non_nullable
              as Talent?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GalaSubmissionImpl extends _GalaSubmission {
  const _$GalaSubmissionImpl(
      {required this.id,
      required this.eventId,
      required this.playerId,
      required this.designId,
      this.talentId,
      this.currentScore = 0.0,
      this.voteCount = 0,
      this.adoreCount = 0,
      this.iconicCount = 0,
      this.sovereignCount = 0,
      this.timelessCount = 0,
      this.submittedAt,
      this.finalRank,
      this.luxeWon = 0,
      this.isGalaSovereign = false,
      this.designName,
      this.designImageUrl,
      this.playerName,
      this.talent})
      : super._();

  factory _$GalaSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalaSubmissionImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String playerId;
  @override
  final String designId;
  @override
  final String? talentId;
  @override
  @JsonKey()
  final double currentScore;
  @override
  @JsonKey()
  final int voteCount;
  @override
  @JsonKey()
  final int adoreCount;
  @override
  @JsonKey()
  final int iconicCount;
  @override
  @JsonKey()
  final int sovereignCount;
  @override
  @JsonKey()
  final int timelessCount;
  @override
  final DateTime? submittedAt;
  @override
  final int? finalRank;
  @override
  @JsonKey()
  final int luxeWon;
  @override
  @JsonKey()
  final bool isGalaSovereign;
// Populated via join
  @override
  final String? designName;
  @override
  final String? designImageUrl;
  @override
  final String? playerName;
  @override
  final Talent? talent;

  @override
  String toString() {
    return 'GalaSubmission(id: $id, eventId: $eventId, playerId: $playerId, designId: $designId, talentId: $talentId, currentScore: $currentScore, voteCount: $voteCount, adoreCount: $adoreCount, iconicCount: $iconicCount, sovereignCount: $sovereignCount, timelessCount: $timelessCount, submittedAt: $submittedAt, finalRank: $finalRank, luxeWon: $luxeWon, isGalaSovereign: $isGalaSovereign, designName: $designName, designImageUrl: $designImageUrl, playerName: $playerName, talent: $talent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalaSubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.designId, designId) ||
                other.designId == designId) &&
            (identical(other.talentId, talentId) ||
                other.talentId == talentId) &&
            (identical(other.currentScore, currentScore) ||
                other.currentScore == currentScore) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.adoreCount, adoreCount) ||
                other.adoreCount == adoreCount) &&
            (identical(other.iconicCount, iconicCount) ||
                other.iconicCount == iconicCount) &&
            (identical(other.sovereignCount, sovereignCount) ||
                other.sovereignCount == sovereignCount) &&
            (identical(other.timelessCount, timelessCount) ||
                other.timelessCount == timelessCount) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.finalRank, finalRank) ||
                other.finalRank == finalRank) &&
            (identical(other.luxeWon, luxeWon) || other.luxeWon == luxeWon) &&
            (identical(other.isGalaSovereign, isGalaSovereign) ||
                other.isGalaSovereign == isGalaSovereign) &&
            (identical(other.designName, designName) ||
                other.designName == designName) &&
            (identical(other.designImageUrl, designImageUrl) ||
                other.designImageUrl == designImageUrl) &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName) &&
            (identical(other.talent, talent) || other.talent == talent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        eventId,
        playerId,
        designId,
        talentId,
        currentScore,
        voteCount,
        adoreCount,
        iconicCount,
        sovereignCount,
        timelessCount,
        submittedAt,
        finalRank,
        luxeWon,
        isGalaSovereign,
        designName,
        designImageUrl,
        playerName,
        talent
      ]);

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalaSubmissionImplCopyWith<_$GalaSubmissionImpl> get copyWith =>
      __$$GalaSubmissionImplCopyWithImpl<_$GalaSubmissionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalaSubmissionImplToJson(
      this,
    );
  }
}

abstract class _GalaSubmission extends GalaSubmission {
  const factory _GalaSubmission(
      {required final String id,
      required final String eventId,
      required final String playerId,
      required final String designId,
      final String? talentId,
      final double currentScore,
      final int voteCount,
      final int adoreCount,
      final int iconicCount,
      final int sovereignCount,
      final int timelessCount,
      final DateTime? submittedAt,
      final int? finalRank,
      final int luxeWon,
      final bool isGalaSovereign,
      final String? designName,
      final String? designImageUrl,
      final String? playerName,
      final Talent? talent}) = _$GalaSubmissionImpl;
  const _GalaSubmission._() : super._();

  factory _GalaSubmission.fromJson(Map<String, dynamic> json) =
      _$GalaSubmissionImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get playerId;
  @override
  String get designId;
  @override
  String? get talentId;
  @override
  double get currentScore;
  @override
  int get voteCount;
  @override
  int get adoreCount;
  @override
  int get iconicCount;
  @override
  int get sovereignCount;
  @override
  int get timelessCount;
  @override
  DateTime? get submittedAt;
  @override
  int? get finalRank;
  @override
  int get luxeWon;
  @override
  bool get isGalaSovereign; // Populated via join
  @override
  String? get designName;
  @override
  String? get designImageUrl;
  @override
  String? get playerName;
  @override
  Talent? get talent;

  /// Create a copy of GalaSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalaSubmissionImplCopyWith<_$GalaSubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GalaVote _$GalaVoteFromJson(Map<String, dynamic> json) {
  return _GalaVote.fromJson(json);
}

/// @nodoc
mixin _$GalaVote {
  String get id => throw _privateConstructorUsedError;
  String get submissionId => throw _privateConstructorUsedError;
  String get voterId => throw _privateConstructorUsedError;
  String get voteTier => throw _privateConstructorUsedError;
  int get basePoints => throw _privateConstructorUsedError;
  double get talentMultiplier => throw _privateConstructorUsedError;
  double get finalPoints => throw _privateConstructorUsedError;
  int get luxeSpent => throw _privateConstructorUsedError;
  DateTime? get votedAt => throw _privateConstructorUsedError;

  /// Serializes this GalaVote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalaVote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalaVoteCopyWith<GalaVote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalaVoteCopyWith<$Res> {
  factory $GalaVoteCopyWith(GalaVote value, $Res Function(GalaVote) then) =
      _$GalaVoteCopyWithImpl<$Res, GalaVote>;
  @useResult
  $Res call(
      {String id,
      String submissionId,
      String voterId,
      String voteTier,
      int basePoints,
      double talentMultiplier,
      double finalPoints,
      int luxeSpent,
      DateTime? votedAt});
}

/// @nodoc
class _$GalaVoteCopyWithImpl<$Res, $Val extends GalaVote>
    implements $GalaVoteCopyWith<$Res> {
  _$GalaVoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalaVote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? voterId = null,
    Object? voteTier = null,
    Object? basePoints = null,
    Object? talentMultiplier = null,
    Object? finalPoints = null,
    Object? luxeSpent = null,
    Object? votedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      voterId: null == voterId
          ? _value.voterId
          : voterId // ignore: cast_nullable_to_non_nullable
              as String,
      voteTier: null == voteTier
          ? _value.voteTier
          : voteTier // ignore: cast_nullable_to_non_nullable
              as String,
      basePoints: null == basePoints
          ? _value.basePoints
          : basePoints // ignore: cast_nullable_to_non_nullable
              as int,
      talentMultiplier: null == talentMultiplier
          ? _value.talentMultiplier
          : talentMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      finalPoints: null == finalPoints
          ? _value.finalPoints
          : finalPoints // ignore: cast_nullable_to_non_nullable
              as double,
      luxeSpent: null == luxeSpent
          ? _value.luxeSpent
          : luxeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      votedAt: freezed == votedAt
          ? _value.votedAt
          : votedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GalaVoteImplCopyWith<$Res>
    implements $GalaVoteCopyWith<$Res> {
  factory _$$GalaVoteImplCopyWith(
          _$GalaVoteImpl value, $Res Function(_$GalaVoteImpl) then) =
      __$$GalaVoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String submissionId,
      String voterId,
      String voteTier,
      int basePoints,
      double talentMultiplier,
      double finalPoints,
      int luxeSpent,
      DateTime? votedAt});
}

/// @nodoc
class __$$GalaVoteImplCopyWithImpl<$Res>
    extends _$GalaVoteCopyWithImpl<$Res, _$GalaVoteImpl>
    implements _$$GalaVoteImplCopyWith<$Res> {
  __$$GalaVoteImplCopyWithImpl(
      _$GalaVoteImpl _value, $Res Function(_$GalaVoteImpl) _then)
      : super(_value, _then);

  /// Create a copy of GalaVote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? voterId = null,
    Object? voteTier = null,
    Object? basePoints = null,
    Object? talentMultiplier = null,
    Object? finalPoints = null,
    Object? luxeSpent = null,
    Object? votedAt = freezed,
  }) {
    return _then(_$GalaVoteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      voterId: null == voterId
          ? _value.voterId
          : voterId // ignore: cast_nullable_to_non_nullable
              as String,
      voteTier: null == voteTier
          ? _value.voteTier
          : voteTier // ignore: cast_nullable_to_non_nullable
              as String,
      basePoints: null == basePoints
          ? _value.basePoints
          : basePoints // ignore: cast_nullable_to_non_nullable
              as int,
      talentMultiplier: null == talentMultiplier
          ? _value.talentMultiplier
          : talentMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      finalPoints: null == finalPoints
          ? _value.finalPoints
          : finalPoints // ignore: cast_nullable_to_non_nullable
              as double,
      luxeSpent: null == luxeSpent
          ? _value.luxeSpent
          : luxeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      votedAt: freezed == votedAt
          ? _value.votedAt
          : votedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GalaVoteImpl extends _GalaVote {
  const _$GalaVoteImpl(
      {required this.id,
      required this.submissionId,
      required this.voterId,
      required this.voteTier,
      this.basePoints = 0,
      this.talentMultiplier = 1.0,
      this.finalPoints = 0.0,
      this.luxeSpent = 0,
      this.votedAt})
      : super._();

  factory _$GalaVoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalaVoteImplFromJson(json);

  @override
  final String id;
  @override
  final String submissionId;
  @override
  final String voterId;
  @override
  final String voteTier;
  @override
  @JsonKey()
  final int basePoints;
  @override
  @JsonKey()
  final double talentMultiplier;
  @override
  @JsonKey()
  final double finalPoints;
  @override
  @JsonKey()
  final int luxeSpent;
  @override
  final DateTime? votedAt;

  @override
  String toString() {
    return 'GalaVote(id: $id, submissionId: $submissionId, voterId: $voterId, voteTier: $voteTier, basePoints: $basePoints, talentMultiplier: $talentMultiplier, finalPoints: $finalPoints, luxeSpent: $luxeSpent, votedAt: $votedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalaVoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.voterId, voterId) || other.voterId == voterId) &&
            (identical(other.voteTier, voteTier) ||
                other.voteTier == voteTier) &&
            (identical(other.basePoints, basePoints) ||
                other.basePoints == basePoints) &&
            (identical(other.talentMultiplier, talentMultiplier) ||
                other.talentMultiplier == talentMultiplier) &&
            (identical(other.finalPoints, finalPoints) ||
                other.finalPoints == finalPoints) &&
            (identical(other.luxeSpent, luxeSpent) ||
                other.luxeSpent == luxeSpent) &&
            (identical(other.votedAt, votedAt) || other.votedAt == votedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, submissionId, voterId,
      voteTier, basePoints, talentMultiplier, finalPoints, luxeSpent, votedAt);

  /// Create a copy of GalaVote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalaVoteImplCopyWith<_$GalaVoteImpl> get copyWith =>
      __$$GalaVoteImplCopyWithImpl<_$GalaVoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalaVoteImplToJson(
      this,
    );
  }
}

abstract class _GalaVote extends GalaVote {
  const factory _GalaVote(
      {required final String id,
      required final String submissionId,
      required final String voterId,
      required final String voteTier,
      final int basePoints,
      final double talentMultiplier,
      final double finalPoints,
      final int luxeSpent,
      final DateTime? votedAt}) = _$GalaVoteImpl;
  const _GalaVote._() : super._();

  factory _GalaVote.fromJson(Map<String, dynamic> json) =
      _$GalaVoteImpl.fromJson;

  @override
  String get id;
  @override
  String get submissionId;
  @override
  String get voterId;
  @override
  String get voteTier;
  @override
  int get basePoints;
  @override
  double get talentMultiplier;
  @override
  double get finalPoints;
  @override
  int get luxeSpent;
  @override
  DateTime? get votedAt;

  /// Create a copy of GalaVote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalaVoteImplCopyWith<_$GalaVoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoteLimits _$VoteLimitsFromJson(Map<String, dynamic> json) {
  return _VoteLimits.fromJson(json);
}

/// @nodoc
mixin _$VoteLimits {
  String get playerId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  DateTime get voteDate => throw _privateConstructorUsedError;
  int get adoreUsed => throw _privateConstructorUsedError;
  int get iconicUsed => throw _privateConstructorUsedError;
  int get sovereignUsed => throw _privateConstructorUsedError;
  int get timelessUsed => throw _privateConstructorUsedError;

  /// Serializes this VoteLimits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoteLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteLimitsCopyWith<VoteLimits> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteLimitsCopyWith<$Res> {
  factory $VoteLimitsCopyWith(
          VoteLimits value, $Res Function(VoteLimits) then) =
      _$VoteLimitsCopyWithImpl<$Res, VoteLimits>;
  @useResult
  $Res call(
      {String playerId,
      String eventId,
      DateTime voteDate,
      int adoreUsed,
      int iconicUsed,
      int sovereignUsed,
      int timelessUsed});
}

/// @nodoc
class _$VoteLimitsCopyWithImpl<$Res, $Val extends VoteLimits>
    implements $VoteLimitsCopyWith<$Res> {
  _$VoteLimitsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoteLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? eventId = null,
    Object? voteDate = null,
    Object? adoreUsed = null,
    Object? iconicUsed = null,
    Object? sovereignUsed = null,
    Object? timelessUsed = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      voteDate: null == voteDate
          ? _value.voteDate
          : voteDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adoreUsed: null == adoreUsed
          ? _value.adoreUsed
          : adoreUsed // ignore: cast_nullable_to_non_nullable
              as int,
      iconicUsed: null == iconicUsed
          ? _value.iconicUsed
          : iconicUsed // ignore: cast_nullable_to_non_nullable
              as int,
      sovereignUsed: null == sovereignUsed
          ? _value.sovereignUsed
          : sovereignUsed // ignore: cast_nullable_to_non_nullable
              as int,
      timelessUsed: null == timelessUsed
          ? _value.timelessUsed
          : timelessUsed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoteLimitsImplCopyWith<$Res>
    implements $VoteLimitsCopyWith<$Res> {
  factory _$$VoteLimitsImplCopyWith(
          _$VoteLimitsImpl value, $Res Function(_$VoteLimitsImpl) then) =
      __$$VoteLimitsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String playerId,
      String eventId,
      DateTime voteDate,
      int adoreUsed,
      int iconicUsed,
      int sovereignUsed,
      int timelessUsed});
}

/// @nodoc
class __$$VoteLimitsImplCopyWithImpl<$Res>
    extends _$VoteLimitsCopyWithImpl<$Res, _$VoteLimitsImpl>
    implements _$$VoteLimitsImplCopyWith<$Res> {
  __$$VoteLimitsImplCopyWithImpl(
      _$VoteLimitsImpl _value, $Res Function(_$VoteLimitsImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoteLimits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? eventId = null,
    Object? voteDate = null,
    Object? adoreUsed = null,
    Object? iconicUsed = null,
    Object? sovereignUsed = null,
    Object? timelessUsed = null,
  }) {
    return _then(_$VoteLimitsImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      voteDate: null == voteDate
          ? _value.voteDate
          : voteDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adoreUsed: null == adoreUsed
          ? _value.adoreUsed
          : adoreUsed // ignore: cast_nullable_to_non_nullable
              as int,
      iconicUsed: null == iconicUsed
          ? _value.iconicUsed
          : iconicUsed // ignore: cast_nullable_to_non_nullable
              as int,
      sovereignUsed: null == sovereignUsed
          ? _value.sovereignUsed
          : sovereignUsed // ignore: cast_nullable_to_non_nullable
              as int,
      timelessUsed: null == timelessUsed
          ? _value.timelessUsed
          : timelessUsed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteLimitsImpl extends _VoteLimits {
  const _$VoteLimitsImpl(
      {required this.playerId,
      required this.eventId,
      required this.voteDate,
      this.adoreUsed = 0,
      this.iconicUsed = 0,
      this.sovereignUsed = 0,
      this.timelessUsed = 0})
      : super._();

  factory _$VoteLimitsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteLimitsImplFromJson(json);

  @override
  final String playerId;
  @override
  final String eventId;
  @override
  final DateTime voteDate;
  @override
  @JsonKey()
  final int adoreUsed;
  @override
  @JsonKey()
  final int iconicUsed;
  @override
  @JsonKey()
  final int sovereignUsed;
  @override
  @JsonKey()
  final int timelessUsed;

  @override
  String toString() {
    return 'VoteLimits(playerId: $playerId, eventId: $eventId, voteDate: $voteDate, adoreUsed: $adoreUsed, iconicUsed: $iconicUsed, sovereignUsed: $sovereignUsed, timelessUsed: $timelessUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteLimitsImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.voteDate, voteDate) ||
                other.voteDate == voteDate) &&
            (identical(other.adoreUsed, adoreUsed) ||
                other.adoreUsed == adoreUsed) &&
            (identical(other.iconicUsed, iconicUsed) ||
                other.iconicUsed == iconicUsed) &&
            (identical(other.sovereignUsed, sovereignUsed) ||
                other.sovereignUsed == sovereignUsed) &&
            (identical(other.timelessUsed, timelessUsed) ||
                other.timelessUsed == timelessUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playerId, eventId, voteDate,
      adoreUsed, iconicUsed, sovereignUsed, timelessUsed);

  /// Create a copy of VoteLimits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteLimitsImplCopyWith<_$VoteLimitsImpl> get copyWith =>
      __$$VoteLimitsImplCopyWithImpl<_$VoteLimitsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteLimitsImplToJson(
      this,
    );
  }
}

abstract class _VoteLimits extends VoteLimits {
  const factory _VoteLimits(
      {required final String playerId,
      required final String eventId,
      required final DateTime voteDate,
      final int adoreUsed,
      final int iconicUsed,
      final int sovereignUsed,
      final int timelessUsed}) = _$VoteLimitsImpl;
  const _VoteLimits._() : super._();

  factory _VoteLimits.fromJson(Map<String, dynamic> json) =
      _$VoteLimitsImpl.fromJson;

  @override
  String get playerId;
  @override
  String get eventId;
  @override
  DateTime get voteDate;
  @override
  int get adoreUsed;
  @override
  int get iconicUsed;
  @override
  int get sovereignUsed;
  @override
  int get timelessUsed;

  /// Create a copy of VoteLimits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteLimitsImplCopyWith<_$VoteLimitsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  int get rank => throw _privateConstructorUsedError;
  String get submissionId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  String get designId => throw _privateConstructorUsedError;
  String? get talentId => throw _privateConstructorUsedError;
  double get currentScore => throw _privateConstructorUsedError;
  int get voteCount => throw _privateConstructorUsedError;
  bool get isGalaSovereign =>
      throw _privateConstructorUsedError; // Populated fields
  String? get playerName => throw _privateConstructorUsedError;
  String? get designName => throw _privateConstructorUsedError;
  String? get designImageUrl => throw _privateConstructorUsedError;
  String? get talentName => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
          LeaderboardEntry value, $Res Function(LeaderboardEntry) then) =
      _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call(
      {int rank,
      String submissionId,
      String playerId,
      String designId,
      String? talentId,
      double currentScore,
      int voteCount,
      bool isGalaSovereign,
      String? playerName,
      String? designName,
      String? designImageUrl,
      String? talentName});
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? submissionId = null,
    Object? playerId = null,
    Object? designId = null,
    Object? talentId = freezed,
    Object? currentScore = null,
    Object? voteCount = null,
    Object? isGalaSovereign = null,
    Object? playerName = freezed,
    Object? designName = freezed,
    Object? designImageUrl = freezed,
    Object? talentName = freezed,
  }) {
    return _then(_value.copyWith(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      talentId: freezed == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentScore: null == currentScore
          ? _value.currentScore
          : currentScore // ignore: cast_nullable_to_non_nullable
              as double,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGalaSovereign: null == isGalaSovereign
          ? _value.isGalaSovereign
          : isGalaSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      playerName: freezed == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      talentName: freezed == talentName
          ? _value.talentName
          : talentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(_$LeaderboardEntryImpl value,
          $Res Function(_$LeaderboardEntryImpl) then) =
      __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int rank,
      String submissionId,
      String playerId,
      String designId,
      String? talentId,
      double currentScore,
      int voteCount,
      bool isGalaSovereign,
      String? playerName,
      String? designName,
      String? designImageUrl,
      String? talentName});
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(_$LeaderboardEntryImpl _value,
      $Res Function(_$LeaderboardEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? submissionId = null,
    Object? playerId = null,
    Object? designId = null,
    Object? talentId = freezed,
    Object? currentScore = null,
    Object? voteCount = null,
    Object? isGalaSovereign = null,
    Object? playerName = freezed,
    Object? designName = freezed,
    Object? designImageUrl = freezed,
    Object? talentName = freezed,
  }) {
    return _then(_$LeaderboardEntryImpl(
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      designId: null == designId
          ? _value.designId
          : designId // ignore: cast_nullable_to_non_nullable
              as String,
      talentId: freezed == talentId
          ? _value.talentId
          : talentId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentScore: null == currentScore
          ? _value.currentScore
          : currentScore // ignore: cast_nullable_to_non_nullable
              as double,
      voteCount: null == voteCount
          ? _value.voteCount
          : voteCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGalaSovereign: null == isGalaSovereign
          ? _value.isGalaSovereign
          : isGalaSovereign // ignore: cast_nullable_to_non_nullable
              as bool,
      playerName: freezed == playerName
          ? _value.playerName
          : playerName // ignore: cast_nullable_to_non_nullable
              as String?,
      designName: freezed == designName
          ? _value.designName
          : designName // ignore: cast_nullable_to_non_nullable
              as String?,
      designImageUrl: freezed == designImageUrl
          ? _value.designImageUrl
          : designImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      talentName: freezed == talentName
          ? _value.talentName
          : talentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl extends _LeaderboardEntry {
  const _$LeaderboardEntryImpl(
      {required this.rank,
      required this.submissionId,
      required this.playerId,
      required this.designId,
      this.talentId,
      required this.currentScore,
      this.voteCount = 0,
      this.isGalaSovereign = false,
      this.playerName,
      this.designName,
      this.designImageUrl,
      this.talentName})
      : super._();

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final int rank;
  @override
  final String submissionId;
  @override
  final String playerId;
  @override
  final String designId;
  @override
  final String? talentId;
  @override
  final double currentScore;
  @override
  @JsonKey()
  final int voteCount;
  @override
  @JsonKey()
  final bool isGalaSovereign;
// Populated fields
  @override
  final String? playerName;
  @override
  final String? designName;
  @override
  final String? designImageUrl;
  @override
  final String? talentName;

  @override
  String toString() {
    return 'LeaderboardEntry(rank: $rank, submissionId: $submissionId, playerId: $playerId, designId: $designId, talentId: $talentId, currentScore: $currentScore, voteCount: $voteCount, isGalaSovereign: $isGalaSovereign, playerName: $playerName, designName: $designName, designImageUrl: $designImageUrl, talentName: $talentName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.designId, designId) ||
                other.designId == designId) &&
            (identical(other.talentId, talentId) ||
                other.talentId == talentId) &&
            (identical(other.currentScore, currentScore) ||
                other.currentScore == currentScore) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.isGalaSovereign, isGalaSovereign) ||
                other.isGalaSovereign == isGalaSovereign) &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName) &&
            (identical(other.designName, designName) ||
                other.designName == designName) &&
            (identical(other.designImageUrl, designImageUrl) ||
                other.designImageUrl == designImageUrl) &&
            (identical(other.talentName, talentName) ||
                other.talentName == talentName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      rank,
      submissionId,
      playerId,
      designId,
      talentId,
      currentScore,
      voteCount,
      isGalaSovereign,
      playerName,
      designName,
      designImageUrl,
      talentName);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(
      this,
    );
  }
}

abstract class _LeaderboardEntry extends LeaderboardEntry {
  const factory _LeaderboardEntry(
      {required final int rank,
      required final String submissionId,
      required final String playerId,
      required final String designId,
      final String? talentId,
      required final double currentScore,
      final int voteCount,
      final bool isGalaSovereign,
      final String? playerName,
      final String? designName,
      final String? designImageUrl,
      final String? talentName}) = _$LeaderboardEntryImpl;
  const _LeaderboardEntry._() : super._();

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  int get rank;
  @override
  String get submissionId;
  @override
  String get playerId;
  @override
  String get designId;
  @override
  String? get talentId;
  @override
  double get currentScore;
  @override
  int get voteCount;
  @override
  bool get isGalaSovereign; // Populated fields
  @override
  String? get playerName;
  @override
  String? get designName;
  @override
  String? get designImageUrl;
  @override
  String? get talentName;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoteResult _$VoteResultFromJson(Map<String, dynamic> json) {
  return _VoteResult.fromJson(json);
}

/// @nodoc
mixin _$VoteResult {
  bool get success => throw _privateConstructorUsedError;
  double get finalPoints => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get submissionId => throw _privateConstructorUsedError;

  /// Serializes this VoteResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteResultCopyWith<VoteResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteResultCopyWith<$Res> {
  factory $VoteResultCopyWith(
          VoteResult value, $Res Function(VoteResult) then) =
      _$VoteResultCopyWithImpl<$Res, VoteResult>;
  @useResult
  $Res call(
      {bool success,
      double finalPoints,
      String? message,
      String? submissionId});
}

/// @nodoc
class _$VoteResultCopyWithImpl<$Res, $Val extends VoteResult>
    implements $VoteResultCopyWith<$Res> {
  _$VoteResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? finalPoints = null,
    Object? message = freezed,
    Object? submissionId = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      finalPoints: null == finalPoints
          ? _value.finalPoints
          : finalPoints // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      submissionId: freezed == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoteResultImplCopyWith<$Res>
    implements $VoteResultCopyWith<$Res> {
  factory _$$VoteResultImplCopyWith(
          _$VoteResultImpl value, $Res Function(_$VoteResultImpl) then) =
      __$$VoteResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      double finalPoints,
      String? message,
      String? submissionId});
}

/// @nodoc
class __$$VoteResultImplCopyWithImpl<$Res>
    extends _$VoteResultCopyWithImpl<$Res, _$VoteResultImpl>
    implements _$$VoteResultImplCopyWith<$Res> {
  __$$VoteResultImplCopyWithImpl(
      _$VoteResultImpl _value, $Res Function(_$VoteResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? finalPoints = null,
    Object? message = freezed,
    Object? submissionId = freezed,
  }) {
    return _then(_$VoteResultImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      finalPoints: null == finalPoints
          ? _value.finalPoints
          : finalPoints // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      submissionId: freezed == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteResultImpl implements _VoteResult {
  const _$VoteResultImpl(
      {required this.success,
      required this.finalPoints,
      this.message,
      this.submissionId});

  factory _$VoteResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteResultImplFromJson(json);

  @override
  final bool success;
  @override
  final double finalPoints;
  @override
  final String? message;
  @override
  final String? submissionId;

  @override
  String toString() {
    return 'VoteResult(success: $success, finalPoints: $finalPoints, message: $message, submissionId: $submissionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.finalPoints, finalPoints) ||
                other.finalPoints == finalPoints) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, finalPoints, message, submissionId);

  /// Create a copy of VoteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteResultImplCopyWith<_$VoteResultImpl> get copyWith =>
      __$$VoteResultImplCopyWithImpl<_$VoteResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteResultImplToJson(
      this,
    );
  }
}

abstract class _VoteResult implements VoteResult {
  const factory _VoteResult(
      {required final bool success,
      required final double finalPoints,
      final String? message,
      final String? submissionId}) = _$VoteResultImpl;

  factory _VoteResult.fromJson(Map<String, dynamic> json) =
      _$VoteResultImpl.fromJson;

  @override
  bool get success;
  @override
  double get finalPoints;
  @override
  String? get message;
  @override
  String? get submissionId;

  /// Create a copy of VoteResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteResultImplCopyWith<_$VoteResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
