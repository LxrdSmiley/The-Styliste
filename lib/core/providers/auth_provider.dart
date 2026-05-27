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
import 'package:flutter/foundation.dart';
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

    final StreamSubscription<User?> subscription =
        FirebaseAuth.instance.idTokenChanges().listen(
      (User? user) async {
        if (user == null) {
          await SupabaseService.cleanupRealtimeChannels();
          return;
        }
        try {
          await _syncSupabaseSession(user);
          if (!controller.isClosed) {
            controller.add(null);
          }
        } catch (e) {
          if (_isFirebaseProviderConfigError(e)) {
            if (Supabase.instance.client.auth.currentSession != null) {
              try {
                await SupabaseService.ensureFreshSession();
                if (!controller.isClosed) {
                  controller.add(null);
                }
                return;
              } catch (_) {
                if (!controller.isClosed) {
                  controller.addError(
                    const SupabaseSessionExpiredException(),
                  );
                }
                return;
              }
            } else {
              try {
                await Supabase.instance.client.auth.signInAnonymously();
                await SupabaseService.ensureFreshSession();
                if (!controller.isClosed) {
                  controller.add(null);
                }
                return;
              } catch (anonymousError) {
                if (kDebugMode) {
                  debugPrint(
                    'supabase anonymous fallback error: $anonymousError',
                  );
                }
              }
            }
          }

          if (SupabaseService.isRecoverableAuthError(e) ||
              !SupabaseService.hasFreshSession) {
            if (!controller.isClosed) {
              controller.addError(const SupabaseSessionExpiredException());
            }
            return;
          }

          // Bridge errors are logged. We emit a value anyway to unblock the
          // app's loading gate, allowing local play/UI to render.
          if (kDebugMode) {
            debugPrint('supabaseBridge error: $e');
          }
          if (!controller.isClosed) {
            controller.add(null);
          }
        }
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('supabaseBridge stream error: $e');
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
  final bool forceFirebaseRefresh = !SupabaseService.hasFreshSession;
  final String? idToken = await user.getIdToken(forceFirebaseRefresh);
  if (idToken == null) {
    throw const SupabaseSessionExpiredException();
  }

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: const OAuthProvider('firebase'),
    idToken: idToken,
  );
  await SupabaseService.ensureFreshSession();
}

bool _isFirebaseProviderConfigError(Object error) {
  if (error is! AuthException) return false;

  final String message = error.message.toLowerCase();
  return message.contains('firebase') &&
      (message.contains('not allowed') ||
          message.contains('provider') ||
          message.contains('oidc'));
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
