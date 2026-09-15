import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_error_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  Future<void> pumpHome(WidgetTester tester, ShellHarness harness) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.reader: (_) => const Text('reader'),
        AppRoutes.settingsCategory: (_) => const Text('category picker'),
      },
      providers: harness.providers,
    );
  }

  testWidgets('shows the skeleton, then the feed with the "You" badge on own articles',
      (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(articles: [
        buildArticle(id: 'r', title: 'Remote headline'),
        buildUserArticle(id: 'u', authorId: user.id),
      ]),
    );
    await pumpHome(tester, harness);
    expect(find.byType(FeedSkeleton), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.textContaining(', Ada'), findsOneWidget);
    expect(find.byType(FeedItem), findsNWidgets(2));
    expect(find.byType(YouBadge), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
  });

  testWidgets('tapping a row opens the reader', (tester) async {
    final harness = ShellHarness(feed: FeedEntity(articles: [buildArticle(title: 'Remote headline')]));
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remote headline'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsOneWidget);
  });

  testWidgets('an empty feed names the category, and a settings change reloads', (tester) async {
    final harness = ShellHarness();
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.textContaining('Nothing new in Top stories'), findsOneWidget);

    harness.settings.settings.add(const AppSettings(defaultCategory: NewsCategory.health));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing new in Health'), findsOneWidget);
    verify(() => harness.getFeed(const NewsQuery(category: NewsCategory.health))).called(1);

    await tester.tap(find.text('Change category'));
    await tester.pumpAndSettle();
    expect(find.text('category picker'), findsOneWidget);
  });

  testWidgets('a partial feed shows the error card above the own articles', (tester) async {
    final harness = ShellHarness(
      feed: FeedEntity(
        articles: [buildUserArticle(authorId: user.id)],
        remoteFailure: const Failure.network(),
      ),
    );
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();

    expect(find.byType(FeedErrorCard), findsOneWidget);
    expect(find.text('Your articles'), findsOneWidget);
    expect(find.byType(FeedItem), findsOneWidget);
  });

  testWidgets('a total failure shows the error card and Try again reloads', (tester) async {
    final harness = ShellHarness();
    when(() => harness.getFeed(any())).thenAnswer((_) async => const DataFailed(Failure.server()));
    await pumpHome(tester, harness);
    await tester.pumpAndSettle();
    expect(find.byType(FeedErrorCard), findsOneWidget);

    when(() => harness.getFeed(any()))
        .thenAnswer((_) async => DataSuccess(FeedEntity(articles: [buildArticle()])));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(FeedItem), findsOneWidget);
  });
}
