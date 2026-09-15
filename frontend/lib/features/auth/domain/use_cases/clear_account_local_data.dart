import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

/// Leaves nothing of the account on the device: bookmarks, the unfinished
/// draft and the settings go back to a fresh install, so the next person to
/// sign in on this phone does not inherit them.
///
/// Every step runs even if an earlier one fails; the first failure is what
/// gets reported.
class ClearAccountLocalDataUseCase implements UseCase<DataState<void>, NoParams> {
  final SavedArticleRepository _savedArticles;
  final DraftRepository _drafts;
  final SettingsRepository _settings;

  const ClearAccountLocalDataUseCase(this._savedArticles, this._drafts, this._settings);

  @override
  Future<DataState<void>> call(NoParams params) async {
    final results = [
      await _savedArticles.clear(),
      await _drafts.clearDraft(),
      await _settings.saveSettings(AppSettings.defaults),
    ];
    for (final result in results) {
      if (result is DataFailed<void>) return result;
    }
    return const DataSuccess(null);
  }
}
