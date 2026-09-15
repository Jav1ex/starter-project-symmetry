import 'dart:async';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

/// [SettingsRepository] that lives for the current run only.
class InMemorySettingsRepository implements SettingsRepository {
  final StreamController<AppSettings> _controller =
      StreamController<AppSettings>.broadcast();
  AppSettings _settings;

  InMemorySettingsRepository({AppSettings initial = AppSettings.defaults})
      : _settings = initial;

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }

  @override
  Future<AppSettings> getSettings() => Future.value(_settings);

  @override
  Future<DataState<void>> saveSettings(AppSettings settings) {
    _settings = settings;
    _controller.add(settings);
    return Future.value(const DataSuccess(null));
  }

  Future<void> dispose() => _controller.close();
}
