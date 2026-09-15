import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/article_source_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/converters/date_time_converter.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  group('DateTimeConverter', () {
    final converter = DateTimeConverter();

    test('encodes as UTC milliseconds and decodes back to UTC', () {
      final local = DateTime(2026, 9, 15, 12, 30);

      final encoded = converter.encode(local);
      final decoded = converter.decode(encoded);

      expect(encoded, local.toUtc().millisecondsSinceEpoch);
      expect(decoded.isUtc, isTrue);
      expect(decoded, local.toUtc());
    });
  });

  group('ArticleSourceConverter', () {
    final converter = ArticleSourceConverter();

    test('round-trips every source by name', () {
      for (final source in ArticleSource.values) {
        expect(converter.decode(converter.encode(source)), source);
      }
    });

    test('falls back to remote for unknown values', () {
      expect(converter.decode('legacy'), ArticleSource.remote);
    });
  });
}
