// GDD §6.x — Player reporting modal: 3-tap flow, pre-filled categories
// TODO: Implement full modal with screenshot attachment in Phase 4

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReportModal extends StatelessWidget {
  const ReportModal({required this.reportedPlayerId, super.key});

  final String reportedPlayerId;

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.obsidianCard,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          Text(
            'Report Player',
            style: TextStyle(color: AppColors.ivory, fontSize: 18.0, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.0),
          // TODO: Phase 4 — category selector, description field, screenshot
          Text(
            'Thank you, darling. We\'ll look into this.',
            style: TextStyle(color: AppColors.gold, fontStyle: FontStyle.italic),
          ),
        ],
        ),
      ),
    );
  }
}
