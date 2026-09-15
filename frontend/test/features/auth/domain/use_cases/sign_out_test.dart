import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('delegates to the repository', () async {
    final auth = MockAuthRepository();
    when(() => auth.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final result = await SignOutUseCase(auth)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => auth.signOut()).called(1);
  });
}
