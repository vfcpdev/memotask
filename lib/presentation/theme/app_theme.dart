import 'package:flutter/material.dart';

import 'app_design_tokens.dart';

/// Sistema de diseño Material 3 con tokens unificados y contraste WCAG AA.
class AppTheme {
  const AppTheme._();

  static ThemeData theme([AppDesignTokens tokens = AppDesignTokens.dark]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.brandNavy,
      primary: tokens.accentLime,
      onPrimary: tokens.onLime,
      secondary: tokens.accentLime,
      onSecondary: tokens.onLime,
      surface: tokens.surfaceNavy,
      onSurface: tokens.onNavy,
      outline: tokens.onNavy.withValues(alpha: 0.35),
      brightness: Brightness.dark,
    );

    final minButtonSize = Size(64, tokens.minTouchTarget);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.brandNavy,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.brandNavy,
        foregroundColor: tokens.onNavy,
        centerTitle: true,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.accentLime,
          foregroundColor: tokens.onLime,
          minimumSize: minButtonSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.onNavy,
          side: BorderSide(color: tokens.onNavy.withValues(alpha: 0.35)),
          minimumSize: minButtonSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.accentLime,
        foregroundColor: tokens.onLime,
      ),
      cardTheme: CardThemeData(
        color: tokens.surfaceNavy,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceNavy,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusLg),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surfaceNavy,
        indicatorColor: tokens.accentLime.withValues(alpha: 0.24),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? tokens.accentLime : tokens.onNavy,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(
            color: tokens.accentLime,
            width: tokens.focusBorderWidth,
          ),
        ),
        labelStyle: TextStyle(color: tokens.onNavy.withValues(alpha: 0.9)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surfaceNavy,
        contentTextStyle: TextStyle(color: tokens.onNavy),
      ),
    );
  }
}
