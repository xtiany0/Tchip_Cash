import 'package:flutter/material.dart';

/// Every colour used by the app. Widgets read colours from here, never inline.
abstract final class TchipColors {
  // Surfaces (dark mode is the default and only theme in v1).
  static const background = Color(0xFF121212);
  static const card = Color(0xFF1B1B1B);
  static const cardRaised = Color(0xFF1E1E1E);
  static const bubble = Color(0xFF242424);
  static const navBar = Color(0xFF161616);
  static const border = Color(0xFF262626);
  static const borderStrong = Color(0xFF2E2E2E);
  static const track = Color(0xFF2A2A2A);
  static const trackMuted = Color(0xFF3A3A3A);
  static const switchOff = Color(0xFF333333);
  static const radioOff = Color(0xFF555555);

  // Text.
  static const text = Color(0xFFF2F2F2);
  static const textSoft = Color(0xFFD0D0D0);
  static const textMuted = Color(0xFFB5B5B5);
  static const textSecondary = Color(0xFF9A9A9A);

  // Brand yellow. Never put yellow text on a white background.
  static const yellow = Color(0xFFE8B931);
  static const yellowLight = Color(0xFFFBF1D3);
  static const yellowDark = Color(0xFFA87F12);
  static const onYellow = Color(0xFF1F1B10);
  static const yellowDashed = Color(0xFF5A4A1A);

  /// Yellow at 14 %, behind small yellow icons.
  static const yellowTint = Color(0x24E8B931);

  // Budget states: base colour for bars and fills, light tone for text on dark.
  static const ok = Color(0xFF2E9E6A);
  static const okText = Color(0xFF4CC28A);
  static const warning = Color(0xFFE07A2E);
  static const warningText = Color(0xFFF0954F);
  static const over = Color(0xFFD64545);
  static const overText = Color(0xFFF07070);

  // Categories.
  static const food = Color(0xFF7FB7FF);
  static const transport = Color(0xFFC79BFF);
  static const bundles = Color(0xFF5FD0C4);
  static const family = Color(0xFFFF9DB8);
  static const leisure = Color(0xFFD7C96A);
  static const other = Color(0xFF9A9A9A);
}

/// Budget state of a cap, derived from spent / cap.
enum BudgetState {
  ok,
  warning,
  over;

  static BudgetState of(int spent, int cap) {
    if (cap <= 0) return spent > 0 ? over : ok;
    if (spent > cap) return over;
    return spent * 100 >= cap * 80 ? warning : ok;
  }

  Color get bar => switch (this) {
    ok => TchipColors.ok,
    warning => TchipColors.warning,
    over => TchipColors.over,
  };

  Color get text => switch (this) {
    ok => TchipColors.okText,
    warning => TchipColors.warningText,
    over => TchipColors.overText,
  };
}
