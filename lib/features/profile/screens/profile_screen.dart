// GDD §8.13 — Brand Story Archive + Founder profile

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(
        child: Text(
          'Profile and Brand Story Archive are unavailable in this alpha build.',
          style: TextStyle(color: AppColors.ivory),
        ),
      ),
    );
  }
}
