import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/update_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_assistant_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';

// Repositories

class MockNewsRepository extends Mock implements NewsRepository {}

class MockArticleAssistantRepository extends Mock implements ArticleAssistantRepository {}

class MockDraftRepository extends Mock implements DraftRepository {}

class MockUserArticleRepository extends Mock implements UserArticleRepository {}

class MockSavedArticleRepository extends Mock implements SavedArticleRepository {}

class MockThumbnailStorageRepository extends Mock
    implements ThumbnailStorageRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// Use cases (for cubit and widget tests)

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}

class MockSignInWithGoogleUseCase extends Mock implements SignInWithGoogleUseCase {}

class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockWatchSettingsUseCase extends Mock implements WatchSettingsUseCase {}

class MockSaveSettingsUseCase extends Mock implements SaveSettingsUseCase {}
