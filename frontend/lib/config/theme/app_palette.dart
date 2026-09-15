import 'package:flutter/material.dart';

/// Design tokens that Material's [ColorScheme] does not model directly.
///
/// The palette is editorial rather than "Material": deep teal ink on warm
/// paper, terracotta for anything urgent or destructive, mustard for the
/// highlights that must catch the eye. Read it with
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

  /// Mustard highlight: the "You" badge, the Brief overline, anything that
  /// must stand out without being an action.
  final Color accent;
  final Color onAccent;

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
    required this.accent,
    required this.onAccent,
  });

  static const AppPalette light = AppPalette(
    primary: Color(0xFF0F4C5C),
    primaryDeep: Color(0xFF0A3540),
    primaryContainer: Color(0xFFCFE3E7),
    onPrimaryContainer: Color(0xFF0A3540),
    tint: Color(0xFFEAF2F3),
    background: Color(0xFFF7F3EC),
    surface: Color(0xFFFFFDF8),
    ink: Color(0xFF1E1E1E),
    inkBody: Color(0xFF4A4A4A),
    inkSecondary: Color(0xFF6B6B6B),
    outline: Color(0xFFEAE4D8),
    outlineStrong: Color(0xFFD6CFC2),
    error: Color(0xFFB8472F),
    errorContainer: Color(0xFFF8E3DC),
    dangerFill: Color(0xFFFBF3F0),
    dangerBorder: Color(0xFFE8C4B8),
    success: Color(0xFF2E7D5B),
    successContainer: Color(0xFFDDF0E6),
    onSuccessContainer: Color(0xFF1D5A3F),
    skeletonBone: Color(0xFFEBE5DA),
    skeletonHighlight: Color(0xFFF5F0E8),
    accent: Color(0xFFE3A33B),
    onAccent: Color(0xFF1E1E1E),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF5FA8B8),
    primaryDeep: Color(0xFF0F4C5C),
    primaryContainer: Color(0xFF1E4A55),
    onPrimaryContainer: Color(0xFFCFE3E7),
    tint: Color(0xFF1A2A2E),
    background: Color(0xFF121416),
    surface: Color(0xFF1C2023),
    ink: Color(0xFFECE7DF),
    inkBody: Color(0xFFD5CFC6),
    inkSecondary: Color(0xFFA39D93),
    outline: Color(0xFF2A2F33),
    outlineStrong: Color(0xFF3A4045),
    error: Color(0xFFE07A5F),
    errorContainer: Color(0xFF4A2418),
    dangerFill: Color(0xFF2A1A16),
    dangerBorder: Color(0xFF5A342A),
    success: Color(0xFF7FCBA5),
    successContainer: Color(0xFF1D5A3F),
    onSuccessContainer: Color(0xFFDDF0E6),
    skeletonBone: Color(0xFF262B2E),
    skeletonHighlight: Color(0xFF32383C),
    accent: Color(0xFFF0B95A),
    onAccent: Color(0xFF1E1E1E),
  );

  /// The brand gradient used by the Brief card, the logo and hero fallbacks.
  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryDeep],
      );

  /// Gradient for thumbnail fallbacks (135°, pale teal to sea teal).
  static const LinearGradient thumbnailFallbackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCFE3E7), Color(0xFF7FB6C2)],
  );

  /// Ink used on top of [thumbnailFallbackGradient].
  static const Color onThumbnailFallback = Color(0xFF0A3540);

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: mix(primary, other.primary),
      primaryDeep: mix(primaryDeep, other.primaryDeep),
      primaryContainer: mix(primaryContainer, other.primaryContainer),
      onPrimaryContainer: mix(onPrimaryContainer, other.onPrimaryContainer),
      tint: mix(tint, other.tint),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      ink: mix(ink, other.ink),
      inkBody: mix(inkBody, other.inkBody),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      outline: mix(outline, other.outline),
      outlineStrong: mix(outlineStrong, other.outlineStrong),
      error: mix(error, other.error),
      errorContainer: mix(errorContainer, other.errorContainer),
      dangerFill: mix(dangerFill, other.dangerFill),
      dangerBorder: mix(dangerBorder, other.dangerBorder),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      skeletonBone: mix(skeletonBone, other.skeletonBone),
      skeletonHighlight: mix(skeletonHighlight, other.skeletonHighlight),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
