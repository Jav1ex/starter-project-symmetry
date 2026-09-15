import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final Failure? failure;

  const LocalArticlesState({this.articles, this.failure});

  @override
  List<Object?> get props => [articles, failure];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

class LocalArticlesError extends LocalArticlesState {
  const LocalArticlesError(Failure failure) : super(failure: failure);
}
