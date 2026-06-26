import 'package:flutter/material.dart';

abstract final class StylisteText {
  static const TextStyle displayEditorial = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    height: 1.04,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 20.0,
    fontWeight: FontWeight.w800,
    height: 1.12,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.0,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );
}
