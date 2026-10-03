import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/tchip_colors.dart';

/// Categories created on first launch. Their id in the `categories` table is
/// [index] + 1; the name shown follows the app language.
enum DefaultCategory {
  food(TchipColors.food, Icons.restaurant_outlined),
  transport(TchipColors.transport, Icons.two_wheeler_outlined),
  bundles(TchipColors.bundles, Icons.wifi),
  family(TchipColors.family, Icons.people_outline),
  leisure(TchipColors.leisure, Icons.sports_esports_outlined),
  other(TchipColors.other, Icons.more_horiz);

  const DefaultCategory(this.color, this.icon);

  final Color color;
  final IconData icon;

  int get id => index + 1;

  static DefaultCategory? byId(int? id) =>
      id == null || id < 1 || id > values.length ? null : values[id - 1];

  String label(AppLocalizations l) => switch (this) {
    food => l.catFood,
    transport => l.catTransport,
    bundles => l.catBundles,
    family => l.catFamily,
    leisure => l.catLeisure,
    other => l.catOther,
  };
}
