// GDD §8.13 — Brand Story Archive + Founder profile
// TODO: Implement in Phase 4

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Profile — Phase 4', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
