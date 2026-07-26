import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/player.dart';
import '../../features/ftue/providers/first_objective_provider.dart';
import '../../features/hq/providers/hq_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell(
      {required this.navigationShell, required this.player, super.key});

  final StatefulNavigationShell navigationShell;
  final Player? player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CareerPath? path = ref.watch(careerPathProvider) ?? player?.path;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        hqIcon: path == CareerPath.designer
            ? Icons.palette_outlined
            : Icons.dashboard_outlined,
        onTap: (int index) {
          if (index == 0) {
            ref.read(firstObjectiveActionsProvider.notifier).markReturnedToHq();
          }
          navigationShell.goBranch(index,
              initialLocation: index == navigationShell.currentIndex);
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar(
      {required this.currentIndex, required this.hqIcon, required this.onTap});

  final int currentIndex;
  final IconData hqIcon;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>[
      'HQ',
      'ATELIER',
      'EMPIRE',
      'FEED',
      'HOUSE'
    ];
    final List<IconData> icons = <IconData>[
      hqIcon,
      Icons.checkroom_outlined,
      Icons.storefront_outlined,
      Icons.public_outlined,
      Icons.home_outlined,
    ];
    return Container(
      color: AppColors.obsidianSurface,
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool selected = currentIndex == index;
            final Color color = selected ? AppColors.gold : AppColors.grey600;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: labels[index],
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(icons[index], color: color, size: 20),
                          const SizedBox(height: 3),
                          Text(labels[index],
                              style: TextStyle(
                                  color: color,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700)),
                        ]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
