// GDD §4.4 - AR Garment Try-On.
// Real body tracking is disabled for the alpha build.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ArTryOnScreen extends StatelessWidget {
  const ArTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.ivory),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.view_in_ar_outlined,
                  color: AppColors.gold.withValues(alpha: 0.7),
                  size: 48.0,
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'AR TRY-ON UNAVAILABLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.ivory,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'This build keeps camera-based try-on disabled until native body tracking and real design binding are production-ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.ivory.withValues(alpha: 0.5),
                    fontSize: 11.0,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
