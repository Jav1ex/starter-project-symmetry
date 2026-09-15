import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

class MockUserArticleRepository extends Mock implements UserArticleRepository {}

class MockSavedArticleRepository extends Mock implements SavedArticleRepository {}

class MockThumbnailStorageRepository extends Mock
    implements ThumbnailStorageRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}
