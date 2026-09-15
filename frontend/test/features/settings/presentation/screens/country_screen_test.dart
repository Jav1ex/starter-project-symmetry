import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/country_screen.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late SettingsHarness settings;

  void createSettings() {
    settings = SettingsHarness();
    addTearDown(settings.dispose);
  }

  testWidgets('marks the stored country, saves the tapped one and goes back', (tester) async {
    createSettings();
    await pumpApp(
      tester,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CountryScreen()),
          ),
          child: const Text('open'),
        ),
      ),
      providers: [BlocProvider.value(value: settings.cubit)],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Country'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('United States'), 200);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'United States'),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Portugal'), -200);
    await tester.tap(find.text('Portugal'));
    await tester.pumpAndSettle();

    expect(settings.cubit.state.settings.country, 'pt');
    expect(find.byType(CountryScreen), findsNothing);
  });

  testWidgets('Back pops without changing anything', (tester) async {
    createSettings();
    await pumpApp(
      tester,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CountryScreen()),
          ),
          child: const Text('open'),
        ),
      ),
      providers: [BlocProvider.value(value: settings.cubit)],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(CountryScreen), findsNothing);
    expect(settings.cubit.state.settings.country, 'us');
  });
}
