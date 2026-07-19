import 'package:flutter/material.dart';

import '../../../core/theme/aurelian_theme.dart';

/// Temporary safe state while mini-game outcomes lack server-verifiable proof.
class MiniGameRewardsUnavailableScreen extends StatelessWidget {
  const MiniGameRewardsUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Semantics(
              container: true,
              liveRegion: true,
              label: 'Mini-game rewards are temporarily unavailable.',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AurelianPalette.champagneGold,
                    size: 44.0,
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'REWARDS PAUSED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AurelianPalette.ivory,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'This activity is temporarily unavailable while result '
                    'verification is being strengthened. No currency, '
                    'progression, or inventory changes are being made.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AurelianPalette.textSecondary,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 15.0,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AurelianPalette.champagneGold,
                        foregroundColor: AurelianPalette.textPrimary,
                        minimumSize: const Size.fromHeight(52.0),
                      ),
                      child: const Text(
                        'RETURN',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
