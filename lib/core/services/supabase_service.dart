// PROJECT_RULES §2 — Supabase client singleton
// All DB queries and Edge Function calls route through this service.

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract final class SupabaseService {
  static const Set<String> _kingstonMutationEndpoints = <String>{
    'founder-trial',
    'drop-design',
    'open-first-store',
    'calculate-idle-income',
    'progression-event',
    'submit-player-report',
  };
  static const Duration _sessionRefreshMargin = Duration(minutes: 2);

  static const String noInternetMessage =
      'No internet connection. Check your network and try again.';

  /// The authenticated Supabase client.
  /// Always use this getter — never construct a new client.
  static SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated Supabase user's ID.
  static String? get currentUserId => client.auth.currentUser?.id;

  /// True when the current session exists and is not near expiry.
  static bool get hasFreshSession {
    return isFreshSession(client.auth.currentSession);
  }

  static bool isFreshSession(Session? session) {
    return session != null && !_shouldRefresh(session);
  }

  /// Refreshes an existing Supabase session before Realtime channels subscribe.
  ///
  /// If there is no session, or the refresh token cannot recover it, callers
  /// receive a player-safe exception instead of leaking raw JWT errors.
  static Future<Session> ensureFreshSession() async {
    final Session? session = client.auth.currentSession;
    if (session == null) {
      throw const SupabaseSessionExpiredException();
    }

    if (!_shouldRefresh(session)) {
      await _setRealtimeAuth(session);
      return session;
    }

    try {
      final AuthResponse response = await client.auth.refreshSession();
      final Session? refreshedSession = response.session;
      if (refreshedSession == null || _shouldRefresh(refreshedSession)) {
        throw const SupabaseSessionExpiredException();
      }
      await _setRealtimeAuth(refreshedSession);
      return refreshedSession;
    } on SupabaseSessionExpiredException {
      rethrow;
    } on Object catch (error) {
      if (isRecoverableAuthError(error)) {
        throw const SupabaseSessionExpiredException();
      }
      rethrow;
    }
  }

  /// Forces active Realtime streams to rebuild around the latest auth token.
  static Future<void> recreateRealtimeChannels() async {
    final Session session = await ensureFreshSession();
    await _setRealtimeAuth(session);
    await client.removeAllChannels();
  }

  /// Clears all Realtime subscriptions after Supabase signs out.
  static Future<void> cleanupRealtimeChannels() async {
    await client.removeAllChannels();
  }

  static Future<void> signOutAndCleanup() async {
    await cleanupRealtimeChannels();
    if (client.auth.currentSession != null) {
      await client.auth.signOut();
    }
  }

  static Stream<T> guardRealtimeStream<T>(Stream<T> stream) {
    return stream.handleError(
      (Object _, StackTrace __) {
        throw const SupabaseSessionExpiredException();
      },
      test: (Object? error) => isRecoverableAuthError(error),
    );
  }

  static String playerSafeErrorMessage(
    Object error, {
    required String fallback,
  }) {
    final String errStr = error.toString().toLowerCase();
    if (errStr.contains('socketexception') ||
        errStr.contains('httpexception') ||
        errStr.contains('failed host lookup')) {
      return noInternetMessage;
    }

    return isRecoverableAuthError(error)
        ? SupabaseSessionExpiredException.safeMessage
        : fallback;
  }

  static Future<void> signOut() async {
    try {
      // 1. Cleanup Realtime
      await cleanupRealtimeChannels();
    } catch (_) {}

    try {
      // Sign out of the only approved identity provider.
      await client.auth.signOut();
    } catch (_) {}
  }

  static bool isRecoverableAuthError(Object? error) {
    if (error == null) return false;
    if (error is SupabaseSessionExpiredException) return true;

    final String message = error.toString().toLowerCase();
    return message.contains('invalidjwttoken') ||
        message.contains('invalid jwt') ||
        message.contains('invalid refresh token') ||
        message.contains('refresh token not found') ||
        message.contains('refresh_token_not_found') ||
        message.contains('refresh token already used') ||
        message.contains('token has expired') ||
        message.contains('jwt expired') ||
        message.contains('session expired') ||
        message.contains('authsessionmissing') ||
        message.contains('auth session missing') ||
        message.contains('access token is expired') ||
        message.contains('realtimesubscribeexception');
  }

  static bool _shouldRefresh(Session session) {
    final int? expiresAt = session.expiresAt;
    if (expiresAt == null || session.isExpired) return true;

    final DateTime expiry =
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().add(_sessionRefreshMargin).isAfter(expiry);
  }

  static Future<void> _setRealtimeAuth(Session session) async {
    try {
      await client.realtime.setAuth(session.accessToken);
    } on Object catch (error) {
      if (isRecoverableAuthError(error)) {
        throw const SupabaseSessionExpiredException();
      }
      rethrow;
    }
  }

  /// Convenience: invoke a Supabase Edge Function by name.
  /// All economy mutations MUST go through Edge Functions (PROJECT_RULES §3).
  static Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    await ensureFreshSession();
    final Map<String, dynamic>? requestBody = body == null
        ? (_kingstonMutationEndpoints.contains(functionName)
            ? <String, dynamic>{'idempotency_key': const Uuid().v4()}
            : null)
        : <String, dynamic>{
            ...body,
            if (_kingstonMutationEndpoints.contains(functionName) &&
                !body.containsKey('idempotency_key'))
              'idempotency_key': const Uuid().v4(),
          };
    final FunctionResponse response = await client.functions.invoke(
      functionName,
      body: requestBody,
    );
    if (response.data == null) {
      throw Exception('Edge function $functionName returned null data.');
    }
    final Object data = response.data as Object;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      final Object? decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw FormatException(
      'Edge function $functionName returned ${data.runtimeType}, expected JSON object.',
    );
  }
}

class SupabaseSessionExpiredException implements Exception {
  const SupabaseSessionExpiredException();

  static const String safeMessage = 'Session expired. Please sign in again.';

  @override
  String toString() => safeMessage;
}
