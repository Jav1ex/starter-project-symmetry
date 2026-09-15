import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/profile_photo_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/local_image.dart';

/// Stand-in used by tests: validates like the real one and answers with a
/// deterministic placeholder URL.
class InMemoryProfilePhotoRepository implements ProfilePhotoRepository {
  @override
  Future<DataState<String>> upload({required String userId, required LocalImage image}) async {
    final errors = image.validate();
    if (errors.isNotEmpty) return DataFailed(Failure.validation(errors.first.message));
    return DataSuccess('https://picsum.photos/seed/avatar-$userId/200/200');
  }
}
