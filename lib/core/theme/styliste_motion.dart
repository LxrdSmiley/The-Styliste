import 'package:flutter/animation.dart';

abstract final class StylisteMotion {
  static const Duration microMin = Duration(milliseconds: 120);
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration microMax = Duration(milliseconds: 220);

  static const Duration screenTransitionMin = Duration(milliseconds: 250);
  static const Duration screenTransition = Duration(milliseconds: 350);
  static const Duration screenTransitionMax = Duration(milliseconds: 450);

  static const Duration cinematicRevealMax = Duration(milliseconds: 900);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve entranceCurve = Curves.easeInOutCubic;
}
