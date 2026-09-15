import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/draft_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  Future<DraftRepositoryImpl> newRepository({bool photoExists = true}) async => DraftRepositoryImpl(
        DraftLocalDataSource(await SharedPreferences.getInstance()),
        fileExists: (_) => photoExists,
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts empty, keeps a save for the next read, and clear forgets it', () async {
    final repository = await newRepository();
    expect(await repository.loadDraft(), isNull);

    final draft = SavedDraft(title: 'T', content: 'C', image: buildImage());
    expect((await repository.saveDraft(draft)).isSuccess, isTrue);
    expect(await (await newRepository()).loadDraft(), draft);

    expect((await repository.clearDraft()).isSuccess, isTrue);
    expect(await repository.loadDraft(), isNull);
  });

  test('a photo whose file is gone is dropped; a draft left with nothing is forgotten', () async {
    final withText = await newRepository(photoExists: false);
    await withText.saveDraft(SavedDraft(title: 'T', image: buildImage()));
    expect(await withText.loadDraft(), const SavedDraft(title: 'T'));

    await withText.saveDraft(SavedDraft(image: buildImage()));
    expect(await withText.loadDraft(), isNull);
    expect((await SharedPreferences.getInstance()).containsKey(DraftLocalDataSource.key), isFalse);
  });

  test('text that is not a draft document reads as no draft', () async {
    SharedPreferences.setMockInitialValues({DraftLocalDataSource.key: '{not json'});

    expect(await (await newRepository()).loadDraft(), isNull);
  });
}
