// GDD §5.7 — Staff Rally mini-game (tap-rhythm morale builder, Luxe dialogue)
// TODO: Implement in Phase 3
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
class StaffRallyScreen extends StatelessWidget {
  const StaffRallyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: AppColors.obsidian, body: Center(child: Text('Staff Rally — Phase 3', style: TextStyle(color: AppColors.ivory))));
  }
}
