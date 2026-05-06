// PROJECT_RULES §2 — Supabase client singleton
// All DB queries and Edge Function calls route through this service.

import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseService {
  /// The authenticated Supabase client.
  /// Always use this getter — never construct a new client.
  static SupabaseClient get client => Supabase.instance.client;

  /// Current authenticated user's ID (Firebase UID linked to Supabase).
  static String? get currentUserId => client.auth.currentUser?.id;

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
    return Map<String, dynamic>.from(response.data as Map<dynamic, dynamic>);
  }
}
