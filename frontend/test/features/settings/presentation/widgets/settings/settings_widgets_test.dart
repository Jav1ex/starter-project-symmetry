import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/text_size_control.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/theme_mode_selector.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('SettingsSection upper-cases its title and divides its rows', (tester) async {
    await pumpApp(
      tester,
      const SettingsSection(
        title: 'Feed',
        children: [SettingsRow(label: 'One'), SettingsRow(label: 'Two')],
      ),
    );

    expect(find.text('FEED'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('SettingsRow shows value, chevron and reacts to taps', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      SettingsRow(
        label: 'Country',
        value: 'Portugal',
        icon: Icons.public,
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('Portugal'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.byIcon(Icons.public), findsOneWidget);
    expect(tester.getSize(find.byType(SettingsRow)).height, greaterThanOrEqualTo(64));

    await tester.tap(find.text('Country'));
    expect(tapped, isTrue);
  });

  testWidgets('a SettingsRow without onTap has no chevron', (tester) async {
    await pumpApp(tester, const SettingsRow(label: 'Version', value: '1.0.0'));

    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('ThemeModeSelector reports the tapped segment', (tester) async {
    AppThemeMode? chosen;
    await pumpApp(
      tester,
      ThemeModeSelector(selected: AppThemeMode.system, onChanged: (mode) => chosen = mode),
    );

    await tester.tap(find.text('Light'));
    expect(chosen, AppThemeMode.light);
    expect(ThemeModeSelector.labelOf(AppThemeMode.dark), 'Dark');
  });

  testWidgets('TextSizeControl shows the step name and a preview', (tester) async {
    TextSizePreference? chosen;
    await pumpApp(
      tester,
      TextSizeControl(selected: TextSizePreference.large, onChanged: (s) => chosen = s),
    );

    expect(find.text('Large'), findsOneWidget);
    expect(find.text(TextSizeControl.previewText), findsOneWidget);

    tester.widget<Slider>(find.byType(Slider)).onChanged!(0);
    expect(chosen, TextSizePreference.small);
  });
}
