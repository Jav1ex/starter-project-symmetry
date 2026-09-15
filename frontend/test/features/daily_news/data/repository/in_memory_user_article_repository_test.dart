import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/mock/sample_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late InMemoryUserArticleRepository repository;

  setUp(() {
    repository = InMemoryUserArticleRepository(latency: Duration.zero);
  });

  group('seed data', () {
    test('covers every rendering variant the UI must handle', () {
      final seed = SampleArticles.build();

      expect(seed.where((a) => a.hasImage), isNotEmpty);
      expect(seed.where((a) => !a.hasImage), isNotEmpty);
      expect(seed.where((a) => a.hasDescription), isNotEmpty);
      expect(seed.where((a) => !a.hasDescription), isNotEmpty);
      expect(seed.map((a) => a.authorId).toSet().length, greaterThan(1));
      expect(seed.every((a) => a.source == ArticleSource.user), isTrue);
      expect(seed.map((a) => a.id).toSet().length, seed.length, reason: 'ids are unique');
    });
  });

  test('getArticles returns the seed newest first', () async {
    final result = await repository.getArticles();

    final dates = result.dataOrNull!.map((a) => a.publishedAt).toList();
    for (var i = 1; i < dates.length; i++) {
      expect(dates[i - 1].isAfter(dates[i]) || dates[i - 1] == dates[i], isTrue);
    }
  });

  test('getArticlesByAuthor filters by author id', () async {
    final result = await repository.getArticlesByAuthor(SampleArticles.authorAdaId);

    expect(result.dataOrNull, isNotEmpty);
    expect(result.dataOrNull!.every((a) => a.authorId == SampleArticles.authorAdaId), isTrue);
  });

  test('getArticle fails with notFound for an unknown id', () async {
    final result = await repository.getArticle('nope');

    expect(result.failureOrNull?.type, FailureType.notFound);
  });

  group('searchArticles', () {
    test('matches title, summary and body case-insensitively', () async {
      final byTitle = await repository.searchArticles('BIKE LANES');
      final byBody = await repository.searchArticles('sourdough');

      expect(byTitle.dataOrNull!.map((a) => a.id), contains('sample-1'));
      expect(byBody.dataOrNull!.map((a) => a.id), contains('sample-2'));
    });

    test('returns nothing for a blank query', () async {
      expect((await repository.searchArticles('  ')).dataOrNull, isEmpty);
    });
  });

  group('createArticle', () {
    test('assigns an id, trims the draft and stores the thumbnail reference', () async {
      final result = await repository.createArticle(
        draft: buildDraft(title: '  New  ', description: '  ', content: ' body '),
        authorId: 'uid-x',
        authorName: 'Someone',
        thumbnail: thumbnailReference,
      );

      final created = result.dataOrNull!;
      expect(created.id, isNotEmpty);
      expect(created.title, 'New');
      expect(created.description, isNull);
      expect(created.content, 'body');
      expect(created.author, 'Someone');
      expect(created.authorId, 'uid-x');
      expect(created.imageUrl, thumbnailReference.url);
      expect(created.imagePath, thumbnailReference.path);
      expect(created.source, ArticleSource.user);

      final all = await repository.getArticles();
      expect(all.dataOrNull!.map((a) => a.id), contains(created.id));
    });

    test('creates unique ids across calls', () async {
      final a = await repository.createArticle(draft: buildDraft(), authorId: 'u', authorName: 'n');
      final b = await repository.createArticle(draft: buildDraft(), authorId: 'u', authorName: 'n');

      expect(a.dataOrNull!.id, isNot(b.dataOrNull!.id));
    });
  });

  group('updateArticle', () {
    test('replaces text and thumbnail, keeping id and author', () async {
      final result = await repository.updateArticle(
        id: 'sample-1',
        draft: buildDraft(title: 'Edited'),
        thumbnail: null,
      );

      final updated = result.dataOrNull!;
      expect(updated.id, 'sample-1');
      expect(updated.title, 'Edited');
      expect(updated.imageUrl, isNull);
      expect(updated.authorId, SampleArticles.authorAdaId);

      final stored = await repository.getArticle('sample-1');
      expect(stored.dataOrNull, updated);
    });

    test('fails with notFound for an unknown id', () async {
      final result = await repository.updateArticle(id: 'nope', draft: buildDraft());

      expect(result.failureOrNull?.type, FailureType.notFound);
    });
  });

  group('deleteArticle', () {
    test('removes the article', () async {
      await repository.deleteArticle('sample-1');

      expect((await repository.getArticle('sample-1')).failureOrNull?.type, FailureType.notFound);
    });

    test('fails with notFound for an unknown id', () async {
      final result = await repository.deleteArticle('nope');

      expect(result.failureOrNull?.type, FailureType.notFound);
    });
  });

  test('a custom seed replaces the samples', () async {
    final custom = InMemoryUserArticleRepository(
      seed: [buildUserArticle(id: 'only')],
      latency: Duration.zero,
    );

    final result = await custom.getArticles();

    expect(result.dataOrNull!.map((a) => a.id), ['only']);
  });
}
