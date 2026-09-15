import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/in_memory_auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late InMemoryAuthRepository auth;

  const signUp = SignUpParams(
    displayName: 'Ada',
    email: 'Ada@Example.com',
    password: 'longenough',
  );

  setUp(() {
    auth = InMemoryAuthRepository(latency: Duration.zero);
  });

  tearDown(() => auth.dispose());

  test('starts signed out unless an initial user is given', () {
    expect(auth.currentUser, isNull);
    expect(InMemoryAuthRepository(initialUser: user).currentUser, user);
  });

  group('signUpWithEmail', () {
    test('creates the account and signs the user in', () async {
      final result = await auth.signUpWithEmail(signUp);

      final created = result.dataOrNull!;
      expect(created.displayName, 'Ada');
      expect(created.email, 'Ada@Example.com');
      expect(auth.currentUser, created);
    });

    test('rejects a second account for the same email, ignoring case', () async {
      await auth.signUpWithEmail(signUp);

      final again = await auth.signUpWithEmail(
        const SignUpParams(displayName: 'Other', email: 'ada@example.com', password: 'x'),
      );

      expect(again.failureOrNull?.type, FailureType.emailAlreadyInUse);
    });
  });

  group('signInWithEmail', () {
    test('accepts the registered password', () async {
      await auth.signUpWithEmail(signUp);
      await auth.signOut();

      final result = await auth.signInWithEmail(
        const SignInParams(email: 'ada@example.com', password: 'longenough'),
      );

      expect(result.dataOrNull?.displayName, 'Ada');
      expect(auth.currentUser, isNotNull);
    });

    test('rejects a wrong password and an unknown email alike', () async {
      await auth.signUpWithEmail(signUp);

      final wrong = await auth.signInWithEmail(
        const SignInParams(email: 'ada@example.com', password: 'nope'),
      );
      final unknown = await auth.signInWithEmail(
        const SignInParams(email: 'ghost@example.com', password: 'longenough'),
      );

      expect(wrong.failureOrNull?.type, FailureType.invalidCredentials);
      expect(unknown.failureOrNull?.type, FailureType.invalidCredentials);
    });
  });

  test('signInWithGoogle always signs in the fixed Google account', () async {
    final result = await auth.signInWithGoogle();

    expect(result.dataOrNull, InMemoryAuthRepository.googleUser);
    expect(auth.currentUser, InMemoryAuthRepository.googleUser);
  });

  test('signOut clears the current user', () async {
    await auth.signInWithGoogle();

    await auth.signOut();

    expect(auth.currentUser, isNull);
  });

  group('deleteAccount', () {
    test('fails when signed out', () async {
      final result = await auth.deleteAccount();

      expect(result.failureOrNull?.type, FailureType.unauthenticated);
    });

    test('removes the account so it can no longer sign in', () async {
      await auth.signUpWithEmail(signUp);

      await auth.deleteAccount();
      final again = await auth.signInWithEmail(
        const SignInParams(email: 'ada@example.com', password: 'longenough'),
      );

      expect(auth.currentUser, isNull);
      expect(again.failureOrNull?.type, FailureType.invalidCredentials);
    });
  });

  test('watchAuthState emits the current state first, then every change', () async {
    final events = <String?>[];
    final subscription = auth.watchAuthState().listen((u) => events.add(u?.id));
    await flush();

    await auth.signInWithGoogle();
    await auth.signOut();
    await flush();
    await subscription.cancel();

    expect(events, [null, InMemoryAuthRepository.googleUser.id, null]);
  });
}
