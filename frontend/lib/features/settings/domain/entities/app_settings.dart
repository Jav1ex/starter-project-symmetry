import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Theme preference, independent of Flutter's `ThemeMode` so the domain stays
/// free of framework types.
enum AppThemeMode { system, light, dark }

/// Reading text size. [factor] multiplies the base text scale so that the
/// 17sp body renders at 16 / 17 / 19 / 21 sp.
enum TextSizePreference {
  small(16 / 17, 'Small'),
  medium(1.0, 'Default'),
  large(19 / 17, 'Large'),
  extraLarge(21 / 17, 'Largest');

  final double factor;
  final String label;

  const TextSizePreference(this.factor, this.label);

  TextSizePreference get smaller =>
      index == 0 ? this : TextSizePreference.values[index - 1];

  TextSizePreference get larger => index == TextSizePreference.values.length - 1
      ? this
      : TextSizePreference.values[index + 1];
}

/// User preferences that persist on the device.
class AppSettings extends Equatable {
  static const String defaultCountry = 'us';

  final AppThemeMode themeMode;
  final TextSizePreference textSize;
  final NewsCategory defaultCategory;

  /// Two-letter ISO country code used for the provider feed.
  final String country;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.textSize = TextSizePreference.medium,
    this.defaultCategory = NewsCategory.general,
    this.country = defaultCountry,
  });

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    AppThemeMode? themeMode,
    TextSizePreference? textSize,
    NewsCategory? defaultCategory,
    String? country,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      country: country ?? this.country,
    );
  }

  @override
  List<Object?> get props => [themeMode, textSize, defaultCategory, country];
}
