// GDD §4 (map section) — 2.5D globe: city nodes, customer flow, heatmap
// TODO: Implement in Phase 2/3

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('World Map — Phase 2/3', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
