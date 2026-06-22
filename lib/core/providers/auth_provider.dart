// PROJECT_RULES §2 — Firebase Auth state provider + Supabase JWT bridge
// GDD §8.15.1 — Anonymous-first sign-in with progressive account linking.
//
// Token refresh strategy:
//   idTokenChanges() emits on every Firebase token refresh (~60min) AND on
//   initial sign-in. supabaseBridgeProvider (keepAlive) listens to this stream
//   and calls signInWithIdToken on the Supabase client, keeping the Supabase
//   session and Realtime WebSocket JWT in sync without reconnection.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
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
// firebaseAnonSignInProvider — triggers anonymous sign-in exactly once.
// Watched in app.dart to boot the auth chain before routing begins.
// ---------------------------------------------------------------------------

final FutureProvider<User> firebaseAnonSignInProvider =
    FutureProvider<User>((Ref<AsyncValue<User>> ref) async {
  final FirebaseAuth auth = ref.watch(firebaseAuthProvider);

  // If already signed in (e.g. hot-restart), reuse the existing session.
  final User? existing = auth.currentUser;
  if (existing != null) return existing;

  final UserCredential credential = await auth.signInAnonymously();
  return credential.user!;
});

// ---------------------------------------------------------------------------
// supabaseBridgeProvider — keepAlive: bridges Firebase ID token → Supabase.
// Must be watched in app.dart to stay alive for the entire app lifecycle.
// On each idTokenChanges emission: extracts fresh token and calls
// supabase.auth.signInWithIdToken, which also fires tokenRefreshed on
// the Realtime client — no WebSocket reconnect required.
// ---------------------------------------------------------------------------

final StreamProvider<void> supabaseBridgeProvider = StreamProvider<void>(
  (Ref<AsyncValue<void>> ref) {
    // keepAlive: directive §1 — never dispose this bridge.
    ref.keepAlive();

    final StreamController<void> controller = StreamController<void>();
    Future<void> bridgeQueue = Future<void>.value();
    int authGeneration = 0;

    final StreamSubscription<User?> subscription =
        FirebaseAuth.instance.idTokenChanges().listen(
      (User? user) {
        final int eventGeneration = ++authGeneration;
        bridgeQueue = bridgeQueue.then((_) async {
          if (eventGeneration != authGeneration) return;
          if (user == null) {
            await SupabaseService.signOutAndCleanup();
            _BridgeIdentity.clear();
            if (!controller.isClosed) {
              controller.addError(const SupabaseSessionExpiredException());
            }
            return;
          }
          try {
            await _syncSupabaseSession(user);
            if (eventGeneration == authGeneration && !controller.isClosed) {
              controller.add(null);
            }
          } catch (_) {
            await SupabaseService.signOutAndCleanup();
            _BridgeIdentity.clear();
            if (!controller.isClosed) {
              controller.addError(const SupabaseSessionExpiredException());
            }
          }
        });
      },
      onError: (Object _) {
        if (!controller.isClosed) {
          controller.addError(const SupabaseSessionExpiredException());
        }
      },
    );

    ref.onDispose(() {
      unawaited(subscription.cancel());
      unawaited(controller.close());
    });

    return controller.stream;
  },
);

Future<void> _syncSupabaseSession(User user) async {
  if (_BridgeIdentity.firebaseUid != null &&
      _BridgeIdentity.firebaseUid != user.uid) {
    await SupabaseService.signOutAndCleanup();
    _BridgeIdentity.clear();
  }
  final bool forceFirebaseRefresh = !SupabaseService.hasFreshSession;
  final String? idToken = await user.getIdToken(forceFirebaseRefresh);
  if (idToken == null) {
    throw const SupabaseSessionExpiredException();
  }

  final AuthResponse response =
      await Supabase.instance.client.auth.signInWithIdToken(
    provider: const OAuthProvider('firebase'),
    idToken: idToken,
  );
  final String? supabaseUserId = response.user?.id;
  if (supabaseUserId == null) {
    throw const SupabaseSessionExpiredException();
  }
  if (_BridgeIdentity.firebaseUid == user.uid &&
      _BridgeIdentity.supabaseUserId != null &&
      _BridgeIdentity.supabaseUserId != supabaseUserId) {
    await SupabaseService.signOutAndCleanup();
    throw const SupabaseSessionExpiredException();
  }
  _BridgeIdentity
    ..firebaseUid = user.uid
    ..supabaseUserId = supabaseUserId;
  await SupabaseService.ensureFreshSession();
}

abstract final class _BridgeIdentity {
  static String? firebaseUid;
  static String? supabaseUserId;

  static void clear() {
    firebaseUid = null;
    supabaseUserId = null;
  }
}

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
