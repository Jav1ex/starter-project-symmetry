import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_speech_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/control_reading.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_top_headlines.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/search_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/suggest_article_edits.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/read_aloud.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:provider/single_child_widget.dart';

import 'fixtures.dart';
import 'pump_app.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

class MockGetSavedArticlesUseCase extends Mock implements GetSavedArticlesUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveSavedArticleUseCase extends Mock implements RemoveSavedArticleUseCase {}

class MockGetMyArticlesUseCase extends Mock implements GetMyArticlesUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockPickThumbnailUseCase extends Mock implements PickThumbnailUseCase {}

class MockGetTopHeadlinesUseCase extends Mock implements GetTopHeadlinesUseCase {}

class MockSearchArticlesUseCase extends Mock implements SearchArticlesUseCase {}

class MockSuggestArticleEditsUseCase extends Mock implements SuggestArticleEditsUseCase {}

class MockApplyArticleLensUseCase extends Mock implements ApplyArticleLensUseCase {}

/// Everything the Home shell needs: session, settings and the app-wide
/// cubits (saved, feed, my articles), plus a PublishCubit factory in the
/// service locator. Create it inside the test body and pass [providers] to
/// the pump helpers.
class ShellHarness {
  final SessionHarness session = SessionHarness();
  final SettingsHarness settings = SettingsHarness();
  final MockGetFeedUseCase getFeed = MockGetFeedUseCase();
  final MockGetSavedArticlesUseCase getSaved = MockGetSavedArticlesUseCase();
  final MockSaveArticleUseCase save = MockSaveArticleUseCase();
  final MockRemoveSavedArticleUseCase remove = MockRemoveSavedArticleUseCase();
  final MockGetMyArticlesUseCase getMyArticles = MockGetMyArticlesUseCase();
  final MockDeleteArticleUseCase deleteArticle = MockDeleteArticleUseCase();
  final MockPublishArticleUseCase publishArticle = MockPublishArticleUseCase();
  final MockUpdateArticleUseCase updateArticle = MockUpdateArticleUseCase();
  final MockPickThumbnailUseCase pickThumbnail = MockPickThumbnailUseCase();
  late final SavedArticlesCubit savedCubit;
  late final FeedCubit feedCubit;
  final MockGetTopHeadlinesUseCase getTopHeadlines = MockGetTopHeadlinesUseCase();
  final MockSearchArticlesUseCase searchArticles = MockSearchArticlesUseCase();
  late final MyArticlesCubit myArticlesCubit;
  late final BriefCubit briefCubit;
  final MockSuggestArticleEditsUseCase suggestEdits = MockSuggestArticleEditsUseCase();
  final MockApplyArticleLensUseCase applyLens = MockApplyArticleLensUseCase();
  final InMemorySpeechRepository speech = InMemorySpeechRepository();
  late final ListenCubit listenCubit;

  ShellHarness({FeedEntity feed = FeedEntity.empty, List<ArticleEntity> myArticles = const []}) {
    registerFallbackValue(const NewsQuery());
    registerFallbackValue(buildArticle());
    registerFallbackValue(PublishArticleParams(draft: buildDraft()));
    registerFallbackValue(UpdateArticleParams(article: buildArticle(), draft: buildDraft()));
    when(() => getFeed(any())).thenAnswer((_) async => DataSuccess(feed));
    when(() => getSaved(any())).thenAnswer((_) async => const DataSuccess([]));
    when(() => save(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => remove(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => getMyArticles(any())).thenAnswer((_) async => DataSuccess(myArticles));
    when(() => deleteArticle(any())).thenAnswer((_) async => const DataSuccess(null));
    when(() => pickThumbnail(any())).thenAnswer((_) async => DataSuccess(buildImage()));
    savedCubit = SavedArticlesCubit(getSaved, save, remove);
    feedCubit = FeedCubit(getFeed);
    myArticlesCubit = MyArticlesCubit(getMyArticles, deleteArticle);
    when(() => getTopHeadlines(any())).thenAnswer((_) async => DataSuccess(feed.articles));
    when(() => searchArticles(any())).thenAnswer((_) async => DataSuccess(feed));
    briefCubit = BriefCubit(getTopHeadlines);
    registerFallbackValue(buildDraft());
    registerFallbackValue(ApplyArticleLensParams(lens: ArticleLens.brief, article: buildArticle()));
    when(() => suggestEdits(any())).thenAnswer((_) async => const DataSuccess(EditorSuggestions(
          headlines: ['Headline one', 'Headline two', 'Headline three'],
          summary: 'A short summary.',
          category: NewsCategory.science,
        )));
    when(() => applyLens(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.single as ApplyArticleLensParams;
      return DataSuccess(params.lens == ArticleLens.brief
          ? ArticleLensResult(lens: params.lens, bullets: const ['First fact', 'Second fact', 'Third fact'])
          : ArticleLensResult(lens: params.lens, text: 'Rewritten body'));
    });
    listenCubit = ListenCubit(
      ReadAloudUseCase(speech),
      PauseReadingUseCase(speech),
      ResumeReadingUseCase(speech),
      StopReadingUseCase(speech),
      WatchReadingStatusUseCase(speech),
    );
    if (sl.isRegistered<EditorAssistantCubit>()) sl.unregister<EditorAssistantCubit>();
    sl.registerFactory<EditorAssistantCubit>(() => EditorAssistantCubit(suggestEdits));
    if (sl.isRegistered<ReaderLensCubit>()) sl.unregister<ReaderLensCubit>();
    sl.registerFactoryParam<ReaderLensCubit, ArticleEntity, void>(
      (article, _) => ReaderLensCubit(applyLens, article: article),
    );
    if (sl.isRegistered<SearchCubit>()) sl.unregister<SearchCubit>();
    sl.registerFactory<SearchCubit>(() => SearchCubit(searchArticles, debounce: Duration.zero));
    if (sl.isRegistered<PublishCubit>()) sl.unregister<PublishCubit>();
    sl.registerFactoryParam<PublishCubit, ArticleEntity?, void>(
      (original, _) => PublishCubit(publishArticle, updateArticle, pickThumbnail, original: original),
    );
    session.signIn(user);
    addTearDown(() async {
      sl.unregister<PublishCubit>();
      sl.unregister<SearchCubit>();
      sl.unregister<EditorAssistantCubit>();
      sl.unregister<ReaderLensCubit>();
      await briefCubit.close();
      await listenCubit.close();
      await speech.dispose();
      await savedCubit.close();
      await feedCubit.close();
      await myArticlesCubit.close();
      await session.dispose();
      await settings.dispose();
    });
  }

  List<SingleChildWidget> get providers => [
        BlocProvider.value(value: session.cubit),
        BlocProvider.value(value: settings.cubit),
        BlocProvider.value(value: savedCubit),
        BlocProvider.value(value: feedCubit),
        BlocProvider.value(value: myArticlesCubit),
        BlocProvider.value(value: briefCubit),
        BlocProvider.value(value: listenCubit),
      ];
}
