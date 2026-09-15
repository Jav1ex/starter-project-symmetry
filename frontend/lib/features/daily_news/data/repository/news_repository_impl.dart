import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/mappers/dio_failure_mapper.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiService _newsApiService;

  const NewsRepositoryImpl(this._newsApiService);

  @override
  Future<DataState<List<ArticleEntity>>> getTopHeadlines(NewsQuery query) {
    return _guard(
      () => _newsApiService.getTopHeadlines(
        country: query.country,
        category: query.category.apiValue,
      ),
      category: query.category,
    );
  }

  @override
  Future<DataState<List<ArticleEntity>>> searchArticles(String query) {
    return _guard(() => _newsApiService.searchArticles(query));
  }

  Future<DataState<List<ArticleEntity>>> _guard(
    Future<List<ArticleModel>> Function() request, {
    NewsCategory category = NewsCategory.general,
  }) async {
    try {
      final models = await request();
      return DataSuccess(
        models.map((model) => model.toEntity(category: category)).toList(),
      );
    } on DioException catch (e) {
      return DataFailed(DioFailureMapper.map(e));
    }
  }
}
