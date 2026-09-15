import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/editor_suggestions_sheet.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_lens_body.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  Finder fieldAt(int index) =>
      find.descendant(of: find.byType(LabeledTextField).at(index), matching: find.byType(TextField));

  testWidgets('Ask the editor works with only the body and "Use this" fills the empty title', (tester) async {
    final harness = ShellHarness();
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.publish,
      routes: {AppRoutes.publish: (_) => const PublishScreen()},
      providers: harness.providers,
    );
    await tester.pumpAndSettle();

    await tester.enterText(fieldAt(2), List.filled(45, 'word').join(' '));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ask the editor'));
    await tester.tap(find.text('Ask the editor'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorSuggestionsSheet), findsOneWidget);
    expect(find.text('Headline one'), findsOneWidget);
    verify(() => harness.suggestEdits(any())).called(1);

    await tester.tap(find.text('Use this').first);
    await tester.pumpAndSettle();

    expect(find.byType(EditorSuggestionsSheet), findsNothing);
    expect(tester.widget<TextField>(fieldAt(0)).controller?.text, 'Headline one');
  });

  testWidgets('Reader lenses show bullets, toggle back, and Listen plays the current view', (tester) async {
    final harness = ShellHarness();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
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
