import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/in_memory_settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

void main() {
  late InMemorySettingsRepository repository;

  setUp(() {
    repository = InMemorySettingsRepository();
  });

  tearDown(() => repository.dispose());

  test('starts with the defaults', () async {
    expect(await repository.getSettings(), AppSettings.defaults);
  });

  test('saveSettings persists for later reads', () async {
    const dark = AppSettings(themeMode: AppThemeMode.dark);

    final result = await repository.saveSettings(dark);

    expect(result.isSuccess, isTrue);
    expect(await repository.getSettings(), dark);
  });

  test('watchSettings emits the current value first, then every save', () async {
    const dark = AppSettings(themeMode: AppThemeMode.dark);
    const large = AppSettings(themeMode: AppThemeMode.dark, textSize: TextSizePreference.large);
    final events = <AppSettings>[];
    final subscription = repository.watchSettings().listen(events.add);
    await Future<void>.delayed(Duration.zero);

    await repository.saveSettings(dark);
    await repository.saveSettings(large);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(events, [AppSettings.defaults, dark, large]);
  });
}
