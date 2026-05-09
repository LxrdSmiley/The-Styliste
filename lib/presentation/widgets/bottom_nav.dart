// GDD §3.0 — Bottom nav tabs: HQ | Feed | Maison | Bank
// Directive O: Wired to go_router with AurelianPalette
// HQ tab routes to /hq (shell handles Designer/Mogul switching)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/aurelian_theme.dart';

/// BottomNav — Main navigation shell tabs
/// Uses context.go() for go_router navigation
class BottomNav extends StatelessWidget {
  const BottomNav({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.hq);
      case 1:
        context.go(AppRouter.feed);
      case 2:
        context.go(AppRouter.maison);
      case 3:
        context.go(AppRouter.bank);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (int index) => _onItemTapped(context, index),
      backgroundColor: AurelianPalette.ivory,
      selectedItemColor: AurelianPalette.champagneGold,
      unselectedItemColor: AurelianPalette.textTertiary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 11,
      ),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'HQ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public_outlined),
          activeIcon: Icon(Icons.public),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_outlined),
          activeIcon: Icon(Icons.business),
          label: 'Maison',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_outlined),
          activeIcon: Icon(Icons.account_balance),
          label: 'Bank',
        ),
      ],
    );
  }
}
