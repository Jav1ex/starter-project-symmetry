import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

void main() {
  group('CredentialRules.isValidEmail', () {
    test('accepts common addresses, trimming whitespace', () {
      expect(CredentialRules.isValidEmail('ada@example.com'), isTrue);
      expect(CredentialRules.isValidEmail('  a.b+tag@sub.domain.co  '), isTrue);
    });

    test('rejects malformed addresses', () {
      for (final email in ['', 'ada', 'ada@', '@example.com', 'ada@example', 'a b@x.com']) {
        expect(CredentialRules.isValidEmail(email), isFalse, reason: email);
      }
    });
  });

  group('SignInParams.validate', () {
    test('accepts a well-formed pair', () {
      const params = SignInParams(email: 'ada@example.com', password: 'x');
      expect(params.validate(), isEmpty);
      expect(params.isValid, isTrue);
    });

    test('reports a missing email', () {
      const params = SignInParams(email: '  ', password: 'x');
      expect(params.validate(), [CredentialValidationError.emptyEmail]);
    });

    test('reports an invalid email', () {
      const params = SignInParams(email: 'nope', password: 'x');
      expect(params.validate(), [CredentialValidationError.invalidEmail]);
    });

    test('reports a missing password after the email problems', () {
      const params = SignInParams(email: 'nope', password: '');
      expect(params.validate(), [
        CredentialValidationError.invalidEmail,
        CredentialValidationError.emptyPassword,
      ]);
    });

    test('does not enforce a minimum password length on sign in', () {
      const params = SignInParams(email: 'ada@example.com', password: '1');
      expect(params.isValid, isTrue);
    });
  });

  group('SignUpParams.validate', () {
    const valid = SignUpParams(
      displayName: 'Ada',
      email: 'ada@example.com',
      password: 'longenough',
    );

    test('accepts a complete form', () {
      expect(valid.validate(), isEmpty);
    });

    test('reports a missing name', () {
      final params = SignUpParams(displayName: ' ', email: valid.email, password: valid.password);
      expect(params.validate(), [CredentialValidationError.emptyDisplayName]);
    });

    test('reports a too-short name', () {
      final params = SignUpParams(displayName: 'A', email: valid.email, password: valid.password);
      expect(params.validate(), [CredentialValidationError.shortDisplayName]);
    });

    test('reports a too-long name', () {
      final params = SignUpParams(
        displayName: 'x' * (CredentialRules.displayNameMaxLength + 1),
        email: valid.email,
        password: valid.password,
      );
      expect(params.validate(), [CredentialValidationError.longDisplayName]);
    });

    test('reports a short password', () {
      final params = SignUpParams(
        displayName: 'Ada',
        email: valid.email,
        password: 'x' * (CredentialRules.passwordMinLength - 1),
      );
      expect(params.validate(), [CredentialValidationError.shortPassword]);
    });

    test('accepts a password at the minimum length', () {
      final params = SignUpParams(
        displayName: 'Ada',
        email: valid.email,
        password: 'x' * CredentialRules.passwordMinLength,
      );
      expect(params.isValid, isTrue);
    });

    test('trims the name and email', () {
      const params = SignUpParams(
        displayName: '  Ada  ',
        email: '  ada@example.com ',
        password: 'longenough',
      );
      expect(params.trimmedDisplayName, 'Ada');
      expect(params.trimmedEmail, 'ada@example.com');
    });

    test('every error has a user-facing message', () {
      for (final error in CredentialValidationError.values) {
        expect(error.message, isNotEmpty);
      }
    });
  });
}
