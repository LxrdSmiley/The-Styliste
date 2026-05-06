// GDD §8.12 — Luxe mentor: 2D animated fox, daily check-ins, quest prompts
// TODO: Implement animated character + dialogue system in Phase 1

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LuxeWidget extends StatelessWidget {
  const LuxeWidget({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.gold),
        ),
      ),
      child: Text(
        message ?? 'Every empire starts with a stitch, darling.',
        style: const TextStyle(color: AppColors.ivory, fontStyle: FontStyle.italic),
      ),
    );
  }
}
