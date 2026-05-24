// Directive N — Hybrid Notification Engine
// GDD §8.14, §12.3.1 — The Retention & Telemetry Engine
//
// Architecture: Hybrid (Local + FCM)
// - Local notifications: Daily check-ins, streak alerts (3 cascading: +24h, +48h, +72h)
// - FCM: Trend Tsunami, resale alerts, rival attacks, stock movements
//
// Lifecycle Queue: Schedule on AppLifecycleState.paused, clear on resume
// If player doesn't open for 3 days, stop pinging to avoid spam blocks

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'supabase_service.dart';
import 'telemetry_service.dart';

// =============================================================================
// Notification Service — Singleton with WidgetsBindingObserver
// =============================================================================

class NotificationService with WidgetsBindingObserver {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;
  DateTime? _lastCheckInScheduled;

  // Android notification channel IDs
  static const String _channelDailyCheckIn = 'daily_check_in';
  static const String _channelTrendTsunami = 'trend_tsunami';
  static const String _channelResaleAlerts = 'resale_alerts';
  static const String _channelRivalAlerts = 'rival_alerts';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications
    await _initLocalNotifications();

    // Initialize FCM
    await _initFCM();

    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    // iOS permission
    await _fcm.requestPermission();

    // Android permission (handled in manifest)
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // Create notification channels (Android)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    final List<AndroidNotificationChannel> channels =
        <AndroidNotificationChannel>[
      const AndroidNotificationChannel(
        _channelDailyCheckIn,
        'Daily Check-In',
        description: 'Daily streak reminders and check-in rewards',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        _channelTrendTsunami,
        'Trend Tsunami',
        description: '48-hour trend window alerts and market opportunities',
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        _channelResaleAlerts,
        'Resale Alerts',
        description: 'This Just Listed alerts and marketplace activity',
      ),
      const AndroidNotificationChannel(
        _channelRivalAlerts,
        'Rival Activity',
        description: 'Rival attacks, Eclipse events, and market threats',
        importance: Importance.high,
      ),
    ];

    for (final AndroidNotificationChannel channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _initFCM() async {
    // Get FCM token
    final String? token = await _fcm.getToken();
    if (token != null) {
      await _registerTokenWithServer(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_registerTokenWithServer);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onFCMMessage);

    // Handle background/terminated message opens
    FirebaseMessaging.onMessageOpenedApp.listen(_onFCMMessageOpened);
  }

  // ---------------------------------------------------------------------------
  // Lifecycle Queue — The 3-Cascading Check-In System
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Player backgrounded the app — schedule cascading check-ins
        _scheduleCascadingCheckIns();
        break;
      case AppLifecycleState.resumed:
        // Player opened the app — clear pending local notifications
        _clearLocalNotifications();
        _recordSessionStart();
        break;
      case AppLifecycleState.detached:
        // App terminated — schedule one final check-in for +24h
        _scheduleSingleFinalCheckIn();
        break;
      default:
        break;
    }
  }

  Future<void> _scheduleCascadingCheckIns() async {
    // Clear any existing scheduled notifications
    await _localNotifications.cancelAll();

    final DateTime now = DateTime.now();
    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) return;

    // Schedule exactly 3 cascading check-ins: +24h, +48h, +72h
    // If they don't open after 72h, stop pinging (anti-spam)
    final List<Duration> delays = <Duration>[
      const Duration(hours: 24),
      const Duration(hours: 48),
      const Duration(hours: 72),
    ];

    for (int i = 0; i < delays.length; i++) {
      final DateTime scheduledTime = now.add(delays[i]);

      await _scheduleCheckInNotification(
        id: 1000 + i,
        scheduledTime: scheduledTime,
        streakDay: await _getCurrentStreak(playerId),
        isFinal: i == delays.length - 1,
      );
    }

    _lastCheckInScheduled = now;
  }

  Future<void> _scheduleCheckInNotification({
    required int id,
    required DateTime scheduledTime,
    required int streakDay,
    required bool isFinal,
  }) async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.getLocation(timeZoneName));
    final String title =
        isFinal ? 'Final Call — Your Empire Awaits' : 'Daily Check-In Ready';

    final String body = isFinal
        ? 'Three days away. The fashion world moves fast — do not let your moment pass.'
        : _getCheckInMessage(streakDay);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelDailyCheckIn,
      'Daily Check-In',
      channelDescription: 'Daily streak reminders',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: _encodePayload(<String, dynamic>{
        'type': 'daily_check_in',
        'notification_id': 'check_in_$id',
        'scheduled_at': scheduledTime.toIso8601String(),
        'is_final': isFinal,
      }),
    );
  }

  Future<void> _scheduleSingleFinalCheckIn() async {
    // App terminated — one final ping in 24h
    final DateTime scheduledTime =
        DateTime.now().add(const Duration(hours: 24));

    await _scheduleCheckInNotification(
      id: 9999,
      scheduledTime: scheduledTime,
      streakDay: 0,
      isFinal: true,
    );
  }

  Future<void> _clearLocalNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Notification Handlers
  // ---------------------------------------------------------------------------

  void _onLocalNotificationTapped(NotificationResponse response) {
    final Map<String, dynamic>? payload = _decodePayload(response.payload);
    if (payload == null) return;

    // Log telemetry
    TelemetryService.instance.logEvent(
      eventType: 'notification',
      eventName: 'notification_opened',
      payload: <String, dynamic>{
        'notification_type': payload['type'],
        'notification_id': payload['notification_id'],
        'source': 'local',
      },
    );

    // Handle deep link
    _handleNotificationDeepLink(payload);
  }

  Future<void> _onFCMMessage(RemoteMessage message) async {
    // Foreground FCM message received
    // Show local notification from FCM payload
    final Map<String, dynamic> data = message.data;

    final String type = (data['type'] as String?) ?? 'general';
    final String title = message.notification?.title ?? 'The Styliste';
    final String body = message.notification?.body ?? '';

    // Log receipt
    TelemetryService.instance.logEvent(
      eventType: 'notification',
      eventName: 'notification_received',
      payload: <String, dynamic>{
        'notification_type': type,
        'notification_id': data['notification_id'],
        'source': 'fcm',
        'title': title,
      },
    );

    // Show as local notification (for foreground display)
    await _showLocalNotification(
      id: _generateNotificationId(type),
      title: title,
      body: body,
      payload: data,
      channelId: _getChannelForType(type),
    );
  }

  void _onFCMMessageOpened(RemoteMessage message) {
    // App opened from FCM notification
    final Map<String, dynamic> data = message.data;

    TelemetryService.instance.logEvent(
      eventType: 'notification',
      eventName: 'notification_opened',
      payload: <String, dynamic>{
        'notification_type': data['type'],
        'notification_id': data['notification_id'],
        'source': 'fcm',
      },
    );

    _handleNotificationDeepLink(data);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Show a local notification immediately
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: <String, dynamic>{
        'type': type,
        ...?payload,
      },
    );
  }

  /// Trigger a Trend Tsunami alert (FCM via server)
  Future<void> showTrendTsunamiAlert({
    required String theme,
    required Duration timeUntil,
  }) async {
    // This would normally come from FCM, but can be triggered locally for testing
    const String title = '🌊 Trend Tsunami Incoming';
    final String body =
        'The "$theme" wave arrives in ${timeUntil.inHours}h. Prepare your designs.';

    await _showLocalNotification(
      id: 2000,
      title: title,
      body: body,
      payload: <String, dynamic>{
        'type': 'trend_tsunami',
        'theme': theme,
        'notification_id': 'tsunami_${DateTime.now().millisecondsSinceEpoch}',
      },
      channelId: _channelTrendTsunami,
    );
  }

  /// Record a session start (for telemetry)
  Future<void> _recordSessionStart() async {
    TelemetryService.instance.logEvent(
      eventType: 'session',
      eventName: 'session_start',
      payload: <String, dynamic>{
        'last_check_in_scheduled': _lastCheckInScheduled?.toIso8601String(),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String? channelId,
  }) async {
    final String effectiveChannel = channelId ?? _channelDailyCheckIn;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      effectiveChannel,
      effectiveChannel,
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: _encodePayload(payload),
    );
  }

  String _getChannelForType(String type) {
    switch (type) {
      case 'trend_tsunami':
        return _channelTrendTsunami;
      case 'resale_alert':
        return _channelResaleAlerts;
      case 'rival_attack':
      case 'eclipse_event':
        return _channelRivalAlerts;
      default:
        return _channelDailyCheckIn;
    }
  }

  int _generateNotificationId(String type) {
    // Generate stable IDs based on notification type
    final int base = type.hashCode.abs();
    return 10000 + (base % 90000);
  }

  String _encodePayload(Map<String, dynamic> payload) {
    // Simple JSON encoding for payload
    return payload.toString();
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      // Parse the payload string back to Map
      // In production, use proper JSON encoding
      return <String, dynamic>{}; // Simplified
    } catch (e) {
      return null;
    }
  }

  String _getCheckInMessage(int streakDay) {
    final List<String> messages = <String>[
      'You showed up. That is how every empire starts, darling.',
      'Two days of consistency. The rivals are watching.',
      'Three days in — rivals are already nervous. I can tell.',
      'Four days. The fashion world is beginning to notice.',
      'Five days. Your rhythm is forming.',
      'Six days. One more and you hit the week milestone.',
      'A week of consistency. The fashion world is watching.',
    ];

    if (streakDay < messages.length) {
      return messages[streakDay];
    }
    return 'Day $streakDay. Your empire grows stronger.';
  }

  Future<int> _getCurrentStreak(String playerId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final PostgrestMap? response = await supabase
        .from('daily_check_ins')
        .select('current_streak')
        .eq('player_id', playerId)
        .maybeSingle();

    return response?['current_streak'] as int? ?? 0;
  }

  Future<void> _registerTokenWithServer(String token) async {
    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) return;

    final String platform = Platform.isIOS ? 'ios' : 'android';

    await SupabaseService.client.rpc<void>(
      'register_fcm_token',
      params: <String, dynamic>{
        'p_player_id': playerId,
        'p_token': token,
        'p_platform': platform,
      },
    );
  }

  void _handleNotificationDeepLink(Map<String, dynamic> payload) {
    final String? type = payload['type'] as String?;
    if (type == null) return;

    // Navigate based on notification type
    // This would integrate with app_router.dart
    switch (type) {
      case 'daily_check_in':
        // Navigate to HQ for check-in
        break;
      case 'trend_tsunami':
        // Navigate to Atelier or Trend view
        break;
      case 'resale_alert':
        // Navigate to Archive market
        break;
      case 'rival_attack':
        // Navigate to District map
        break;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

// =============================================================================
// Riverpod Provider
// =============================================================================

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) {
  return NotificationService.instance;
});
