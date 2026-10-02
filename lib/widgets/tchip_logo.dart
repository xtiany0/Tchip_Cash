import 'package:flutter/material.dart';

import '../theme/tchip_theme.dart';

/// "Tchip !" with a narrow no-break space and the "!" in yellow.
class TchipLogo extends StatelessWidget {
  const TchipLogo({super.key, this.size = 22, this.compact = false});

  final double size;

  /// "T!" for the tablet rail.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = TchipText.title.copyWith(
      fontSize: size,
      letterSpacing: -size * 0.02,
    );
    return Semantics(
      label: 'Tchip !',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: compact ? 'T' : 'Tchip\u202F'),
            const TextSpan(
              text: '!',
              style: TextStyle(color: TchipColors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}
