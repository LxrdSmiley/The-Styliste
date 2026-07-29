import 'package:flutter/material.dart';

import '../../../core/theme/styliste_visual_mode.dart';
import '../../../domain/models/player.dart';
import 'hq_foundation_view.dart';

class HqArchitectView extends StatelessWidget {
  const HqArchitectView({required this.player, super.key});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return HqFoundationView(
      player: player,
      mode: StylisteVisualMode.executiveObsidian,
      lens: 'Architect',
      lensDetail:
          'Lead with positioning: audience, run shape, operating trade-offs, and how the House enters the market.',
    );
  }
}
