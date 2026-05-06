// GDD §3.0 + §6.1 + §6.3 — Main navigation shell (Phase 6 + 7).
// StatefulShellRoute host: HQ (tab 0) | Global Feed (tab 1) | Maison (tab 2).
// Uses StatefulNavigationShell from go_router — keeps branch widget trees
// alive on tab switch (no stream re-subscription, no auth re-trigger).
// Atelier / Ledger remain pushed routes over the shell, not tabs.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/player.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    required this.player,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final Player? player;

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;
    final CareerPath? path = player?.path;

    // Override HQ icon/label based on player path when available.
    final IconData hqIcon = path == CareerPath.designer
        ? Icons.palette_outlined
        : Icons.bar_chart_outlined;
    final String hqLabel = path == CareerPath.designer ? 'ATELIER' : 'LEDGER';

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: currentIndex,
        hqIcon: hqIcon,
        hqLabel: hqLabel,
        onTap: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating obsidian nav bar — Gold/Lime selected accent.
// ---------------------------------------------------------------------------
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.hqIcon,
    required this.hqLabel,
    required this.onTap,
  });

  final int currentIndex;
  final IconData hqIcon;
  final String hqLabel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidianSurface,
        border: Border(
          top: BorderSide(color: AppColors.grey800),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            _NavTab(
              icon: hqIcon,
              label: hqLabel,
              selected: currentIndex == 0,
              selectedColor: AppColors.gold,
              onTap: () => onTap(0),
            ),
            _NavTab(
              icon: Icons.public_outlined,
              label: 'FEED',
              selected: currentIndex == 1,
              selectedColor: AppColors.lime,
              onTap: () => onTap(1),
            ),
            _NavTab(
              icon: Icons.group_outlined,
              label: 'MAISON',
              selected: currentIndex == 2,
              selectedColor: AppColors.ivory,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? selectedColor : AppColors.grey600;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color, size: 20.0),
              const SizedBox(height: 3.0),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 8.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2.0),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 16.0 : 0.0,
                height: 2.0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
