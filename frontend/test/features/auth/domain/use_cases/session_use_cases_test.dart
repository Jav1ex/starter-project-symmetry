import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/delete_account.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

/// Session use cases delegate without extra logic; these tests pin that.
void main() {
  late MockAuthRepository auth;

  setUp(() {
    auth = MockAuthRepository();
  });

  test('SignInWithGoogleUseCase returns the provider result', () async {
    when(() => auth.signInWithGoogle()).thenAnswer((_) async => const DataSuccess(user));

    final result = await SignInWithGoogleUseCase(auth)(const NoParams());

    expect(result.dataOrNull, user);
  });

  test('SignInWithGoogleUseCase surfaces a cancelled picker', () async {
    when(() => auth.signInWithGoogle())
        .thenAnswer((_) async => const DataFailed(Failure.cancelled()));

    final result = await SignInWithGoogleUseCase(auth)(const NoParams());

    expect(result.failureOrNull?.type, FailureType.cancelled);
  });

  test('SignOutUseCase delegates', () async {
    when(() => auth.signOut()).thenAnswer((_) async => const DataSuccess(null));

    final result = await SignOutUseCase(auth)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => auth.signOut()).called(1);
  });

  test('DeleteAccountUseCase delegates', () async {
    when(() => auth.deleteAccount()).thenAnswer((_) async => const DataSuccess(null));

    final result = await DeleteAccountUseCase(auth)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => auth.deleteAccount()).called(1);
  });

  test('WatchAuthStateUseCase re-emits the repository stream', () {
    when(() => auth.watchAuthState()).thenAnswer((_) => Stream.fromIterable([null, user, null]));

    final stream = WatchAuthStateUseCase(auth)(const NoParams());

    expect(stream, emitsInOrder([null, user, null, emitsDone]));
  });

  test('GetCurrentUserUseCase returns the current user or null', () async {
    when(() => auth.currentUser).thenReturn(user);
    expect(await GetCurrentUserUseCase(auth)(const NoParams()), user);

    when(() => auth.currentUser).thenReturn(null);
    expect(await GetCurrentUserUseCase(auth)(const NoParams()), isNull);
  });
}
