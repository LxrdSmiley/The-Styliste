// Legacy ThemeData entry points delegate to the canonical Aurelian theme.

import 'package:flutter/material.dart';

import 'aurelian_theme.dart';

@Deprecated('Use AurelianTheme directly.')
abstract final class AppTheme {
  static ThemeData get darkTheme => AurelianTheme.darkTheme;
  static ThemeData get lightTheme => AurelianTheme.lightTheme;
}
