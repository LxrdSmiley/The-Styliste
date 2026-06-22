// GDD §8.13 — Brand Story Archive + Founder profile

import 'package:flutter/material.dart';

import '../../../core/widgets/locked_feature_preview.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LockedFeaturePreview(
      icon: Icons.auto_stories_outlined,
      eyebrow: 'Brand Story Archive',
      title: 'Every Empire Leaves A Record',
      description:
          'Your founder profile will become the permanent editorial history '
          'of every Alpha, crisis, Gala win, and sovereign milestone.',
      highlights: <String>[
        'Iconic drops and provenance chapters',
        'Founder Rep, titles, badges, and Kintsugi history',
        'A public-facing legacy built from authoritative game events',
      ],
    );
  }
}
