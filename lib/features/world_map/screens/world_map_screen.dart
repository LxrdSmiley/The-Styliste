// GDD §4 (map section) — 2.5D globe: city nodes, customer flow, heatmap
// Phase 4 Feature — 2.5D globe view with city nodes, customer flow, and heatmap

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('World Map — Coming in Phase 4', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
