import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';

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

  test('wipes the device data while signed in, then signs out', () async {
    when(() => auth.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final result = await SignOutUseCase(auth, clearLocal)(const NoParams());

    expect(result.isSuccess, isTrue);
    verifyInOrder([() => clearLocal(any()), () => auth.signOut()]);
  });

  test('reports the sign-out failure', () async {
    when(() => auth.signOut()).thenAnswer((_) async => const DataFailed(Failure.network()));

    final result = await SignOutUseCase(auth, clearLocal)(const NoParams());

    expect(result.failureOrNull?.type, FailureType.network);
  });
}
