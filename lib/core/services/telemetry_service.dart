// Directive N — Telemetry Service
// GDD §8.15, §9.9 — Analytics and anomaly detection engine
// 
// Every notification, every check-in, every economic spike logged
// Server-authoritative with client-side batching for performance

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';


// =============================================================================
// Telemetry Service — Singleton
// =============================================================================

class TelemetryService {
  TelemetryService._internal();
  static final TelemetryService _instance = TelemetryService._internal();
  static TelemetryService get instance => _instance;

  final Uuid _uuid = const Uuid();
  final List<TelemetryEvent> _eventBuffer = <TelemetryEvent>[];
  final List<TelemetryEvent> _pendingQueue = <TelemetryEvent>[];
  
  Timer? _flushTimer;
  bool _initialized = false;
  String? _currentSessionId;
  Map<String, dynamic>? _deviceInfo;
  Map<String, dynamic>? _appInfo;

  // Batching configuration
  static const int _maxBufferSize = 50;
  static const int _flushIntervalSeconds = 30;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    _currentSessionId = _uuid.v4();
    _deviceInfo = await _getDeviceInfo();
    _appInfo = await _getAppInfo();

    // Start periodic flush timer
    _flushTimer = Timer.periodic(
      const Duration(seconds: _flushIntervalSeconds),
      (_) => _flushEvents(),
    );

    _initialized = true;

    // Log session start
    logEvent(
      eventType: 'session',
      eventName: 'session_start',
      payload: <String, dynamic>{
        'device_info': _deviceInfo,
        'app_info': _appInfo,
      },
    );
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final Map<String, dynamic> info = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        info['platform'] = 'android';
        info['os_version'] = 'Android ${androidInfo.version.release}';
        info['model'] = androidInfo.model;
        info['brand'] = androidInfo.brand;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        info['platform'] = 'ios';
        info['os_version'] = 'iOS ${iosInfo.systemVersion}';
        info['model'] = iosInfo.model;
        info['name'] = iosInfo.name;
      }
    } catch (e) {
      info['platform'] = 'unknown';
    }

    return info;
  }

  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return <String, dynamic>{
        'app_name': packageInfo.appName,
        'package_name': packageInfo.packageName,
        'version': packageInfo.version,
        'build_number': packageInfo.buildNumber,
      };
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Log a telemetry event
  void logEvent({
    required String eventType,
    required String eventName,
    Map<String, dynamic>? payload,
  }) {
    if (!_initialized) return;

    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) return;

    final TelemetryEvent event = TelemetryEvent(
      id: _uuid.v4(),
      playerId: playerId,
      eventType: eventType,
      eventName: eventName,
      payload: <String, dynamic>{
        ...?payload,
        '_local_timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: _currentSessionId,
      deviceInfo: _deviceInfo,
      occurredAt: DateTime.now(),
    );

    _eventBuffer.add(event);

    // Flush immediately if buffer is full
    if (_eventBuffer.length >= _maxBufferSize) {
      _flushEvents();
    }
  }

  /// Log notification interaction
  void logNotificationEvent({
    required String action, // 'received', 'opened', 'dismissed'
    required String notificationType,
    required String notificationId,
    String? source, // 'local', 'fcm'
  }) {
    logEvent(
      eventType: 'notification',
      eventName: 'notification_$action',
      payload: <String, dynamic>{
        'notification_type': notificationType,
        'notification_id': notificationId,
        'source': source ?? 'unknown',
      },
    );
  }

  /// Log daily check-in
  void logCheckIn({
    required int streakDay,
    required String rewardGranted,
    required bool isNewDay,
  }) {
    logEvent(
      eventType: 'check_in',
      eventName: 'daily_check_in_day_$streakDay',
      payload: <String, dynamic>{
        'streak_day': streakDay,
        'reward_granted': rewardGranted,
        'is_new_day': isNewDay,
        'session_id': _currentSessionId,
      },
    );
  }

  /// Log economy anomaly detection
  void logEconomyAnomaly({
    required String anomalyType,
    required double deviationSigma,
    required double flaggedValue,
  }) {
    logEvent(
      eventType: 'economy_anomaly',
      eventName: 'anomaly_${anomalyType.toLowerCase()}',
      payload: <String, dynamic>{
        'anomaly_type': anomalyType,
        'deviation_sigma': deviationSigma,
        'flagged_value': flaggedValue,
        'severity': deviationSigma > 5.0
            ? 'critical'
            : deviationSigma > 4.0
                ? 'high'
                : 'medium',
      },
    );
  }

  /// Log design/session events
  void logDesignEvent({
    required String action, // 'started', 'completed', 'published'
    required String designId,
    double? hypeScore,
  }) {
    logEvent(
      eventType: 'design',
      eventName: 'design_$action',
      payload: <String, dynamic>{
        'design_id': designId,
        'hype_score': hypeScore,
      },
    );
  }

  /// Log feed interactions
  void logFeedInteraction({
    required String action, // 'like', 'comment', 'share', 'follow'
    required String postId,
    String? targetPlayerId,
  }) {
    logEvent(
      eventType: 'feed_interaction',
      eventName: 'feed_$action',
      payload: <String, dynamic>{
        'post_id': postId,
        'target_player_id': targetPlayerId,
      },
    );
  }

  /// Get current session ID for funnel analysis
  String? get currentSessionId => _currentSessionId;

  /// Start a new session (call on app resume after long background)
  void startNewSession() {
    _currentSessionId = _uuid.v4();
    logEvent(
      eventType: 'session',
      eventName: 'session_resume',
      payload: <String, dynamic>{
        'previous_session_id': _currentSessionId,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  Future<void> _flushEvents() async {
    if (_eventBuffer.isEmpty) return;

    // Move buffered events to pending queue
    _pendingQueue.addAll(_eventBuffer);
    _eventBuffer.clear();

    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) {
      // Keep events in pending queue until player logs in
      return;
    }

    try {
      final List<Map<String, dynamic>> eventsData = _pendingQueue
          .where((TelemetryEvent e) => e.playerId == playerId)
          .map((TelemetryEvent e) => <String, dynamic>{
                'player_id': e.playerId,
                'event_type': e.eventType,
                'event_name': e.eventName,
                'payload': e.payload,
                'session_id': e.sessionId,
                'device_info': e.deviceInfo,
                'occurred_at': e.occurredAt.toIso8601String(),
              },)
          .toList();

      if (eventsData.isEmpty) return;

      // Batch insert via RPC
      final SupabaseClient supabase = Supabase.instance.client;
      await supabase.rpc<void>(
        'batch_log_telemetry',
        params: <String, dynamic>{
          'p_events': eventsData,
        },
      );

      // Clear sent events from pending queue
      _pendingQueue.removeWhere(
        (TelemetryEvent e) => eventsData.any(
          (Map<String, dynamic> d) => 
            d['event_name'] == e.eventName && 
            d['occurred_at'] == e.occurredAt.toIso8601String(),
        ),
      );
    } catch (e) {
      // Failed to send — events remain in pending queue for retry
      debugPrint('Telemetry flush failed: $e');
    }
  }

  /// Force immediate flush (call on app background/terminate)
  Future<void> forceFlush() async {
    await _flushEvents();
  }

  void dispose() {
    _flushTimer?.cancel();
    forceFlush();
  }
}

// =============================================================================
// Telemetry Event Model
// =============================================================================

class TelemetryEvent {
  TelemetryEvent({
    required this.id,
    required this.playerId,
    required this.eventType,
    required this.eventName,
    required this.payload,
    required this.occurredAt, this.sessionId,
    this.deviceInfo,
  });

  final String id;
  final String playerId;
  final String eventType;
  final String eventName;
  final Map<String, dynamic>? payload;
  final String? sessionId;
  final Map<String, dynamic>? deviceInfo;
  final DateTime occurredAt;
}

// =============================================================================
// SQL RPC for Batch Logging (add to telemetry migration)
// =============================================================================
// 
// CREATE OR REPLACE FUNCTION batch_log_telemetry(p_events JSONB[])
// RETURNS VOID
// LANGUAGE plpgsql
// SECURITY DEFINER
// AS $$
// BEGIN
//   INSERT INTO telemetry_events (player_id, event_type, event_name, payload, session_id, device_info, occurred_at)
//   SELECT 
//     (event->>'player_id')::UUID,
//     event->>'event_type',
//     event->>'event_name',
//     event->'payload',
//     (event->>'session_id')::UUID,
//     event->'device_info',
//     (event->>'occurred_at')::TIMESTAMPTZ
//   FROM unnest(p_events) AS event;
// END;
// $$;
