import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/delete_account.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('delegates to the repository', () async {
    final auth = MockAuthRepository();
    when(() => auth.deleteAccount()).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteAccountUseCase(auth)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => auth.deleteAccount()).called(1);
  });
}
