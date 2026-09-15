import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/in_memory_auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/delete_account.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/watch_auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/device/device_image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/image_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/news_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/saved_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/news_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/image_picker_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/saved_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/thumbnail_storage_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/is_article_saved.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/in_memory_settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _registerDataSources();
  _registerRepositories();
  _registerArticleUseCases();
  _registerAuthUseCases();
  _registerSettingsUseCases();
  _registerBlocs();
}

Future<void> _registerDataSources() async {
  final database = await AppDatabase.open();
  sl.registerSingleton<AppDatabase>(database);
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<DeviceImagePicker>(DeviceImagePicker(ImagePicker()));
}

/// Provider news and on-device bookmarks use their real implementations.
/// Journalist articles, thumbnails, authentication and settings run on
/// in-memory stand-ins until the Firebase data layer lands; swapping them is a
/// one-line change per repository.
void _registerRepositories() {
  sl.registerSingleton<NewsRepository>(NewsRepositoryImpl(sl()));
  sl.registerSingleton<SavedArticleRepository>(
    SavedArticleRepositoryImpl(sl<AppDatabase>().savedArticleDao),
  );
  sl.registerSingleton<UserArticleRepository>(InMemoryUserArticleRepository());
  sl.registerSingleton<ThumbnailStorageRepository>(
    InMemoryThumbnailStorageRepository(),
  );
  sl.registerSingleton<AuthRepository>(InMemoryAuthRepository());
  sl.registerSingleton<ImagePickerRepository>(ImagePickerRepositoryImpl(sl()));
  sl.registerSingleton<SettingsRepository>(InMemorySettingsRepository());
}

void _registerArticleUseCases() {
  sl.registerSingleton<GetTopHeadlinesUseCase>(GetTopHeadlinesUseCase(sl()));
  sl.registerSingleton<GetFeedUseCase>(GetFeedUseCase(sl(), sl()));
  sl.registerSingleton<SearchArticlesUseCase>(SearchArticlesUseCase(sl(), sl()));
  sl.registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl(), sl()));
  sl.registerSingleton<PublishArticleUseCase>(PublishArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<DeleteArticleUseCase>(DeleteArticleUseCase(sl(), sl(), sl()));
  sl.registerSingleton<GetSavedArticlesUseCase>(GetSavedArticlesUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveSavedArticleUseCase>(RemoveSavedArticleUseCase(sl()));
  sl.registerSingleton<IsArticleSavedUseCase>(IsArticleSavedUseCase(sl()));
  sl.registerSingleton<PickThumbnailUseCase>(PickThumbnailUseCase(sl()));
}

void _registerAuthUseCases() {
  sl.registerSingleton<WatchAuthStateUseCase>(WatchAuthStateUseCase(sl()));
  sl.registerSingleton<GetCurrentUserUseCase>(GetCurrentUserUseCase(sl()));
  sl.registerSingleton<SignInWithEmailUseCase>(SignInWithEmailUseCase(sl()));
  sl.registerSingleton<SignUpWithEmailUseCase>(SignUpWithEmailUseCase(sl()));
  sl.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(sl()));
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(sl()));
  sl.registerSingleton<DeleteAccountUseCase>(DeleteAccountUseCase(sl()));
}

void _registerSettingsUseCases() {
  sl.registerSingleton<GetSettingsUseCase>(GetSettingsUseCase(sl()));
  sl.registerSingleton<WatchSettingsUseCase>(WatchSettingsUseCase(sl()));
  sl.registerSingleton<SaveSettingsUseCase>(SaveSettingsUseCase(sl()));
}

/// App-wide cubits live as long as the app; form cubits are created per
/// screen.
void _registerBlocs() {
  sl.registerLazySingleton<SessionCubit>(() => SessionCubit(sl(), sl(), sl()));
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl(), sl()));
  sl.registerLazySingleton<SavedArticlesCubit>(() => SavedArticlesCubit(sl(), sl(), sl()));
  sl.registerLazySingleton<FeedCubit>(() => FeedCubit(sl()));
  sl.registerLazySingleton<BriefCubit>(() => BriefCubit(sl()));
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl()));
  sl.registerLazySingleton<MyArticlesCubit>(() => MyArticlesCubit(sl(), sl()));
  sl.registerFactoryParam<PublishCubit, ArticleEntity?, void>(
    (original, _) => PublishCubit(sl(), sl(), sl(), original: original),
  );
  sl.registerFactory<SignInCubit>(() => SignInCubit(sl(), sl()));
  sl.registerFactory<SignUpCubit>(() => SignUpCubit(sl(), sl()));
}
