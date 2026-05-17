// GDD §8.13 — Brand Story Archive + Founder profile
// Phase 4 Feature — Brand Story Archive + Founder profile with Brand Rank history and achievement badges

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Profile — Coming in Phase 4', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
