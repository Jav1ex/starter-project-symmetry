import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/editor_suggestions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/apply_article_lens.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reader_lens/reader_lens_cubit.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(buildDraft());
    registerFallbackValue(ApplyArticleLensParams(lens: ArticleLens.brief, article: buildArticle()));
  });

  group('EditorAssistantCubit', () {
    late MockSuggestArticleEditsUseCase suggest;
    const suggestions = EditorSuggestions(headlines: ['A'], summary: 'S', category: NewsCategory.science);

    setUp(() => suggest = MockSuggestArticleEditsUseCase());

    test('ask goes loading then ready, dismiss resets', () async {
      when(() => suggest(any())).thenAnswer((_) async => const DataSuccess(suggestions));
      final cubit = EditorAssistantCubit(suggest);
      final statuses = <EditorAssistantStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.ask(buildDraft());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(statuses, [EditorAssistantStatus.loading, EditorAssistantStatus.ready]);
      expect(cubit.state.suggestions, suggestions);

      cubit.dismiss();
      expect(cubit.state, const EditorAssistantState());
      await cubit.close();
    });

    test('a failure is kept for the sheet to show', () async {
      when(() => suggest(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
      final cubit = EditorAssistantCubit(suggest);

      await cubit.ask(buildDraft());

      expect(cubit.state.status, EditorAssistantStatus.failure);
      expect(cubit.state.failure, const Failure.network());
      await cubit.close();
    });
  });

  group('ReaderLensCubit', () {
    late MockApplyArticleLensUseCase apply;
    final article = buildArticle();
    const brief = ArticleLensResult(lens: ArticleLens.brief, bullets: ['a', 'b', 'c']);

    setUp(() {
      apply = MockApplyArticleLensUseCase();
      when(() => apply(any())).thenAnswer((_) async => const DataSuccess(brief));
    });

    test('toggling a lens fetches once, toggling again shows the original, third time is cached', () async {
      final cubit = ReaderLensCubit(apply, article: article);

      await cubit.toggle(ArticleLens.brief);
      expect(cubit.state.active, ArticleLens.brief);
      expect(cubit.state.current, brief);
      expect(cubit.state.isLoading, isFalse);

      await cubit.toggle(ArticleLens.brief);
      expect(cubit.state.active, isNull);
      expect(cubit.state.current, isNull);

      await cubit.toggle(ArticleLens.brief);
      expect(cubit.state.current, brief);
      verify(() => apply(any())).called(1);
      await cubit.close();
    });

    test('a failed lens falls back to the original and reports', () async {
      when(() => apply(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
      final cubit = ReaderLensCubit(apply, article: article);

      await cubit.toggle(ArticleLens.plain);

      expect(cubit.state.active, isNull);
      expect(cubit.state.failure, const Failure.server());
      await cubit.close();
    });

    test('showOriginal clears the active lens but keeps the cache', () async {
      final cubit = ReaderLensCubit(apply, article: article);
      await cubit.toggle(ArticleLens.brief);

      cubit.showOriginal();

      expect(cubit.state.active, isNull);
      expect(cubit.state.results.containsKey(ArticleLens.brief), isTrue);
      await cubit.close();
    });
  });
}
