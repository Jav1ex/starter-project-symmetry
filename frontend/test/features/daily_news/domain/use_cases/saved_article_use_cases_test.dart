import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

/// The single-call use cases only delegate; these tests pin that contract so a
/// future "helpful" transformation shows up as a failure.
void main() {
  late MockSavedArticleRepository saved;
  late MockNewsRepository news;

  final article = buildArticle();

  setUp(() {
    saved = MockSavedArticleRepository();
    news = MockNewsRepository();
  });

  test('GetSavedArticlesUseCase returns the repository result unchanged', () async {
    when(() => saved.getSavedArticles()).thenAnswer((_) async => DataSuccess([article]));

    final result = await GetSavedArticlesUseCase(saved)(const NoParams());

    expect(result.dataOrNull, [article]);
  });

  test('SaveArticleUseCase forwards the entity', () async {
    when(() => saved.saveArticle(article)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveArticleUseCase(saved)(article);

    expect(result.isSuccess, isTrue);
    verify(() => saved.saveArticle(article)).called(1);
  });

  test('RemoveSavedArticleUseCase forwards the id', () async {
    when(() => saved.removeArticle('a')).thenAnswer((_) async => const DataSuccess(null));

    await RemoveSavedArticleUseCase(saved)('a');

    verify(() => saved.removeArticle('a')).called(1);
  });

  test('IsArticleSavedUseCase forwards the id and the answer', () async {
    when(() => saved.isSaved('a')).thenAnswer((_) async => const DataSuccess(true));

    final result = await IsArticleSavedUseCase(saved)('a');

    expect(result.dataOrNull, isTrue);
  });

  test('GetTopHeadlinesUseCase forwards the query and failures', () async {
    const query = NewsQuery(country: 'gb');
    when(() => news.getTopHeadlines(query))
        .thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await GetTopHeadlinesUseCase(news)(query);

    expect(result.failureOrNull?.type, FailureType.network);
  });
}
