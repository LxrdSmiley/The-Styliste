// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTsunamiHash() => r'edde5995b5cf2ea165f25e6fa83a164faacd0d23';

/// Stream of active Trend Tsunamis from Supabase Realtime
///
/// Emits a list of currently active (non-expired) trend waves.
/// Each tsunami represents a style tag with a multiplier (2.5x for Crest, 1.5x for Surge)
///
/// Usage in UI:
/// ```dart
/// final tsunamis = ref.watch(activeTsunamiProvider);
/// tsunamis.when(
///   data: (waves) => TsunamiIndicator(waves: waves),
///   loading: () => ChampagneGoldPulse(),
///   error: (err, stack) => ErrorView(err),
/// );
/// ```
///
/// Copied from [activeTsunami].
@ProviderFor(activeTsunami)
final activeTsunamiProvider =
    AutoDisposeStreamProvider<List<TrendTsunami>>.internal(
  activeTsunami,
  name: r'activeTsunamiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTsunamiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTsunamiRef = AutoDisposeStreamProviderRef<List<TrendTsunami>>;
String _$crestTagHash() => r'0af361f59bc56fbab2c55d579875b53b2bed8516';

/// Provider for just the Crest tag (rank 1, 2.5x multiplier)
///
/// Copied from [crestTag].
@ProviderFor(crestTag)
final crestTagProvider =
    AutoDisposeProvider<AsyncValue<TrendTsunami?>>.internal(
  crestTag,
  name: r'crestTagProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$crestTagHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CrestTagRef = AutoDisposeProviderRef<AsyncValue<TrendTsunami?>>;
String _$surgeTagsHash() => r'f8f7bccfc98438896cdc229e9fc96f9cfeaf15c5';

/// Provider for Surge tags (rank 2-3, 1.5x multiplier)
///
/// Copied from [surgeTags].
@ProviderFor(surgeTags)
final surgeTagsProvider =
    AutoDisposeProvider<AsyncValue<List<TrendTsunami>>>.internal(
  surgeTags,
  name: r'surgeTagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$surgeTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SurgeTagsRef = AutoDisposeProviderRef<AsyncValue<List<TrendTsunami>>>;
String _$tsunamiMultiplierHash() => r'a537d72b66b66839a5a32dc6db50088ce6243377';

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

/// Provider that calculates the tsunami multiplier for a specific design's tags
///
/// Usage:
/// ```dart
/// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
/// // Returns 2.5 if 'minimalist' is the Crest tag
/// // Returns 1.5 if 'ivory' is a Surge tag
/// // Returns 1.0 if no match
/// ```
///
/// Copied from [tsunamiMultiplier].
@ProviderFor(tsunamiMultiplier)
const tsunamiMultiplierProvider = TsunamiMultiplierFamily();

/// Provider that calculates the tsunami multiplier for a specific design's tags
///
/// Usage:
/// ```dart
/// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
/// // Returns 2.5 if 'minimalist' is the Crest tag
/// // Returns 1.5 if 'ivory' is a Surge tag
/// // Returns 1.0 if no match
/// ```
///
/// Copied from [tsunamiMultiplier].
class TsunamiMultiplierFamily extends Family<double> {
  /// Provider that calculates the tsunami multiplier for a specific design's tags
  ///
  /// Usage:
  /// ```dart
  /// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
  /// // Returns 2.5 if 'minimalist' is the Crest tag
  /// // Returns 1.5 if 'ivory' is a Surge tag
  /// // Returns 1.0 if no match
  /// ```
  ///
  /// Copied from [tsunamiMultiplier].
  const TsunamiMultiplierFamily();

  /// Provider that calculates the tsunami multiplier for a specific design's tags
  ///
  /// Usage:
  /// ```dart
  /// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
  /// // Returns 2.5 if 'minimalist' is the Crest tag
  /// // Returns 1.5 if 'ivory' is a Surge tag
  /// // Returns 1.0 if no match
  /// ```
  ///
  /// Copied from [tsunamiMultiplier].
  TsunamiMultiplierProvider call(
    List<String> designTags,
  ) {
    return TsunamiMultiplierProvider(
      designTags,
    );
  }

  @override
  TsunamiMultiplierProvider getProviderOverride(
    covariant TsunamiMultiplierProvider provider,
  ) {
    return call(
      provider.designTags,
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
  String? get name => r'tsunamiMultiplierProvider';
}

/// Provider that calculates the tsunami multiplier for a specific design's tags
///
/// Usage:
/// ```dart
/// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
/// // Returns 2.5 if 'minimalist' is the Crest tag
/// // Returns 1.5 if 'ivory' is a Surge tag
/// // Returns 1.0 if no match
/// ```
///
/// Copied from [tsunamiMultiplier].
class TsunamiMultiplierProvider extends AutoDisposeProvider<double> {
  /// Provider that calculates the tsunami multiplier for a specific design's tags
  ///
  /// Usage:
  /// ```dart
  /// final multiplier = ref.watch(tsunamiMultiplierProvider(['minimalist', 'ivory']));
  /// // Returns 2.5 if 'minimalist' is the Crest tag
  /// // Returns 1.5 if 'ivory' is a Surge tag
  /// // Returns 1.0 if no match
  /// ```
  ///
  /// Copied from [tsunamiMultiplier].
  TsunamiMultiplierProvider(
    List<String> designTags,
  ) : this._internal(
          (ref) => tsunamiMultiplier(
            ref as TsunamiMultiplierRef,
            designTags,
          ),
          from: tsunamiMultiplierProvider,
          name: r'tsunamiMultiplierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tsunamiMultiplierHash,
          dependencies: TsunamiMultiplierFamily._dependencies,
          allTransitiveDependencies:
              TsunamiMultiplierFamily._allTransitiveDependencies,
          designTags: designTags,
        );

  TsunamiMultiplierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.designTags,
  }) : super.internal();

  final List<String> designTags;

  @override
  Override overrideWith(
    double Function(TsunamiMultiplierRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TsunamiMultiplierProvider._internal(
        (ref) => create(ref as TsunamiMultiplierRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        designTags: designTags,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _TsunamiMultiplierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TsunamiMultiplierProvider && other.designTags == designTags;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, designTags.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TsunamiMultiplierRef on AutoDisposeProviderRef<double> {
  /// The parameter `designTags` of this provider.
  List<String> get designTags;
}

class _TsunamiMultiplierProviderElement
    extends AutoDisposeProviderElement<double> with TsunamiMultiplierRef {
  _TsunamiMultiplierProviderElement(super.provider);

  @override
  List<String> get designTags =>
      (origin as TsunamiMultiplierProvider).designTags;
}

String _$isTagInTsunamiHash() => r'7ca3fcd1b7c945a888b0f6ee535dbe46d7a41fbe';

/// Provider for checking if a specific tag is part of the active tsunami
///
/// Copied from [isTagInTsunami].
@ProviderFor(isTagInTsunami)
const isTagInTsunamiProvider = IsTagInTsunamiFamily();

/// Provider for checking if a specific tag is part of the active tsunami
///
/// Copied from [isTagInTsunami].
class IsTagInTsunamiFamily extends Family<bool> {
  /// Provider for checking if a specific tag is part of the active tsunami
  ///
  /// Copied from [isTagInTsunami].
  const IsTagInTsunamiFamily();

  /// Provider for checking if a specific tag is part of the active tsunami
  ///
  /// Copied from [isTagInTsunami].
  IsTagInTsunamiProvider call(
    String tag,
  ) {
    return IsTagInTsunamiProvider(
      tag,
    );
  }

  @override
  IsTagInTsunamiProvider getProviderOverride(
    covariant IsTagInTsunamiProvider provider,
  ) {
    return call(
      provider.tag,
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
  String? get name => r'isTagInTsunamiProvider';
}

/// Provider for checking if a specific tag is part of the active tsunami
///
/// Copied from [isTagInTsunami].
class IsTagInTsunamiProvider extends AutoDisposeProvider<bool> {
  /// Provider for checking if a specific tag is part of the active tsunami
  ///
  /// Copied from [isTagInTsunami].
  IsTagInTsunamiProvider(
    String tag,
  ) : this._internal(
          (ref) => isTagInTsunami(
            ref as IsTagInTsunamiRef,
            tag,
          ),
          from: isTagInTsunamiProvider,
          name: r'isTagInTsunamiProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isTagInTsunamiHash,
          dependencies: IsTagInTsunamiFamily._dependencies,
          allTransitiveDependencies:
              IsTagInTsunamiFamily._allTransitiveDependencies,
          tag: tag,
        );

  IsTagInTsunamiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tag,
  }) : super.internal();

  final String tag;

  @override
  Override overrideWith(
    bool Function(IsTagInTsunamiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsTagInTsunamiProvider._internal(
        (ref) => create(ref as IsTagInTsunamiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tag: tag,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsTagInTsunamiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsTagInTsunamiProvider && other.tag == tag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsTagInTsunamiRef on AutoDisposeProviderRef<bool> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _IsTagInTsunamiProviderElement extends AutoDisposeProviderElement<bool>
    with IsTagInTsunamiRef {
  _IsTagInTsunamiProviderElement(super.provider);

  @override
  String get tag => (origin as IsTagInTsunamiProvider).tag;
}

String _$matchingTsunamiForTagHash() =>
    r'c8a77bf483eaea0113a31a313c2ec3e7e8f95fac';

/// Provider for getting the matching tsunami details for a specific tag
///
/// Copied from [matchingTsunamiForTag].
@ProviderFor(matchingTsunamiForTag)
const matchingTsunamiForTagProvider = MatchingTsunamiForTagFamily();

/// Provider for getting the matching tsunami details for a specific tag
///
/// Copied from [matchingTsunamiForTag].
class MatchingTsunamiForTagFamily extends Family<TrendTsunami?> {
  /// Provider for getting the matching tsunami details for a specific tag
  ///
  /// Copied from [matchingTsunamiForTag].
  const MatchingTsunamiForTagFamily();

  /// Provider for getting the matching tsunami details for a specific tag
  ///
  /// Copied from [matchingTsunamiForTag].
  MatchingTsunamiForTagProvider call(
    String tag,
  ) {
    return MatchingTsunamiForTagProvider(
      tag,
    );
  }

  @override
  MatchingTsunamiForTagProvider getProviderOverride(
    covariant MatchingTsunamiForTagProvider provider,
  ) {
    return call(
      provider.tag,
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
  String? get name => r'matchingTsunamiForTagProvider';
}

/// Provider for getting the matching tsunami details for a specific tag
///
/// Copied from [matchingTsunamiForTag].
class MatchingTsunamiForTagProvider extends AutoDisposeProvider<TrendTsunami?> {
  /// Provider for getting the matching tsunami details for a specific tag
  ///
  /// Copied from [matchingTsunamiForTag].
  MatchingTsunamiForTagProvider(
    String tag,
  ) : this._internal(
          (ref) => matchingTsunamiForTag(
            ref as MatchingTsunamiForTagRef,
            tag,
          ),
          from: matchingTsunamiForTagProvider,
          name: r'matchingTsunamiForTagProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchingTsunamiForTagHash,
          dependencies: MatchingTsunamiForTagFamily._dependencies,
          allTransitiveDependencies:
              MatchingTsunamiForTagFamily._allTransitiveDependencies,
          tag: tag,
        );

  MatchingTsunamiForTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tag,
  }) : super.internal();

  final String tag;

  @override
  Override overrideWith(
    TrendTsunami? Function(MatchingTsunamiForTagRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchingTsunamiForTagProvider._internal(
        (ref) => create(ref as MatchingTsunamiForTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tag: tag,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<TrendTsunami?> createElement() {
    return _MatchingTsunamiForTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchingTsunamiForTagProvider && other.tag == tag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchingTsunamiForTagRef on AutoDisposeProviderRef<TrendTsunami?> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _MatchingTsunamiForTagProviderElement
    extends AutoDisposeProviderElement<TrendTsunami?>
    with MatchingTsunamiForTagRef {
  _MatchingTsunamiForTagProviderElement(super.provider);

  @override
  String get tag => (origin as MatchingTsunamiForTagProvider).tag;
}

String _$timeUntilNextTsunamiHash() =>
    r'454ab06ab678d51d8a6ece61d75fddc6c20275d8';

/// Provider for the time remaining until the current tsunami expires
/// Returns the shortest time remaining (closest to expiration)
///
/// Copied from [timeUntilNextTsunami].
@ProviderFor(timeUntilNextTsunami)
final timeUntilNextTsunamiProvider = AutoDisposeProvider<Duration>.internal(
  timeUntilNextTsunami,
  name: r'timeUntilNextTsunamiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeUntilNextTsunamiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeUntilNextTsunamiRef = AutoDisposeProviderRef<Duration>;
String _$timeUntilNextTsunamiFormattedHash() =>
    r'c0bb9389b2c9c54d9546e12a1f5cc270e01e848e';

/// Provider for formatted time remaining string (HH:MM:SS)
///
/// Copied from [timeUntilNextTsunamiFormatted].
@ProviderFor(timeUntilNextTsunamiFormatted)
final timeUntilNextTsunamiFormattedProvider =
    AutoDisposeProvider<String>.internal(
  timeUntilNextTsunamiFormatted,
  name: r'timeUntilNextTsunamiFormattedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeUntilNextTsunamiFormattedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeUntilNextTsunamiFormattedRef = AutoDisposeProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
