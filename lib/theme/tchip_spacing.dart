import 'package:flutter/widgets.dart';

/// Spacing, radii and sizes taken from the maquette.
abstract final class TchipSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;

  /// Side padding of phone screens.
  static const screen = 20.0;

  /// Vertical gap between blocks on a screen.
  static const section = 18.0;

  /// Minimum touch target (accessibility).
  static const touch = 48.0;

  static const iconButton = 44.0;
  static const fab = 52.0;
  static const bottomNavHeight = 84.0;
  static const railWidth = 96.0;
}

abstract final class TchipRadii {
  static const sm = 10.0;
  static const md = 12.0;
  static const lg = 14.0;
  static const xl = 16.0;
  static const card = 18.0;
  static const hero = 20.0;
  static const sheet = 24.0;
  static const pill = 999.0;

  static BorderRadius all(double r) => BorderRadius.circular(r);
}

/// Layout breakpoints, in logical pixels of the available width.
abstract final class TchipBreakpoints {
  /// From this width the app switches to the tablet layout (NavigationRail).
  static const tablet = 840.0;

  /// Short side from which a device counts as a tablet.
  static const tabletShortestSide = 600.0;

  /// Smallest width the layout must support without clipping.
  static const minPhone = 320.0;
}
