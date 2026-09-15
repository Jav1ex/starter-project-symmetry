import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_country.dart';

void main() {
  test('every country has a two-letter lowercase code and a label', () {
    for (final country in NewsCountry.values) {
      expect(country.code, matches(RegExp(r'^[a-z]{2}$')), reason: country.name);
      expect(country.label, isNotEmpty, reason: country.name);
    }
  });

  test('codes are unique', () {
    final codes = NewsCountry.values.map((c) => c.code).toSet();
    expect(codes.length, NewsCountry.values.length);
  });

  test('fromCode resolves case- and whitespace-insensitively', () {
    expect(NewsCountry.fromCode('pt'), NewsCountry.portugal);
    expect(NewsCountry.fromCode(' GB '), NewsCountry.unitedKingdom);
  });

  test('fromCode falls back to the United States for unknown or null codes', () {
    expect(NewsCountry.fromCode('zz'), NewsCountry.unitedStates);
    expect(NewsCountry.fromCode(null), NewsCountry.unitedStates);
    expect(NewsCountry.fallback, NewsCountry.unitedStates);
  });
}
