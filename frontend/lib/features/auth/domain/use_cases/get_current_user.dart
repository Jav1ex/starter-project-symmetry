import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// The signed-in user at this moment, or `null`.
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository _authRepository;

  const GetCurrentUserUseCase(this._authRepository);

  @override
  Future<UserEntity?> call(NoParams params) {
    return Future.value(_authRepository.currentUser);
  }
}
