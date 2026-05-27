// PROJECT_RULES §2 — Supabase client singleton
// All DB queries and Edge Function calls route through this service.

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseService {
  static const Duration _sessionRefreshMargin = Duration(minutes: 2);

  /// The authenticated Supabase client.
  /// Always use this getter — never construct a new client.
  static SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user's ID (Firebase UID linked to Supabase).
  static String? get currentUserId => client.auth.currentUser?.id;

  /// True when the current session exists and is not near expiry.
  static bool get hasFreshSession {
    final Session? session = client.auth.currentSession;
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
      return session;
    }

    try {
      final AuthResponse response = await client.auth.refreshSession();
      final Session? refreshedSession = response.session;
      if (refreshedSession == null || _shouldRefresh(refreshedSession)) {
        throw const SupabaseSessionExpiredException();
      }
      return refreshedSession;
    } catch (_) {
      throw const SupabaseSessionExpiredException();
    }
  }

  static bool isRecoverableAuthError(Object error) {
    if (error is SupabaseSessionExpiredException) return true;

    final String message = error.toString().toLowerCase();
    return message.contains('invalidjwttoken') ||
        message.contains('token has expired') ||
        message.contains('jwt expired') ||
        message.contains('session expired') ||
        message.contains('authsessionmissing') ||
        message.contains('realtimesubscribeexception');
  }

  static bool _shouldRefresh(Session session) {
    final int? expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    final DateTime expiry =
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().add(_sessionRefreshMargin).isAfter(expiry);
  }

  /// Convenience: invoke a Supabase Edge Function by name.
  /// All economy mutations MUST go through Edge Functions (PROJECT_RULES §3).
  static Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    final FunctionResponse response = await client.functions.invoke(
      functionName,
      body: body,
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
