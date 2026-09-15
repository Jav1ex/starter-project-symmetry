import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/theme_mode_mapper.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

void main() {
  test('maps every domain theme mode onto its Flutter counterpart', () {
    expect(AppThemeMode.system.material, ThemeMode.system);
    expect(AppThemeMode.light.material, ThemeMode.light);
    expect(AppThemeMode.dark.material, ThemeMode.dark);
  });
}
