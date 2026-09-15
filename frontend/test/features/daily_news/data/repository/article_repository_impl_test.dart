import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class MockNewsApiService extends Mock implements NewsApiService {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockArticleDao extends Mock implements ArticleDao {}

void main() {
  late MockNewsApiService api;
  late MockAppDatabase database;
  late MockArticleDao dao;
  late ArticleRepositoryImpl repository;

  const entity = ArticleEntity(
    id: 1,
    author: 'Ada',
    title: 'Title',
    description: 'Description',
    url: 'https://example.com',
    urlToImage: 'https://example.com/a.jpg',
    publishedAt: '2026-09-15T10:00:00Z',
    content: 'Content',
  );
  final model = ArticleModel.fromEntity(entity);

  setUpAll(() {
    registerFallbackValue(const ArticleModel());
  });

  setUp(() {
    api = MockNewsApiService();
    database = MockAppDatabase();
    dao = MockArticleDao();
    when(() => database.articleDAO).thenReturn(dao);
    repository = ArticleRepositoryImpl(api, database);
  });

  group('getNewsArticles', () {
    When<Future<List<ArticleModel>>> stubApi() => when(
          () => api.getNewsArticles(
            apiKey: any(named: 'apiKey'),
            country: any(named: 'country'),
            category: any(named: 'category'),
          ),
        );

    test('wraps the fetched articles as entities in DataSuccess', () async {
      stubApi().thenAnswer((_) async => [model]);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());
      expect(result.data, [entity]);
      expect(result.data!.single, isNot(isA<ArticleModel>()));
      expect(result.error, isNull);
    });

    test('wraps a DioException in DataFailed instead of throwing', () async {
      final failure = DioException(
        requestOptions: RequestOptions(path: '/top-headlines'),
        type: DioExceptionType.badResponse,
      );
      stubApi().thenThrow(failure);

      final result = await repository.getNewsArticles();

      expect(result, isA<DataFailed<List<ArticleEntity>>>());
      expect(result.error, same(failure));
      expect(result.data, isNull);
    });

    test('does not swallow exceptions that are not DioException', () {
      stubApi().thenThrow(StateError('unexpected'));

      expect(repository.getNewsArticles(), throwsStateError);
    });
  });

  group('local articles', () {
    test('getSavedArticles maps the DAO models to entities', () async {
      when(() => dao.getArticles()).thenAnswer((_) async => [model]);

      final saved = await repository.getSavedArticles();

      expect(saved, [entity]);
      expect(saved.single, isNot(isA<ArticleModel>()));
    });

    test('saveArticle converts the entity to a model before inserting', () async {
      when(() => dao.insertArticle(any())).thenAnswer((_) async {});

      await repository.saveArticle(entity);

      verify(() => dao.insertArticle(model)).called(1);
    });

    test('removeArticle converts the entity to a model before deleting', () async {
      when(() => dao.deleteArticle(any())).thenAnswer((_) async {});

      await repository.removeArticle(entity);

      verify(() => dao.deleteArticle(model)).called(1);
    });
  });
}
