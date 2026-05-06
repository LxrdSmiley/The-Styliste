// GDD §1.1 Screen 6 — Career Path Divergence
// Split-card: Artisan (gold) vs Architect (lime). Permanent choice.
// Heavy haptics on selection. Confirmation modal before state commitment.
// On confirm: createPlayerProfile writes players + brand_state to Supabase.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/mock_auth_provider.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/supabase_player_repository.dart';
import '../../../domain/models/player.dart';

class CareerPathScreen extends ConsumerStatefulWidget {
  const CareerPathScreen({super.key});

  @override
  ConsumerState<CareerPathScreen> createState() => _CareerPathScreenState();
}

class _CareerPathScreenState extends ConsumerState<CareerPathScreen> {
  // Path hovered/pressed for visual feedback before confirmation.
  CareerPath? _pendingSelection;

  void _onPathTapped(CareerPath path) {
    HapticFeedback.heavyImpact();
    setState(() => _pendingSelection = path);
    _showConfirmationModal(path);
  }

  Future<void> _showConfirmationModal(CareerPath path) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => _ConfirmModal(path: path),
    );

    if (!mounted) return;

    if (confirmed ?? false) {
      unawaited(_commitProfile(path));
    } else {
      setState(() => _pendingSelection = null);
    }
  }

  Future<void> _commitProfile(CareerPath path) async {
    final OnboardingNotifier notifier =
        ref.read(onboardingProvider.notifier);
    notifier.setPath(path);

    // Default HQ city to New York if not set (Brand Selection is Phase 1c).
    final OnboardingState state = ref.read(onboardingProvider);
    final HqCity city = state.selectedCity ?? HqCity.newYork;
    notifier.setCity(city);
    notifier.setCommitting(value: true);

    final String uid = ref.read(activeUidProvider);

    try {
      await const SupabasePlayerRepository().createPlayerProfile(
        uid: uid,
        brandName: state.brandName,
        path: path,
        hqCity: city,
      );
      notifier.setCommitting(value: false);

      if (!mounted) return;
      unawaited(HapticFeedback.heavyImpact());
      context.go(AppRouter.hq);
    } catch (e) {
      notifier.setCommitError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCommitting = ref.watch(
      onboardingProvider.select((OnboardingState s) => s.isCommitting),
    );
    final String? commitError = ref.watch(
      onboardingProvider.select((OnboardingState s) => s.commitError),
    );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(height: 48.0),

                // --- Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: const Text(
                    'CHOOSE YOUR\nPATH.',
                    style: TextStyle(
                      color: AppColors.ivory,
                      fontSize: 36.0,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: 2.0,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .slideY(begin: 0.08, curve: Curves.easeOut),
                ),

                const SizedBox(height: 8.0),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: const Text(
                    'This choice is permanent.',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 13.0,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 400),
                      ),
                ),

                const SizedBox(height: 36.0),

                // --- Split cards ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        // --- Artisan (Designer) card ---
                        Expanded(
                          child: _PathCard(
                            path: CareerPath.designer,
                            title: 'THE\nARTISAN',
                            subtitle: 'Designer Track',
                            description:
                                'Atelier. Hype. Cloth physics.\n'
                                'Build the look the world follows.',
                            accentColor: AppColors.gold,
                            icon: Icons.palette_outlined,
                            isSelected: _pendingSelection == CareerPath.designer,
                            onTap: isCommitting
                                ? null
                                : () => _onPathTapped(CareerPath.designer),
                          )
                              .animate()
                              .fadeIn(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 500),
                              )
                              .slideX(begin: -0.05, curve: Curves.easeOut),
                        ),

                        const SizedBox(width: 12.0),

                        // --- Architect (Mogul) card ---
                        Expanded(
                          child: _PathCard(
                            path: CareerPath.mogul,
                            title: 'THE\nARCHITECT',
                            subtitle: 'Mogul Track',
                            description:
                                'Ledger. Supply chains.\n'
                                'Build the empire behind the brand.',
                            accentColor: AppColors.lime,
                            icon: Icons.bar_chart_outlined,
                            isSelected: _pendingSelection == CareerPath.mogul,
                            onTap: isCommitting
                                ? null
                                : () => _onPathTapped(CareerPath.mogul),
                          )
                              .animate()
                              .fadeIn(
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 500),
                              )
                              .slideX(begin: 0.05, curve: Curves.easeOut),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Commit error ---
                if (commitError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 0.0, 28.0, 16.0),
                    child: Text(
                      'Error: $commitError',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12.0,
                      ),
                    ),
                  ),

                const SizedBox(height: 32.0),
              ],
            ),

            // --- Committing overlay ---
            if (isCommitting)
              const ColoredBox(
                color: Color(0xCC0A0A0A),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                    strokeWidth: 2.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Path card widget
// ---------------------------------------------------------------------------

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.path,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final CareerPath path;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : AppColors.obsidianCard,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.grey700,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: accentColor, size: 32.0),
              const SizedBox(height: 20.0),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.grey400,
                  fontSize: 11.0,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.ivoryMuted,
                  fontSize: 13.0,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmation modal
// ---------------------------------------------------------------------------

class _ConfirmModal extends StatelessWidget {
  const _ConfirmModal({required this.path});

  final CareerPath path;

  @override
  Widget build(BuildContext context) {
    final bool isDesigner = path == CareerPath.designer;
    final Color accentColor =
        isDesigner ? AppColors.gold : AppColors.lime;
    final String pathName =
        isDesigner ? 'The Artisan' : 'The Architect';

    return Dialog(
      backgroundColor: AppColors.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'THIS IS PERMANENT.',
              style: TextStyle(
                color: accentColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'You have chosen $pathName.\n\n'
              'This path shapes your entire empire. '
              'A change costs premium currency. '
              'Are you certain?',
              style: const TextStyle(
                color: AppColors.ivoryMuted,
                fontSize: 14.0,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey400,
                      side: const BorderSide(color: AppColors.grey700),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text('RECONSIDER'),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: AppColors.obsidian,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: const Text(
                      'COMMIT',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
