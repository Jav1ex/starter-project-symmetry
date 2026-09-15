import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/delete_account.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockAuthRepository auth;
  late MockClearAccountLocalDataUseCase clearLocal;

  setUp(() {
    auth = MockAuthRepository();
    clearLocal = MockClearAccountLocalDataUseCase();
    when(() => clearLocal(any())).thenAnswer((_) async => const DataSuccess(null));
  });

  test('deletes the account and then wipes the device data', () async {
    when(() => auth.deleteAccount()).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteAccountUseCase(auth, clearLocal)(const NoParams());

    expect(result.isSuccess, isTrue);
    verifyInOrder([() => auth.deleteAccount(), () => clearLocal(any())]);
  });

  test('a refused deletion leaves the device data alone', () async {
    when(() => auth.deleteAccount())
        .thenAnswer((_) async => const DataFailed(Failure.permissionDenied('Sign in again.')));

    final result = await DeleteAccountUseCase(auth, clearLocal)(const NoParams());

    expect(result.failureOrNull?.type, FailureType.permissionDenied);
    verifyNever(() => clearLocal(any()));
  });
}
