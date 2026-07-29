import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/styliste_visual_mode.dart';
import '../widgets/aurelian_components.dart';
import '../widgets/styliste_scaffold.dart';

class FeatureUnavailableScreen extends StatelessWidget {
  const FeatureUnavailableScreen({
    this.title = 'Held for a later chapter',
    this.message =
        'This part of The Styliste is deliberately unavailable in the Gate A build.',
    this.returnLocation = '/hq',
    super.key,
  });

  final String title;
  final String message;
  final String returnLocation;

  @override
  Widget build(BuildContext context) {
    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      body: AurelianResponsiveBody(
        maxWidth: 520,
        child: AurelianStatePanel(
          kind: AurelianStateKind.unavailable,
          title: title,
          message: message,
          actionLabel: 'Return to the Early Game',
          onAction: () => context.go(returnLocation),
        ),
      ),
    );
  }
}
