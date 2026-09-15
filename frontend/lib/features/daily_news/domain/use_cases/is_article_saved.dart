import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';

/// Whether the article with the given id is bookmarked on this device.
class IsArticleSavedUseCase implements UseCase<DataState<bool>, String> {
  final SavedArticleRepository _savedArticleRepository;

  const IsArticleSavedUseCase(this._savedArticleRepository);

  @override
  Future<DataState<bool>> call(String params) {
    return _savedArticleRepository.isSaved(params);
  }
}
