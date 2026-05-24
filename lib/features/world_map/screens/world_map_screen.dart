// GDD §4 (map section) — 2.5D globe: city nodes, customer flow, heatmap

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(
        child: Text(
          'World Map is unavailable in this alpha build.',
          style: TextStyle(color: AppColors.ivory),
        ),
      ),
    );
  }
}
