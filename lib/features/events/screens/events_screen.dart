// GDD §7.2–7.4 — Fashion Week, seasonal events, holiday events
// Phase 4 Feature — Fashion Week, seasonal events, holiday events

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(child: Text('Events — Coming in Phase 4', style: TextStyle(color: AppColors.ivory))),
    );
  }
}
