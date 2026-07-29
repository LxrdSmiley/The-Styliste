import 'package:flutter/material.dart';

abstract final class StylisteMotion {
  static const Duration microMin = Duration(milliseconds: 150);
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration microMax = Duration(milliseconds: 300);

  static const Duration screenTransitionMin = Duration(milliseconds: 250);
  static const Duration screenTransition = Duration(milliseconds: 300);
  static const Duration screenTransitionMax = Duration(milliseconds: 400);

  static const Duration cinematicRevealMax = Duration(milliseconds: 700);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve entranceCurve = Curves.easeInOutCubic;

  static Duration resolve(
    BuildContext context,
    Duration duration,
  ) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
