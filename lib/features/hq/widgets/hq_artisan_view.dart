import 'package:flutter/material.dart';

import '../../../core/theme/styliste_visual_mode.dart';
import '../../../domain/models/player.dart';
import 'hq_foundation_view.dart';

class HqArtisanView extends StatelessWidget {
  const HqArtisanView({required this.player, super.key});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return HqFoundationView(
      player: player,
      mode: StylisteVisualMode.editorialLight,
      lens: 'Artisan',
      lensDetail:
          'Lead with authorship: silhouette, material, construction, and the emotional clarity of the garment.',
    );
  }
}
