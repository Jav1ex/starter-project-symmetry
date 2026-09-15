import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/thumbnail_storage_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/thumbnail_storage_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/shared/data/mappers/firebase_failure_mapper.dart';

/// Profile photos live at `media/avatars/{uid}.{ext}`, the only name the
/// Storage rules let that account write.
class ProfilePhotoRepositoryImpl implements ProfilePhotoRepository {
  final ThumbnailStorageService _service;

  const ProfilePhotoRepositoryImpl(this._service);

  static const String folder = 'media/avatars';

  static String objectPathFor(String userId, LocalImage image) =>
      '$folder/$userId.${ThumbnailStorageRepositoryImpl.extensionFor(image.mimeType)}';

  @override
  Future<DataState<String>> upload({required String userId, required LocalImage image}) async {
    final errors = image.validate();
    if (errors.isNotEmpty) return DataFailed(Failure.validation(errors.first.message));
    try {
      final url = await _service.upload(
        filePath: image.path,
        objectPath: objectPathFor(userId, image),
        contentType: image.mimeType,
      );
      return DataSuccess(url);
    } catch (error) {
      return DataFailed(FirebaseFailureMapper.map(error));
    }
  }
}
