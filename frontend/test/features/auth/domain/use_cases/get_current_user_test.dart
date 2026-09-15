import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/get_current_user.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  test('returns the current user or null', () async {
    final auth = MockAuthRepository();

    when(() => auth.currentUser).thenReturn(user);
    expect(await GetCurrentUserUseCase(auth)(const NoParams()), user);

    when(() => auth.currentUser).thenReturn(null);
    expect(await GetCurrentUserUseCase(auth)(const NoParams()), isNull);
  });
}
