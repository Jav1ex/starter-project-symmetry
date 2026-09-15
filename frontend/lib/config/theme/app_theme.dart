import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Builds the Material 3 themes from the design tokens.
abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light, Brightness.light);

  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: isDark ? const Color(0xFF2A1A33) : Colors.white,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.primaryDeep,
      onSecondary: Colors.white,
      secondaryContainer: p.tint,
      onSecondaryContainer: p.onPrimaryContainer,
      tertiary: p.success,
      onTertiary: Colors.white,
      tertiaryContainer: p.successContainer,
      onTertiaryContainer: p.onSuccessContainer,
      error: p.error,
      onError: Colors.white,
      errorContainer: p.errorContainer,
      onErrorContainer: p.error,
      surface: p.background,
      onSurface: p.ink,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.tint,
      surfaceContainerHighest: p.tint,
      onSurfaceVariant: p.inkSecondary,
      outline: p.outlineStrong,
      outlineVariant: p.outline,
      shadow: Colors.black,
      scrim: p.ink,
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: p.primaryContainer,
    );

    final textTheme = AppTypography.textTheme(p.ink, p.inkBody, p.inkSecondary);
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: AppTypography.sans,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.outline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.button),
          shape: pill,
          textStyle: AppTypography.button,
          backgroundColor: p.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: p.outlineStrong,
          disabledForegroundColor: p.inkSecondary,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? p.primaryDeep : null,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.button),
          shape: pill,
          textStyle: AppTypography.button,
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
          shape: pill,
          textStyle: AppTypography.buttonSecondary,
          foregroundColor: p.primary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        extendedTextStyle: AppTypography.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.fab)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: AppTypography.valueLine.copyWith(color: p.inkSecondary),
        border: _fieldBorder(p.outlineStrong, 1.5),
        enabledBorder: _fieldBorder(p.outlineStrong, 1.5),
        focusedBorder: _fieldBorder(p.primary, 2),
        errorBorder: _fieldBorder(p.error, 2),
        focusedErrorBorder: _fieldBorder(p.error, 2),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomBar,
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.navIndicator),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.navLabel.copyWith(
            color: states.contains(WidgetState.selected) ? p.ink : p.inkSecondary,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.onPrimaryContainer : p.inkBody,
            size: AppSizes.icon,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: AppTypography.bodySmall.copyWith(color: p.background),
        actionTextColor: p.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.primaryContainer,
        side: BorderSide(color: p.outlineStrong),
        shape: pill,
        labelStyle: AppTypography.bodySmall.copyWith(color: p.ink),
        showCheckmark: true,
        checkmarkColor: p.onPrimaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.primaryContainer,
          selectedForegroundColor: p.onPrimaryContainer,
          foregroundColor: p.ink,
          side: BorderSide(color: p.outlineStrong, width: 1.5),
          textStyle: AppTypography.buttonSecondary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: p.outlineStrong,
        thumbColor: p.primary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.primary,
        textColor: p.ink,
        minVerticalPadding: 12,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.outline),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
