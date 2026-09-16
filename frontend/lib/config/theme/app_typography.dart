import 'package:flutter/material.dart';

/// Type scale of the Daily News UI system.
///
/// One typeface, the Newsreader serif, at every size: headlines carry weight
/// 500, running text and controls weight 400 or 700. Sizes are in logical
/// pixels and scale with the user's text-size setting through
/// [MediaQuery.textScaler].
abstract final class AppTypography {
  static const String serif = 'Newsreader';

  static TextStyle _serif(double size, double lineHeight, {FontWeight weight = FontWeight.w500}) {
    return TextStyle(
      fontFamily: serif,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
    );
  }

  /// Text styles: regular weight by default, so labels and buttons read as
  /// text rather than as headlines.
  static TextStyle _text(double size, double lineHeight, {FontWeight weight = FontWeight.w400}) =>
      _serif(size, lineHeight, weight: weight);

  // Headlines
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

  // Text and controls
  static final TextStyle body = _text(17, 28);
  static final TextStyle bodySmall = _text(16, 24);
  static final TextStyle valueLine = _text(18, 28);
  static final TextStyle label = _text(15, 20, weight: FontWeight.w700);
  static final TextStyle button = _text(17, 22, weight: FontWeight.w700);
  static final TextStyle buttonSecondary = _text(16, 20, weight: FontWeight.w700);
  static final TextStyle caption = _text(14, 20);
  static final TextStyle captionSmall = _text(13, 18);
  static final TextStyle navLabel = _text(13, 18, weight: FontWeight.w700);
  static final TextStyle overline = _text(12, 16, weight: FontWeight.w700).copyWith(
    letterSpacing: 12 * 0.08,
  );
  static final TextStyle sectionOverline = _text(12, 16, weight: FontWeight.w700).copyWith(
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

  /// Text at an explicit size for controls that are not part of the scale
  /// (the A- / A+ stepper, slider ends).
  static TextStyle sized(double size, {FontWeight weight = FontWeight.w400}) {
    return TextStyle(fontFamily: serif, fontSize: size, height: 1.2, fontWeight: weight);
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
