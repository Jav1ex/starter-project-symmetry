import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/image_picker_repository.dart';

/// Picks a thumbnail and rejects it right away if the backend would
/// (wrong type or over 5 MB), so the form can explain before uploading.
class PickThumbnailUseCase implements UseCase<DataState<LocalImage?>, NoParams> {
  final ImagePickerRepository _imagePickerRepository;

  const PickThumbnailUseCase(this._imagePickerRepository);

  @override
  Future<DataState<LocalImage?>> call(NoParams params) async {
    final picked = await _imagePickerRepository.pickFromGallery();
    final image = picked.dataOrNull;
    if (image == null) return picked;

    final errors = image.validate();
    if (errors.isNotEmpty) {
      return DataFailed(Failure.validation(errors.first.message));
    }
    return DataSuccess(image);
  }
}
