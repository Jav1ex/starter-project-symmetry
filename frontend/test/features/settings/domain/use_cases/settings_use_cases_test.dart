import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository repository;

  const dark = AppSettings(themeMode: AppThemeMode.dark);

  setUp(() {
    repository = MockSettingsRepository();
  });

  test('GetSettingsUseCase returns the stored settings', () async {
    when(() => repository.getSettings()).thenAnswer((_) async => dark);

    expect(await GetSettingsUseCase(repository)(const NoParams()), dark);
  });

  test('WatchSettingsUseCase re-emits the repository stream', () {
    when(() => repository.watchSettings())
        .thenAnswer((_) => Stream.fromIterable([AppSettings.defaults, dark]));

    final stream = WatchSettingsUseCase(repository)(const NoParams());

    expect(stream, emitsInOrder([AppSettings.defaults, dark, emitsDone]));
  });

  test('SaveSettingsUseCase forwards the settings', () async {
    when(() => repository.saveSettings(dark)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveSettingsUseCase(repository)(dark);

    expect(result.isSuccess, isTrue);
    verify(() => repository.saveSettings(dark)).called(1);
  });
}
