import 'package:flutter/widgets.dart';

import '../../theme/tchip_spacing.dart';

enum LayoutSize { phone, tablet }

extension LayoutSizeOf on BuildContext {
  /// Tablet layout from [TchipBreakpoints.tablet] logical pixels of width.
  LayoutSize get layoutSize =>
      MediaQuery.sizeOf(this).width >= TchipBreakpoints.tablet
      ? LayoutSize.tablet
      : LayoutSize.phone;

  bool get isTablet => layoutSize == LayoutSize.tablet;
}
