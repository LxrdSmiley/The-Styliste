import 'package:flutter/material.dart';

import '../theme/aurelian_theme.dart';

class LockedFeaturePreview extends StatelessWidget {
  const LockedFeaturePreview({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.highlights,
    super.key,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
              )
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 40.0),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AurelianPalette.alabaster,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: AurelianPalette.champagneGoldDark.withValues(
                    alpha: 0.55,
                  ),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AurelianPalette.champagneGoldDark.withValues(
                      alpha: 0.12,
                    ),
                    blurRadius: 28.0,
                    offset: const Offset(0.0, 16.0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 54.0,
                        height: 54.0,
                        decoration: BoxDecoration(
                          color: AurelianPalette.champagneGold.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Icon(
                          icon,
                          color: AurelianPalette.textPrimary,
                          size: 28.0,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: AurelianPalette.textPrimary,
                          borderRadius: BorderRadius.circular(999.0),
                        ),
                        child: const Text(
                          'LATER BUILD',
                          style: TextStyle(
                            color: AurelianPalette.ivory,
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: AurelianPalette.champagneGoldDark,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.6,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AurelianPalette.textPrimary,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AurelianPalette.textSecondary,
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 14.0,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  for (final String highlight in highlights)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.auto_awesome,
                              color: AurelianPalette.champagneGoldDark,
                              size: 15.0,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              highlight,
                              style: const TextStyle(
                                color: AurelianPalette.textSecondary,
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 13.0,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'This preview is intentionally locked. No progress, currency, or '
              'player action is simulated here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AurelianPalette.textTertiary,
                fontFamily: 'SpaceGrotesk',
                fontSize: 11.0,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
