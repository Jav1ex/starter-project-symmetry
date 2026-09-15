import 'package:equatable/equatable.dart';

/// Constraints for article thumbnails. They mirror `backend/storage.rules`.
abstract final class ThumbnailLimits {
  static const int maxSizeInBytes = 5 * 1024 * 1024;
  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}

enum ImageValidationError {
  unsupportedType('Use a JPEG, PNG or WebP image.'),
  tooLarge('The image must be smaller than 5 MB.');

  final String message;

  const ImageValidationError(this.message);
}

/// An image picked on the device, before it is uploaded.
class LocalImage extends Equatable {
  /// Absolute path on the device file system.
  final String path;
  final String mimeType;
  final int sizeInBytes;

  const LocalImage({
    required this.path,
    required this.mimeType,
    required this.sizeInBytes,
  });

  List<ImageValidationError> validate() {
    final errors = <ImageValidationError>[];
    if (!ThumbnailLimits.allowedMimeTypes.contains(mimeType.toLowerCase())) {
      errors.add(ImageValidationError.unsupportedType);
    }
    if (sizeInBytes > ThumbnailLimits.maxSizeInBytes) {
      errors.add(ImageValidationError.tooLarge);
    }
    return errors;
  }

  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [path, mimeType, sizeInBytes];
}

/// Where an uploaded thumbnail lives.
class ThumbnailReference extends Equatable {
  /// Public download URL, used to render the image.
  final String url;

  /// Object path inside the storage bucket, used to delete or replace it.
  final String path;

  const ThumbnailReference({required this.url, required this.path});

  @override
  List<Object?> get props => [url, path];
}
