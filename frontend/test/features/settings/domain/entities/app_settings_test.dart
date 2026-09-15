import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

void main() {
  test('defaults follow the system theme, medium text, top stories in the US', () {
    const settings = AppSettings.defaults;

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.textSize, TextSizePreference.medium);
    expect(settings.defaultCategory, NewsCategory.general);
    expect(settings.country, 'us');
  });

  test('copyWith replaces only the given fields', () {
    final settings = AppSettings.defaults.copyWith(
      themeMode: AppThemeMode.dark,
      textSize: TextSizePreference.large,
    );

    expect(settings.themeMode, AppThemeMode.dark);
    expect(settings.textSize, TextSizePreference.large);
    expect(settings.defaultCategory, NewsCategory.general);
    expect(settings.country, 'us');
  });

  test('equality is by value', () {
    expect(const AppSettings(), AppSettings.defaults);
    expect(const AppSettings(country: 'gb'), isNot(AppSettings.defaults));
  });

  test('text size factors grow monotonically around 1.0', () {
    final factors = TextSizePreference.values.map((t) => t.factor).toList();
    expect(factors, orderedEquals([...factors]..sort()));
    expect(TextSizePreference.medium.factor, 1.0);
    for (final size in TextSizePreference.values) {
      expect(size.label, isNotEmpty);
    }
  });
}
