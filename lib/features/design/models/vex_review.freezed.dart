// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vex_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VexReview _$VexReviewFromJson(Map<String, dynamic> json) {
  return _VexReview.fromJson(json);
}

/// @nodoc
mixin _$VexReview {
  /// Editorial headline — the verdict's thesis statement
  String get headline => throw _privateConstructorUsedError;

  /// Body copy — the analytical breakdown
  String get body => throw _privateConstructorUsedError;

  /// The verdict tier — determines UI styling and emotional weight
  VexVerdict get verdict => throw _privateConstructorUsedError;

  /// Final hype score that generated this review
  double get hypeScore => throw _privateConstructorUsedError;

  /// The matching tsunami tag (if any) — referenced in critique
  String? get matchingTsunamiTag => throw _privateConstructorUsedError;

  /// Tsunami multiplier applied (1.0 or 1.5)
  double? get tsunamiMultiplier => throw _privateConstructorUsedError;

  /// Whether player opted in to receive this review
  bool get wasOptedIn => throw _privateConstructorUsedError;

  /// Timestamp of generation
  DateTime? get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this VexReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VexReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VexReviewCopyWith<VexReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VexReviewCopyWith<$Res> {
  factory $VexReviewCopyWith(VexReview value, $Res Function(VexReview) then) =
      _$VexReviewCopyWithImpl<$Res, VexReview>;
  @useResult
  $Res call(
      {String headline,
      String body,
      VexVerdict verdict,
      double hypeScore,
      String? matchingTsunamiTag,
      double? tsunamiMultiplier,
      bool wasOptedIn,
      DateTime? generatedAt});
}

/// @nodoc
class _$VexReviewCopyWithImpl<$Res, $Val extends VexReview>
    implements $VexReviewCopyWith<$Res> {
  _$VexReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VexReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? body = null,
    Object? verdict = null,
    Object? hypeScore = null,
    Object? matchingTsunamiTag = freezed,
    Object? tsunamiMultiplier = freezed,
    Object? wasOptedIn = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as VexVerdict,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      matchingTsunamiTag: freezed == matchingTsunamiTag
          ? _value.matchingTsunamiTag
          : matchingTsunamiTag // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunamiMultiplier: freezed == tsunamiMultiplier
          ? _value.tsunamiMultiplier
          : tsunamiMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      wasOptedIn: null == wasOptedIn
          ? _value.wasOptedIn
          : wasOptedIn // ignore: cast_nullable_to_non_nullable
              as bool,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VexReviewImplCopyWith<$Res>
    implements $VexReviewCopyWith<$Res> {
  factory _$$VexReviewImplCopyWith(
          _$VexReviewImpl value, $Res Function(_$VexReviewImpl) then) =
      __$$VexReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String headline,
      String body,
      VexVerdict verdict,
      double hypeScore,
      String? matchingTsunamiTag,
      double? tsunamiMultiplier,
      bool wasOptedIn,
      DateTime? generatedAt});
}

/// @nodoc
class __$$VexReviewImplCopyWithImpl<$Res>
    extends _$VexReviewCopyWithImpl<$Res, _$VexReviewImpl>
    implements _$$VexReviewImplCopyWith<$Res> {
  __$$VexReviewImplCopyWithImpl(
      _$VexReviewImpl _value, $Res Function(_$VexReviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of VexReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? body = null,
    Object? verdict = null,
    Object? hypeScore = null,
    Object? matchingTsunamiTag = freezed,
    Object? tsunamiMultiplier = freezed,
    Object? wasOptedIn = null,
    Object? generatedAt = freezed,
  }) {
    return _then(_$VexReviewImpl(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      verdict: null == verdict
          ? _value.verdict
          : verdict // ignore: cast_nullable_to_non_nullable
              as VexVerdict,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      matchingTsunamiTag: freezed == matchingTsunamiTag
          ? _value.matchingTsunamiTag
          : matchingTsunamiTag // ignore: cast_nullable_to_non_nullable
              as String?,
      tsunamiMultiplier: freezed == tsunamiMultiplier
          ? _value.tsunamiMultiplier
          : tsunamiMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      wasOptedIn: null == wasOptedIn
          ? _value.wasOptedIn
          : wasOptedIn // ignore: cast_nullable_to_non_nullable
              as bool,
      generatedAt: freezed == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _$VexReviewImpl extends _VexReview {
  const _$VexReviewImpl(
      {required this.headline,
      required this.body,
      required this.verdict,
      required this.hypeScore,
      this.matchingTsunamiTag,
      this.tsunamiMultiplier,
      this.wasOptedIn = true,
      this.generatedAt = null})
      : super._();

  factory _$VexReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$VexReviewImplFromJson(json);

  /// Editorial headline — the verdict's thesis statement
  @override
  final String headline;

  /// Body copy — the analytical breakdown
  @override
  final String body;

  /// The verdict tier — determines UI styling and emotional weight
  @override
  final VexVerdict verdict;

  /// Final hype score that generated this review
  @override
  final double hypeScore;

  /// The matching tsunami tag (if any) — referenced in critique
  @override
  final String? matchingTsunamiTag;

  /// Tsunami multiplier applied (1.0 or 1.5)
  @override
  final double? tsunamiMultiplier;

  /// Whether player opted in to receive this review
  @override
  @JsonKey()
  final bool wasOptedIn;

  /// Timestamp of generation
  @override
  @JsonKey()
  final DateTime? generatedAt;

  @override
  String toString() {
    return 'VexReview(headline: $headline, body: $body, verdict: $verdict, hypeScore: $hypeScore, matchingTsunamiTag: $matchingTsunamiTag, tsunamiMultiplier: $tsunamiMultiplier, wasOptedIn: $wasOptedIn, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VexReviewImpl &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.verdict, verdict) || other.verdict == verdict) &&
            (identical(other.hypeScore, hypeScore) ||
                other.hypeScore == hypeScore) &&
            (identical(other.matchingTsunamiTag, matchingTsunamiTag) ||
                other.matchingTsunamiTag == matchingTsunamiTag) &&
            (identical(other.tsunamiMultiplier, tsunamiMultiplier) ||
                other.tsunamiMultiplier == tsunamiMultiplier) &&
            (identical(other.wasOptedIn, wasOptedIn) ||
                other.wasOptedIn == wasOptedIn) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      headline,
      body,
      verdict,
      hypeScore,
      matchingTsunamiTag,
      tsunamiMultiplier,
      wasOptedIn,
      generatedAt);

  /// Create a copy of VexReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VexReviewImplCopyWith<_$VexReviewImpl> get copyWith =>
      __$$VexReviewImplCopyWithImpl<_$VexReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VexReviewImplToJson(
      this,
    );
  }
}

abstract class _VexReview extends VexReview {
  const factory _VexReview(
      {required final String headline,
      required final String body,
      required final VexVerdict verdict,
      required final double hypeScore,
      final String? matchingTsunamiTag,
      final double? tsunamiMultiplier,
      final bool wasOptedIn,
      final DateTime? generatedAt}) = _$VexReviewImpl;
  const _VexReview._() : super._();

  factory _VexReview.fromJson(Map<String, dynamic> json) =
      _$VexReviewImpl.fromJson;

  /// Editorial headline — the verdict's thesis statement
  @override
  String get headline;

  /// Body copy — the analytical breakdown
  @override
  String get body;

  /// The verdict tier — determines UI styling and emotional weight
  @override
  VexVerdict get verdict;

  /// Final hype score that generated this review
  @override
  double get hypeScore;

  /// The matching tsunami tag (if any) — referenced in critique
  @override
  String? get matchingTsunamiTag;

  /// Tsunami multiplier applied (1.0 or 1.5)
  @override
  double? get tsunamiMultiplier;

  /// Whether player opted in to receive this review
  @override
  bool get wasOptedIn;

  /// Timestamp of generation
  @override
  DateTime? get generatedAt;

  /// Create a copy of VexReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VexReviewImplCopyWith<_$VexReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
