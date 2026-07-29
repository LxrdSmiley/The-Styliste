// GDD v8 §§18.2–18.4 — stable, portrait-first Early Game navigation.
// StatefulShellRoute retains each destination tree while tabs are switched.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/styliste_visual_mode.dart';
import '../../core/widgets/aurelian_navigation.dart';
import '../../core/widgets/styliste_scaffold.dart';
import '../../features/ftue/providers/first_objective_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = navigationShell.currentIndex;

    return PopScope<void>(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: AurelianScaffold(
        mode: StylisteVisualMode.noirCinematic,
        applyHorizontalInset: false,
        useSafeArea: false,
        body: navigationShell,
        bottomNavigationBar: AurelianBottomNavigation(
          currentIndex: currentIndex,
          onDestinationSelected: (int index) {
            if (index == 0) {
              ref
                  .read(firstObjectiveActionsProvider.notifier)
                  .markReturnedToHq();
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
