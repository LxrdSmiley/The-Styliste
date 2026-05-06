// GDD §1 — The Styliste entry point
// PROJECT_RULES §2 — Firebase Auth + App Check + Supabase initialised here
// Env strategy: --dart-define-from-file=.env.json (never hardcode keys)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/services/firebase_service.dart';

// --- Environment constants via --dart-define-from-file=.env.json ---
// Usage: flutter run --dart-define-from-file=.env.json
const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (GDD §1 — portrait-first)
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise Firebase (PROJECT_RULES §2)
  await Firebase.initializeApp(
    options: FirebaseService.currentPlatformOptions,
  );

  // Activate Firebase App Check (Play Integrity / DeviceCheck — GDD §8.15.1)
  await FirebaseService.activateAppCheck();

  // Initialise Supabase (PROJECT_RULES §2 — source of truth for economy)
  assert(_supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set via --dart-define-from-file');
  assert(_supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be set via --dart-define-from-file');

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(
    // Riverpod scope wraps the entire app (PROJECT_RULES §3)
    const ProviderScope(
      child: TheStyliste(),
    ),
  );
}
