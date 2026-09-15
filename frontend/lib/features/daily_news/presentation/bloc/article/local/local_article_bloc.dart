import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent, LocalArticlesState> {
  final GetSavedArticlesUseCase _getSavedArticlesUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveSavedArticleUseCase _removeSavedArticleUseCase;

  LocalArticleBloc(
    this._getSavedArticlesUseCase,
    this._saveArticleUseCase,
    this._removeSavedArticleUseCase,
  ) : super(const LocalArticlesLoading()) {
    on<GetSavedArticles>(onGetSavedArticles);
    on<RemoveArticle>(onRemoveArticle);
    on<SaveArticle>(onSaveArticle);
  }

  Future<void> onGetSavedArticles(
    GetSavedArticles event,
    Emitter<LocalArticlesState> emit,
  ) async {
    await _emitSavedArticles(emit);
  }

  Future<void> onRemoveArticle(
    RemoveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    await _removeSavedArticleUseCase(event.article.id);
    await _emitSavedArticles(emit);
  }

  Future<void> onSaveArticle(
    SaveArticle event,
    Emitter<LocalArticlesState> emit,
  ) async {
    await _saveArticleUseCase(event.article);
    await _emitSavedArticles(emit);
  }

  Future<void> _emitSavedArticles(Emitter<LocalArticlesState> emit) async {
    final result = await _getSavedArticlesUseCase(const NoParams());
    emit(
      switch (result) {
        DataSuccess(:final data) => LocalArticlesDone(data),
        DataFailed(:final failure) => LocalArticlesError(failure),
      },
    );
  }
}
