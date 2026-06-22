// GDD §7.2–7.4 — Fashion Week, seasonal events, holiday events

import 'package:flutter/material.dart';

import '../../../core/widgets/locked_feature_preview.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LockedFeaturePreview(
      icon: Icons.calendar_month_outlined,
      eyebrow: 'The Aurelian Calendar',
      title: 'The Next Front Row Is Forming',
      description:
          'Fashion Weeks, seasonal windows, and community tournaments will '
          'turn the live calendar into a rotating prestige circuit.',
      highlights: <String>[
        'Timed themes and global submission windows',
        'Maison participation and community voting',
        'Prestige rewards that remain earned—not simulated',
      ],
    );
  }
}
