import 'package:flutter/material.dart';

import '../theme/styliste_spacing.dart';
import '../theme/styliste_visual_mode.dart';

class StylisteScaffold extends StatelessWidget {
  const StylisteScaffold({
    required this.mode,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    super.key,
  });

  final StylisteVisualMode mode;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final Widget content = ColoredBox(
      color: mode.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: StylisteSpacing.safeMargin,
        ),
        child: body,
      ),
    );

    return Scaffold(
      backgroundColor: mode.background,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}
