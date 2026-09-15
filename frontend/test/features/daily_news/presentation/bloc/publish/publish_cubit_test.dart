import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';

import '../../../../../helpers/feed_harness.dart';
import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    registerCommonFallbacks();
    registerFallbackValue(PublishArticleParams(draft: buildDraft()));
    registerFallbackValue(UpdateArticleParams(article: buildArticle(), draft: buildDraft()));
  });

  late MockPublishArticleUseCase publish;
  late MockUpdateArticleUseCase update;
  late MockPickThumbnailUseCase pick;
  final now = DateTime(2026, 9, 16, 9, 41);
  final published = buildUserArticle(id: 'new');

  PublishCubit newCubit() => PublishCubit(publish, update, pick, now: now);

  setUp(() {
    publish = MockPublishArticleUseCase();
    update = MockUpdateArticleUseCase();
    pick = MockPickThumbnailUseCase();
    when(() => publish(any())).thenAnswer((_) async => DataSuccess(published));
    when(() => update(any())).thenAnswer((_) async => DataSuccess(published));
    when(() => pick(any())).thenAnswer((_) async => DataSuccess(buildImage()));
  });

  test('starts empty, dated now, and cannot submit until title and text exist', () {
    final cubit = newCubit();
    expect(cubit.state.publishedAt, now);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.missingHint, 'Fill in the title and article text to publish.');

    cubit.titleChanged('A title');
    expect(cubit.state.missingHint, 'Write the article text to publish.');
    cubit.contentChanged('Body');
    expect(cubit.state.canSubmit, isTrue);
    expect(cubit.state.missingHint, isNull);
  });

  test('editing preloads the article and submits an update with the thumbnail decision', () async {
    final original = buildUserArticle(id: 'doc-1').copyWith(description: 'Old summary');
    final cubit = PublishCubit(publish, update, pick, original: original, now: now);
    expect(cubit.state.isEditing, isTrue);
    expect(cubit.state.title, original.title);
    expect(cubit.state.existingImageUrl, original.imageUrl);

    cubit.removePhoto();
    expect(cubit.state.hasPhoto, isFalse);
    await cubit.submit();

    final params = verify(() => update(captureAny())).captured.single as UpdateArticleParams;
    expect(params.article, original);
    expect(params.removeThumbnail, isTrue);
    expect(params.newThumbnail, isNull);
    expect(cubit.state.status, PublishStatus.success);
    expect(cubit.state.result, published);
    verifyNever(() => publish(any()));
  });

  test('submit validates through the draft and keeps other field errors while typing', () async {
    final cubit = newCubit();
    cubit.titleChanged('x' * (ArticleLimits.titleMaxLength + 1));
    cubit.contentChanged('Body');

    await cubit.submit();
    expect(cubit.state.status, PublishStatus.failure);
    expect(cubit.state.titleError, ArticleValidationError.titleTooLong);
    verifyNever(() => publish(any()));

    cubit.descriptionChanged('fine');
    expect(cubit.state.titleError, ArticleValidationError.titleTooLong);
    cubit.titleChanged('Short');
    expect(cubit.state.titleError, isNull);
  });

  test('a new article is published with the picked photo and category, dated now', () async {
    final cubit = newCubit();
    cubit
      ..titleChanged('A title')
      ..contentChanged('Body')
      ..categoryChanged(NewsCategory.science);
    await cubit.pickPhoto();
    expect(cubit.state.pickedImage, buildImage());

    final before = DateTime.now();
    await cubit.submit();

    final params = verify(() => publish(captureAny())).captured.single as PublishArticleParams;
    expect(params.thumbnail, buildImage());
    expect(params.draft.category, NewsCategory.science);
    expect(params.draft.publishedAt.isBefore(before), isFalse);
    expect(cubit.state.status, PublishStatus.success);
  });

  test('a dismissed picker changes nothing and a bad file reports the failure', () async {
    final cubit = newCubit();
    when(() => pick(any())).thenAnswer((_) async => const DataSuccess(null));
    await cubit.pickPhoto();
    expect(cubit.state.pickedImage, isNull);

    when(() => pick(any()))
        .thenAnswer((_) async => const DataFailed(Failure.validation('Use a JPEG, PNG or WebP image.')));
    await cubit.pickPhoto();
    expect(cubit.state.failure?.type, FailureType.validation);
  });

  test('a rejected publish ends in failure with the reason', () async {
    when(() => publish(any())).thenAnswer((_) async => const DataFailed(Failure.network()));
    final cubit = newCubit()
      ..titleChanged('A title')
      ..contentChanged('Body');

    await cubit.submit();

    expect(cubit.state.status, PublishStatus.failure);
    expect(cubit.state.failure, const Failure.network());
  });
}
