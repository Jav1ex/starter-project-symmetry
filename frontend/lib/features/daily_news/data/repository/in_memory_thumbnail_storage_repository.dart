import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/mock/sample_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';

/// [ThumbnailStorageRepository] that only remembers which paths exist.
///
/// Nothing is uploaded. The returned URL points at a deterministic placeholder
/// image so the UI still renders a real picture for the article.
class InMemoryThumbnailStorageRepository implements ThumbnailStorageRepository {
  final Set<String> _storedPaths = {};
  final Duration _latency;
  int _counter = 0;

  InMemoryThumbnailStorageRepository({
    Duration latency = const Duration(milliseconds: 600),
  }) : _latency = latency;

  /// Paths currently "stored", exposed for tests and debugging.
  Set<String> get storedPaths => Set.unmodifiable(_storedPaths);

  @override
  Future<DataState<ThumbnailReference>> upload(LocalImage image) async {
    await _simulateLatency();
    final errors = image.validate();
    if (errors.isNotEmpty) {
      return DataFailed(Failure.validation(errors.first.message));
    }
    final index = ++_counter;
    final path = 'media/articles/local-$index${_extensionFor(image.mimeType)}';
    _storedPaths.add(path);
    return DataSuccess(
      ThumbnailReference(url: SampleArticles.sampleImageUrl(100 + index), path: path),
    );
  }

  @override
  Future<DataState<void>> delete(String path) async {
    await _simulateLatency();
    _storedPaths.remove(path);
    return const DataSuccess(null);
  }

  String _extensionFor(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      default:
        return '.jpg';
    }
  }

  Future<void> _simulateLatency() {
    return _latency == Duration.zero ? Future.value() : Future.delayed(_latency);
  }
}
