import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/splash_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

import 'helpers/fixtures.dart';
import 'helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late SessionHarness session;
  late SettingsHarness settings;

  void createHarnesses() {
    session = SessionHarness();
    settings = SettingsHarness();
    addTearDown(() async {
      await session.dispose();
      await settings.dispose();
    });
  }

  Future<void> pumpDailyNews(WidgetTester tester) async {
    await tester.pumpWidget(
      DailyNewsApp(sessionCubit: session.cubit, settingsCubit: settings.cubit),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('follows the session: splash, then home, then welcome', (tester) async {
    createHarnesses();
    await pumpDailyNews(tester);
    expect(find.byType(SplashScreen), findsOneWidget);

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

    final context = tester.element(find.byType(SplashScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      MediaQuery.textScalerOf(context).scale(17),
      closeTo(21, 0.01),
    );
  });
}
