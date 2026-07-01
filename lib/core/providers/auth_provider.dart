// PROJECT_RULES §2 — Firebase Auth state provider + Supabase Auth bootstrap
// GDD §8.15.1 — Anonymous-first sign-in with progressive account linking.
//
// Game identity is the Supabase anonymous session UUID. Firebase auth state is
// available for future account linking, but Firebase auth is not started during
// first-session gameplay.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../services/supabase_service.dart';

// ---------------------------------------------------------------------------
// Firebase Auth instance
// ---------------------------------------------------------------------------

final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>(
  (Ref<FirebaseAuth> ref) => FirebaseAuth.instance,
);

// ---------------------------------------------------------------------------
// authStateProvider — drives on idTokenChanges (superset of authStateChanges)
// This stream emits on initial sign-in AND every ~60min token refresh.
// ---------------------------------------------------------------------------

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref<AsyncValue<User?>> ref) {
    return ref.watch(firebaseAuthProvider).idTokenChanges();
  },
);

// ---------------------------------------------------------------------------
// supabaseAnonSignInProvider — establishes the authoritative game identity.
// Supabase UUID auth is required by existing RLS policies and gameplay RPCs.
// ---------------------------------------------------------------------------

final FutureProvider<Session> supabaseAnonSignInProvider =
    FutureProvider<Session>((Ref<AsyncValue<Session>> ref) async {
  if (SupabaseService.hasFreshSession) {
    return SupabaseService.ensureFreshSession();
  }

  final AuthResponse response =
      await SupabaseService.client.auth.signInAnonymously();
  final Session? session =
      response.session ?? SupabaseService.client.auth.currentSession;
  if (session == null) {
    throw const SupabaseSessionExpiredException();
  }

  return SupabaseService.ensureFreshSession();
});

// ---------------------------------------------------------------------------
// Convenience providers
// ---------------------------------------------------------------------------

/// True if a Firebase user is authenticated (including anonymous).
final Provider<bool> isAuthenticatedProvider = Provider<bool>(
  (Ref<bool> ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);
    return authState.maybeWhen(
      data: (User? user) => user != null,
      orElse: () => false,
    );
  },
);

/// True if the current user has linked a permanent account (non-anonymous).
final Provider<bool> isAccountLinkedProvider = Provider<bool>(
  (Ref<bool> ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);
    return authState.maybeWhen(
      data: (User? user) => user != null && !user.isAnonymous,
      orElse: () => false,
    );
  },
);
