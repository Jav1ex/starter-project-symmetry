import 'dart:async';

import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _local;
  final StreamController<AppSettings> _changes = StreamController<AppSettings>.broadcast();

  SettingsRepositoryImpl(this._local);

  @override
  Stream<AppSettings> watchSettings() async* {
    yield _local.read().toEntity();
    yield* _changes.stream;
  }

  @override
  Future<AppSettings> getSettings() => Future.value(_local.read().toEntity());

  @override
  Future<DataState<void>> saveSettings(AppSettings settings) async {
    try {
      await _local.write(AppSettingsModel.fromEntity(settings));
      _changes.add(settings);
      return const DataSuccess(null);
    } catch (_) {
      return const DataFailed(Failure.unknown("Your settings couldn't be saved."));
    }
  }

  Future<void> dispose() => _changes.close();
}
