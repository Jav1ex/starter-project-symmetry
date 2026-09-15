import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  final GetTopHeadlinesUseCase _getTopHeadlinesUseCase;

  RemoteArticlesBloc(this._getTopHeadlinesUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  Future<void> onGetArticles(
    GetArticles event,
    Emitter<RemoteArticlesState> emit,
  ) async {
    emit(const RemoteArticlesLoading());
    final result = await _getTopHeadlinesUseCase(const NewsQuery());
    emit(
      switch (result) {
        DataSuccess(:final data) => RemoteArticlesDone(data),
        DataFailed(:final failure) => RemoteArticlesError(failure),
      },
    );
  }
}
