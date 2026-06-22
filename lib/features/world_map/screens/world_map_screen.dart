// GDD §4 (map section) — 2.5D globe: city nodes, customer flow, heatmap

import 'package:flutter/material.dart';

import '../../../core/widgets/locked_feature_preview.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LockedFeaturePreview(
      icon: Icons.public,
      eyebrow: 'Global Expansion',
      title: 'The World Is Your Runway',
      description:
          'A radiant command map for opening cities, tracing customer flow, '
          'and seeing where your brand burns brightest.',
      highlights: <String>[
        'Champagne-gold city nodes and live market heat',
        'Trade routes, district control, and rival pressure',
        'Expansion decisions tied to real server-owned progress',
      ],
    );
  }
}
