// GDD v7 §§19.1–19.9 — fail-closed Supabase startup for Android and iOS.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/theme/aurelian_theme.dart';
import 'core/theme/styliste_visual_mode.dart';
import 'core/widgets/aurelian_components.dart';
import 'core/widgets/styliste_scaffold.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
const String _legacySupabaseAnonKey =
    String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  final String publicClientKey = _supabasePublishableKey.isNotEmpty
      ? _supabasePublishableKey
      : _legacySupabaseAnonKey;
  if (_supabaseUrl.isEmpty || publicClientKey.isEmpty) {
    runApp(const _StartupFailureApp(
      'This build is missing its required game-service configuration.',
    ));
    return;
  }

  try {
    await Supabase.initialize(
      url: _supabaseUrl,
      // supabase_flutter 2.x names this parameter `anonKey`, but it accepts
      // the current publishable-key format as well as the legacy anon JWT.
      anonKey: publicClientKey,
    );
  } catch (_) {
    runApp(const _StartupFailureApp(
      'Game services are unavailable. Please try again later.',
    ));
    return;
  }

  runApp(const ProviderScope(child: TheStyliste()));
}

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AurelianTheme.darkTheme,
      home: AurelianScaffold(
        mode: StylisteVisualMode.noirCinematic,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AurelianStatePanel(
              kind: AurelianStateKind.terminalError,
              title: 'This build cannot start safely',
              message: message,
            ),
          ),
        ),
      ),
    );
  }
}
