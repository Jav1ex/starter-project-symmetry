import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/reader_screen.dart';
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

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();
    expect(find.text('Link copied to clipboard'), findsOneWidget);
  });
}
