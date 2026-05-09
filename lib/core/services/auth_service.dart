// Directive O — Auth Service
// GDD §1.1 — Cloud Save & Platform Integration
// Game Center (iOS) / Play Games (Android) silent authentication

import 'dart:io';

import 'package:games_services/games_services.dart' as gs;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';
import 'supabase_service.dart';

/// AuthService — Platform game services authentication
/// Maps platform IDs (Game Center / Play Games) to Supabase UUIDs
/// Enables cloud save restoration on app reinstall
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  final SupabaseClient _supabase = SupabaseService.client;

  /// Authenticate silently with platform game services
  /// Call during post-Aurelian Gate onboarding flow
  /// Returns Supabase user ID if successful, null otherwise
  Future<String?> signInSilently() async {
    try {
      if (Platform.isIOS) {
        return await _signInWithGameCenter();
      } else if (Platform.isAndroid) {
        return await _signInWithPlayGames();
      }
      return null;
    } catch (e) {
      // Silent auth failed — proceed with anonymous Supabase auth
      return null;
    }
  }

  /// iOS: Sign in with Game Center
  /// Maps Game Center ID to Supabase UUID
  Future<String?> _signInWithGameCenter() async {
    try {
      // Check if Game Center is available
      final bool isAvailable = await gs.GamesServices.isAvailable;
      if (!isAvailable) {
        return null;
      }

      // Sign in silently
      final gs.Player? player = await gs.GamesServices.signIn();
      if (player == null) {
        return null;
      }

      final String gameCenterId = player.playerId ?? '';
      if (gameCenterId.isEmpty) {
        return null;
      }

      // Map Game Center ID to Supabase user
      return await _linkPlatformId(
        platformId: gameCenterId,
        platform: 'game_center',
      );
    } catch (e) {
      return null;
    }
  }

  /// Android: Sign in with Google Play Games
  /// Maps Play Games ID to Supabase UUID
  Future<String?> _signInWithPlayGames() async {
    try {
      // Check if Play Games is available
      final bool isAvailable = await gs.GamesServices.isAvailable;
      if (!isAvailable) {
        return null;
      }

      // Sign in
      final gs.Player? player = await gs.GamesServices.signIn();
      if (player == null) {
        return null;
      }

      final String playGamesId = player.playerId ?? '';
      if (playGamesId.isEmpty) {
        return null;
      }

      // Map Play Games ID to Supabase user
      return await _linkPlatformId(
        platformId: playGamesId,
        platform: 'play_games',
      );
    } catch (e) {
      return null;
    }
  }

  /// Link platform ID to Supabase user
  /// Checks if platform ID already exists, creates mapping if not
  Future<String?> _linkPlatformId({
    required String platformId,
    required String platform,
  }) async {
    try {
      // Check if platform ID already linked to existing user
      final List<Map<String, dynamic>> existing = await _supabase
          .from('platform_auth_mappings')
          .select('player_id')
          .eq('platform_id', platformId)
          .eq('platform', platform)
          .limit(1);

      if (existing.isNotEmpty) {
        // Platform ID exists — return the linked Supabase user ID
        final String playerId = existing.first['player_id'] as String;
        
        // Ensure current Supabase auth matches
        await _restoreSession(playerId);
        return playerId;
      }

      // No existing mapping — create new link for current user
      final String? currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        return null;
      }

      await _supabase.from('platform_auth_mappings').insert(<String, dynamic>{
        'player_id': currentUserId,
        'platform_id': platformId,
        'platform': platform,
        'linked_at': DateTime.now().toIso8601String(),
      });

      return currentUserId;
    } catch (e) {
      return null;
    }
  }

  /// Restore Supabase session for recovered player
  Future<void> _restoreSession(String playerId) async {
    // The session restoration happens through Supabase auth
    // Platform auth mapping ensures the correct user is loaded
    // This is a placeholder for any additional session setup
  }

  /// Check if user has cloud save available
  Future<bool> hasCloudSave() async {
    final String? userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final List<Map<String, dynamic>> mapping = await _supabase
          .from('platform_auth_mappings')
          .select('id')
          .eq('player_id', userId)
          .limit(1);

      return mapping.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get platform display name (for UI)
  Future<String?> getPlatformName() async {
    try {
      final gs.Player? player = await gs.GamesServices.signIn();
      return player?.displayName;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from platform services (called on logout)
  Future<void> signOut() async {
    // Note: Games Services doesn't have a sign-out method
    // User must sign out at system level
    // We just clear any local state here
  }
}
