import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_lens_body.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  testWidgets('shows the article, saves it and steps the text size', (tester) async {
    final harness = ShellHarness();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final article = buildUserArticle(authorId: user.id, imageUrl: null).copyWith(
      title: 'Own story',
      content: 'Body text of the story.',
    );
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    expect(find.text('Own story'), findsOneWidget);
    expect(find.text('Body text of the story.'), findsOneWidget);
    expect(find.byType(YouBadge), findsOneWidget);
    expect(find.textContaining('(you)'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    verify(() => harness.save(article)).called(1);

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    verify(() => harness.remove(article.id)).called(1);

    await tester.tap(find.text('A+'));
    await tester.pumpAndSettle();
    expect(harness.settings.cubit.state.settings.textSize, TextSizePreference.large);
    await tester.tap(find.text('A−'));
    await tester.pumpAndSettle();
    expect(harness.settings.cubit.state.settings.textSize, TextSizePreference.medium);
  });

  testWidgets('lenses show bullets, toggle back, and Listen plays the current view', (tester) async {
    final harness = ShellHarness();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final article = buildArticle(imageUrl: null, title: 'Tram strike', content: 'Long original body text.');
    await tester.pump();
    await pumpApp(tester, ReaderScreen(article: article), providers: harness.providers);
    await tester.pumpAndSettle();

    expect(find.text('Long original body text.'), findsOneWidget);

    await tester.tap(find.text('Brief it'));
    await tester.pumpAndSettle();
    expect(find.text('First fact'), findsOneWidget);
    expect(find.textContaining('Written by AI'), findsOneWidget);
    expect(find.text('Long original body text.'), findsNothing);

    await tester.tap(find.text('Listen'));
    await tester.pumpAndSettle();
    expect(find.text('Pause'), findsOneWidget);
    expect(harness.speech.spoken.single, 'Tram strike. First fact. Second fact. Third fact');

    await tester.tap(find.text('Brief it'));
    await tester.pumpAndSettle();
    expect(find.text('Long original body text.'), findsOneWidget);
    expect(find.byType(ReaderLensBody), findsOneWidget);
    verify(() => harness.applyLens(any())).called(1);
  });
}
