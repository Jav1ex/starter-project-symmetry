import 'package:equatable/equatable.dart';

/// Rules for account credentials. Kept in the domain so the form and the
/// use cases agree.
abstract final class CredentialRules {
  static const int passwordMinLength = 8;
  static const int displayNameMinLength = 2;
  static const int displayNameMaxLength = 50;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static bool isValidEmail(String email) => _emailPattern.hasMatch(email.trim());
}

enum CredentialValidationError {
  emptyEmail('Enter your email.'),
  invalidEmail('That does not look like a valid email.'),
  emptyPassword('Enter your password.'),
  shortPassword(
      'Use at least ${CredentialRules.passwordMinLength} characters for your password.'),
  emptyDisplayName('Tell us your name.'),
  shortDisplayName('Your name needs at least '
      '${CredentialRules.displayNameMinLength} characters.'),
  longDisplayName('Your name cannot exceed '
      '${CredentialRules.displayNameMaxLength} characters.');

  final String message;

  const CredentialValidationError(this.message);
}

/// Email and password typed on the sign-in form.
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  String get trimmedEmail => email.trim();

  List<CredentialValidationError> validate() {
    final errors = <CredentialValidationError>[];
    if (trimmedEmail.isEmpty) {
      errors.add(CredentialValidationError.emptyEmail);
    } else if (!CredentialRules.isValidEmail(trimmedEmail)) {
      errors.add(CredentialValidationError.invalidEmail);
    }
    if (password.isEmpty) {
      errors.add(CredentialValidationError.emptyPassword);
    }
    return errors;
  }

  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [email, password];
}

/// Fields typed on the create-account form.
class SignUpParams extends Equatable {
  final String displayName;
  final String email;
  final String password;

  const SignUpParams({
    required this.displayName,
    required this.email,
    required this.password,
  });

  String get trimmedDisplayName => displayName.trim();

  String get trimmedEmail => email.trim();

  List<CredentialValidationError> validate() {
    final errors = <CredentialValidationError>[];

    if (trimmedDisplayName.isEmpty) {
      errors.add(CredentialValidationError.emptyDisplayName);
    } else if (trimmedDisplayName.length < CredentialRules.displayNameMinLength) {
      errors.add(CredentialValidationError.shortDisplayName);
    } else if (trimmedDisplayName.length > CredentialRules.displayNameMaxLength) {
      errors.add(CredentialValidationError.longDisplayName);
    }

    if (trimmedEmail.isEmpty) {
      errors.add(CredentialValidationError.emptyEmail);
    } else if (!CredentialRules.isValidEmail(trimmedEmail)) {
      errors.add(CredentialValidationError.invalidEmail);
    }

    if (password.isEmpty) {
      errors.add(CredentialValidationError.emptyPassword);
    } else if (password.length < CredentialRules.passwordMinLength) {
      errors.add(CredentialValidationError.shortPassword);
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [displayName, email, password];
}
