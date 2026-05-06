// Phase 2 — Mock scaffolding retained for integration tests only.
// Live Firebase Anonymous Auth is now active; mockAuthOverride is no longer
// injected into main.dart. kMockUid is kept as a compile-time constant.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// Stable mock UID — retained for integration/unit tests only.
/// NOT used in production or debug app flows post-Phase 2.
const String kMockUid = 'mock-uid-phase1';

/// Active UID provider — reads the live Firebase UID from authStateProvider.
/// Returns empty string while auth is loading (guarded by app.dart auth gate).
final Provider<String> activeUidProvider = Provider<String>(
  (Ref<String> ref) {
    final AsyncValue<User?> auth = ref.watch(authStateProvider);
    return auth.maybeWhen(
      data: (User? user) => user?.uid ?? '',
      orElse: () => '',
    );
  },
);
