// GDD §4.4 - AR Garment Try-On.
// Real body tracking is disabled for the alpha build.

import 'package:flutter/material.dart';

import '../../../core/widgets/locked_feature_preview.dart';

class ArTryOnScreen extends StatelessWidget {
  const ArTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LockedFeaturePreview(
      icon: Icons.view_in_ar_outlined,
      eyebrow: 'AR Garment Try-On',
      title: 'Step Inside The Look',
      description:
          'Camera-based try-on will arrive only when body tracking and '
          'player-owned design binding meet the production standard.',
      highlights: <String>[
        'Real garment ownership—not a generic camera filter',
        'Privacy-aware body tracking and explicit camera consent',
        'Share-ready looks without fabricating game rewards',
      ],
    );
  }
}
