import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Theme preference, independent of Flutter's `ThemeMode` so the domain stays
/// free of framework types.
enum AppThemeMode { system, light, dark }

/// Reading text size. [factor] multiplies the base text scale.
enum TextSizePreference {
  small(0.9, 'Small'),
  medium(1.0, 'Medium'),
  large(1.15, 'Large'),
  extraLarge(1.3, 'Extra large');

  final double factor;
  final String label;

  const TextSizePreference(this.factor, this.label);
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
