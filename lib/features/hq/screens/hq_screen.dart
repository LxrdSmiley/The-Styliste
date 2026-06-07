// GDD §3.0 — Main HQ Dashboard gateway
// Fetches player profile via hqPlayerStreamProvider, then routes to the
// correct path-specific view based on CareerPath committed in Phase 1b.
// Obsidian loading state while player profile is fetching (no UI flash).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/player.dart';
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Player> playerAsync = ref.watch(hqPlayerStreamProvider);

    return playerAsync.when(
      // --- Obsidian loading gate (directive §3 — pure black, no flash) ---
      loading: () => const Scaffold(
        backgroundColor: AppColors.obsidian,
        body: SizedBox.expand(),
      ),

      // --- Error state ---
      error: (Object e, _) => Scaffold(
        backgroundColor: AppColors.obsidian,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _profileErrorMessage(e),
              style: const TextStyle(color: AppColors.danger, fontSize: 12.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),

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
  return SupabaseService.playerSafeErrorMessage(
    error,
    fallback: 'Profile unavailable. Please try again.',
  );
}
