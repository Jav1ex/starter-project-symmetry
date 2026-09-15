import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:provider/single_child_widget.dart';

import 'fixtures.dart';
import 'pump_app.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockGetSavedArticlesUseCase extends Mock implements GetSavedArticlesUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveSavedArticleUseCase extends Mock implements RemoveSavedArticleUseCase {}

/// Everything the Home shell needs: session, settings, saved articles and a
/// FeedCubit registered in the service locator. Create it inside the test
/// body and pass [providers] to the pump helpers.
class ShellHarness {
  final SessionHarness session = SessionHarness();
  final SettingsHarness settings = SettingsHarness();
  final MockGetFeedUseCase getFeed = MockGetFeedUseCase();
  final MockGetSavedArticlesUseCase getSaved = MockGetSavedArticlesUseCase();
  final MockSaveArticleUseCase save = MockSaveArticleUseCase();
  final MockRemoveSavedArticleUseCase remove = MockRemoveSavedArticleUseCase();
  late final SavedArticlesCubit savedCubit;

  ShellHarness({FeedEntity feed = FeedEntity.empty}) {
    registerFallbackValue(const NewsQuery());
    registerFallbackValue(buildArticle());
    when(() => getFeed(any())).thenAnswer((_) async => DataSuccess(feed));
    when(() => getSaved(any())).thenAnswer((_) async => const DataSuccess([]));
    when(() => save(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => remove(any())).thenAnswer((_) async => const DataSuccess(null));
    savedCubit = SavedArticlesCubit(getSaved, save, remove);
    if (sl.isRegistered<FeedCubit>()) sl.unregister<FeedCubit>();
    sl.registerFactory<FeedCubit>(() => FeedCubit(getFeed));
    session.signIn(user);
    addTearDown(() async {
      sl.unregister<FeedCubit>();
      await savedCubit.close();
      await session.dispose();
      await settings.dispose();
    });
  }

  List<SingleChildWidget> get providers => [
        BlocProvider.value(value: session.cubit),
        BlocProvider.value(value: settings.cubit),
        BlocProvider.value(value: savedCubit),
      ];
}
