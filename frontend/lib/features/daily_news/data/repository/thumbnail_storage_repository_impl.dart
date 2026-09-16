import 'dart:math';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/shared/data/mappers/firebase_failure_mapper.dart';

/// Thumbnails live at `media/articles/{uid}-{millis}-{random}.{ext}`. The
/// uid prefix is what the Storage rules check, so only the journalist who
/// uploaded a file can replace or delete it.
class ThumbnailStorageRepositoryImpl implements ThumbnailStorageRepository {
  final ThumbnailStorageService _service;
  final AuthRepository _auth;
  final Random _random;

  ThumbnailStorageRepositoryImpl(this._service, this._auth, {Random? random})
      : _random = random ?? Random();

  /// The only folder the Storage rules accept.
  static const String folder = 'media/articles';

  @override
  Future<DataState<ThumbnailReference>> upload(LocalImage image) async {
    final errors = image.validate();
    if (errors.isNotEmpty) {
      return DataFailed(Failure.validation(errors.first.message));
    }
    final ownerId = _auth.currentUser?.id;
    if (ownerId == null) return const DataFailed(Failure.unauthenticated());
    final objectPath = '$folder/${objectNameFor(image, ownerId: ownerId)}';
    try {
      final url = await _service.upload(
        filePath: image.path,
        objectPath: objectPath,
        contentType: image.mimeType,
      );
      return DataSuccess(ThumbnailReference(url: url, path: objectPath));
    } catch (error) {
      return DataFailed(FirebaseFailureMapper.map(error));
    }
  }

  @override
  Future<DataState<void>> delete(String path) async {
    try {
      await _service.delete(path);
      return const DataSuccess(null);
    } catch (error) {
      final failure = FirebaseFailureMapper.map(error);
      // A file that is already gone is the outcome we wanted.
      return failure.type == FailureType.notFound ? const DataSuccess(null) : DataFailed(failure);
    }
  }

  /// `{uid}-{millis}-{random}.{ext}`: owned by one journalist, unique across
  /// uploads, one file directly inside the folder, as the rules require.
  String objectNameFor(LocalImage image, {required String ownerId}) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return '$ownerId-$stamp-$salt.${extensionFor(image.mimeType)}';
  }

  static String extensionFor(String mimeType) => switch (mimeType.toLowerCase()) {
        'image/png' => 'png',
        'image/webp' => 'webp',
        _ => 'jpg',
      };
}
