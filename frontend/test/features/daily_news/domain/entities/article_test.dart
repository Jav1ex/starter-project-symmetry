import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('ArticleEntity', () {
    test('hasImage is false for a null or blank url', () {
      expect(buildArticle(imageUrl: null).hasImage, isFalse);
      expect(buildArticle(imageUrl: '   ').hasImage, isFalse);
      expect(buildArticle().hasImage, isTrue);
    });

    test('hasDescription is false for a null or blank summary', () {
      expect(buildArticle(description: null).hasDescription, isFalse);
      expect(buildArticle(description: '').hasDescription, isFalse);
      expect(buildArticle().hasDescription, isTrue);
    });

    test('isUserArticle reflects the source', () {
      expect(buildArticle().isUserArticle, isFalse);
      expect(buildUserArticle().isUserArticle, isTrue);
    });

    group('isOwnedBy', () {
      test('is true only for the matching author id', () {
        final article = buildUserArticle(authorId: 'uid-1');
        expect(article.isOwnedBy('uid-1'), isTrue);
        expect(article.isOwnedBy('uid-2'), isFalse);
      });

      test('is false when either side has no id', () {
        expect(buildUserArticle(authorId: 'uid-1').isOwnedBy(null), isFalse);
        expect(buildArticle(authorId: null).isOwnedBy('uid-1'), isFalse);
      });
    });

    test('copyWith replaces only the given fields', () {
      final original = buildArticle();
      final copy = original.copyWith(title: 'New title', source: ArticleSource.user);

      expect(copy.title, 'New title');
      expect(copy.source, ArticleSource.user);
      expect(copy.id, original.id);
      expect(copy.publishedAt, original.publishedAt);
    });

    test('equality is by value', () {
      expect(buildArticle(), buildArticle());
      expect(buildArticle(), isNot(buildArticle(id: 'other')));
    });
  });
}
