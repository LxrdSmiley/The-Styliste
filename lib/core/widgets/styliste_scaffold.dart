import 'package:flutter/material.dart';

import '../theme/aurelian_theme.dart';
import '../theme/styliste_spacing.dart';
import '../theme/styliste_visual_mode.dart';

/// Canonical portrait-first shell for reachable Gate A surfaces.
class AurelianScaffold extends StatelessWidget {
  const AurelianScaffold({
    required this.mode,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    this.applyHorizontalInset = true,
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final StylisteVisualMode mode;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;
  final bool applyHorizontalInset;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AurelianTheme.forMode(mode),
      child: Builder(
        builder: (BuildContext themedContext) {
          Widget content = ColoredBox(
            color: mode.background,
            child: body,
          );
          if (applyHorizontalInset) {
            final Widget insetChild = content;
            content = LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: StylisteSpacing.pageInset(
                      constraints.maxWidth,
                    ),
                  ),
                  child: insetChild,
                );
              },
            );
          }
          if (useSafeArea) content = SafeArea(child: content);

          return Scaffold(
            backgroundColor: mode.background,
            appBar: appBar,
            body: content,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          );
        },
      ),
    );
  }
}

/// Compatibility wrapper for inherited Wave 0–2A widgets.
@Deprecated('Use AurelianScaffold for reachable player-facing UI.')
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
    return AurelianScaffold(
      mode: mode,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      useSafeArea: useSafeArea,
    );
  }
}
