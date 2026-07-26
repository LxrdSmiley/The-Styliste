// GDD v7 §§19.6–19.9 — Supabase Auth is the only player identity source.
// Anonymous founder-trial sessions are authenticated Supabase users, so every
// authoritative write remains bound to auth.uid() across Android and iOS.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

enum SupabaseAuthFailureCode {
  sessionMissing,
  anonymousSignInRejected,
  sessionExpired,
}

class SupabaseAuthException implements Exception {
  const SupabaseAuthException(this.code);

  final SupabaseAuthFailureCode code;

  String get safeMessage => switch (code) {
        SupabaseAuthFailureCode.sessionMissing =>
          'Sign-in is required before the game can continue.',
        SupabaseAuthFailureCode.anonymousSignInRejected =>
          'Your secure game session could not be created. Please try again.',
        SupabaseAuthFailureCode.sessionExpired =>
          SupabaseSessionExpiredException.safeMessage,
      };

  @override
  String toString() => safeMessage;
}

class SupabaseAuthRecoveryState {
  const SupabaseAuthRecoveryState({
    this.isRecovering = false,
    this.failure,
    this.attempts = 0,
  });

  final bool isRecovering;
  final SupabaseAuthException? failure;
  final int attempts;

  SupabaseAuthRecoveryState copyWith({
    bool? isRecovering,
    SupabaseAuthException? failure,
    bool clearFailure = false,
    int? attempts,
  }) {
    return SupabaseAuthRecoveryState(
      isRecovering: isRecovering ?? this.isRecovering,
      failure: clearFailure ? null : (failure ?? this.failure),
      attempts: attempts ?? this.attempts,
    );
  }
}

final StateProvider<SupabaseAuthRecoveryState> supabaseAuthRecoveryProvider =
    StateProvider<SupabaseAuthRecoveryState>(
  (Ref<SupabaseAuthRecoveryState> ref) => const SupabaseAuthRecoveryState(),
);

final StreamProvider<User?> authStateProvider = StreamProvider<User?>(
  (Ref<AsyncValue<User?>> ref) => SupabaseService.client.auth.onAuthStateChange
      .map((AuthState state) => state.session?.user),
);

/// Restores a saved Supabase session or creates the anonymous founder-trial
/// identity. The client never chooses a user id; Supabase creates and signs it.
final FutureProvider<User> supabaseSessionBootstrapProvider =
    FutureProvider<User>((Ref<AsyncValue<User>> ref) async {
  try {
    final User user = await _establishSupabaseUser();
    await SupabaseService.recreateRealtimeChannels();
    return user;
  } on SupabaseAuthException {
    rethrow;
  } on AuthException {
    throw const SupabaseAuthException(
      SupabaseAuthFailureCode.anonymousSignInRejected,
    );
  } on SupabaseSessionExpiredException {
    throw const SupabaseAuthException(
      SupabaseAuthFailureCode.sessionExpired,
    );
  }
});

abstract interface class SupabaseAuthActions {
  Future<String> requireEstablishedUserId();
  Future<String> retrySession();
  Future<void> signOutAndRestart();
}

final Provider<SupabaseAuthActions> supabaseAuthActionsProvider =
    Provider<SupabaseAuthActions>((Ref<SupabaseAuthActions> ref) {
  return _SupabaseAuthActions(
    restart: () => ref.invalidate(supabaseSessionBootstrapProvider),
    updateRecovery: (SupabaseAuthRecoveryState value) {
      ref.read(supabaseAuthRecoveryProvider.notifier).state = value;
    },
    recovery: () => ref.read(supabaseAuthRecoveryProvider),
  );
});

final class _SupabaseAuthActions implements SupabaseAuthActions {
  _SupabaseAuthActions({
    required this.restart,
    required this.updateRecovery,
    required this.recovery,
  });

  final void Function() restart;
  final void Function(SupabaseAuthRecoveryState) updateRecovery;
  final SupabaseAuthRecoveryState Function() recovery;

  @override
  Future<String> requireEstablishedUserId() async {
    try {
      return (await SupabaseService.ensureFreshSession()).user.id;
    } on SupabaseSessionExpiredException {
      throw const SupabaseAuthException(
        SupabaseAuthFailureCode.sessionExpired,
      );
    }
  }

  @override
  Future<String> retrySession() async {
    final SupabaseAuthRecoveryState prior = recovery();
    updateRecovery(prior.copyWith(isRecovering: true, clearFailure: true));
    try {
      final User user = await _establishSupabaseUser();
      await SupabaseService.recreateRealtimeChannels();
      updateRecovery(const SupabaseAuthRecoveryState());
      return user.id;
    } on Object catch (error) {
      final SupabaseAuthException failure = _asAuthFailure(error);
      updateRecovery(prior.copyWith(
        isRecovering: false,
        failure: failure,
        attempts: prior.attempts + 1,
      ));
      throw failure;
    }
  }

  @override
  Future<void> signOutAndRestart() async {
    await SupabaseService.signOut();
    updateRecovery(const SupabaseAuthRecoveryState());
    restart();
  }
}

Future<User> _establishSupabaseUser() async {
  final Session? existing = SupabaseService.client.auth.currentSession;
  if (existing == null) {
    return _signInAnonymousFounderTrial();
  }

  try {
    return (await SupabaseService.ensureFreshSession()).user;
  } on SupabaseSessionExpiredException {
    // A linked account has a recoverable identity and must return to an
    // explicit sign-in flow. Silently replacing it would orphan player state.
    if (!existing.user.isAnonymous) rethrow;

    // Supabase anonymous users cannot sign back in after their refresh token is
    // invalid. Only that terminal case may start a new founder-trial identity.
    await SupabaseService.signOutAndCleanup();
    return _signInAnonymousFounderTrial();
  }
}

Future<User> _signInAnonymousFounderTrial() async {
  final AuthResponse response =
      await SupabaseService.client.auth.signInAnonymously();
  final Session? session = response.session;
  final User? user = response.user;
  if (session == null || user == null) {
    throw const SupabaseAuthException(
      SupabaseAuthFailureCode.anonymousSignInRejected,
    );
  }
  return user;
}

SupabaseAuthException _asAuthFailure(Object error) {
  if (error is SupabaseAuthException) return error;
  if (error is SupabaseSessionExpiredException) {
    return const SupabaseAuthException(
      SupabaseAuthFailureCode.sessionExpired,
    );
  }
  return const SupabaseAuthException(
    SupabaseAuthFailureCode.anonymousSignInRejected,
  );
}

final Provider<bool> isAuthenticatedProvider = Provider<bool>((Ref<bool> ref) {
  return ref.watch(authStateProvider).maybeWhen(
        data: (User? user) => user != null,
        orElse: () => false,
      );
});

final Provider<bool> isAccountLinkedProvider = Provider<bool>((Ref<bool> ref) {
  return ref.watch(authStateProvider).maybeWhen(
        data: (User? user) => user != null && !user.isAnonymous,
        orElse: () => false,
      );
});
