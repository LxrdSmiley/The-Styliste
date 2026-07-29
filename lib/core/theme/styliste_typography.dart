import 'package:flutter/material.dart';

abstract final class StylisteText {
  static const String displayFamily = 'SpaceGrotesk';
  static const String bodyFamily = 'Inter';
  static const String metricFamily = 'JetBrainsMono';

  static const TextStyle displayHero = TextStyle(
    fontFamily: displayFamily,
    fontSize: 42.0,
    fontWeight: FontWeight.w700,
    height: 0.98,
    letterSpacing: -1.1,
  );

  static const TextStyle displayEditorial = TextStyle(
    fontFamily: displayFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    height: 1.04,
    letterSpacing: -0.55,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: displayFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.1,
  );

  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: displayFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.35,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: metricFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: metricFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.42,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.38,
  );
}
