import 'package:flutter/material.dart';

import '../theme/tchip_theme.dart';

/// Rounded budget bar: [fill] from 0 to 1 on a dark track.
class TchipProgressBar extends StatelessWidget {
  const TchipProgressBar({
    super.key,
    required this.fill,
    required this.color,
    this.height = 6,
  });

  final double fill;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: TchipRadii.all(TchipRadii.pill),
    child: SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: TchipColors.track),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fill.clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: TchipRadii.all(TchipRadii.pill),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
