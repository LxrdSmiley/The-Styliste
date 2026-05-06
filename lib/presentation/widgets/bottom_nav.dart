// GDD §3.0 — Bottom nav tabs: Atelier/Ledger | Feed | Maison | Bank
// Path-specific primary tab (Atelier for Designer, Ledger for Mogul)
// TODO: Wire go_router navigation in Phase 1

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/player.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    required this.currentIndex,
    required this.path,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final CareerPath path;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final String primaryLabel =
        path == CareerPath.designer ? 'Atelier' : 'Ledger';
    final IconData primaryIcon =
        path == CareerPath.designer ? Icons.palette : Icons.bar_chart;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.obsidianSurface,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.grey600,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(primaryIcon), label: primaryLabel),
        const BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Feed'),
        const BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Maison'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Bank',
        ),
      ],
    );
  }
}
