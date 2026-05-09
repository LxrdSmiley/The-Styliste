// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'district_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalDistrictsHash() => r'70f89e324a32ff0b14e8730f2777014a8554520a';

/// Real-time stream of all 9 fashion districts
///
/// Updates automatically when:
/// - Takeover occurs
/// - Control changes
/// - Hype values update
///
/// Copied from [globalDistricts].
@ProviderFor(globalDistricts)
final globalDistrictsProvider =
    AutoDisposeStreamProvider<List<FashionDistrict>>.internal(
  globalDistricts,
  name: r'globalDistrictsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$globalDistrictsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GlobalDistrictsRef
    = AutoDisposeStreamProviderRef<List<FashionDistrict>>;
String _$districtByIdHash() => r'a250166a187112d6393d8ab8787b69c26e9ee076';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Single district by ID
///
/// Copied from [districtById].
@ProviderFor(districtById)
const districtByIdProvider = DistrictByIdFamily();

/// Single district by ID
///
/// Copied from [districtById].
class DistrictByIdFamily extends Family<AsyncValue<FashionDistrict?>> {
  /// Single district by ID
  ///
  /// Copied from [districtById].
  const DistrictByIdFamily();

  /// Single district by ID
  ///
  /// Copied from [districtById].
  DistrictByIdProvider call(
    String districtId,
  ) {
    return DistrictByIdProvider(
      districtId,
    );
  }

  @override
  DistrictByIdProvider getProviderOverride(
    covariant DistrictByIdProvider provider,
  ) {
    return call(
      provider.districtId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'districtByIdProvider';
}

/// Single district by ID
///
/// Copied from [districtById].
class DistrictByIdProvider extends AutoDisposeStreamProvider<FashionDistrict?> {
  /// Single district by ID
  ///
  /// Copied from [districtById].
  DistrictByIdProvider(
    String districtId,
  ) : this._internal(
          (ref) => districtById(
            ref as DistrictByIdRef,
            districtId,
          ),
          from: districtByIdProvider,
          name: r'districtByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$districtByIdHash,
          dependencies: DistrictByIdFamily._dependencies,
          allTransitiveDependencies:
              DistrictByIdFamily._allTransitiveDependencies,
          districtId: districtId,
        );

  DistrictByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.districtId,
  }) : super.internal();

  final String districtId;

  @override
  Override overrideWith(
    Stream<FashionDistrict?> Function(DistrictByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistrictByIdProvider._internal(
        (ref) => create(ref as DistrictByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        districtId: districtId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<FashionDistrict?> createElement() {
    return _DistrictByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistrictByIdProvider && other.districtId == districtId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, districtId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistrictByIdRef on AutoDisposeStreamProviderRef<FashionDistrict?> {
  /// The parameter `districtId` of this provider.
  String get districtId;
}

class _DistrictByIdProviderElement
    extends AutoDisposeStreamProviderElement<FashionDistrict?>
    with DistrictByIdRef {
  _DistrictByIdProviderElement(super.provider);

  @override
  String get districtId => (origin as DistrictByIdProvider).districtId;
}

String _$districtsByMaisonHash() => r'475934fa84a2d4e846aecd5924cc711e1cbca35e';

/// Districts controlled by a specific maison
///
/// Copied from [districtsByMaison].
@ProviderFor(districtsByMaison)
const districtsByMaisonProvider = DistrictsByMaisonFamily();

/// Districts controlled by a specific maison
///
/// Copied from [districtsByMaison].
class DistrictsByMaisonFamily
    extends Family<AsyncValue<List<FashionDistrict>>> {
  /// Districts controlled by a specific maison
  ///
  /// Copied from [districtsByMaison].
  const DistrictsByMaisonFamily();

  /// Districts controlled by a specific maison
  ///
  /// Copied from [districtsByMaison].
  DistrictsByMaisonProvider call(
    String maisonId,
  ) {
    return DistrictsByMaisonProvider(
      maisonId,
    );
  }

  @override
  DistrictsByMaisonProvider getProviderOverride(
    covariant DistrictsByMaisonProvider provider,
  ) {
    return call(
      provider.maisonId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'districtsByMaisonProvider';
}

/// Districts controlled by a specific maison
///
/// Copied from [districtsByMaison].
class DistrictsByMaisonProvider
    extends AutoDisposeStreamProvider<List<FashionDistrict>> {
  /// Districts controlled by a specific maison
  ///
  /// Copied from [districtsByMaison].
  DistrictsByMaisonProvider(
    String maisonId,
  ) : this._internal(
          (ref) => districtsByMaison(
            ref as DistrictsByMaisonRef,
            maisonId,
          ),
          from: districtsByMaisonProvider,
          name: r'districtsByMaisonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$districtsByMaisonHash,
          dependencies: DistrictsByMaisonFamily._dependencies,
          allTransitiveDependencies:
              DistrictsByMaisonFamily._allTransitiveDependencies,
          maisonId: maisonId,
        );

  DistrictsByMaisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.maisonId,
  }) : super.internal();

  final String maisonId;

  @override
  Override overrideWith(
    Stream<List<FashionDistrict>> Function(DistrictsByMaisonRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistrictsByMaisonProvider._internal(
        (ref) => create(ref as DistrictsByMaisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        maisonId: maisonId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FashionDistrict>> createElement() {
    return _DistrictsByMaisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistrictsByMaisonProvider && other.maisonId == maisonId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, maisonId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistrictsByMaisonRef
    on AutoDisposeStreamProviderRef<List<FashionDistrict>> {
  /// The parameter `maisonId` of this provider.
  String get maisonId;
}

class _DistrictsByMaisonProviderElement
    extends AutoDisposeStreamProviderElement<List<FashionDistrict>>
    with DistrictsByMaisonRef {
  _DistrictsByMaisonProviderElement(super.provider);

  @override
  String get maisonId => (origin as DistrictsByMaisonProvider).maisonId;
}

String _$maisonWatermarksHash() => r'228acd0c24cbe0e540149f4b7a686ecd7243ce37';

/// Legacy watermarks for a maison (permanent 30-day achievements)
///
/// Copied from [maisonWatermarks].
@ProviderFor(maisonWatermarks)
const maisonWatermarksProvider = MaisonWatermarksFamily();

/// Legacy watermarks for a maison (permanent 30-day achievements)
///
/// Copied from [maisonWatermarks].
class MaisonWatermarksFamily
    extends Family<AsyncValue<List<DistrictWatermark>>> {
  /// Legacy watermarks for a maison (permanent 30-day achievements)
  ///
  /// Copied from [maisonWatermarks].
  const MaisonWatermarksFamily();

  /// Legacy watermarks for a maison (permanent 30-day achievements)
  ///
  /// Copied from [maisonWatermarks].
  MaisonWatermarksProvider call(
    String maisonId,
  ) {
    return MaisonWatermarksProvider(
      maisonId,
    );
  }

  @override
  MaisonWatermarksProvider getProviderOverride(
    covariant MaisonWatermarksProvider provider,
  ) {
    return call(
      provider.maisonId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'maisonWatermarksProvider';
}

/// Legacy watermarks for a maison (permanent 30-day achievements)
///
/// Copied from [maisonWatermarks].
class MaisonWatermarksProvider
    extends AutoDisposeStreamProvider<List<DistrictWatermark>> {
  /// Legacy watermarks for a maison (permanent 30-day achievements)
  ///
  /// Copied from [maisonWatermarks].
  MaisonWatermarksProvider(
    String maisonId,
  ) : this._internal(
          (ref) => maisonWatermarks(
            ref as MaisonWatermarksRef,
            maisonId,
          ),
          from: maisonWatermarksProvider,
          name: r'maisonWatermarksProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$maisonWatermarksHash,
          dependencies: MaisonWatermarksFamily._dependencies,
          allTransitiveDependencies:
              MaisonWatermarksFamily._allTransitiveDependencies,
          maisonId: maisonId,
        );

  MaisonWatermarksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.maisonId,
  }) : super.internal();

  final String maisonId;

  @override
  Override overrideWith(
    Stream<List<DistrictWatermark>> Function(MaisonWatermarksRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MaisonWatermarksProvider._internal(
        (ref) => create(ref as MaisonWatermarksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        maisonId: maisonId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DistrictWatermark>> createElement() {
    return _MaisonWatermarksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MaisonWatermarksProvider && other.maisonId == maisonId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, maisonId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MaisonWatermarksRef
    on AutoDisposeStreamProviderRef<List<DistrictWatermark>> {
  /// The parameter `maisonId` of this provider.
  String get maisonId;
}

class _MaisonWatermarksProviderElement
    extends AutoDisposeStreamProviderElement<List<DistrictWatermark>>
    with MaisonWatermarksRef {
  _MaisonWatermarksProviderElement(super.provider);

  @override
  String get maisonId => (origin as MaisonWatermarksProvider).maisonId;
}

String _$allWatermarksHash() => r'c6f71107c105ef7ac61396f8db72c609134ec9f5';

/// All legacy watermarks (for map rendering)
///
/// Copied from [allWatermarks].
@ProviderFor(allWatermarks)
final allWatermarksProvider =
    AutoDisposeStreamProvider<List<DistrictWatermark>>.internal(
  allWatermarks,
  name: r'allWatermarksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allWatermarksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllWatermarksRef
    = AutoDisposeStreamProviderRef<List<DistrictWatermark>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
