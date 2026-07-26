// GDD v7 §3.0 — MaterialApp.router with fail-closed Supabase Auth startup.
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
    final AsyncValue<Object?> sessionBootstrap =
        ref.watch(supabaseSessionBootstrapProvider);

    if (sessionBootstrap.isLoading) {
      return const _ObsidianGate();
    }
    if (sessionBootstrap.hasError) {
      return _ObsidianGate(
        errorMessage: _authErrorMessage(sessionBootstrap.error!),
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

/// Prevents a white flash while Supabase restores or creates the session.
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
  if (error is SupabaseAuthException) return error.safeMessage;
  return SupabaseService.playerSafeErrorMessage(
    error,
    fallback: 'Authentication unavailable. Please try again.',
  );
}
