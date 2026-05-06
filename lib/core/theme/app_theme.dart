// GDD §3.0 — Premium dark/light ThemeData for The Styliste
// Visual language: noir-cinematic, fashion-forward, high-contrast

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  // --- Dark Theme (primary — GDD aesthetic) ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidian,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.obsidian,
        secondary: AppColors.lime,
        onSecondary: AppColors.obsidian,
        surface: AppColors.obsidianCard,
        onSurface: AppColors.ivory,
        error: AppColors.danger,
        onError: AppColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidian,
        foregroundColor: AppColors.ivory,
        elevation: 0.0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: AppColors.transparent,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.obsidianCard,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.obsidian,
          minimumSize: const Size(double.infinity, 52.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
      textTheme: _buildTextTheme(baseColor: AppColors.ivory),
      dividerColor: AppColors.grey700,
      iconTheme: const IconThemeData(color: AppColors.ivory),
    );
  }

  // --- Light Theme (accessibility / settings option) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.goldDark,
        onPrimary: AppColors.ivory,
        secondary: AppColors.limeDark,
        onSecondary: AppColors.obsidian,
        surface: AppColors.grey100,
        onSurface: AppColors.obsidian,
        error: AppColors.danger,
        onError: AppColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.obsidian,
        elevation: 0.0,
        centerTitle: true,
      ),
      textTheme: _buildTextTheme(baseColor: AppColors.obsidian),
      dividerColor: AppColors.grey200,
      iconTheme: const IconThemeData(color: AppColors.obsidian),
    );
  }

  static TextTheme _buildTextTheme({required Color baseColor}) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57.0,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45.0,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 1.25,
      ),
    );
  }
}
