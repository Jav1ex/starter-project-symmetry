import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/clear_account_local_data.dart';

/// Signs out and leaves the device clean for whoever signs in next.
///
/// The local data goes first, while the session still exists, so the next
/// account can never load it; the sign-out itself is what gets reported.
class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;
  final ClearAccountLocalDataUseCase _clearLocalData;

  const SignOutUseCase(this._authRepository, this._clearLocalData);

  @override
  Future<DataState<void>> call(NoParams params) async {
    await _clearLocalData(params);
    return _authRepository.signOut();
  }
}
