import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late SettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepositoryImpl(SettingsLocalDataSource(await SharedPreferences.getInstance()));
  });
  tearDown(() => repository.dispose());

  test('starts with the defaults and persists a save for the next read', () async {
    expect(await repository.getSettings(), AppSettings.defaults);

    const changed = AppSettings(themeMode: AppThemeMode.dark, defaultCategory: NewsCategory.health);
    expect((await repository.saveSettings(changed)).isSuccess, isTrue);

    expect(await repository.getSettings(), changed);
    final fresh = SettingsRepositoryImpl(SettingsLocalDataSource(await SharedPreferences.getInstance()));
    expect(await fresh.getSettings(), changed);
    await fresh.dispose();
  });

  test('watchSettings emits the current value first, then every save', () async {
    final emitted = <AppSettings>[];
    final sub = repository.watchSettings().listen(emitted.add);
    await flush();
    await repository.saveSettings(const AppSettings(textSize: TextSizePreference.large));
    await flush();
    await sub.cancel();

    expect(emitted, [AppSettings.defaults, const AppSettings(textSize: TextSizePreference.large)]);
  });

  test('the model tolerates unknown stored values', () {
    final model = AppSettingsModel.fromRawData({
      AppSettingsModel.keyThemeMode: 'sepia',
      AppSettingsModel.keyTextSize: null,
      AppSettingsModel.keyDefaultCategory: 'nope',
      AppSettingsModel.keySpeechRate: 'fast',
    });

    expect(model.themeMode, AppThemeMode.system);
    expect(model.textSize, TextSizePreference.medium);
    expect(model.defaultCategory, NewsCategory.general);
    expect(model.speechRate, SpeechRatePreference.fast);
    expect(AppSettingsModel.fromEntity(model.toEntity()).toRawData()[AppSettingsModel.keySpeechRate], 'fast');
  });
}
