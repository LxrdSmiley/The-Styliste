import 'package:flutter/material.dart';

import '../theme/styliste_colors.dart';

class AurelianBottomNavigation extends StatelessWidget {
  const AurelianBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<String> labels = <String>[
    'HQ',
    'Atelier',
    'Empire',
    'Feed',
    'House',
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Primary navigation',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: StylisteColors.obsidian.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'HQ',
                tooltip: 'Open HQ',
              ),
              NavigationDestination(
                icon: Icon(Icons.design_services_outlined),
                selectedIcon: Icon(Icons.design_services),
                label: 'Atelier',
                tooltip: 'Open Atelier',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance),
                label: 'Empire',
                tooltip: 'Open Empire',
              ),
              NavigationDestination(
                icon: Icon(Icons.public_outlined),
                selectedIcon: Icon(Icons.public),
                label: 'Feed',
                tooltip: 'Open Feed',
              ),
              NavigationDestination(
                icon: Icon(Icons.house_outlined),
                selectedIcon: Icon(Icons.house),
                label: 'House',
                tooltip: 'Open House',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
