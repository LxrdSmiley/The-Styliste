// GDD v6 §1.1 — Aurelian Sanctuary Design System
// Alabaster Standard: Ivory, Champagne Gold, Soft Rose
// Replaces deprecated Obsidian & Titanium aesthetic

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Aurelian Radiance Palette — the foundation of all Alabaster Standard UI
/// 
/// Ivory (#FFFFF0) — Primary backgrounds, pure light
/// Champagne Gold (#F7E7CE) — Accents, luxury highlights, interactive elements
/// Soft Rose (#FFB7C5) — Decorative flourishes, ribbon physics, gentle contrast
/// Alabaster (#FEFEFE) — Subtle variations, card surfaces
abstract final class AurelianPalette {
  // --- Core Radiance Colors ---
  static const Color ivory = Color(0xFFFFFFF0);
  static const Color champagneGold = Color(0xFFF7E7CE);
  static const Color softRose = Color(0xFFFFB7C5);
  static const Color alabaster = Color(0xFFFEFEFE);

  // --- Depth Variations ---
  static const Color ivoryDark = Color(0xFFF5F5E8);
  static const Color champagneGoldLight = Color(0xFFFAF0D9);
  static const Color champagneGoldDark = Color(0xFFE8D4A8);
  static const Color softRoseMuted = Color(0xFFFFC4CF);

  // --- Semantic Colors (Aurelian tinted) ---
  static const Color success = Color(0xFF7EB89C); // Muted sage
  static const Color warning = Color(0xFFE8C96A); // Gold amber
  static const Color danger = Color(0xFFE08E8E);  // Rose red
  static const Color info = Color(0xFF9AB8C9);    // Soft blue-grey

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF2A2825);   // Warm dark
  static const Color textSecondary = Color(0xFF6B6560); // Muted warm grey
  static const Color textTertiary = Color(0xFF9B9590);  // Light warm grey

  // --- Transparency Helpers ---
  static Color ivoryWithOpacity(double opacity) =>
      ivory.withValues(alpha: opacity);
  static Color champagneWithOpacity(double opacity) =>
      champagneGold.withValues(alpha: opacity);
  static Color roseWithOpacity(double opacity) =>
      softRose.withValues(alpha: opacity);
}

/// Aurelian Typography — Light-etched, fashion-forward letterforms
/// 
/// Primary: Space Grotesk (geometric, editorial)
/// Fallback: System sans-serif
abstract final class AurelianTypography {
  // --- Manifesto / Poetic Text (GDD §1.1 Screen 2) ---
  static const TextStyle manifestoStyle = TextStyle(
    fontFamily: 'SpaceGrotesk',
    color: AurelianPalette.champagneGold,
    fontWeight: FontWeight.w300,
    letterSpacing: 2.0,
    height: 1.6,
  );

  // --- Display Hierarchy ---
  static TextStyle get displayHero => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 48.0,
        fontWeight: FontWeight.w700,
        color: AurelianPalette.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 36.0,
        fontWeight: FontWeight.w600,
        color: AurelianPalette.textPrimary,
        letterSpacing: 0.0,
      );

  // --- Title Hierarchy ---
  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        color: AurelianPalette.textPrimary,
        letterSpacing: 0.25,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: AurelianPalette.textPrimary,
        letterSpacing: 0.15,
      );

  // --- Body Text ---
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: AurelianPalette.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AurelianPalette.textSecondary,
        letterSpacing: 0.25,
      );

  // --- Interactive / Button ---
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AurelianPalette.champagneGold,
        letterSpacing: 1.25,
      );
}

/// Aurelian ThemeData — Complete Material 3 theme configuration
abstract final class AurelianTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AurelianPalette.ivory,
      colorScheme: const ColorScheme.light(
        primary: AurelianPalette.champagneGold,
        onPrimary: AurelianPalette.textPrimary,
        secondary: AurelianPalette.softRose,
        onSecondary: AurelianPalette.textPrimary,
        surface: AurelianPalette.alabaster,
        onSurface: AurelianPalette.textPrimary,
        surfaceContainerHighest: AurelianPalette.ivoryDark,
        error: AurelianPalette.danger,
        onError: AurelianPalette.ivory,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AurelianPalette.ivory,
        foregroundColor: AurelianPalette.textPrimary,
        elevation: 0.0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AurelianPalette.alabaster,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AurelianPalette.champagneGold,
          foregroundColor: AurelianPalette.textPrimary,
          minimumSize: const Size(double.infinity, 56.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          elevation: 0.0,
        ),
      ),
      textTheme: _buildTextTheme(),
      dividerColor: AurelianPalette.textTertiary.withValues(alpha: 0.3),
      iconTheme: const IconThemeData(color: AurelianPalette.champagneGold),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: AurelianTypography.displayHero,
      displayMedium: AurelianTypography.displayLarge,
      headlineLarge: AurelianTypography.titleLarge,
      headlineMedium: AurelianTypography.titleMedium,
      bodyLarge: AurelianTypography.bodyLarge,
      bodyMedium: AurelianTypography.bodyMedium,
      labelLarge: AurelianTypography.labelLarge,
    );
  }
}
