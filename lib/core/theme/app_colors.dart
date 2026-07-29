// Legacy compatibility only. Reachable UI imports StylisteColors directly.

import 'package:flutter/material.dart';

import 'styliste_colors.dart';

@Deprecated('Import StylisteColors directly in reachable UI.')
abstract final class AppColors {
  static const Color obsidian = StylisteColors.obsidian;
  static const Color obsidianSurface = StylisteColors.obsidianSurface;
  static const Color obsidianCard = StylisteColors.obsidianRaised;
  static const Color gold = StylisteColors.champagneGold;
  static const Color goldLight = StylisteColors.paleGold;
  static const Color goldDark = StylisteColors.deepGold;
  static const Color ivory = StylisteColors.ivory;
  static const Color ivoryMuted = StylisteColors.warmGreyLight;
  static const Color lime = StylisteColors.signalLime;
  static const Color limeGlow = StylisteColors.signalLime;
  static const Color limeDark = StylisteColors.profitGreen;
  static const Color cream = StylisteColors.alabaster;
  static const Color creamDark = StylisteColors.warmGrey;
  static const Color success = StylisteColors.profitGreen;
  static const Color warning = StylisteColors.warningAmber;
  static const Color danger = StylisteColors.rivalRed;
  static const Color info = StylisteColors.informationBlue;
  static const Color hype = StylisteColors.hypeAmber;
  static const Color heat = StylisteColors.rivalRed;
  static const Color rival = StylisteColors.rivalRed;
  static const Color grey900 = StylisteColors.obsidianSurface;
  static const Color grey800 = StylisteColors.obsidianRaised;
  static const Color grey700 = StylisteColors.outlineDark;
  static const Color grey600 = StylisteColors.warmGreyDark;
  static const Color grey400 = StylisteColors.textTertiary;
  static const Color grey200 = StylisteColors.warmGrey;
  static const Color grey100 = StylisteColors.warmGreyLight;
  static const Color transparent = StylisteColors.transparent;

  static Color goldWithOpacity(double opacity) =>
      gold.withValues(alpha: opacity);
  static Color limeWithOpacity(double opacity) =>
      lime.withValues(alpha: opacity);
}
