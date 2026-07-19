// Directive 26 — Functional Talent Casting quarantine

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../models/talent.dart';
import '../providers/casting_provider.dart';

/// Keeps the Casting route navigable while the noncompliant functional Talent
/// acquisition loop is unavailable. Historical roster data remains read-only.
class CastingRoomScreen extends ConsumerWidget {
  const CastingRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CastingState castingState = ref.watch(castingProvider);
    final AsyncValue<List<RosterTalent>> roster =
        ref.watch(playerRosterProvider);

    return Scaffold(
      backgroundColor: AurelianPalette.ivory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            _CastingHeader(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 32.0),
            if (castingState.isUnavailable)
              Semantics(
                container: true,
                liveRegion: true,
                label: kCastingUnavailableMessage,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AurelianPalette.alabaster,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: AurelianPalette.champagneGoldDark,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AurelianPalette.textPrimary.withValues(
                          alpha: 0.08,
                        ),
                        blurRadius: 24.0,
                        offset: const Offset(0.0, 12.0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.lock_clock_outlined,
                        size: 48.0,
                        color: AurelianPalette.champagneGoldDark,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'CASTING TEMPORARILY UNAVAILABLE',
                        textAlign: TextAlign.center,
                        style: AurelianTypography.titleMedium,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        castingState.message,
                        textAlign: TextAlign.center,
                        style: AurelianTypography.bodyMedium,
                      ),
                      const SizedBox(height: 20.0),
                      const SizedBox(
                        width: double.infinity,
                        child: GoldPrimaryButton(
                          label: 'CASTING UNAVAILABLE',
                          onPressed: null,
                          disabledReason:
                              'Talent acquisition is temporarily unavailable.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32.0),
            Text('OWNED TALENT', style: AurelianTypography.titleMedium),
            const SizedBox(height: 8.0),
            Text(
              'Your historical roster remains available while new acquisition '
              'is paused.',
              style: AurelianTypography.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            roster.when(
              data: (List<RosterTalent> talent) {
                if (talent.isEmpty) {
                  return const _RosterMessage(
                    icon: Icons.badge_outlined,
                    message: 'NO OWNED TALENT TO DISPLAY',
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final RosterTalent ownedTalent in talent)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _OwnedTalentCard(talent: ownedTalent),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AurelianPalette.champagneGoldDark,
                ),
              ),
              error: (Object error, StackTrace stackTrace) =>
                  const _RosterMessage(
                icon: Icons.cloud_off_outlined,
                message: 'OWNED TALENT UNAVAILABLE',
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: IvorySecondaryButton(
                label: 'RETURN',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CastingHeader extends StatelessWidget {
  const _CastingHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconCircleButton(
          icon: Icons.arrow_back,
          tooltip: 'Return to the previous screen',
          onPressed: onBack,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('THE CASTING ROOM', style: AurelianTypography.titleLarge),
              const SizedBox(height: 4.0),
              Text(
                'HISTORICAL ROSTER',
                style: AurelianTypography.labelLarge.copyWith(
                  color: AurelianPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwnedTalentCard extends StatelessWidget {
  const _OwnedTalentCard({required this.talent});

  final RosterTalent talent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: talent.tier.tierColor),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: talent.tier.tierColor.withValues(alpha: 0.18),
            foregroundColor: AurelianPalette.textPrimary,
            child: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(talent.name, style: AurelianTypography.titleMedium),
                const SizedBox(height: 2.0),
                Text(
                  talent.tier.displayName.toUpperCase(),
                  style: AurelianTypography.labelLarge.copyWith(
                    color: talent.tier.tierColor,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_outline,
            color: AurelianPalette.textTertiary,
            semanticLabel: 'Historically owned Talent',
          ),
        ],
      ),
    );
  }
}

class _RosterMessage extends StatelessWidget {
  const _RosterMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivoryDark,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AurelianPalette.textSecondary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(message, style: AurelianTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}
