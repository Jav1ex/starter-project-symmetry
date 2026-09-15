import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class GetSettingsUseCase implements UseCase<AppSettings, NoParams> {
  final SettingsRepository _settingsRepository;

  const GetSettingsUseCase(this._settingsRepository);

  @override
  Future<AppSettings> call(NoParams params) {
    return _settingsRepository.getSettings();
  }
}
