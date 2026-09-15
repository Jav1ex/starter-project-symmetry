import 'package:flutter/material.dart';

/// Type scale of the Daily News UI system.
///
/// Headlines use the Newsreader serif, everything else Mulish. Sizes are in
/// logical pixels and scale with the user's text-size setting through
/// [MediaQuery.textScaler].
abstract final class AppTypography {
  static const String serif = 'Newsreader';
  static const String sans = 'Mulish';

  static TextStyle _serif(double size, double lineHeight, {FontWeight weight = FontWeight.w500}) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
    );
  }

  static TextStyle _sans(double size, double lineHeight, {FontWeight weight = FontWeight.w400}) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
    );
  }

  // Serif
  static final TextStyle display = _serif(34, 40);
  static final TextStyle wordmark = _serif(44, 46);
  static final TextStyle briefQuestion = _serif(38, 42);
  static final TextStyle briefSummaryTitle = _serif(36, 39);
  static final TextStyle headline = _serif(28, 32);
  static final TextStyle readerTitle = _serif(30, 36);
  static final TextStyle briefCardHeadline = _serif(32, 36);
  static final TextStyle cardTitle = _serif(24, 29);
  static final TextStyle dialogTitle = _serif(26, 31);
  static final TextStyle title = _serif(20, 26);
  static final TextStyle counter = _serif(34, 38);

  // Sans
  static final TextStyle body = _sans(17, 28);
  static final TextStyle bodySmall = _sans(16, 24);
  static final TextStyle valueLine = _sans(18, 28);
  static final TextStyle label = _sans(15, 20, weight: FontWeight.w700);
  static final TextStyle button = _sans(17, 22, weight: FontWeight.w700);
  static final TextStyle buttonSecondary = _sans(16, 20, weight: FontWeight.w700);
  static final TextStyle caption = _sans(14, 20);
  static final TextStyle captionSmall = _sans(13, 18);
  static final TextStyle navLabel = _sans(13, 18, weight: FontWeight.w700);
  static final TextStyle overline = _sans(12, 16, weight: FontWeight.w700).copyWith(
    letterSpacing: 12 * 0.08,
  );
  static final TextStyle sectionOverline = _sans(12, 16, weight: FontWeight.w700).copyWith(
    letterSpacing: 12 * 0.1,
  );

  /// Large serif glyphs: logo letter, empty-state glyph, avatar initials,
  /// hero and thumbnail fallbacks. Sized by the widget, never ad hoc.
  static TextStyle serifGlyph(double size, {FontWeight weight = FontWeight.w500, bool italic = false}) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      height: 1,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  /// Sans text at an explicit size for controls that are not part of the
  /// scale (the A- / A+ stepper, slider ends).
  static TextStyle sansSized(double size, {FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: sans, fontSize: size, height: 1.2, fontWeight: weight);
  }

  /// Material [TextTheme] fed from the same scale so M3 widgets pick it up.
  static TextTheme textTheme(Color ink, Color inkBody, Color inkSecondary) {
    return TextTheme(
      displayLarge: wordmark.copyWith(color: ink),
      displayMedium: display.copyWith(color: ink),
      displaySmall: readerTitle.copyWith(color: ink),
      headlineLarge: headline.copyWith(color: ink),
      headlineMedium: dialogTitle.copyWith(color: ink),
      headlineSmall: cardTitle.copyWith(color: ink),
      titleLarge: title.copyWith(color: ink),
      titleMedium: label.copyWith(color: ink),
      titleSmall: captionSmall.copyWith(color: inkSecondary, fontWeight: FontWeight.w700),
      bodyLarge: body.copyWith(color: inkBody),
      bodyMedium: bodySmall.copyWith(color: inkBody),
      bodySmall: caption.copyWith(color: inkSecondary),
      labelLarge: button.copyWith(color: ink),
      labelMedium: buttonSecondary.copyWith(color: ink),
      labelSmall: overline.copyWith(color: inkSecondary),
    );
  }
}
