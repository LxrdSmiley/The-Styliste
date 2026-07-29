// GDD v8 §§18–19 — fail-closed Supabase session gate and Aurelian shell.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/aurelian_theme.dart';
import 'core/theme/styliste_colors.dart';
import 'core/theme/styliste_spacing.dart';
import 'core/theme/styliste_typography.dart';
import 'core/theme/styliste_visual_mode.dart';
import 'core/widgets/aurelian_components.dart';
import 'core/widgets/styliste_scaffold.dart';

class TheStyliste extends ConsumerWidget {
  const TheStyliste({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Object?> sessionBootstrap =
        ref.watch(supabaseSessionBootstrapProvider);

    if (sessionBootstrap.isLoading) {
      return const AurelianSessionGate();
    }
    if (sessionBootstrap.hasError) {
      return AurelianSessionGate(
        errorMessage: _authErrorMessage(sessionBootstrap.error!),
        onRetry: () async {
          try {
            await ref.read(supabaseAuthActionsProvider).retrySession();
          } finally {
            ref.invalidate(supabaseSessionBootstrapProvider);
          }
        },
      );
    }

    return MaterialApp.router(
      title: 'The Styliste',
      debugShowCheckedModeBanner: false,
      theme: AurelianTheme.lightTheme,
      darkTheme: AurelianTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}

class AurelianSessionGate extends StatelessWidget {
  const AurelianSessionGate({
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final String? errorMessage;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final bool failed = errorMessage != null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AurelianTheme.darkTheme,
      home: AurelianScaffold(
        mode: StylisteVisualMode.noirCinematic,
        body: AurelianResponsiveBody(
          maxWidth: 480,
          child: failed
              ? AurelianStatePanel(
                  kind: AurelianStateKind.sessionExpired,
                  title: 'Your House is still secure',
                  message: errorMessage!,
                  authorityLabel:
                      'The secure game service must confirm your player identity.',
                  preservationLabel:
                      'No gameplay write or progression change was started.',
                  retrySafetyLabel:
                      'Retry restores or replaces the session without granting rewards.',
                  actionLabel: 'Retry secure session',
                  onAction:
                      onRetry == null ? null : () => unawaited(onRetry!()),
                )
              : const _SessionRestoring(),
        ),
      ),
    );
  }
}

class _SessionRestoring extends StatelessWidget {
  const _SessionRestoring();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Restoring your secure House session.',
      child: AurelianEditorialHero(
        dark: true,
        eyebrow: 'Secure House entry',
        title: 'Restoring your House',
        detail:
            'The session is resolved before any player-owned projection or gameplay intent can load.',
        visual: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: StylisteColors.champagneGold,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'S',
                style: StylisteText.displayEditorial.copyWith(
                  color: StylisteColors.champagneGold,
                ),
              ),
            ),
            const SizedBox(width: StylisteSpacing.md),
            const Expanded(
              child: LinearProgressIndicator(
                minHeight: StylisteSpacing.xxs,
                color: StylisteColors.champagneGold,
                backgroundColor: StylisteColors.outlineDark,
              ),
            ),
          ],
        ),
        status: const AurelianStatusChip(
          label: 'No gameplay request started',
          icon: Icons.shield_outlined,
        ),
      ),
    );
  }
}

String _authErrorMessage(Object error) {
  if (error is SupabaseAuthException) return error.safeMessage;
  return SupabaseService.playerSafeErrorMessage(
    error,
    fallback: 'Authentication is unavailable. Retry when you are ready.',
  );
}
