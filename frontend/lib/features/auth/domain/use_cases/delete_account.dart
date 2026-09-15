import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;

  const DeleteAccountUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _authRepository.deleteAccount();
  }
}
