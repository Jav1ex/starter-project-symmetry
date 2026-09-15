import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/clear_account_local_data.dart';

/// Deletes the account, then leaves the device clean.
///
/// Unlike signing out, the provider can refuse (it asks for a recent sign-in
/// first), so nothing local is touched until the account is really gone.
class DeleteAccountUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;
  final ClearAccountLocalDataUseCase _clearLocalData;

  const DeleteAccountUseCase(this._authRepository, this._clearLocalData);

  @override
  Future<DataState<void>> call(NoParams params) async {
    final deleted = await _authRepository.deleteAccount();
    if (deleted is DataFailed<void>) return deleted;
    await _clearLocalData(params);
    return deleted;
  }
}
