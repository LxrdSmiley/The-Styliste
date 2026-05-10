// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ascension_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerStatuesHash() => r'9f3dabc24078b845c7f3dda89e0625823231c226';

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

/// Stream of player's memorialized statues
///
/// Copied from [playerStatues].
@ProviderFor(playerStatues)
const playerStatuesProvider = PlayerStatuesFamily();

/// Stream of player's memorialized statues
///
/// Copied from [playerStatues].
class PlayerStatuesFamily extends Family<AsyncValue<List<SovereignStatue>>> {
  /// Stream of player's memorialized statues
  ///
  /// Copied from [playerStatues].
  const PlayerStatuesFamily();

  /// Stream of player's memorialized statues
  ///
  /// Copied from [playerStatues].
  PlayerStatuesProvider call(
    String playerId,
  ) {
    return PlayerStatuesProvider(
      playerId,
    );
  }

  @override
  PlayerStatuesProvider getProviderOverride(
    covariant PlayerStatuesProvider provider,
  ) {
    return call(
      provider.playerId,
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
  String? get name => r'playerStatuesProvider';
}

/// Stream of player's memorialized statues
///
/// Copied from [playerStatues].
class PlayerStatuesProvider
    extends AutoDisposeStreamProvider<List<SovereignStatue>> {
  /// Stream of player's memorialized statues
  ///
  /// Copied from [playerStatues].
  PlayerStatuesProvider(
    String playerId,
  ) : this._internal(
          (ref) => playerStatues(
            ref as PlayerStatuesRef,
            playerId,
          ),
          from: playerStatuesProvider,
          name: r'playerStatuesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playerStatuesHash,
          dependencies: PlayerStatuesFamily._dependencies,
          allTransitiveDependencies:
              PlayerStatuesFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PlayerStatuesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final String playerId;

  @override
  Override overrideWith(
    Stream<List<SovereignStatue>> Function(PlayerStatuesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerStatuesProvider._internal(
        (ref) => create(ref as PlayerStatuesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SovereignStatue>> createElement() {
    return _PlayerStatuesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerStatuesProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayerStatuesRef on AutoDisposeStreamProviderRef<List<SovereignStatue>> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerStatuesProviderElement
    extends AutoDisposeStreamProviderElement<List<SovereignStatue>>
    with PlayerStatuesRef {
  _PlayerStatuesProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerStatuesProvider).playerId;
}

String _$hallOfSovereignsHash() => r'40c25b681f342a42b873e28cc5b3e87f62edfc0c';

/// Stream of all statues in Hall of Sovereigns (global gallery)
///
/// Copied from [hallOfSovereigns].
@ProviderFor(hallOfSovereigns)
final hallOfSovereignsProvider =
    AutoDisposeStreamProvider<List<SovereignStatue>>.internal(
  hallOfSovereigns,
  name: r'hallOfSovereignsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hallOfSovereignsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HallOfSovereignsRef
    = AutoDisposeStreamProviderRef<List<SovereignStatue>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
