import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/device_image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/image_picker_repository.dart';

class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final DeviceImagePicker _picker;

  const ImagePickerRepositoryImpl(this._picker);

  @override
  Future<DataState<LocalImage?>> pickFromGallery() async {
    try {
      final model = await _picker.pickImage();
      return DataSuccess(model?.toEntity());
    } catch (_) {
      return const DataFailed(Failure.unknown("The photo library couldn't be opened."));
    }
  }
}
