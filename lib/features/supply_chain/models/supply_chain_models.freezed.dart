// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supply_chain_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SupplyChainState _$SupplyChainStateFromJson(Map<String, dynamic> json) {
  return _SupplyChainState.fromJson(json);
}

/// @nodoc
mixin _$SupplyChainState {
  int get warehouseCapacity => throw _privateConstructorUsedError;
  int get currentInventoryValue => throw _privateConstructorUsedError;
  int get logisticsLevel => throw _privateConstructorUsedError;
  double get idleRevenuePerHour => throw _privateConstructorUsedError;
  bool get isFull => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  /// Serializes this SupplyChainState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupplyChainState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplyChainStateCopyWith<SupplyChainState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplyChainStateCopyWith<$Res> {
  factory $SupplyChainStateCopyWith(
          SupplyChainState value, $Res Function(SupplyChainState) then) =
      _$SupplyChainStateCopyWithImpl<$Res, SupplyChainState>;
  @useResult
  $Res call(
      {int warehouseCapacity,
      int currentInventoryValue,
      int logisticsLevel,
      double idleRevenuePerHour,
      bool isFull,
      DateTime? lastActiveAt});
}

/// @nodoc
class _$SupplyChainStateCopyWithImpl<$Res, $Val extends SupplyChainState>
    implements $SupplyChainStateCopyWith<$Res> {
  _$SupplyChainStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplyChainState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouseCapacity = null,
    Object? currentInventoryValue = null,
    Object? logisticsLevel = null,
    Object? idleRevenuePerHour = null,
    Object? isFull = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_value.copyWith(
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
      idleRevenuePerHour: null == idleRevenuePerHour
          ? _value.idleRevenuePerHour
          : idleRevenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      isFull: null == isFull
          ? _value.isFull
          : isFull // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplyChainStateImplCopyWith<$Res>
    implements $SupplyChainStateCopyWith<$Res> {
  factory _$$SupplyChainStateImplCopyWith(_$SupplyChainStateImpl value,
          $Res Function(_$SupplyChainStateImpl) then) =
      __$$SupplyChainStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int warehouseCapacity,
      int currentInventoryValue,
      int logisticsLevel,
      double idleRevenuePerHour,
      bool isFull,
      DateTime? lastActiveAt});
}

/// @nodoc
class __$$SupplyChainStateImplCopyWithImpl<$Res>
    extends _$SupplyChainStateCopyWithImpl<$Res, _$SupplyChainStateImpl>
    implements _$$SupplyChainStateImplCopyWith<$Res> {
  __$$SupplyChainStateImplCopyWithImpl(_$SupplyChainStateImpl _value,
      $Res Function(_$SupplyChainStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupplyChainState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouseCapacity = null,
    Object? currentInventoryValue = null,
    Object? logisticsLevel = null,
    Object? idleRevenuePerHour = null,
    Object? isFull = null,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_$SupplyChainStateImpl(
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
      idleRevenuePerHour: null == idleRevenuePerHour
          ? _value.idleRevenuePerHour
          : idleRevenuePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      isFull: null == isFull
          ? _value.isFull
          : isFull // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplyChainStateImpl extends _SupplyChainState {
  const _$SupplyChainStateImpl(
      {this.warehouseCapacity = 5000,
      this.currentInventoryValue = 0,
      this.logisticsLevel = 1,
      this.idleRevenuePerHour = 0.0,
      this.isFull = false,
      this.lastActiveAt})
      : super._();

  factory _$SupplyChainStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplyChainStateImplFromJson(json);

  @override
  @JsonKey()
  final int warehouseCapacity;
  @override
  @JsonKey()
  final int currentInventoryValue;
  @override
  @JsonKey()
  final int logisticsLevel;
  @override
  @JsonKey()
  final double idleRevenuePerHour;
  @override
  @JsonKey()
  final bool isFull;
  @override
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'SupplyChainState(warehouseCapacity: $warehouseCapacity, currentInventoryValue: $currentInventoryValue, logisticsLevel: $logisticsLevel, idleRevenuePerHour: $idleRevenuePerHour, isFull: $isFull, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplyChainStateImpl &&
            (identical(other.warehouseCapacity, warehouseCapacity) ||
                other.warehouseCapacity == warehouseCapacity) &&
            (identical(other.currentInventoryValue, currentInventoryValue) ||
                other.currentInventoryValue == currentInventoryValue) &&
            (identical(other.logisticsLevel, logisticsLevel) ||
                other.logisticsLevel == logisticsLevel) &&
            (identical(other.idleRevenuePerHour, idleRevenuePerHour) ||
                other.idleRevenuePerHour == idleRevenuePerHour) &&
            (identical(other.isFull, isFull) || other.isFull == isFull) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      warehouseCapacity,
      currentInventoryValue,
      logisticsLevel,
      idleRevenuePerHour,
      isFull,
      lastActiveAt);

  /// Create a copy of SupplyChainState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplyChainStateImplCopyWith<_$SupplyChainStateImpl> get copyWith =>
      __$$SupplyChainStateImplCopyWithImpl<_$SupplyChainStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplyChainStateImplToJson(
      this,
    );
  }
}

abstract class _SupplyChainState extends SupplyChainState {
  const factory _SupplyChainState(
      {final int warehouseCapacity,
      final int currentInventoryValue,
      final int logisticsLevel,
      final double idleRevenuePerHour,
      final bool isFull,
      final DateTime? lastActiveAt}) = _$SupplyChainStateImpl;
  const _SupplyChainState._() : super._();

  factory _SupplyChainState.fromJson(Map<String, dynamic> json) =
      _$SupplyChainStateImpl.fromJson;

  @override
  int get warehouseCapacity;
  @override
  int get currentInventoryValue;
  @override
  int get logisticsLevel;
  @override
  double get idleRevenuePerHour;
  @override
  bool get isFull;
  @override
  DateTime? get lastActiveAt;

  /// Create a copy of SupplyChainState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplyChainStateImplCopyWith<_$SupplyChainStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LiquidationResult _$LiquidationResultFromJson(Map<String, dynamic> json) {
  return _LiquidationResult.fromJson(json);
}

/// @nodoc
mixin _$LiquidationResult {
  int get liquidatedAmount => throw _privateConstructorUsedError;
  int get newInventory => throw _privateConstructorUsedError;
  double get newRevenue => throw _privateConstructorUsedError;

  /// Serializes this LiquidationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiquidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiquidationResultCopyWith<LiquidationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiquidationResultCopyWith<$Res> {
  factory $LiquidationResultCopyWith(
          LiquidationResult value, $Res Function(LiquidationResult) then) =
      _$LiquidationResultCopyWithImpl<$Res, LiquidationResult>;
  @useResult
  $Res call({int liquidatedAmount, int newInventory, double newRevenue});
}

/// @nodoc
class _$LiquidationResultCopyWithImpl<$Res, $Val extends LiquidationResult>
    implements $LiquidationResultCopyWith<$Res> {
  _$LiquidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiquidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liquidatedAmount = null,
    Object? newInventory = null,
    Object? newRevenue = null,
  }) {
    return _then(_value.copyWith(
      liquidatedAmount: null == liquidatedAmount
          ? _value.liquidatedAmount
          : liquidatedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      newInventory: null == newInventory
          ? _value.newInventory
          : newInventory // ignore: cast_nullable_to_non_nullable
              as int,
      newRevenue: null == newRevenue
          ? _value.newRevenue
          : newRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LiquidationResultImplCopyWith<$Res>
    implements $LiquidationResultCopyWith<$Res> {
  factory _$$LiquidationResultImplCopyWith(_$LiquidationResultImpl value,
          $Res Function(_$LiquidationResultImpl) then) =
      __$$LiquidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int liquidatedAmount, int newInventory, double newRevenue});
}

/// @nodoc
class __$$LiquidationResultImplCopyWithImpl<$Res>
    extends _$LiquidationResultCopyWithImpl<$Res, _$LiquidationResultImpl>
    implements _$$LiquidationResultImplCopyWith<$Res> {
  __$$LiquidationResultImplCopyWithImpl(_$LiquidationResultImpl _value,
      $Res Function(_$LiquidationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of LiquidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liquidatedAmount = null,
    Object? newInventory = null,
    Object? newRevenue = null,
  }) {
    return _then(_$LiquidationResultImpl(
      liquidatedAmount: null == liquidatedAmount
          ? _value.liquidatedAmount
          : liquidatedAmount // ignore: cast_nullable_to_non_nullable
              as int,
      newInventory: null == newInventory
          ? _value.newInventory
          : newInventory // ignore: cast_nullable_to_non_nullable
              as int,
      newRevenue: null == newRevenue
          ? _value.newRevenue
          : newRevenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LiquidationResultImpl extends _LiquidationResult {
  const _$LiquidationResultImpl(
      {this.liquidatedAmount = 0, this.newInventory = 0, this.newRevenue = 0.0})
      : super._();

  factory _$LiquidationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiquidationResultImplFromJson(json);

  @override
  @JsonKey()
  final int liquidatedAmount;
  @override
  @JsonKey()
  final int newInventory;
  @override
  @JsonKey()
  final double newRevenue;

  @override
  String toString() {
    return 'LiquidationResult(liquidatedAmount: $liquidatedAmount, newInventory: $newInventory, newRevenue: $newRevenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiquidationResultImpl &&
            (identical(other.liquidatedAmount, liquidatedAmount) ||
                other.liquidatedAmount == liquidatedAmount) &&
            (identical(other.newInventory, newInventory) ||
                other.newInventory == newInventory) &&
            (identical(other.newRevenue, newRevenue) ||
                other.newRevenue == newRevenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, liquidatedAmount, newInventory, newRevenue);

  /// Create a copy of LiquidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiquidationResultImplCopyWith<_$LiquidationResultImpl> get copyWith =>
      __$$LiquidationResultImplCopyWithImpl<_$LiquidationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiquidationResultImplToJson(
      this,
    );
  }
}

abstract class _LiquidationResult extends LiquidationResult {
  const factory _LiquidationResult(
      {final int liquidatedAmount,
      final int newInventory,
      final double newRevenue}) = _$LiquidationResultImpl;
  const _LiquidationResult._() : super._();

  factory _LiquidationResult.fromJson(Map<String, dynamic> json) =
      _$LiquidationResultImpl.fromJson;

  @override
  int get liquidatedAmount;
  @override
  int get newInventory;
  @override
  double get newRevenue;

  /// Create a copy of LiquidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiquidationResultImplCopyWith<_$LiquidationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LogisticsUpgrade _$LogisticsUpgradeFromJson(Map<String, dynamic> json) {
  return _LogisticsUpgrade.fromJson(json);
}

/// @nodoc
mixin _$LogisticsUpgrade {
  bool get success => throw _privateConstructorUsedError;
  int get newLevel => throw _privateConstructorUsedError;
  int get newCapacity => throw _privateConstructorUsedError;
  int get cost => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this LogisticsUpgrade to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogisticsUpgrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogisticsUpgradeCopyWith<LogisticsUpgrade> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogisticsUpgradeCopyWith<$Res> {
  factory $LogisticsUpgradeCopyWith(
          LogisticsUpgrade value, $Res Function(LogisticsUpgrade) then) =
      _$LogisticsUpgradeCopyWithImpl<$Res, LogisticsUpgrade>;
  @useResult
  $Res call(
      {bool success, int newLevel, int newCapacity, int cost, String? message});
}

/// @nodoc
class _$LogisticsUpgradeCopyWithImpl<$Res, $Val extends LogisticsUpgrade>
    implements $LogisticsUpgradeCopyWith<$Res> {
  _$LogisticsUpgradeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogisticsUpgrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? newLevel = null,
    Object? newCapacity = null,
    Object? cost = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      newLevel: null == newLevel
          ? _value.newLevel
          : newLevel // ignore: cast_nullable_to_non_nullable
              as int,
      newCapacity: null == newCapacity
          ? _value.newCapacity
          : newCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as int,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogisticsUpgradeImplCopyWith<$Res>
    implements $LogisticsUpgradeCopyWith<$Res> {
  factory _$$LogisticsUpgradeImplCopyWith(_$LogisticsUpgradeImpl value,
          $Res Function(_$LogisticsUpgradeImpl) then) =
      __$$LogisticsUpgradeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success, int newLevel, int newCapacity, int cost, String? message});
}

/// @nodoc
class __$$LogisticsUpgradeImplCopyWithImpl<$Res>
    extends _$LogisticsUpgradeCopyWithImpl<$Res, _$LogisticsUpgradeImpl>
    implements _$$LogisticsUpgradeImplCopyWith<$Res> {
  __$$LogisticsUpgradeImplCopyWithImpl(_$LogisticsUpgradeImpl _value,
      $Res Function(_$LogisticsUpgradeImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogisticsUpgrade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? newLevel = null,
    Object? newCapacity = null,
    Object? cost = null,
    Object? message = freezed,
  }) {
    return _then(_$LogisticsUpgradeImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      newLevel: null == newLevel
          ? _value.newLevel
          : newLevel // ignore: cast_nullable_to_non_nullable
              as int,
      newCapacity: null == newCapacity
          ? _value.newCapacity
          : newCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
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
class _$LogisticsUpgradeImpl extends _LogisticsUpgrade {
  const _$LogisticsUpgradeImpl(
      {this.success = false,
      this.newLevel = 1,
      this.newCapacity = 5000,
      this.cost = 0,
      this.message})
      : super._();

  factory _$LogisticsUpgradeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogisticsUpgradeImplFromJson(json);

  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey()
  final int newLevel;
  @override
  @JsonKey()
  final int newCapacity;
  @override
  @JsonKey()
  final int cost;
  @override
  final String? message;

  @override
  String toString() {
    return 'LogisticsUpgrade(success: $success, newLevel: $newLevel, newCapacity: $newCapacity, cost: $cost, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogisticsUpgradeImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.newLevel, newLevel) ||
                other.newLevel == newLevel) &&
            (identical(other.newCapacity, newCapacity) ||
                other.newCapacity == newCapacity) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, newLevel, newCapacity, cost, message);

  /// Create a copy of LogisticsUpgrade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogisticsUpgradeImplCopyWith<_$LogisticsUpgradeImpl> get copyWith =>
      __$$LogisticsUpgradeImplCopyWithImpl<_$LogisticsUpgradeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogisticsUpgradeImplToJson(
      this,
    );
  }
}

abstract class _LogisticsUpgrade extends LogisticsUpgrade {
  const factory _LogisticsUpgrade(
      {final bool success,
      final int newLevel,
      final int newCapacity,
      final int cost,
      final String? message}) = _$LogisticsUpgradeImpl;
  const _LogisticsUpgrade._() : super._();

  factory _LogisticsUpgrade.fromJson(Map<String, dynamic> json) =
      _$LogisticsUpgradeImpl.fromJson;

  @override
  bool get success;
  @override
  int get newLevel;
  @override
  int get newCapacity;
  @override
  int get cost;
  @override
  String? get message;

  /// Create a copy of LogisticsUpgrade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogisticsUpgradeImplCopyWith<_$LogisticsUpgradeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
