// GDD §1.1 — Brand colour palette for The Styliste
// Obsidian Gate aesthetic: deep blacks, gold, lime green accents

import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Primary Brand Palette ---
  static const Color obsidian = Color(0xFF0A0A0A);
  static const Color obsidianSurface = Color(0xFF141414);
  static const Color obsidianCard = Color(0xFF1C1C1C);

  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldDark = Color(0xFF9A7A2E);

  static const Color ivory = Color(0xFFFAF7F0);
  static const Color ivoryMuted = Color(0xFFE8E3D8);

  // --- Mogul Path: Lime Green ---
  static const Color lime = Color(0xFFC8FF00);
  static const Color limeGlow = Color(0xFFDEFF4D);
  static const Color limeDark = Color(0xFF8EBF00);

  // --- Designer Path: Warm White / Cream ---
  static const Color cream = Color(0xFFF5F0E8);
  static const Color creamDark = Color(0xFFD4C9B4);

  // --- Semantic Colours ---
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // --- Feed / Social Colours ---
  static const Color hype = Color(0xFFFF6B35);     // hype meter orange
  static const Color heat = Color(0xFFFF3366);     // brand heat red
  static const Color rival = Color(0xFFFF1744);    // rival red glow

  // --- Neutral Greys ---
  static const Color grey900 = Color(0xFF1A1A1A);
  static const Color grey800 = Color(0xFF2A2A2A);
  static const Color grey700 = Color(0xFF3A3A3A);
  static const Color grey600 = Color(0xFF4A4A4A);
  static const Color grey400 = Color(0xFF8A8A8A);
  static const Color grey200 = Color(0xFFCACACA);
  static const Color grey100 = Color(0xFFEAEAEA);

  // --- Transparency helpers ---
  static const Color transparent = Colors.transparent;
  static Color goldWithOpacity(double opacity) => gold.withValues(alpha: opacity);
  static Color limeWithOpacity(double opacity) => lime.withValues(alpha: opacity);
}
