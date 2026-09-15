import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  late SessionHarness session;

  void createSession() {
    session = SessionHarness();
    addTearDown(session.dispose);
  }

  testWidgets('greets the signed-in user by first name', (tester) async {
    createSession();
    session.signIn(user);
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {AppRoutes.home: (_) => const HomeScreen()},
      providers: [BlocProvider.value(value: session.cubit)],
    );

    expect(find.textContaining(', Ada'), findsOneWidget);
    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('shows no header while nobody is signed in', (tester) async {
    createSession();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {AppRoutes.home: (_) => const HomeScreen()},
      providers: [BlocProvider.value(value: session.cubit)],
    );

    expect(find.byType(HomeHeader), findsNothing);
  });

  Future<void> pumpHomeWithSettings(WidgetTester tester) async {
    createSession();
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    session.signIn(user);
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.settings: (_) => const Text('settings'),
      },
      providers: [BlocProvider.value(value: session.cubit)],
    );
  }

  testWidgets('the avatar opens Settings', (tester) async {
    await pumpHomeWithSettings(tester);

    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();

    expect(find.text('settings'), findsOneWidget);
  });

  testWidgets('the Open settings button opens Settings', (tester) async {
    await pumpHomeWithSettings(tester);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('settings'), findsOneWidget);
  });
}
