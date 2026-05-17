// GDD §3.0 — App root widget: MaterialApp.router with portrait lock and theming
// PROJECT_RULES §3 — go_router manages all navigation
// Phase 2 — Auth gate: holds pure obsidian SizedBox until Firebase anonymous
// sign-in resolves. supabaseBridgeProvider watched here (keepAlive) so the
// Firebase→Supabase JWT sync stays alive for the entire app lifecycle.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

class TheStyliste extends ConsumerWidget {
  const TheStyliste({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly trigger anonymous sign-in. The FutureProvider caches the result
    // so hot-restarts reuse the existing Firebase session.
    final AsyncValue<Object?> anonSignIn =
        ref.watch(firebaseAnonSignInProvider);

    // Keep the bridge alive for the entire app lifecycle (directive §1).
    // We don't use the value — just watching it prevents Riverpod disposal.
    final AsyncValue<void> supabaseBridge = ref.watch(supabaseBridgeProvider);

    // Auth gate: hold obsidian until Firebase resolves (no white flash).
    // On error: surface a minimal danger-coloured message for debugging.
    return anonSignIn.when(
      loading: () => const _ObsidianGate(),
      error: (Object e, _) => _ObsidianGate(errorMessage: e.toString()),
      data: (_) => supabaseBridge.when(
        loading: () => const _ObsidianGate(),
        error: (Object e, _) => _ObsidianGate(errorMessage: e.toString()),
        data: (_) => MaterialApp.router(
          title: 'The Styliste',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

/// Pure obsidian loading gate — rendered until Firebase auth resolves.
/// Strictly enforces no white flash or Material loader bleed-through.
class _ObsidianGate extends StatelessWidget {
  const _ObsidianGate({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.obsidian,
        body: errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Auth error: $errorMessage',
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
