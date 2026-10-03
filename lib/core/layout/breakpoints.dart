import 'package:flutter/widgets.dart';

import '../../theme/tchip_spacing.dart';

enum LayoutSize { phone, tablet }

extension LayoutSizeOf on BuildContext {
  /// Tablet layout from [TchipBreakpoints.tablet] logical pixels of width,
  /// on devices whose short side is tablet-sized: a phone in landscape keeps
  /// the phone layout.
  LayoutSize get layoutSize {
    final size = MediaQuery.sizeOf(this);
    return size.width >= TchipBreakpoints.tablet &&
            size.shortestSide >= TchipBreakpoints.tabletShortestSide
        ? LayoutSize.tablet
        : LayoutSize.phone;
  }

  bool get isTablet => layoutSize == LayoutSize.tablet;
}
