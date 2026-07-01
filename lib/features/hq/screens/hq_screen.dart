// GDD §3.0 — Main HQ Dashboard gateway
// Fetches player profile via hqPlayerStreamProvider, then routes to the
// correct path-specific view based on CareerPath committed in Phase 1b.
// Obsidian loading state while player profile is fetching (no UI flash).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/gold_primary_button.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/player.dart';
import '../../../domain/repositories/player_repository.dart';
import '../../ftue/providers/first_objective_provider.dart';
import '../../ftue/widgets/luxe_first_objective_overlay.dart';
import '../providers/hq_provider.dart';
import '../widgets/hq_architect_view.dart';
import '../widgets/hq_artisan_view.dart';

final Set<String> _sessionLuxeOverlaySeen = <String>{};

class HqScreen extends ConsumerStatefulWidget {
  const HqScreen({super.key});

  @override
  ConsumerState<HqScreen> createState() => _HqScreenState();
}

class _HqScreenState extends ConsumerState<HqScreen> {
  String? _overlayCheckPlayerId;
  String? _lastScheduledHqEffectsPlayerId;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Player> playerAsync = ref.watch(hqPlayerStreamProvider);

    return playerAsync.when(
      // --- Obsidian loading gate (directive §3 — pure black, no flash) ---
      loading: () => const StylisteScaffold(
        mode: StylisteVisualMode.noirCinematic,
        body: SizedBox.expand(),
      ),

      // --- Error state ---
      error: (Object e, _) => _HqErrorView(error: e),

      // --- Path-specific view switch ---
      data: (Player player) {
        _scheduleHqEffects(player);
        return switch (player.path) {
          CareerPath.designer => HqArtisanView(player: player),
          CareerPath.mogul => HqArchitectView(player: player),
        };
      },
    );
  }

  void _scheduleHqEffects(Player player) {
    if (_lastScheduledHqEffectsPlayerId == player.id) return;
    _lastScheduledHqEffectsPlayerId = player.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(firstObjectiveActionsProvider.notifier).markReturnedToHq();
      unawaited(_maybeShowLuxeOverlay(player));
    });
  }

  Future<void> _maybeShowLuxeOverlay(Player player) async {
    if (!player.onboardingComplete) return;
    if (_sessionLuxeOverlaySeen.contains(player.id)) return;
    if (_overlayCheckPlayerId == player.id) return;

    _overlayCheckPlayerId = player.id;
    final String preferenceKey = 'ftue_luxe_overlay_seen_${player.id}';
    bool seenOnDevice = false;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      seenOnDevice = prefs.getBool(preferenceKey) ?? false;
      if (!seenOnDevice) {
        await prefs.setBool(preferenceKey, true);
      }
    } catch (_) {
      seenOnDevice = false;
    } finally {
      _overlayCheckPlayerId = null;
    }

    if (!mounted || seenOnDevice) {
      if (seenOnDevice) _sessionLuxeOverlaySeen.add(player.id);
      return;
    }

    _sessionLuxeOverlaySeen.add(player.id);
    await showLuxeFirstObjectiveOverlay(context: context, player: player);
  }
}

String _profileErrorMessage(Object error) {
  if (error is PlayerProfileMissingException) {
    return PlayerProfileMissingException.safeMessage;
  }
  return SupabaseService.playerSafeErrorMessage(
    error,
    fallback: 'Profile unavailable. Please try again.',
  );
}

class _HqErrorView extends ConsumerWidget {
  const _HqErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool missingProfile = error is PlayerProfileMissingException;
    final String message = _profileErrorMessage(error);

    return StylisteScaffold(
      mode: StylisteVisualMode.noirCinematic,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                missingProfile ? 'CREATE YOUR HOUSE' : 'CANNOT LOAD HQ',
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: AurelianPalette.champagneGold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 16.0,
                  color: AurelianPalette.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (!missingProfile)
                    OutlinedButton(
                      onPressed: () => SupabaseService.signOut(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AurelianPalette.textTertiary,
                        side: const BorderSide(
                          color: AurelianPalette.textTertiary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: const Text('SIGN OUT'),
                    ),
                  if (!missingProfile) const SizedBox(width: 16.0),
                  GoldPrimaryButton(
                    label: missingProfile ? 'Start Onboarding' : 'Retry',
                    onPressed: () {
                      if (missingProfile) {
                        context.go(AppRouter.onboardingAurelianGate);
                        return;
                      }
                      ref.invalidate(hqPlayerStreamProvider);
                      ref.invalidate(hqBrandStreamProvider);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
