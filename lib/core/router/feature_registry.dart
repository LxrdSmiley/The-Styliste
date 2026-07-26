import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Server-delivered feature configuration is reduced to this compile-safe
/// interface. A disabled feature has no route implementation in the Early Game
/// client and is therefore unavailable before any data provider can start.
enum AppFeature { hq, atelier, empire, feed, house }

class FeatureRegistry {
  const FeatureRegistry(this.enabled);

  final Set<AppFeature> enabled;

  static const FeatureRegistry earlyGame = FeatureRegistry(<AppFeature>{
    AppFeature.hq,
    AppFeature.atelier,
    AppFeature.empire,
    AppFeature.feed,
    AppFeature.house,
  });

  bool isEnabled(AppFeature feature) => enabled.contains(feature);
}

final StateProvider<FeatureRegistry> featureRegistryProvider =
    StateProvider<FeatureRegistry>((Ref<FeatureRegistry> ref) {
  return FeatureRegistry.earlyGame;
});
