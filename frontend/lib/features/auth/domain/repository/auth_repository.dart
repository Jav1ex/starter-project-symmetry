import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';

/// Identity provider access.
abstract interface class AuthRepository {
  /// Emits the current user, or `null` when signed out, starting with the
  /// present state.
  Stream<UserEntity?> watchAuthState();

  /// The signed-in user right now, if any.
  UserEntity? get currentUser;

  Future<DataState<UserEntity>> signInWithEmail(SignInParams params);

  /// Creates the account and signs the user in. No email verification step.
  Future<DataState<UserEntity>> signUpWithEmail(SignUpParams params);

  Future<DataState<UserEntity>> signInWithGoogle();

  Future<DataState<void>> signOut();

  Future<DataState<void>> deleteAccount();
}
