// GDD v8 §§18.1–18.4 — canonical Aurelian Radiance theme wiring.
//
// StylisteColors, StylisteText, StylisteSpacing, StylisteRadii,
// StylisteMotion, and StylisteVisualMode are the only independent visual
// token sources. The legacy palette and typography names below are read-only
// compatibility facades while reachable surfaces migrate.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'styliste_colors.dart';
import 'styliste_radii.dart';
import 'styliste_spacing.dart';
import 'styliste_typography.dart';
import 'styliste_visual_mode.dart';

@Deprecated('Import StylisteColors directly in reachable UI.')
abstract final class AurelianPalette {
  static const Color ivory = StylisteColors.ivory;
  static const Color champagneGold = StylisteColors.champagneGold;
  static const Color softRose = StylisteColors.roseAccent;
  static const Color alabaster = StylisteColors.alabaster;
  static const Color ivoryDark = StylisteColors.warmGreyLight;
  static const Color champagneGoldLight = StylisteColors.paleGold;
  static const Color champagneGoldDark = StylisteColors.deepGold;
  static const Color softRoseMuted = StylisteColors.roseMuted;
  static const Color success = StylisteColors.profitGreen;
  static const Color warning = StylisteColors.warningAmber;
  static const Color danger = StylisteColors.rivalRed;
  static const Color info = StylisteColors.informationBlue;
  static const Color textPrimary = StylisteColors.textPrimary;
  static const Color textSecondary = StylisteColors.textSecondary;
  static const Color textTertiary = StylisteColors.textTertiary;

  static Color ivoryWithOpacity(double opacity) =>
      ivory.withValues(alpha: opacity);
  static Color champagneWithOpacity(double opacity) =>
      champagneGold.withValues(alpha: opacity);
  static Color roseWithOpacity(double opacity) =>
      softRose.withValues(alpha: opacity);
}

@Deprecated('Import StylisteText directly in reachable UI.')
abstract final class AurelianTypography {
  static TextStyle get manifestoStyle => StylisteText.bodyLarge.copyWith(
        color: StylisteColors.champagneGold,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
        height: 1.55,
      );

  static TextStyle get displayHero => StylisteText.displayHero.copyWith(
        color: StylisteColors.textPrimary,
      );

  static TextStyle get displayLarge => StylisteText.displayEditorial.copyWith(
        color: StylisteColors.textPrimary,
      );

  static TextStyle get titleLarge => StylisteText.headline.copyWith(
        color: StylisteColors.textPrimary,
      );

  static TextStyle get titleMedium => StylisteText.title.copyWith(
        color: StylisteColors.textPrimary,
      );

  static TextStyle get bodyLarge => StylisteText.bodyLarge.copyWith(
        color: StylisteColors.textSecondary,
      );

  static TextStyle get bodyMedium => StylisteText.body.copyWith(
        color: StylisteColors.textSecondary,
      );

  static TextStyle get labelLarge => StylisteText.labelCaps.copyWith(
        color: StylisteColors.deepGold,
      );
}

abstract final class AurelianTheme {
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: StylisteColors.ivory,
        surface: StylisteColors.alabaster,
        elevatedSurface: StylisteColors.warmGreyLight,
        foreground: StylisteColors.textPrimary,
        secondaryForeground: StylisteColors.textSecondary,
        accent: StylisteColors.deepGold,
        accentSurface: StylisteColors.paleGold,
        outline: StylisteColors.outlineSubtle,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: StylisteColors.obsidian,
        surface: StylisteColors.obsidianSurface,
        elevatedSurface: StylisteColors.obsidianRaised,
        foreground: StylisteColors.ivory,
        secondaryForeground: StylisteColors.warmGrey,
        accent: StylisteColors.champagneGold,
        accentSurface: StylisteColors.deepGold,
        outline: StylisteColors.outlineDark,
      );

  static ThemeData forMode(StylisteVisualMode mode) {
    return mode.isDark ? darkTheme : lightTheme;
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color elevatedSurface,
    required Color foreground,
    required Color secondaryForeground,
    required Color accent,
    required Color accentSurface,
    required Color outline,
  }) {
    final bool dark = brightness == Brightness.dark;
    final Color onAccent =
        dark ? StylisteColors.textPrimary : StylisteColors.ivory;
    final ColorScheme colors = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: accentSurface,
      onPrimaryContainer:
          dark ? StylisteColors.ivory : StylisteColors.textPrimary,
      secondary: StylisteColors.roseAccent,
      onSecondary: StylisteColors.textPrimary,
      secondaryContainer: StylisteColors.roseMuted,
      onSecondaryContainer: StylisteColors.textPrimary,
      tertiary: StylisteColors.informationBlue,
      onTertiary: StylisteColors.ivory,
      error: StylisteColors.rivalRed,
      onError: StylisteColors.ivory,
      surface: surface,
      onSurface: foreground,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.58),
      shadow: StylisteColors.obsidian.withValues(alpha: 0.24),
      scrim: StylisteColors.obsidian.withValues(alpha: 0.56),
      inverseSurface:
          dark ? StylisteColors.ivory : StylisteColors.obsidianSurface,
      onInverseSurface:
          dark ? StylisteColors.textPrimary : StylisteColors.ivory,
      inversePrimary:
          dark ? StylisteColors.deepGold : StylisteColors.champagneGold,
      surfaceTint: StylisteColors.transparent,
    );

    final TextTheme textTheme = TextTheme(
      displayLarge: StylisteText.displayHero.copyWith(color: foreground),
      displayMedium: StylisteText.displayEditorial.copyWith(color: foreground),
      headlineLarge: StylisteText.headline.copyWith(color: foreground),
      headlineMedium: StylisteText.title.copyWith(color: foreground),
      titleLarge: StylisteText.title.copyWith(color: foreground),
      bodyLarge: StylisteText.bodyLarge.copyWith(color: foreground),
      bodyMedium: StylisteText.body.copyWith(color: foreground),
      bodySmall: StylisteText.bodySmall.copyWith(
        color: secondaryForeground,
      ),
      labelLarge: StylisteText.labelCaps.copyWith(color: foreground),
    );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(StylisteRadii.control),
      borderSide: BorderSide(color: outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: StylisteText.bodyFamily,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      colorScheme: colors,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: StylisteColors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: StylisteText.title.copyWith(color: foreground),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: StylisteColors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: StylisteColors.transparent,
              ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: StylisteColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StylisteRadii.card),
          side: BorderSide(color: outline.withValues(alpha: 0.58)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StylisteSpacing.md,
          vertical: StylisteSpacing.md,
        ),
        labelStyle: StylisteText.body.copyWith(color: secondaryForeground),
        hintStyle: StylisteText.body.copyWith(color: secondaryForeground),
        errorStyle:
            StylisteText.bodySmall.copyWith(color: StylisteColors.rivalRed),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: StylisteColors.rivalRed),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide:
              const BorderSide(color: StylisteColors.rivalRed, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            StylisteSpacing.minTapTarget,
            StylisteSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StylisteSpacing.md,
            vertical: StylisteSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StylisteRadii.control),
          ),
          textStyle: StylisteText.labelCaps,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            StylisteSpacing.minTapTarget,
            StylisteSpacing.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StylisteSpacing.md,
            vertical: StylisteSpacing.sm,
          ),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StylisteRadii.control),
          ),
          textStyle: StylisteText.labelCaps,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            StylisteSpacing.minTapTarget,
            StylisteSpacing.minTapTarget,
          ),
          textStyle: StylisteText.labelCaps,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(StylisteSpacing.minTapTarget),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: dark ? 0.22 : 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) => StylisteText.labelCaps.copyWith(
            color: states.contains(WidgetState.selected)
                ? accent
                : secondaryForeground,
            fontSize: 9.5,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? accent
                : secondaryForeground,
            size: StylisteSpacing.iconMd,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: StylisteColors.transparent,
        modalBackgroundColor: surface,
        modalBarrierColor: StylisteColors.obsidian.withValues(alpha: 0.56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StylisteRadii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: StylisteColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StylisteRadii.card),
          side: BorderSide(color: outline),
        ),
      ),
      dividerColor: outline.withValues(alpha: 0.58),
      focusColor: accent.withValues(alpha: 0.22),
      hoverColor: accent.withValues(alpha: 0.08),
      highlightColor: accent.withValues(alpha: 0.12),
    );
  }
}
