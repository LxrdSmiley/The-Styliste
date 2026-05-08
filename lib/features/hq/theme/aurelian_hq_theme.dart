// Directive F — Aurelian HQ Theme
// Golden Hour aesthetic system for the Glass-Walled Penthouse
// GDD §3.0 — Champagne-gold gradients, ivory marble, soft rose accents

import 'package:flutter/material.dart';

/// Golden Hour palette extensions for HQ Dashboard
/// 
/// The penthouse environment evolves with Brand Rank:
/// - Higher floors, bigger windows, richer materials as rank increases
/// - Warm champagne-gold sunlight streaming through floor-to-ceiling windows
/// - Ivory marble surfaces with soft rose accents
class AurelianHQTheme {
  const AurelianHQTheme._();

  // --- Golden Hour Gradients ---
  
  /// Main penthouse background: warm sunlight gradient
  static const LinearGradient penthouseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFFF8F0), // Warm ivory
      Color(0xFFFAF0E6), // Champagne base
      Color(0xFFF5E6D3), // Deeper gold
    ],
    stops: <double>[0.0, 0.5, 1.0],
  );

  /// Golden hour sunlight streaming through windows
  static const LinearGradient sunlightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFFF7E7CE), // Champagne gold
      Color(0xFFF7E7CE).withValues(alpha: 0.3),
      Colors.transparent,
    ],
  );

  /// Empire Pulse graph gradient (champagne-gold glow)
  static const LinearGradient empirePulseGradient = LinearGradient(
    colors: <Color>[
      Color(0xFFF7E7CE),
      Color(0xFFE8D4B8),
    ],
  );

  /// Sun-Dial Hype Meter gradient (white → champagne-gold)
  static const SweepGradient sunDialGradient = SweepGradient(
    center: Alignment.center,
    startAngle: 0.0,
    endAngle: 3.14159 * 2,
    colors: <Color>[
      Colors.white,
      Color(0xFFF7E7CE),
      Color(0xFFE8D4B8),
      Color(0xFFF7E7CE),
      Colors.white,
    ],
  );

  // --- Brand Heat Meter Gradients ---
  
  /// 0-100 brand heat gradient: cool-grey → champagne-gold
  static LinearGradient brandHeatGradient(double heatPercent) {
    return LinearGradient(
      colors: <Color>[
        const Color(0xFF8A8A8A), // Cool grey (cold)
        const Color(0xFFB8B8B8), // Warm grey
        const Color(0xFFE8D4B8), // Champagne
        const Color(0xFFF7E7CE), // Gold (hot)
      ],
      stops: <double>[0.0, 0.3, 0.7, heatPercent.clamp(0.0, 1.0)],
    );
  }

  // --- Surface Colors ---
  
  /// Ivory marble surface
  static const Color marbleSurface = Color(0xFFFAF7F0);
  
  /// Richer marble for higher ranks
  static const Color marblePremium = Color(0xFFF5F0E8);
  
  /// Glass reflection tint
  static const Color glassTint = Color(0x14F7E7CE); // 8% champagne
  
  /// Soft rose accent
  static const Color roseAccent = Color(0xFFFFB7C5);
  
  /// Obsidian crack color (for tarnish state 0-25)
  static const Color obsidianCrack = Color(0xFF1A1A1A);

  // --- Typography ---
  
  /// Rank display text style
  static TextStyle rankStyle(int rank) {
    return TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: rank >= 50 ? 14.0 : 12.0,
      fontWeight: rank >= 100 ? FontWeight.w200 : FontWeight.w400,
      letterSpacing: 3.0,
      color: const Color(0xFF2A2A2A),
    );
  }

  /// Penthouse address text ("Floor 47, Manhattan")
  static TextStyle penthouseAddress(int rank) {
    final int floor = (rank / 2).clamp(1, 100).toInt();
    return TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 10.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 2.0,
      color: const Color(0xFF666666),
    );
  }

  // --- Rank-Based Visual Evolution ---
  
  /// Window size factor based on rank (0.5 = small, 1.0 = penthouse)
  static double windowScale(int rank) {
    return 0.5 + ((rank / 100.0) * 0.5);
  }
  
  /// Floor height visualization
  static String floorLabel(int rank) {
    final int floor = ((rank / 100.0) * 99 + 1).toInt();
    return 'F$floor';
  }
  
  /// Material richness tier
  static MaterialTier materialTier(int rank) {
    if (rank >= 80) return MaterialTier.alabaster;
    if (rank >= 50) return MaterialTier.marble;
    if (rank >= 25) return MaterialTier.glass;
    return MaterialTier.concrete;
  }
}

/// Material richness tiers for HQ evolution
enum MaterialTier {
  concrete,  // Ranks 1-24: Startup studio
  glass,     // Ranks 25-49: First proper office
  marble,    // Ranks 50-79: Premium penthouse
  alabaster, // Ranks 80-100: Sovereign suite
}

extension MaterialTierExtension on MaterialTier {
  String get displayName {
    switch (this) {
      case MaterialTier.concrete:
        return 'The Studio';
      case MaterialTier.glass:
        return 'The Atelier';
      case MaterialTier.marble:
        return 'The Penthouse';
      case MaterialTier.alabaster:
        return 'The Sovereign Suite';
    }
  }
  
  Color get surfaceColor {
    switch (this) {
      case MaterialTier.concrete:
        return const Color(0xFFE8E8E8);
      case MaterialTier.glass:
        return const Color(0xFFF5F5F5);
      case MaterialTier.marble:
        return const Color(0xFFFAF7F0);
      case MaterialTier.alabaster:
        return const Color(0xFFFFFFF8);
    }
  }
}

/// Brand heat states with visual treatments
enum BrandHeatState {
  cold,      // 0-25: Obsidian cracks
  cool,      // 26-50: Grey tones
  warm,      // 51-75: Champagne emergence
  iconic,    // 76-100: Gold pulse
}

extension BrandHeatStateExtension on BrandHeatState {
  static BrandHeatState fromPercent(int percent) {
    if (percent <= 25) return BrandHeatState.cold;
    if (percent <= 50) return BrandHeatState.cool;
    if (percent <= 75) return BrandHeatState.warm;
    return BrandHeatState.iconic;
  }
  
  bool get hasCracks => this == BrandHeatState.cold;
  bool get hasPulse => this == BrandHeatState.iconic;
  
  Color get primaryColor {
    switch (this) {
      case BrandHeatState.cold:
        return const Color(0xFF8A8A8A);
      case BrandHeatState.cool:
        return const Color(0xFFB8B8B8);
      case BrandHeatState.warm:
        return const Color(0xFFE8D4B8);
      case BrandHeatState.iconic:
        return const Color(0xFFF7E7CE);
    }
  }
}
