import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_thumbnail_storage_repository.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late InMemoryThumbnailStorageRepository storage;

  setUp(() {
    storage = InMemoryThumbnailStorageRepository(latency: Duration.zero);
  });

  test('upload returns a reference inside media/articles/ with the right extension', () async {
    final result = await storage.upload(buildImage(mimeType: 'image/png'));

    final reference = result.dataOrNull!;
    expect(reference.path, startsWith('media/articles/'));
    expect(reference.path, endsWith('.png'));
    expect(reference.url, startsWith('https://'));
    expect(storage.storedPaths, contains(reference.path));
  });

  test('defaults to .jpg for jpeg and unknown-but-allowed types', () async {
    final jpeg = await storage.upload(buildImage(mimeType: 'image/jpeg'));
    final webp = await storage.upload(buildImage(mimeType: 'image/webp'));

    expect(jpeg.dataOrNull!.path, endsWith('.jpg'));
    expect(webp.dataOrNull!.path, endsWith('.webp'));
  });

  test('rejects an invalid image like the real storage rules would', () async {
    final result = await storage.upload(buildImage(mimeType: 'image/gif'));

    expect(result.failureOrNull?.type, FailureType.validation);
    expect(storage.storedPaths, isEmpty);
  });

  test('uploads get distinct paths', () async {
    final a = await storage.upload(buildImage());
    final b = await storage.upload(buildImage());

    expect(a.dataOrNull!.path, isNot(b.dataOrNull!.path));
  });

  test('delete forgets the path and succeeds even if it never existed', () async {
    final uploaded = await storage.upload(buildImage());

    await storage.delete(uploaded.dataOrNull!.path);
    final result = await storage.delete('media/articles/ghost.jpg');

    expect(storage.storedPaths, isEmpty);
    expect(result.isSuccess, isTrue);
  });
}
