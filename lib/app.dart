// GDD §3.0 — App root widget: MaterialApp.router with portrait lock and theming
// PROJECT_RULES §3 — go_router manages all navigation
// Phase 2 — Auth gate: holds pure obsidian SizedBox until the Supabase
// anonymous game identity resolves. Firebase services initialize in main.dart,
// but Firebase Auth is not started during first-session gameplay.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

class TheStyliste extends ConsumerWidget {
  const TheStyliste({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Object?> supabaseSignIn =
        ref.watch(supabaseAnonSignInProvider);

    // Auth gate: hold obsidian until Supabase game identity resolves.
    // On error: surface a minimal danger-coloured message for debugging.
    return supabaseSignIn.when(
      loading: () => const _ObsidianGate(),
      error: (Object e, _) => _ObsidianGate(errorMessage: _authErrorMessage(e)),
      data: (_) => MaterialApp.router(
        title: 'The Styliste',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
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
                    errorMessage!,
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

String _authErrorMessage(Object error) {
  return SupabaseService.playerSafeErrorMessage(
    error,
    fallback: 'Authentication unavailable. Please try again.',
  );
}
