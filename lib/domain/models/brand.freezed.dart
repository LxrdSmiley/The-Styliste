// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'brand.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Brand {
  String get playerId => throw _privateConstructorUsedError;
  int get heat =>
      throw _privateConstructorUsedError; // 0–100 Brand Heat (GDD §8.9.7)
  @_SafeDouble()
  double get hypeScore => throw _privateConstructorUsedError;
  int get followers => throw _privateConstructorUsedError;
  @_SafeDouble()
  double get idleRevenuePerHour => throw _privateConstructorUsedError;
  @_SafeDouble()
  double get totalRevenue => throw _privateConstructorUsedError;
  bool get momentumBuffActive => throw _privateConstructorUsedError;
  DateTime? get momentumBuffUntil => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt =>
      throw _privateConstructorUsedError; // Sustainability (GDD §8.9.5)
  int get sustainabilityTier => throw _privateConstructorUsedError;
  bool get dppEnabled => throw _privateConstructorUsedError;
  bool get dppFullyMapped =>
      throw _privateConstructorUsedError; // Founder Rep (GDD §8.9.8)
  int get founderRep =>
      throw _privateConstructorUsedError; // Luxe Tokens — hard currency (GDD §9.8); minted by validate-iap Edge Function.
  int get luxeTokens =>
      throw _privateConstructorUsedError; // Directive H: Crisis Engine — Tarnish & Kintsugi (GDD §8.9.2)
  int get currentTarnish =>
      throw _privateConstructorUsedError; // 0-100 reputation damage
  int get kintsugiLevel =>
      throw _privateConstructorUsedError; // Number of successful repairs
  int get totalScandalsSurvived => throw _privateConstructorUsedError;
  int get prestigeTokens =>
      throw _privateConstructorUsedError; // Future Gacha system
  String? get marketTier =>
      throw _privateConstructorUsedError; // high_luxury / mid_luxury / mass_market
  Map<String, dynamic>? get avatarConfiguration =>
      throw _privateConstructorUsedError; // Directive L: Supply Chain & Buffer Stock Engine (GDD §12.1.2)
  int get warehouseCapacity =>
      throw _privateConstructorUsedError; // Max inventory storage
  int get currentInventoryValue =>
      throw _privateConstructorUsedError; // Current stored inventory
  int get logisticsLevel => throw _privateConstructorUsedError;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BrandCopyWith<Brand> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrandCopyWith<$Res> {
  factory $BrandCopyWith(Brand value, $Res Function(Brand) then) =
      _$BrandCopyWithImpl<$Res, Brand>;
  @useResult
  $Res call(
      {String playerId,
      int heat,
      @_SafeDouble() double hypeScore,
      int followers,
      @_SafeDouble() double idleRevenuePerHour,
      @_SafeDouble() double totalRevenue,
      bool momentumBuffActive,
      DateTime? momentumBuffUntil,
      DateTime? lastActiveAt,
      int sustainabilityTier,
      bool dppEnabled,
      bool dppFullyMapped,
      int founderRep,
      int luxeTokens,
      int currentTarnish,
      int kintsugiLevel,
      int totalScandalsSurvived,
      int prestigeTokens,
      String? marketTier,
      Map<String, dynamic>? avatarConfiguration,
      int warehouseCapacity,
      int currentInventoryValue,
      int logisticsLevel});
}

/// @nodoc
class _$BrandCopyWithImpl<$Res, $Val extends Brand>
    implements $BrandCopyWith<$Res> {
  _$BrandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? heat = null,
    Object? hypeScore = null,
    Object? followers = null,
    Object? idleRevenuePerHour = null,
    Object? totalRevenue = null,
    Object? momentumBuffActive = null,
    Object? momentumBuffUntil = freezed,
    Object? lastActiveAt = freezed,
    Object? sustainabilityTier = null,
    Object? dppEnabled = null,
    Object? dppFullyMapped = null,
    Object? founderRep = null,
    Object? luxeTokens = null,
    Object? currentTarnish = null,
    Object? kintsugiLevel = null,
    Object? totalScandalsSurvived = null,
    Object? prestigeTokens = null,
    Object? marketTier = freezed,
    Object? avatarConfiguration = freezed,
    Object? warehouseCapacity = null,
    Object? currentInventoryValue = null,
    Object? logisticsLevel = null,
  }) {
    return _then(_value.copyWith(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      heat: null == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as int,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      idleRevenuePerHour: null == idleRevenuePerHour
          ? _value.idleRevenuePerHour
          : idleRevenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      momentumBuffActive: null == momentumBuffActive
          ? _value.momentumBuffActive
          : momentumBuffActive // ignore: cast_nullable_to_non_nullable
              as bool,
      momentumBuffUntil: freezed == momentumBuffUntil
          ? _value.momentumBuffUntil
          : momentumBuffUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sustainabilityTier: null == sustainabilityTier
          ? _value.sustainabilityTier
          : sustainabilityTier // ignore: cast_nullable_to_non_nullable
              as int,
      dppEnabled: null == dppEnabled
          ? _value.dppEnabled
          : dppEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      dppFullyMapped: null == dppFullyMapped
          ? _value.dppFullyMapped
          : dppFullyMapped // ignore: cast_nullable_to_non_nullable
              as bool,
      founderRep: null == founderRep
          ? _value.founderRep
          : founderRep // ignore: cast_nullable_to_non_nullable
              as int,
      luxeTokens: null == luxeTokens
          ? _value.luxeTokens
          : luxeTokens // ignore: cast_nullable_to_non_nullable
              as int,
      currentTarnish: null == currentTarnish
          ? _value.currentTarnish
          : currentTarnish // ignore: cast_nullable_to_non_nullable
              as int,
      kintsugiLevel: null == kintsugiLevel
          ? _value.kintsugiLevel
          : kintsugiLevel // ignore: cast_nullable_to_non_nullable
              as int,
      totalScandalsSurvived: null == totalScandalsSurvived
          ? _value.totalScandalsSurvived
          : totalScandalsSurvived // ignore: cast_nullable_to_non_nullable
              as int,
      prestigeTokens: null == prestigeTokens
          ? _value.prestigeTokens
          : prestigeTokens // ignore: cast_nullable_to_non_nullable
              as int,
      marketTier: freezed == marketTier
          ? _value.marketTier
          : marketTier // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarConfiguration: freezed == avatarConfiguration
          ? _value.avatarConfiguration
          : avatarConfiguration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      warehouseCapacity: null == warehouseCapacity
          ? _value.warehouseCapacity
          : warehouseCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      currentInventoryValue: null == currentInventoryValue
          ? _value.currentInventoryValue
          : currentInventoryValue // ignore: cast_nullable_to_non_nullable
              as int,
      logisticsLevel: null == logisticsLevel
          ? _value.logisticsLevel
          : logisticsLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BrandImplCopyWith<$Res> implements $BrandCopyWith<$Res> {
  factory _$$BrandImplCopyWith(
          _$BrandImpl value, $Res Function(_$BrandImpl) then) =
      __$$BrandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String playerId,
      int heat,
      @_SafeDouble() double hypeScore,
      int followers,
      @_SafeDouble() double idleRevenuePerHour,
      @_SafeDouble() double totalRevenue,
      bool momentumBuffActive,
      DateTime? momentumBuffUntil,
      DateTime? lastActiveAt,
      int sustainabilityTier,
      bool dppEnabled,
      bool dppFullyMapped,
      int founderRep,
      int luxeTokens,
      int currentTarnish,
      int kintsugiLevel,
      int totalScandalsSurvived,
      int prestigeTokens,
      String? marketTier,
      Map<String, dynamic>? avatarConfiguration,
      int warehouseCapacity,
      int currentInventoryValue,
      int logisticsLevel});
}

/// @nodoc
class __$$BrandImplCopyWithImpl<$Res>
    extends _$BrandCopyWithImpl<$Res, _$BrandImpl>
    implements _$$BrandImplCopyWith<$Res> {
  __$$BrandImplCopyWithImpl(
      _$BrandImpl _value, $Res Function(_$BrandImpl) _then)
      : super(_value, _then);

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? heat = null,
    Object? hypeScore = null,
    Object? followers = null,
    Object? idleRevenuePerHour = null,
    Object? totalRevenue = null,
    Object? momentumBuffActive = null,
    Object? momentumBuffUntil = freezed,
    Object? lastActiveAt = freezed,
    Object? sustainabilityTier = null,
    Object? dppEnabled = null,
    Object? dppFullyMapped = null,
    Object? founderRep = null,
    Object? luxeTokens = null,
    Object? currentTarnish = null,
    Object? kintsugiLevel = null,
    Object? totalScandalsSurvived = null,
    Object? prestigeTokens = null,
    Object? marketTier = freezed,
    Object? avatarConfiguration = freezed,
    Object? warehouseCapacity = null,
    Object? currentInventoryValue = null,
    Object? logisticsLevel = null,
  }) {
    return _then(_$BrandImpl(
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      heat: null == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as int,
      hypeScore: null == hypeScore
          ? _value.hypeScore
          : hypeScore // ignore: cast_nullable_to_non_nullable
              as double,
      followers: null == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      idleRevenuePerHour: null == idleRevenuePerHour
          ? _value.idleRevenuePerHour
          : idleRevenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      momentumBuffActive: null == momentumBuffActive
          ? _value.momentumBuffActive
          : momentumBuffActive // ignore: cast_nullable_to_non_nullable
              as bool,
      momentumBuffUntil: freezed == momentumBuffUntil
          ? _value.momentumBuffUntil
          : momentumBuffUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sustainabilityTier: null == sustainabilityTier
          ? _value.sustainabilityTier
          : sustainabilityTier // ignore: cast_nullable_to_non_nullable
              as int,
      dppEnabled: null == dppEnabled
          ? _value.dppEnabled
          : dppEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      dppFullyMapped: null == dppFullyMapped
          ? _value.dppFullyMapped
          : dppFullyMapped // ignore: cast_nullable_to_non_nullable
              as bool,
      founderRep: null == founderRep
          ? _value.founderRep
          : founderRep // ignore: cast_nullable_to_non_nullable
              as int,
      luxeTokens: null == luxeTokens
          ? _value.luxeTokens
          : luxeTokens // ignore: cast_nullable_to_non_nullable
              as int,
      currentTarnish: null == currentTarnish
          ? _value.currentTarnish
          : currentTarnish // ignore: cast_nullable_to_non_nullable
              as int,
      kintsugiLevel: null == kintsugiLevel
          ? _value.kintsugiLevel
          : kintsugiLevel // ignore: cast_nullable_to_non_nullable
              as int,
      totalScandalsSurvived: null == totalScandalsSurvived
          ? _value.totalScandalsSurvived
          : totalScandalsSurvived // ignore: cast_nullable_to_non_nullable
              as int,
      prestigeTokens: null == prestigeTokens
          ? _value.prestigeTokens
          : prestigeTokens // ignore: cast_nullable_to_non_nullable
              as int,
      marketTier: freezed == marketTier
          ? _value.marketTier
          : marketTier // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarConfiguration: freezed == avatarConfiguration
          ? _value._avatarConfiguration
          : avatarConfiguration // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      warehouseCapacity: null == warehouseCapacity
          ? _value.warehouseCapacity
          : warehouseCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      currentInventoryValue: null == currentInventoryValue
          ? _value.currentInventoryValue
          : currentInventoryValue // ignore: cast_nullable_to_non_nullable
              as int,
      logisticsLevel: null == logisticsLevel
          ? _value.logisticsLevel
          : logisticsLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$BrandImpl implements _Brand {
  const _$BrandImpl(
      {required this.playerId,
      this.heat = 50,
      @_SafeDouble() this.hypeScore = 0.0,
      this.followers = 0,
      @_SafeDouble() this.idleRevenuePerHour = 0.0,
      @_SafeDouble() this.totalRevenue = 0.0,
      this.momentumBuffActive = false,
      this.momentumBuffUntil,
      this.lastActiveAt,
      this.sustainabilityTier = 0,
      this.dppEnabled = false,
      this.dppFullyMapped = false,
      this.founderRep = 50,
      this.luxeTokens = 0,
      this.currentTarnish = 0,
      this.kintsugiLevel = 0,
      this.totalScandalsSurvived = 0,
      this.prestigeTokens = 0,
      this.marketTier,
      final Map<String, dynamic>? avatarConfiguration,
      this.warehouseCapacity = 5000,
      this.currentInventoryValue = 0,
      this.logisticsLevel = 1})
      : _avatarConfiguration = avatarConfiguration;

  @override
  final String playerId;
  @override
  @JsonKey()
  final int heat;
// 0–100 Brand Heat (GDD §8.9.7)
  @override
  @JsonKey()
  @_SafeDouble()
  final double hypeScore;
  @override
  @JsonKey()
  final int followers;
  @override
  @JsonKey()
  @_SafeDouble()
  final double idleRevenuePerHour;
  @override
  @JsonKey()
  @_SafeDouble()
  final double totalRevenue;
  @override
  @JsonKey()
  final bool momentumBuffActive;
  @override
  final DateTime? momentumBuffUntil;
  @override
  final DateTime? lastActiveAt;
// Sustainability (GDD §8.9.5)
  @override
  @JsonKey()
  final int sustainabilityTier;
  @override
  @JsonKey()
  final bool dppEnabled;
  @override
  @JsonKey()
  final bool dppFullyMapped;
// Founder Rep (GDD §8.9.8)
  @override
  @JsonKey()
  final int founderRep;
// Luxe Tokens — hard currency (GDD §9.8); minted by validate-iap Edge Function.
  @override
  @JsonKey()
  final int luxeTokens;
// Directive H: Crisis Engine — Tarnish & Kintsugi (GDD §8.9.2)
  @override
  @JsonKey()
  final int currentTarnish;
// 0-100 reputation damage
  @override
  @JsonKey()
  final int kintsugiLevel;
// Number of successful repairs
  @override
  @JsonKey()
  final int totalScandalsSurvived;
  @override
  @JsonKey()
  final int prestigeTokens;
// Future Gacha system
  @override
  final String? marketTier;
// high_luxury / mid_luxury / mass_market
  final Map<String, dynamic>? _avatarConfiguration;
// high_luxury / mid_luxury / mass_market
  @override
  Map<String, dynamic>? get avatarConfiguration {
    final value = _avatarConfiguration;
    if (value == null) return null;
    if (_avatarConfiguration is EqualUnmodifiableMapView)
      return _avatarConfiguration;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Directive L: Supply Chain & Buffer Stock Engine (GDD §12.1.2)
  @override
  @JsonKey()
  final int warehouseCapacity;
// Max inventory storage
  @override
  @JsonKey()
  final int currentInventoryValue;
// Current stored inventory
  @override
  @JsonKey()
  final int logisticsLevel;

  @override
  String toString() {
    return 'Brand(playerId: $playerId, heat: $heat, hypeScore: $hypeScore, followers: $followers, idleRevenuePerHour: $idleRevenuePerHour, totalRevenue: $totalRevenue, momentumBuffActive: $momentumBuffActive, momentumBuffUntil: $momentumBuffUntil, lastActiveAt: $lastActiveAt, sustainabilityTier: $sustainabilityTier, dppEnabled: $dppEnabled, dppFullyMapped: $dppFullyMapped, founderRep: $founderRep, luxeTokens: $luxeTokens, currentTarnish: $currentTarnish, kintsugiLevel: $kintsugiLevel, totalScandalsSurvived: $totalScandalsSurvived, prestigeTokens: $prestigeTokens, marketTier: $marketTier, avatarConfiguration: $avatarConfiguration, warehouseCapacity: $warehouseCapacity, currentInventoryValue: $currentInventoryValue, logisticsLevel: $logisticsLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrandImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.heat, heat) || other.heat == heat) &&
            (identical(other.hypeScore, hypeScore) ||
                other.hypeScore == hypeScore) &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.idleRevenuePerHour, idleRevenuePerHour) ||
                other.idleRevenuePerHour == idleRevenuePerHour) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.momentumBuffActive, momentumBuffActive) ||
                other.momentumBuffActive == momentumBuffActive) &&
            (identical(other.momentumBuffUntil, momentumBuffUntil) ||
                other.momentumBuffUntil == momentumBuffUntil) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.sustainabilityTier, sustainabilityTier) ||
                other.sustainabilityTier == sustainabilityTier) &&
            (identical(other.dppEnabled, dppEnabled) ||
                other.dppEnabled == dppEnabled) &&
            (identical(other.dppFullyMapped, dppFullyMapped) ||
                other.dppFullyMapped == dppFullyMapped) &&
            (identical(other.founderRep, founderRep) ||
                other.founderRep == founderRep) &&
            (identical(other.luxeTokens, luxeTokens) ||
                other.luxeTokens == luxeTokens) &&
            (identical(other.currentTarnish, currentTarnish) ||
                other.currentTarnish == currentTarnish) &&
            (identical(other.kintsugiLevel, kintsugiLevel) ||
                other.kintsugiLevel == kintsugiLevel) &&
            (identical(other.totalScandalsSurvived, totalScandalsSurvived) ||
                other.totalScandalsSurvived == totalScandalsSurvived) &&
            (identical(other.prestigeTokens, prestigeTokens) ||
                other.prestigeTokens == prestigeTokens) &&
            (identical(other.marketTier, marketTier) ||
                other.marketTier == marketTier) &&
            const DeepCollectionEquality()
                .equals(other._avatarConfiguration, _avatarConfiguration) &&
            (identical(other.warehouseCapacity, warehouseCapacity) ||
                other.warehouseCapacity == warehouseCapacity) &&
            (identical(other.currentInventoryValue, currentInventoryValue) ||
                other.currentInventoryValue == currentInventoryValue) &&
            (identical(other.logisticsLevel, logisticsLevel) ||
                other.logisticsLevel == logisticsLevel));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        playerId,
        heat,
        hypeScore,
        followers,
        idleRevenuePerHour,
        totalRevenue,
        momentumBuffActive,
        momentumBuffUntil,
        lastActiveAt,
        sustainabilityTier,
        dppEnabled,
        dppFullyMapped,
        founderRep,
        luxeTokens,
        currentTarnish,
        kintsugiLevel,
        totalScandalsSurvived,
        prestigeTokens,
        marketTier,
        const DeepCollectionEquality().hash(_avatarConfiguration),
        warehouseCapacity,
        currentInventoryValue,
        logisticsLevel
      ]);

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrandImplCopyWith<_$BrandImpl> get copyWith =>
      __$$BrandImplCopyWithImpl<_$BrandImpl>(this, _$identity);
}

abstract class _Brand implements Brand {
  const factory _Brand(
      {required final String playerId,
      final int heat,
      @_SafeDouble() final double hypeScore,
      final int followers,
      @_SafeDouble() final double idleRevenuePerHour,
      @_SafeDouble() final double totalRevenue,
      final bool momentumBuffActive,
      final DateTime? momentumBuffUntil,
      final DateTime? lastActiveAt,
      final int sustainabilityTier,
      final bool dppEnabled,
      final bool dppFullyMapped,
      final int founderRep,
      final int luxeTokens,
      final int currentTarnish,
      final int kintsugiLevel,
      final int totalScandalsSurvived,
      final int prestigeTokens,
      final String? marketTier,
      final Map<String, dynamic>? avatarConfiguration,
      final int warehouseCapacity,
      final int currentInventoryValue,
      final int logisticsLevel}) = _$BrandImpl;

  @override
  String get playerId;
  @override
  int get heat; // 0–100 Brand Heat (GDD §8.9.7)
  @override
  @_SafeDouble()
  double get hypeScore;
  @override
  int get followers;
  @override
  @_SafeDouble()
  double get idleRevenuePerHour;
  @override
  @_SafeDouble()
  double get totalRevenue;
  @override
  bool get momentumBuffActive;
  @override
  DateTime? get momentumBuffUntil;
  @override
  DateTime? get lastActiveAt; // Sustainability (GDD §8.9.5)
  @override
  int get sustainabilityTier;
  @override
  bool get dppEnabled;
  @override
  bool get dppFullyMapped; // Founder Rep (GDD §8.9.8)
  @override
  int get founderRep; // Luxe Tokens — hard currency (GDD §9.8); minted by validate-iap Edge Function.
  @override
  int get luxeTokens; // Directive H: Crisis Engine — Tarnish & Kintsugi (GDD §8.9.2)
  @override
  int get currentTarnish; // 0-100 reputation damage
  @override
  int get kintsugiLevel; // Number of successful repairs
  @override
  int get totalScandalsSurvived;
  @override
  int get prestigeTokens; // Future Gacha system
  @override
  String? get marketTier; // high_luxury / mid_luxury / mass_market
  @override
  Map<String, dynamic>?
      get avatarConfiguration; // Directive L: Supply Chain & Buffer Stock Engine (GDD §12.1.2)
  @override
  int get warehouseCapacity; // Max inventory storage
  @override
  int get currentInventoryValue; // Current stored inventory
  @override
  int get logisticsLevel;

  /// Create a copy of Brand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrandImplCopyWith<_$BrandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
