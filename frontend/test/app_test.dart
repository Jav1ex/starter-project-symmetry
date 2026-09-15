import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

import 'helpers/feed_harness.dart';
import 'helpers/fixtures.dart';
import 'helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late ShellHarness shell;
  late SessionHarness session;
  late SettingsHarness settings;

  void createHarnesses() {
    shell = ShellHarness();
    session = shell.session;
    settings = shell.settings;
    session.signOutUser();
  }

  Future<void> pumpDailyNews(WidgetTester tester) async {
    await tester.pumpWidget(
      DailyNewsApp(
        sessionCubit: session.cubit,
        settingsCubit: settings.cubit,
        savedArticlesCubit: shell.savedCubit,
        feedCubit: shell.feedCubit,
        myArticlesCubit: shell.myArticlesCubit,
        briefCubit: shell.briefCubit,
        listenCubit: shell.listenCubit,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('follows the session: welcome, then home, then welcome again', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    session.signIn(user);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    session.signOutUser();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('applies the stored theme mode and text size', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);

    settings.settings.add(const AppSettings(
      themeMode: AppThemeMode.dark,
      textSize: TextSizePreference.extraLarge,
    ));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WelcomeScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      MediaQuery.textScalerOf(context).scale(17),
      closeTo(21, 0.01),
    );
  });
}
