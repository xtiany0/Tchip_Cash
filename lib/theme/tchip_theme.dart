import 'package:flutter/material.dart';
import 'package:hux/hux.dart';

import 'tchip_colors.dart';
import 'tchip_spacing.dart';
import 'tchip_typography.dart';

export 'tchip_colors.dart';
export 'tchip_spacing.dart';
export 'tchip_typography.dart';

/// App theme: Hux dark theme as a base, overridden with the Tchip palette.
abstract final class TchipTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: TchipColors.yellow,
      onPrimary: TchipColors.onYellow,
      primaryContainer: TchipColors.yellowLight,
      onPrimaryContainer: TchipColors.onYellow,
      secondary: TchipColors.yellowLight,
      onSecondary: TchipColors.onYellow,
      surface: TchipColors.background,
      onSurface: TchipColors.text,
      onSurfaceVariant: TchipColors.textSecondary,
      surfaceContainer: TchipColors.card,
      surfaceContainerHigh: TchipColors.cardRaised,
      outline: TchipColors.borderStrong,
      outlineVariant: TchipColors.border,
      error: TchipColors.over,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: TchipRadii.all(TchipRadii.lg),
    );

    return HuxTheme.darkTheme.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: TchipColors.background,
      canvasColor: TchipColors.background,
      dividerColor: TchipColors.border,
      textTheme: _textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: TchipColors.yellow,
              foregroundColor: TchipColors.onYellow,
              minimumSize: const Size(TchipSpacing.touch, 52),
              shape: buttonShape,
              textStyle: TchipText.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ).copyWith(
              overlayColor: const WidgetStatePropertyAll(
                TchipColors.yellowDark,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TchipColors.text,
          minimumSize: const Size(TchipSpacing.touch, TchipSpacing.touch),
          side: const BorderSide(color: TchipColors.borderStrong),
          shape: buttonShape,
          textStyle: TchipText.body.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TchipColors.yellow,
          minimumSize: const Size(TchipSpacing.touch, TchipSpacing.touch),
          textStyle: TchipText.bodySmall,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TchipColors.card,
        hintStyle: TchipText.body.copyWith(color: TchipColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: _inputBorder(TchipColors.borderStrong),
        enabledBorder: _inputBorder(TchipColors.borderStrong),
        focusedBorder: _inputBorder(TchipColors.yellow),
      ),
      cardTheme: CardThemeData(
        color: TchipColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: TchipRadii.all(TchipRadii.card),
          side: const BorderSide(color: TchipColors.border),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? TchipColors.onYellow
              : TchipColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? TchipColors.yellow
              : TchipColors.switchOff,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? TchipColors.yellow
              : TchipColors.radioOff,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: TchipColors.navBar,
        indicatorColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: TchipColors.yellow),
        unselectedIconTheme: const IconThemeData(
          color: TchipColors.textSecondary,
        ),
        selectedLabelTextStyle: TchipText.navLabel.copyWith(
          color: TchipColors.yellow,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TchipText.navLabel.copyWith(
          color: TchipColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: TchipColors.cardRaised,
        contentTextStyle: TchipText.bodySmall,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: TchipRadii.all(TchipRadii.md),
    borderSide: BorderSide(color: color),
  );

  static final _textTheme = TextTheme(
    displaySmall: TchipText.display,
    headlineSmall: TchipText.title,
    titleLarge: TchipText.titleSmall,
    titleMedium: TchipText.section,
    titleSmall: TchipText.bodyStrong,
    bodyLarge: TchipText.body,
    bodyMedium: TchipText.bodySmall,
    bodySmall: TchipText.caption,
    labelLarge: TchipText.bodySmall.copyWith(fontWeight: FontWeight.w500),
    labelSmall: TchipText.navLabel,
  ).apply(fontFamily: TchipFonts.sans);
}
