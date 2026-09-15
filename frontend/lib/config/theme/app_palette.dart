import 'package:flutter/material.dart';

/// Design tokens that Material's [ColorScheme] does not model directly.
///
/// Values come from the Daily News UI system. Read them with
/// `Theme.of(context).extension<AppPalette>()!` or the [AppPaletteX] shortcut.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color primaryDeep;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color tint;
  final Color background;
  final Color surface;
  final Color ink;
  final Color inkBody;
  final Color inkSecondary;
  final Color outline;
  final Color outlineStrong;
  final Color error;
  final Color errorContainer;
  final Color dangerFill;
  final Color dangerBorder;
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color skeletonBone;
  final Color skeletonHighlight;

  const AppPalette({
    required this.primary,
    required this.primaryDeep,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.tint,
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkBody,
    required this.inkSecondary,
    required this.outline,
    required this.outlineStrong,
    required this.error,
    required this.errorContainer,
    required this.dangerFill,
    required this.dangerBorder,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.skeletonBone,
    required this.skeletonHighlight,
  });

  static const AppPalette light = AppPalette(
    primary: Color(0xFF7B4FA0),
    primaryDeep: Color(0xFF5E3A7C),
    primaryContainer: Color(0xFFE3BEE8),
    onPrimaryContainer: Color(0xFF3B1F4E),
    tint: Color(0xFFF4EAF6),
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1E1A20),
    inkBody: Color(0xFF4B4550),
    inkSecondary: Color(0xFF6B6470),
    outline: Color(0xFFEFE9E2),
    outlineStrong: Color(0xFFD9CFCB),
    error: Color(0xFFB3261E),
    errorContainer: Color(0xFFFBEAE8),
    dangerFill: Color(0xFFFDF6F5),
    dangerBorder: Color(0xFFE6C7C4),
    success: Color(0xFF2E7D5B),
    successContainer: Color(0xFFDDF0E6),
    onSuccessContainer: Color(0xFF1D5A3F),
    skeletonBone: Color(0xFFEDE6E0),
    skeletonHighlight: Color(0xFFF6F1EC),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFFC9A6E0),
    primaryDeep: Color(0xFF7B4FA0),
    primaryContainer: Color(0xFF4A2E5E),
    onPrimaryContainer: Color(0xFFE3BEE8),
    tint: Color(0xFF2A2230),
    background: Color(0xFF171418),
    surface: Color(0xFF221E24),
    ink: Color(0xFFF5F0EE),
    inkBody: Color(0xFFE9E3E1),
    inkSecondary: Color(0xFFB3A9B7),
    outline: Color(0xFF2E2930),
    outlineStrong: Color(0xFF443C48),
    error: Color(0xFFF2B8B5),
    errorContainer: Color(0xFF4A1B18),
    dangerFill: Color(0xFF2A1A1A),
    dangerBorder: Color(0xFF5A2E2B),
    success: Color(0xFF7FCBA5),
    successContainer: Color(0xFF1D5A3F),
    onSuccessContainer: Color(0xFFDDF0E6),
    skeletonBone: Color(0xFF2E2930),
    skeletonHighlight: Color(0xFF3A333E),
  );

  /// The brand gradient used by the Brief card, the logo and hero fallbacks.
  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryDeep],
      );

  /// Gradient for thumbnail fallbacks (135°, lilac to deeper lilac).
  static const LinearGradient thumbnailFallbackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3BEE8), Color(0xFFB48CCB)],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDeep: Color.lerp(primaryDeep, other.primaryDeep, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkBody: Color.lerp(inkBody, other.inkBody, t)!,
      inkSecondary: Color.lerp(inkSecondary, other.inkSecondary, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      dangerFill: Color.lerp(dangerFill, other.dangerFill, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      skeletonBone: Color.lerp(skeletonBone, other.skeletonBone, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
