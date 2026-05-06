// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Supplier _$SupplierFromJson(Map<String, dynamic> json) {
  return _Supplier.fromJson(json);
}

/// @nodoc
mixin _$Supplier {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  SupplierTier get tier => throw _privateConstructorUsedError;
  SupplierCategory get category => throw _privateConstructorUsedError;
  int get quality => throw _privateConstructorUsedError; // 0–100
  int get cost =>
      throw _privateConstructorUsedError; // 0–100 (higher = more expensive)
  int get reliability => throw _privateConstructorUsedError; // 0–100
  int get prestige => throw _privateConstructorUsedError; // 0–100
  bool get livingWageEnabled =>
      throw _privateConstructorUsedError; // GDD §8.9.4
  bool get blockchainTraceable =>
      throw _privateConstructorUsedError; // GDD §8.9.4
  bool get ethicalSupplierBadge => throw _privateConstructorUsedError;

  /// Serializes this Supplier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplierCopyWith<Supplier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplierCopyWith<$Res> {
  factory $SupplierCopyWith(Supplier value, $Res Function(Supplier) then) =
      _$SupplierCopyWithImpl<$Res, Supplier>;
  @useResult
  $Res call(
      {String id,
      String name,
      SupplierTier tier,
      SupplierCategory category,
      int quality,
      int cost,
      int reliability,
      int prestige,
      bool livingWageEnabled,
      bool blockchainTraceable,
      bool ethicalSupplierBadge});
}

/// @nodoc
class _$SupplierCopyWithImpl<$Res, $Val extends Supplier>
    implements $SupplierCopyWith<$Res> {
  _$SupplierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tier = null,
    Object? category = null,
    Object? quality = null,
    Object? cost = null,
    Object? reliability = null,
    Object? prestige = null,
    Object? livingWageEnabled = null,
    Object? blockchainTraceable = null,
    Object? ethicalSupplierBadge = null,
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
              as SupplierTier,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as SupplierCategory,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      reliability: null == reliability
          ? _value.reliability
          : reliability // ignore: cast_nullable_to_non_nullable
              as int,
      prestige: null == prestige
          ? _value.prestige
          : prestige // ignore: cast_nullable_to_non_nullable
              as int,
      livingWageEnabled: null == livingWageEnabled
          ? _value.livingWageEnabled
          : livingWageEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      blockchainTraceable: null == blockchainTraceable
          ? _value.blockchainTraceable
          : blockchainTraceable // ignore: cast_nullable_to_non_nullable
              as bool,
      ethicalSupplierBadge: null == ethicalSupplierBadge
          ? _value.ethicalSupplierBadge
          : ethicalSupplierBadge // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplierImplCopyWith<$Res>
    implements $SupplierCopyWith<$Res> {
  factory _$$SupplierImplCopyWith(
          _$SupplierImpl value, $Res Function(_$SupplierImpl) then) =
      __$$SupplierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      SupplierTier tier,
      SupplierCategory category,
      int quality,
      int cost,
      int reliability,
      int prestige,
      bool livingWageEnabled,
      bool blockchainTraceable,
      bool ethicalSupplierBadge});
}

/// @nodoc
class __$$SupplierImplCopyWithImpl<$Res>
    extends _$SupplierCopyWithImpl<$Res, _$SupplierImpl>
    implements _$$SupplierImplCopyWith<$Res> {
  __$$SupplierImplCopyWithImpl(
      _$SupplierImpl _value, $Res Function(_$SupplierImpl) _then)
      : super(_value, _then);

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tier = null,
    Object? category = null,
    Object? quality = null,
    Object? cost = null,
    Object? reliability = null,
    Object? prestige = null,
    Object? livingWageEnabled = null,
    Object? blockchainTraceable = null,
    Object? ethicalSupplierBadge = null,
  }) {
    return _then(_$SupplierImpl(
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
              as SupplierTier,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as SupplierCategory,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      reliability: null == reliability
          ? _value.reliability
          : reliability // ignore: cast_nullable_to_non_nullable
              as int,
      prestige: null == prestige
          ? _value.prestige
          : prestige // ignore: cast_nullable_to_non_nullable
              as int,
      livingWageEnabled: null == livingWageEnabled
          ? _value.livingWageEnabled
          : livingWageEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      blockchainTraceable: null == blockchainTraceable
          ? _value.blockchainTraceable
          : blockchainTraceable // ignore: cast_nullable_to_non_nullable
              as bool,
      ethicalSupplierBadge: null == ethicalSupplierBadge
          ? _value.ethicalSupplierBadge
          : ethicalSupplierBadge // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplierImpl implements _Supplier {
  const _$SupplierImpl(
      {required this.id,
      required this.name,
      required this.tier,
      required this.category,
      this.quality = 50,
      this.cost = 50,
      this.reliability = 50,
      this.prestige = 50,
      this.livingWageEnabled = false,
      this.blockchainTraceable = false,
      this.ethicalSupplierBadge = false});

  factory _$SupplierImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplierImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final SupplierTier tier;
  @override
  final SupplierCategory category;
  @override
  @JsonKey()
  final int quality;
// 0–100
  @override
  @JsonKey()
  final int cost;
// 0–100 (higher = more expensive)
  @override
  @JsonKey()
  final int reliability;
// 0–100
  @override
  @JsonKey()
  final int prestige;
// 0–100
  @override
  @JsonKey()
  final bool livingWageEnabled;
// GDD §8.9.4
  @override
  @JsonKey()
  final bool blockchainTraceable;
// GDD §8.9.4
  @override
  @JsonKey()
  final bool ethicalSupplierBadge;

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, tier: $tier, category: $category, quality: $quality, cost: $cost, reliability: $reliability, prestige: $prestige, livingWageEnabled: $livingWageEnabled, blockchainTraceable: $blockchainTraceable, ethicalSupplierBadge: $ethicalSupplierBadge)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplierImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.reliability, reliability) ||
                other.reliability == reliability) &&
            (identical(other.prestige, prestige) ||
                other.prestige == prestige) &&
            (identical(other.livingWageEnabled, livingWageEnabled) ||
                other.livingWageEnabled == livingWageEnabled) &&
            (identical(other.blockchainTraceable, blockchainTraceable) ||
                other.blockchainTraceable == blockchainTraceable) &&
            (identical(other.ethicalSupplierBadge, ethicalSupplierBadge) ||
                other.ethicalSupplierBadge == ethicalSupplierBadge));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      tier,
      category,
      quality,
      cost,
      reliability,
      prestige,
      livingWageEnabled,
      blockchainTraceable,
      ethicalSupplierBadge);

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplierImplCopyWith<_$SupplierImpl> get copyWith =>
      __$$SupplierImplCopyWithImpl<_$SupplierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplierImplToJson(
      this,
    );
  }
}

abstract class _Supplier implements Supplier {
  const factory _Supplier(
      {required final String id,
      required final String name,
      required final SupplierTier tier,
      required final SupplierCategory category,
      final int quality,
      final int cost,
      final int reliability,
      final int prestige,
      final bool livingWageEnabled,
      final bool blockchainTraceable,
      final bool ethicalSupplierBadge}) = _$SupplierImpl;

  factory _Supplier.fromJson(Map<String, dynamic> json) =
      _$SupplierImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  SupplierTier get tier;
  @override
  SupplierCategory get category;
  @override
  int get quality; // 0–100
  @override
  int get cost; // 0–100 (higher = more expensive)
  @override
  int get reliability; // 0–100
  @override
  int get prestige; // 0–100
  @override
  bool get livingWageEnabled; // GDD §8.9.4
  @override
  bool get blockchainTraceable; // GDD §8.9.4
  @override
  bool get ethicalSupplierBadge;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplierImplCopyWith<_$SupplierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SupplyChainContract _$SupplyChainContractFromJson(Map<String, dynamic> json) {
  return _SupplyChainContract.fromJson(json);
}

/// @nodoc
mixin _$SupplyChainContract {
  String get id => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  SupplierTier get tier => throw _privateConstructorUsedError;
  bool get exclusivity => throw _privateConstructorUsedError;
  DateTime? get contractExpiresAt => throw _privateConstructorUsedError;

  /// Serializes this SupplyChainContract to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupplyChainContract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplyChainContractCopyWith<SupplyChainContract> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplyChainContractCopyWith<$Res> {
  factory $SupplyChainContractCopyWith(
          SupplyChainContract value, $Res Function(SupplyChainContract) then) =
      _$SupplyChainContractCopyWithImpl<$Res, SupplyChainContract>;
  @useResult
  $Res call(
      {String id,
      String playerId,
      String supplierId,
      SupplierTier tier,
      bool exclusivity,
      DateTime? contractExpiresAt});
}

/// @nodoc
class _$SupplyChainContractCopyWithImpl<$Res, $Val extends SupplyChainContract>
    implements $SupplyChainContractCopyWith<$Res> {
  _$SupplyChainContractCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplyChainContract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? supplierId = null,
    Object? tier = null,
    Object? exclusivity = null,
    Object? contractExpiresAt = freezed,
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
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SupplierTier,
      exclusivity: null == exclusivity
          ? _value.exclusivity
          : exclusivity // ignore: cast_nullable_to_non_nullable
              as bool,
      contractExpiresAt: freezed == contractExpiresAt
          ? _value.contractExpiresAt
          : contractExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplyChainContractImplCopyWith<$Res>
    implements $SupplyChainContractCopyWith<$Res> {
  factory _$$SupplyChainContractImplCopyWith(_$SupplyChainContractImpl value,
          $Res Function(_$SupplyChainContractImpl) then) =
      __$$SupplyChainContractImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String playerId,
      String supplierId,
      SupplierTier tier,
      bool exclusivity,
      DateTime? contractExpiresAt});
}

/// @nodoc
class __$$SupplyChainContractImplCopyWithImpl<$Res>
    extends _$SupplyChainContractCopyWithImpl<$Res, _$SupplyChainContractImpl>
    implements _$$SupplyChainContractImplCopyWith<$Res> {
  __$$SupplyChainContractImplCopyWithImpl(_$SupplyChainContractImpl _value,
      $Res Function(_$SupplyChainContractImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupplyChainContract
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? playerId = null,
    Object? supplierId = null,
    Object? tier = null,
    Object? exclusivity = null,
    Object? contractExpiresAt = freezed,
  }) {
    return _then(_$SupplyChainContractImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      playerId: null == playerId
          ? _value.playerId
          : playerId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as SupplierTier,
      exclusivity: null == exclusivity
          ? _value.exclusivity
          : exclusivity // ignore: cast_nullable_to_non_nullable
              as bool,
      contractExpiresAt: freezed == contractExpiresAt
          ? _value.contractExpiresAt
          : contractExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplyChainContractImpl implements _SupplyChainContract {
  const _$SupplyChainContractImpl(
      {required this.id,
      required this.playerId,
      required this.supplierId,
      required this.tier,
      this.exclusivity = false,
      this.contractExpiresAt});

  factory _$SupplyChainContractImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplyChainContractImplFromJson(json);

  @override
  final String id;
  @override
  final String playerId;
  @override
  final String supplierId;
  @override
  final SupplierTier tier;
  @override
  @JsonKey()
  final bool exclusivity;
  @override
  final DateTime? contractExpiresAt;

  @override
  String toString() {
    return 'SupplyChainContract(id: $id, playerId: $playerId, supplierId: $supplierId, tier: $tier, exclusivity: $exclusivity, contractExpiresAt: $contractExpiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplyChainContractImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.exclusivity, exclusivity) ||
                other.exclusivity == exclusivity) &&
            (identical(other.contractExpiresAt, contractExpiresAt) ||
                other.contractExpiresAt == contractExpiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, playerId, supplierId, tier,
      exclusivity, contractExpiresAt);

  /// Create a copy of SupplyChainContract
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplyChainContractImplCopyWith<_$SupplyChainContractImpl> get copyWith =>
      __$$SupplyChainContractImplCopyWithImpl<_$SupplyChainContractImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplyChainContractImplToJson(
      this,
    );
  }
}

abstract class _SupplyChainContract implements SupplyChainContract {
  const factory _SupplyChainContract(
      {required final String id,
      required final String playerId,
      required final String supplierId,
      required final SupplierTier tier,
      final bool exclusivity,
      final DateTime? contractExpiresAt}) = _$SupplyChainContractImpl;

  factory _SupplyChainContract.fromJson(Map<String, dynamic> json) =
      _$SupplyChainContractImpl.fromJson;

  @override
  String get id;
  @override
  String get playerId;
  @override
  String get supplierId;
  @override
  SupplierTier get tier;
  @override
  bool get exclusivity;
  @override
  DateTime? get contractExpiresAt;

  /// Create a copy of SupplyChainContract
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplyChainContractImplCopyWith<_$SupplyChainContractImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
