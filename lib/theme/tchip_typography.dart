import 'package:flutter/material.dart';

import 'tchip_colors.dart';

/// Geist for the interface, Geist Mono for amounts. Both are bundled in
/// assets/fonts so the app never fetches fonts over the network.
abstract final class TchipFonts {
  static const sans = 'Geist';
  static const mono = 'GeistMono';
}

abstract final class TchipText {
  static const _base = TextStyle(
    fontFamily: TchipFonts.sans,
    color: TchipColors.text,
    height: 1.3,
  );

  static final display = _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.15,
  );
  static final title = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static final titleSmall = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static final section = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final body = _base.copyWith(fontSize: 15);
  static final bodyStrong = body.copyWith(fontWeight: FontWeight.w600);
  static final bodySmall = _base.copyWith(fontSize: 14);
  static final caption = _base.copyWith(
    fontSize: 12,
    color: TchipColors.textSecondary,
  );
  static final overline = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: TchipColors.textSecondary,
    letterSpacing: 0.8,
  );
  static final navLabel = _base.copyWith(fontSize: 11);

  /// Amounts. Size varies, so pass it in.
  static TextStyle amount(double size, {Color? color}) => TextStyle(
    fontFamily: TchipFonts.mono,
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: size >= 26 ? -size * 0.03 : 0,
    color: color ?? TchipColors.text,
    height: 1.2,
  );

  static TextStyle amountLight(double size, {Color? color}) =>
      amount(size, color: color).copyWith(fontWeight: FontWeight.w500);
}
