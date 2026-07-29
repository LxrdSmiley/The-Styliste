abstract final class StylisteSpacing {
  static const double unit = 4.0;
  static const double xxs = unit;
  static const double xs = unit * 2;
  static const double sm = unit * 3;
  static const double md = unit * 4;
  static const double lg = unit * 6;
  static const double xl = unit * 8;
  static const double xxl = unit * 12;
  static const double safeMargin = 24.0;
  static const double gutter = 16.0;
  static const double stackSm = 8.0;
  static const double stackMd = 16.0;
  static const double stackLg = 32.0;
  static const double minTapTarget = 48.0;
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 28.0;

  static double pageInset(double width) {
    if (width <= 340.0) return md;
    if (width <= 520.0) return lg;
    return xl;
  }
}
