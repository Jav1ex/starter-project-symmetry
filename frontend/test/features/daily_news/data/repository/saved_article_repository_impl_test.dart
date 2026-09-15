import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/saved_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockSavedArticleDao extends Mock implements SavedArticleDao {}

void main() {
  late MockSavedArticleDao dao;
  late SavedArticleRepositoryImpl repository;

  final entity = ArticleEntity(
    id: 'doc-1',
    source: ArticleSource.user,
    title: 'Title',
    content: 'Content',
    author: 'Ada',
    authorId: 'uid-1',
    imageUrl: 'https://img.example/1.jpg',
    imagePath: 'media/articles/1.jpg',
    publishedAt: DateTime.utc(2026, 9, 15),
  );
  final model = SavedArticleModel.fromEntity(entity);

  setUpAll(() {
    registerFallbackValue(model);
  });

  setUp(() {
    dao = MockSavedArticleDao();
    repository = SavedArticleRepositoryImpl(dao);
  });

  group('getSavedArticles', () {
    test('maps rows to plain entities', () async {
      when(() => dao.getArticles()).thenAnswer((_) async => [model]);

      final result = await repository.getSavedArticles();

      expect(result.dataOrNull, [entity]);
      expect(result.dataOrNull!.single, isNot(isA<SavedArticleModel>()));
    });

    test('returns an unknown failure when the database throws', () async {
      when(() => dao.getArticles()).thenThrow(Exception('disk'));

      final result = await repository.getSavedArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.failureOrNull?.type, FailureType.unknown);
    });
  });

  group('saveArticle', () {
    test('inserts the entity converted to a row', () async {
      when(() => dao.insertArticle(any())).thenAnswer((_) async {});

      final result = await repository.saveArticle(entity);

      expect(result, isA<DataSuccess<void>>());
      verify(() => dao.insertArticle(model)).called(1);
    });

    test('reports a failure instead of throwing', () async {
      when(() => dao.insertArticle(any())).thenThrow(Exception('constraint'));

      final result = await repository.saveArticle(entity);

      expect(result, isA<DataFailed<void>>());
    });
  });

  group('removeArticle', () {
    test('deletes by id', () async {
      when(() => dao.deleteById('doc-1')).thenAnswer((_) async {});

      final result = await repository.removeArticle('doc-1');

      expect(result, isA<DataSuccess<void>>());
      verify(() => dao.deleteById('doc-1')).called(1);
    });
  });

  group('isSaved', () {
    test('is true when a row exists', () async {
      when(() => dao.findById('doc-1')).thenAnswer((_) async => model);

      final result = await repository.isSaved('doc-1');

      expect(result.dataOrNull, isTrue);
    });

    test('is false when no row exists', () async {
      when(() => dao.findById('doc-1')).thenAnswer((_) async => null);

      final result = await repository.isSaved('doc-1');

      expect(result.dataOrNull, isFalse);
    });
  });

  test('SavedArticleModel round-trips through the entity', () {
    expect(model.toEntity(), entity);
    expect(SavedArticleModel.fromEntity(model.toEntity()), model);
  });
}
