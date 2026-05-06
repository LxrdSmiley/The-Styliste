// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Campaign _$CampaignFromJson(Map<String, dynamic> json) {
  return _Campaign.fromJson(json);
}

/// @nodoc
mixin _$Campaign {
  String get id => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  CampaignType get type => throw _privateConstructorUsedError;
  CampaignStatus get status => throw _privateConstructorUsedError;
  double get budget => throw _privateConstructorUsedError;
  double get roiActual => throw _privateConstructorUsedError;
  double get roiForecast => throw _privateConstructorUsedError;
  double get hypeLift =>
      throw _privateConstructorUsedError; // GDD §5.4: +30–100% hype
  double get salesLift => throw _privateConstructorUsedError;
  String? get maisonPoolId =>
      throw _privateConstructorUsedError; // if pooled with Maison (40% cost reduction)
  DateTime? get launchedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CampaignCopyWith<Campaign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampaignCopyWith<$Res> {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) then) =
      _$CampaignCopyWithImpl<$Res, Campaign>;
  @useResult
  $Res call(
      {String id,
      String playerId,
      CampaignType type,
      CampaignStatus status,
      double budget,
      double roiActual,
      double roiForecast,
      double hypeLift,
      double salesLift,
      String? maisonPoolId,
      DateTime? launchedAt,
      DateTime? expiresAt});
}

/// @nodoc
class _$CampaignCopyWithImpl<$Res, $Val extends Campaign>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? type = null,
    Object? status = null,
    Object? budget = null,
    Object? roiActual = null,
    Object? roiForecast = null,
    Object? hypeLift = null,
    Object? salesLift = null,
    Object? maisonPoolId = freezed,
    Object? launchedAt = freezed,
    Object? expiresAt = freezed,
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
              as CampaignType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CampaignStatus,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      roiActual: null == roiActual
          ? _value.roiActual
          : roiActual // ignore: cast_nullable_to_non_nullable
              as double,
      roiForecast: null == roiForecast
          ? _value.roiForecast
          : roiForecast // ignore: cast_nullable_to_non_nullable
              as double,
      hypeLift: null == hypeLift
          ? _value.hypeLift
          : hypeLift // ignore: cast_nullable_to_non_nullable
              as double,
      salesLift: null == salesLift
          ? _value.salesLift
          : salesLift // ignore: cast_nullable_to_non_nullable
              as double,
      maisonPoolId: freezed == maisonPoolId
          ? _value.maisonPoolId
          : maisonPoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      launchedAt: freezed == launchedAt
          ? _value.launchedAt
          : launchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CampaignImplCopyWith<$Res>
    implements $CampaignCopyWith<$Res> {
  factory _$$CampaignImplCopyWith(
          _$CampaignImpl value, $Res Function(_$CampaignImpl) then) =
      __$$CampaignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String playerId,
      CampaignType type,
      CampaignStatus status,
      double budget,
      double roiActual,
      double roiForecast,
      double hypeLift,
      double salesLift,
      String? maisonPoolId,
      DateTime? launchedAt,
      DateTime? expiresAt});
}

/// @nodoc
class __$$CampaignImplCopyWithImpl<$Res>
    extends _$CampaignCopyWithImpl<$Res, _$CampaignImpl>
    implements _$$CampaignImplCopyWith<$Res> {
  __$$CampaignImplCopyWithImpl(
      _$CampaignImpl _value, $Res Function(_$CampaignImpl) _then)
      : super(_value, _then);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? type = null,
    Object? status = null,
    Object? budget = null,
    Object? roiActual = null,
    Object? roiForecast = null,
    Object? hypeLift = null,
    Object? salesLift = null,
    Object? maisonPoolId = freezed,
    Object? launchedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$CampaignImpl(
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
              as CampaignType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CampaignStatus,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      roiActual: null == roiActual
          ? _value.roiActual
          : roiActual // ignore: cast_nullable_to_non_nullable
              as double,
      roiForecast: null == roiForecast
          ? _value.roiForecast
          : roiForecast // ignore: cast_nullable_to_non_nullable
              as double,
      hypeLift: null == hypeLift
          ? _value.hypeLift
          : hypeLift // ignore: cast_nullable_to_non_nullable
              as double,
      salesLift: null == salesLift
          ? _value.salesLift
          : salesLift // ignore: cast_nullable_to_non_nullable
              as double,
      maisonPoolId: freezed == maisonPoolId
          ? _value.maisonPoolId
          : maisonPoolId // ignore: cast_nullable_to_non_nullable
              as String?,
      launchedAt: freezed == launchedAt
          ? _value.launchedAt
          : launchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CampaignImpl implements _Campaign {
  const _$CampaignImpl(
      {required this.id,
      required this.playerId,
      required this.type,
      this.status = CampaignStatus.draft,
      this.budget = 0.0,
      this.roiActual = 0.0,
      this.roiForecast = 0.0,
      this.hypeLift = 0.0,
      this.salesLift = 0.0,
      this.maisonPoolId,
      this.launchedAt,
      this.expiresAt});

  factory _$CampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$CampaignImplFromJson(json);

  @override
  final String id;
  @override
  final String playerId;
  @override
  final CampaignType type;
  @override
  @JsonKey()
  final CampaignStatus status;
  @override
  @JsonKey()
  final double budget;
  @override
  @JsonKey()
  final double roiActual;
  @override
  @JsonKey()
  final double roiForecast;
  @override
  @JsonKey()
  final double hypeLift;
// GDD §5.4: +30–100% hype
  @override
  @JsonKey()
  final double salesLift;
  @override
  final String? maisonPoolId;
// if pooled with Maison (40% cost reduction)
  @override
  final DateTime? launchedAt;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'Campaign(id: $id, playerId: $playerId, type: $type, status: $status, budget: $budget, roiActual: $roiActual, roiForecast: $roiForecast, hypeLift: $hypeLift, salesLift: $salesLift, maisonPoolId: $maisonPoolId, launchedAt: $launchedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.roiActual, roiActual) ||
                other.roiActual == roiActual) &&
            (identical(other.roiForecast, roiForecast) ||
                other.roiForecast == roiForecast) &&
            (identical(other.hypeLift, hypeLift) ||
                other.hypeLift == hypeLift) &&
            (identical(other.salesLift, salesLift) ||
                other.salesLift == salesLift) &&
            (identical(other.maisonPoolId, maisonPoolId) ||
                other.maisonPoolId == maisonPoolId) &&
            (identical(other.launchedAt, launchedAt) ||
                other.launchedAt == launchedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      playerId,
      type,
      status,
      budget,
      roiActual,
      roiForecast,
      hypeLift,
      salesLift,
      maisonPoolId,
      launchedAt,
      expiresAt);

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      __$$CampaignImplCopyWithImpl<_$CampaignImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CampaignImplToJson(
      this,
    );
  }
}

abstract class _Campaign implements Campaign {
  const factory _Campaign(
      {required final String id,
      required final String playerId,
      required final CampaignType type,
      final CampaignStatus status,
      final double budget,
      final double roiActual,
      final double roiForecast,
      final double hypeLift,
      final double salesLift,
      final String? maisonPoolId,
      final DateTime? launchedAt,
      final DateTime? expiresAt}) = _$CampaignImpl;

  factory _Campaign.fromJson(Map<String, dynamic> json) =
      _$CampaignImpl.fromJson;

  @override
  String get id;
  @override
  String get playerId;
  @override
  CampaignType get type;
  @override
  CampaignStatus get status;
  @override
  double get budget;
  @override
  double get roiActual;
  @override
  double get roiForecast;
  @override
  double get hypeLift; // GDD §5.4: +30–100% hype
  @override
  double get salesLift;
  @override
  String? get maisonPoolId; // if pooled with Maison (40% cost reduction)
  @override
  DateTime? get launchedAt;
  @override
  DateTime? get expiresAt;

  /// Create a copy of Campaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CampaignImplCopyWith<_$CampaignImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
