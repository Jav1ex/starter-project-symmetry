import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/mock/sample_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';

/// [UserArticleRepository] backed by a list in memory.
///
/// Stands in for the Firestore implementation so the presentation layer can
/// be built and demoed before the backend is wired in. Behaviour mirrors the
/// real one: newest first, ids assigned on create, not-found failures.
class InMemoryUserArticleRepository implements UserArticleRepository {
  final List<ArticleEntity> _articles;
  final Duration _latency;
  int _nextId;

  InMemoryUserArticleRepository({
    List<ArticleEntity>? seed,
    Duration latency = const Duration(milliseconds: 350),
  })  : _articles = List.of(seed ?? SampleArticles.build()),
        _latency = latency,
        _nextId = (seed ?? SampleArticles.build()).length + 1;

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() async {
    await _simulateLatency();
    return DataSuccess(FeedEntity.sortNewestFirst(_articles));
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId) async {
    await _simulateLatency();
    final own = _articles.where((article) => article.authorId == authorId);
    return DataSuccess(FeedEntity.sortNewestFirst(own));
  }

  @override
  Future<DataState<ArticleEntity>> getArticle(String id) async {
    await _simulateLatency();
    final index = _indexOf(id);
    if (index < 0) return const DataFailed(Failure.notFound('Article not found.'));
    return DataSuccess(_articles[index]);
  }

  @override
  Future<DataState<List<ArticleEntity>>> searchArticles(String query) async {
    await _simulateLatency();
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const DataSuccess([]);
    final matches = _articles.where((article) => _matches(article, needle));
    return DataSuccess(FeedEntity.sortNewestFirst(matches));
  }

  @override
  Future<DataState<ArticleEntity>> createArticle({
    required ArticleDraft draft,
    required String authorId,
    required String authorName,
    ThumbnailReference? thumbnail,
  }) async {
    await _simulateLatency();
    final article = ArticleEntity(
      id: 'local-${_nextId++}',
      source: ArticleSource.user,
      title: draft.trimmedTitle,
      content: draft.trimmedContent,
      description: draft.trimmedDescription,
      author: authorName,
      authorId: authorId,
      imageUrl: thumbnail?.url,
      imagePath: thumbnail?.path,
      publishedAt: draft.publishedAt,
    );
    _articles.add(article);
    return DataSuccess(article);
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle({
    required String id,
    required ArticleDraft draft,
    ThumbnailReference? thumbnail,
  }) async {
    await _simulateLatency();
    final index = _indexOf(id);
    if (index < 0) return const DataFailed(Failure.notFound('Article not found.'));

    final current = _articles[index];
    final updated = ArticleEntity(
      id: current.id,
      source: current.source,
      title: draft.trimmedTitle,
      content: draft.trimmedContent,
      description: draft.trimmedDescription,
      author: current.author,
      authorId: current.authorId,
      imageUrl: thumbnail?.url,
      imagePath: thumbnail?.path,
      url: current.url,
      publishedAt: draft.publishedAt,
    );
    _articles[index] = updated;
    return DataSuccess(updated);
  }

  @override
  Future<DataState<void>> deleteArticle(String id) async {
    await _simulateLatency();
    final index = _indexOf(id);
    if (index < 0) return const DataFailed(Failure.notFound('Article not found.'));
    _articles.removeAt(index);
    return const DataSuccess(null);
  }

  int _indexOf(String id) => _articles.indexWhere((article) => article.id == id);

  bool _matches(ArticleEntity article, String needle) {
    return article.title.toLowerCase().contains(needle) ||
        (article.description?.toLowerCase().contains(needle) ?? false) ||
        article.content.toLowerCase().contains(needle);
  }

  Future<void> _simulateLatency() {
    return _latency == Duration.zero ? Future.value() : Future.delayed(_latency);
  }
}
