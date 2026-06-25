import 'package:flutter/material.dart';

import 'styliste_colors.dart';

enum StylisteVisualMode {
  editorialLight,
  noirCinematic,
  executiveObsidian,
  atelierWarmStudio,
}

extension StylisteVisualModePalette on StylisteVisualMode {
  Color get background {
    return switch (this) {
      StylisteVisualMode.editorialLight => StylisteColors.ivory,
      StylisteVisualMode.noirCinematic => StylisteColors.obsidian,
      StylisteVisualMode.executiveObsidian => StylisteColors.obsidian,
      StylisteVisualMode.atelierWarmStudio => StylisteColors.alabaster,
    };
  }

  Color get surface {
    return switch (this) {
      StylisteVisualMode.editorialLight => StylisteColors.alabaster,
      StylisteVisualMode.noirCinematic => StylisteColors.surfaceNoir,
      StylisteVisualMode.executiveObsidian => StylisteColors.surfaceNoir,
      StylisteVisualMode.atelierWarmStudio => StylisteColors.surfaceGlass,
    };
  }

  Color get text {
    return switch (this) {
      StylisteVisualMode.editorialLight => StylisteColors.textPrimary,
      StylisteVisualMode.noirCinematic => StylisteColors.ivory,
      StylisteVisualMode.executiveObsidian => StylisteColors.ivory,
      StylisteVisualMode.atelierWarmStudio => StylisteColors.textPrimary,
    };
  }

  Color get secondaryText {
    return switch (this) {
      StylisteVisualMode.editorialLight => StylisteColors.textSecondary,
      StylisteVisualMode.noirCinematic => StylisteColors.alabaster,
      StylisteVisualMode.executiveObsidian => StylisteColors.alabaster,
      StylisteVisualMode.atelierWarmStudio => StylisteColors.textSecondary,
    };
  }

  Color get accent {
    return switch (this) {
      StylisteVisualMode.editorialLight => StylisteColors.deepGold,
      StylisteVisualMode.noirCinematic => StylisteColors.champagneGold,
      StylisteVisualMode.executiveObsidian => StylisteColors.champagneGold,
      StylisteVisualMode.atelierWarmStudio => StylisteColors.deepGold,
    };
  }

  Color get danger => StylisteColors.rivalRed;

  Color get profit => StylisteColors.profitGreen;

  bool get isDark {
    return switch (this) {
      StylisteVisualMode.editorialLight => false,
      StylisteVisualMode.noirCinematic => true,
      StylisteVisualMode.executiveObsidian => true,
      StylisteVisualMode.atelierWarmStudio => false,
    };
  }
}
