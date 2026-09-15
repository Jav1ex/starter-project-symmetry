import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/thumbnail_storage_repository_impl.dart';

import '../../../../helpers/fixtures.dart';

class MockThumbnailStorageService extends Mock implements ThumbnailStorageService {}

void main() {
  late MockThumbnailStorageService service;
  late ThumbnailStorageRepositoryImpl repository;

  setUp(() {
    service = MockThumbnailStorageService();
    repository = ThumbnailStorageRepositoryImpl(service, random: Random(1));
  });

  test('upload stores the file under media/articles with the right extension and type', () async {
    when(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        )).thenAnswer((_) async => 'https://download/url?alt=media');

    final result = await repository.upload(buildImage(mimeType: 'image/png'));

    final captured = verify(() => service.upload(
          filePath: '/tmp/photo.jpg',
          objectPath: captureAny(named: 'objectPath'),
          contentType: 'image/png',
        )).captured.single as String;
    expect(captured, matches(RegExp(r'^media/articles/\d+-[0-9a-f]{6}\.png$')));
    expect(result.dataOrNull?.path, captured);
    expect(result.dataOrNull?.url, 'https://download/url?alt=media');
  });

  test('an invalid image is rejected before any upload', () async {
    final result = await repository.upload(buildImage(mimeType: 'image/gif'));

    expect(result.failureOrNull?.type, FailureType.validation);
    verifyNever(() => service.upload(
          filePath: any(named: 'filePath'),
          objectPath: any(named: 'objectPath'),
          contentType: any(named: 'contentType'),
        ));
  });

  test('delete succeeds, and a file already gone counts as success', () async {
    when(() => service.delete('media/articles/a.jpg')).thenAnswer((_) async {});
    expect((await repository.delete('media/articles/a.jpg')).isSuccess, isTrue);

    when(() => service.delete('media/articles/b.jpg'))
        .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'object-not-found'));
    expect((await repository.delete('media/articles/b.jpg')).isSuccess, isTrue);

    when(() => service.delete('media/articles/c.jpg'))
        .thenThrow(FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'));
    expect((await repository.delete('media/articles/c.jpg')).failureOrNull?.type, FailureType.permissionDenied);
  });

  test('extensions follow the MIME type', () {
    expect(ThumbnailStorageRepositoryImpl.extensionFor('image/webp'), 'webp');
    expect(ThumbnailStorageRepositoryImpl.extensionFor('image/jpeg'), 'jpg');
  });
}
