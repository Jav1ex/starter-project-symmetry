import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/saved_article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_article_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

class SavedArticleRepositoryImpl implements SavedArticleRepository {
  final SavedArticleDao _dao;

  const SavedArticleRepositoryImpl(this._dao);

  static const String _storageErrorMessage = 'Could not access your saved articles.';

  @override
  Future<DataState<List<ArticleEntity>>> getSavedArticles() {
    return _guard(() async {
      final models = await _dao.getArticles();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<DataState<void>> saveArticle(ArticleEntity article) {
    return _guard(() => _dao.insertArticle(SavedArticleModel.fromEntity(article)));
  }

  @override
  Future<DataState<void>> removeArticle(String id) {
    return _guard(() => _dao.deleteById(id));
  }

  @override
  Future<DataState<void>> clear() {
    return _guard(() async {
      for (final model in await _dao.getArticles()) {
        await _dao.deleteById(model.id);
      }
    });
  }

  @override
  Future<DataState<bool>> isSaved(String id) {
    return _guard(() async => await _dao.findById(id) != null);
  }

  Future<DataState<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return DataSuccess(await operation());
    } on Exception {
      return const DataFailed(Failure.unknown(_storageErrorMessage));
    }
  }
}
