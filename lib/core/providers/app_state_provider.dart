// Global app state flags (loading, onboarding complete, etc.)
// PROJECT_RULES §3 — Riverpod state management

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the player has completed onboarding (GDD §1.1).
/// Persisted locally via Hive; validated against Supabase player record.
final StateProvider<bool> onboardingCompleteProvider = StateProvider<bool>(
  (Ref<bool> ref) => false,
);

/// Controls whether the app is in a global loading state.
final StateProvider<bool> globalLoadingProvider = StateProvider<bool>(
  (Ref<bool> ref) => false,
);

/// Current app theme mode preference.
/// GDD §3.6 — Accessibility: dark/light mode supported.
enum AppThemePreference { dark, light, system }

final StateProvider<AppThemePreference> themePrefProvider =
    StateProvider<AppThemePreference>(
  (Ref<AppThemePreference> ref) => AppThemePreference.dark,
);
