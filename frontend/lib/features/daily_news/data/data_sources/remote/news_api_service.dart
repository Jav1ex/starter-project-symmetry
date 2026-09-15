import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

/// Remote data source for the NewsAPI `top-headlines` endpoint.
///
/// Converts the raw JSON payload into [ArticleModel]s and lets [DioException]s
/// propagate, so the repository decides how failures surface to the domain.
class NewsApiService {
  final Dio _dio;

  NewsApiService(this._dio);

  static const String _topHeadlinesPath = '/top-headlines';
  static const String _articlesKey = 'articles';

  Future<List<ArticleModel>> getNewsArticles({
    required String apiKey,
    required String country,
    required String category,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$newsAPIBaseURL$_topHeadlinesPath',
      queryParameters: {
        'apiKey': apiKey,
        'country': country,
        'category': category,
      },
    );

    return _parseArticles(response.data);
  }

  List<ArticleModel> _parseArticles(Map<String, dynamic>? body) {
    final rawArticles = body?[_articlesKey];
    if (rawArticles is! List) {
      return const [];
    }
    return rawArticles
        .whereType<Map<String, dynamic>>()
        .map(ArticleModel.fromJson)
        .toList();
  }
}
