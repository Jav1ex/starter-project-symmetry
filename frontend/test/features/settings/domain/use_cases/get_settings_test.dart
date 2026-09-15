import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('returns the stored settings', () async {
    final repository = MockSettingsRepository();
    const dark = AppSettings(themeMode: AppThemeMode.dark);
    when(() => repository.getSettings()).thenAnswer((_) async => dark);

    expect(await GetSettingsUseCase(repository)(const NoParams()), dark);
  });
}
