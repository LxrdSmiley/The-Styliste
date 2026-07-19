// GDD §3.0 — App root widget: MaterialApp.router with portrait lock and theming
// PROJECT_RULES §3 — go_router manages all navigation
// Phase 2 — Auth gate: holds pure obsidian SizedBox until the Firebase
// anonymous identity and its Supabase bridge resolve.

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
    final AsyncValue<Object?> firebaseSignIn =
        ref.watch(firebaseAnonSignInProvider);
    final AsyncValue<Object?> supabaseBridge =
        ref.watch(supabaseBridgeProvider);

    // Auth gate: hold obsidian until the game identity is bridged to Supabase.
    // On error: surface a minimal danger-coloured message for debugging.
    if (firebaseSignIn.isLoading || supabaseBridge.isLoading) {
      return const _ObsidianGate();
    }
    if (firebaseSignIn.hasError) {
      return _ObsidianGate(
        errorMessage: _authErrorMessage(firebaseSignIn.error!),
      );
    }
    if (supabaseBridge.hasError) {
      return _ObsidianGate(
        errorMessage: _authErrorMessage(supabaseBridge.error!),
      );
    }

    return MaterialApp.router(
      title: 'The Styliste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
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
