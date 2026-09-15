import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/clear_account_local_data.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late MockSavedArticleRepository saved;
  late MockDraftRepository drafts;
  late MockSettingsRepository settings;

  setUp(() {
    saved = MockSavedArticleRepository();
    drafts = MockDraftRepository();
    settings = MockSettingsRepository();
    when(() => saved.clear()).thenAnswer((_) async => const DataSuccess(null));
    when(() => drafts.clearDraft()).thenAnswer((_) async => const DataSuccess(null));
    when(() => settings.saveSettings(any())).thenAnswer((_) async => const DataSuccess(null));
  });

  test('clears bookmarks and the draft, and puts the settings back to the defaults', () async {
    final result = await ClearAccountLocalDataUseCase(saved, drafts, settings)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => saved.clear()).called(1);
    verify(() => drafts.clearDraft()).called(1);
    verify(() => settings.saveSettings(AppSettings.defaults)).called(1);
  });

  test('a failing step does not stop the others and is the one reported', () async {
    when(() => saved.clear()).thenAnswer((_) async => const DataFailed(Failure.unknown('db')));

    final result = await ClearAccountLocalDataUseCase(saved, drafts, settings)(const NoParams());

    expect(result.failureOrNull, const Failure.unknown('db'));
    verify(() => drafts.clearDraft()).called(1);
    verify(() => settings.saveSettings(AppSettings.defaults)).called(1);
  });
}
