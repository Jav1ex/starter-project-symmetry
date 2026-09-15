import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Failure? failure;

  const RemoteArticlesState({this.articles, this.failure});

  @override
  List<Object?> get props => [articles, failure];
}

class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

class RemoteArticlesDone extends RemoteArticlesState {
  const RemoteArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(Failure failure) : super(failure: failure);
}
