import 'package:flutter/material.dart';

/// Tokens visuales unificados de MemoTask inyectados mediante [ThemeExtension].
@immutable
class AppDesignTokens extends ThemeExtension<AppDesignTokens> {
  final Color brandNavy;
  final Color surfaceNavy;
  final Color accentLime;
  final Color onNavy;
  final Color onLime;
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double minTouchTarget;
  final double cardVerticalMargin;
  final double focusBorderWidth;
  final int calendarGridColumns;

  const AppDesignTokens({
    required this.brandNavy,
    required this.surfaceNavy,
    required this.accentLime,
    required this.onNavy,
    required this.onLime,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.minTouchTarget,
    required this.cardVerticalMargin,
    required this.focusBorderWidth,
    required this.calendarGridColumns,
  });

  static const AppDesignTokens dark = AppDesignTokens(
    brandNavy: Color(0xFF0B2239),
    surfaceNavy: Color(0xFF12314F),
    accentLime: Color(0xFF76B800),
    onNavy: Colors.white,
    onLime: Color(0xFF0B2239),
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    radiusSm: 8,
    radiusMd: 14,
    radiusLg: 20,
    minTouchTarget: 48,
    cardVerticalMargin: 6,
    focusBorderWidth: 2,
    calendarGridColumns: 4,
  );

  @override
  AppDesignTokens copyWith({
    Color? brandNavy,
    Color? surfaceNavy,
    Color? accentLime,
    Color? onNavy,
    Color? onLime,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? minTouchTarget,
    double? cardVerticalMargin,
    double? focusBorderWidth,
    int? calendarGridColumns,
  }) {
    return AppDesignTokens(
      brandNavy: brandNavy ?? this.brandNavy,
      surfaceNavy: surfaceNavy ?? this.surfaceNavy,
      accentLime: accentLime ?? this.accentLime,
      onNavy: onNavy ?? this.onNavy,
      onLime: onLime ?? this.onLime,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      cardVerticalMargin: cardVerticalMargin ?? this.cardVerticalMargin,
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
      calendarGridColumns: calendarGridColumns ?? this.calendarGridColumns,
    );
  }

  @override
  AppDesignTokens lerp(ThemeExtension<AppDesignTokens>? other, double t) {
    if (other is! AppDesignTokens) return this;
    return AppDesignTokens(
      brandNavy: Color.lerp(brandNavy, other.brandNavy, t) ?? brandNavy,
      surfaceNavy: Color.lerp(surfaceNavy, other.surfaceNavy, t) ?? surfaceNavy,
      accentLime: Color.lerp(accentLime, other.accentLime, t) ?? accentLime,
      onNavy: Color.lerp(onNavy, other.onNavy, t) ?? onNavy,
      onLime: Color.lerp(onLime, other.onLime, t) ?? onLime,
      spaceXs: spaceXs + (other.spaceXs - spaceXs) * t,
      spaceSm: spaceSm + (other.spaceSm - spaceSm) * t,
      spaceMd: spaceMd + (other.spaceMd - spaceMd) * t,
      spaceLg: spaceLg + (other.spaceLg - spaceLg) * t,
      radiusSm: radiusSm + (other.radiusSm - radiusSm) * t,
      radiusMd: radiusMd + (other.radiusMd - radiusMd) * t,
      radiusLg: radiusLg + (other.radiusLg - radiusLg) * t,
      minTouchTarget: minTouchTarget,
      cardVerticalMargin: cardVerticalMargin,
      focusBorderWidth: focusBorderWidth,
      calendarGridColumns: calendarGridColumns,
    );
  }
}
