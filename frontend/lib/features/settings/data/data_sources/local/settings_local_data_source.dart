import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists settings in the platform's key-value store.
class SettingsLocalDataSource {
  final SharedPreferences _preferences;

  SettingsLocalDataSource(this._preferences);

  static const List<String> keys = [
    AppSettingsModel.keyThemeMode,
    AppSettingsModel.keyTextSize,
    AppSettingsModel.keyDefaultCategory,
    AppSettingsModel.keyCountry,
    AppSettingsModel.keySpeechRate,
  ];

  AppSettingsModel read() {
    return AppSettingsModel.fromRawData({
      for (final key in keys) key: _preferences.getString(key),
    });
  }

  Future<void> write(AppSettingsModel model) async {
    for (final entry in model.toRawData().entries) {
      await _preferences.setString(entry.key, entry.value);
    }
  }
}
