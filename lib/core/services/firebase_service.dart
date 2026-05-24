// PROJECT_RULES §2 — Firebase App + App Check initialisation
// GDD §8.15.1 — Play Integrity (Android) / DeviceCheck (iOS)

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class FirebaseService {
  // --- Platform Firebase Options (populated from --dart-define-from-file) ---
  static FirebaseOptions get currentPlatformOptions {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidOptions;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosOptions;
    }
    throw UnsupportedError('Unsupported platform for Firebase.');
  }

  static const FirebaseOptions _androidOptions = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions _iosOptions = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  /// Activates App Check with platform-appropriate provider.
  /// Uses debug token in debug mode; Play Integrity / DeviceCheck in release.
  /// In kDebugMode, fetches and prints the debug token for Firebase Console
  /// whitelisting (required for local emulator / dev device attestation).
  static Future<void> activateAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );

    if (kDebugMode) {
      debugPrint(
          'Firebase App Check debug provider active for local development.');
    }
  }
}
