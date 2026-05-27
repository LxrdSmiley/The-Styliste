// GDD §3.0 — Main HQ Dashboard gateway
// Fetches player profile via hqPlayerStreamProvider, then routes to the
// correct path-specific view based on CareerPath committed in Phase 1b.
// Obsidian loading state while player profile is fetching (no UI flash).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/player.dart';
import '../providers/hq_provider.dart';
import '../widgets/hq_architect_view.dart';
import '../widgets/hq_artisan_view.dart';

class HqScreen extends ConsumerWidget {
  const HqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        return switch (player.path) {
          CareerPath.designer => HqArtisanView(player: player),
          CareerPath.mogul => HqArchitectView(player: player),
        };
      },
    );
  }
}

String _profileErrorMessage(Object error) {
  return SupabaseService.isRecoverableAuthError(error)
      ? SupabaseSessionExpiredException.safeMessage
      : 'Profile error: $error';
}
