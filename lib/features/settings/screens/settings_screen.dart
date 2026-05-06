// GDD §3.6 — Settings: accessibility, legal, notifications, theme
// TODO: Implement in Phase 1

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Settings — Phase 1', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
