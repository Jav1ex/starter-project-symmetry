import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';

import '../../../../../helpers/fixtures.dart';
import '../../../../../helpers/pump_app.dart';

class MockGetFeedUseCase extends Mock implements GetFeedUseCase {}

void main() {
  setUpAll(() => registerFallbackValue(const NewsQuery()));

  late MockGetFeedUseCase getFeed;
  late FeedCubit cubit;
  const query = NewsQuery(category: NewsCategory.health, country: 'pt');
  final feed = FeedEntity(articles: [buildArticle()]);

  setUp(() {
    getFeed = MockGetFeedUseCase();
    cubit = FeedCubit(getFeed);
  });
  tearDown(() => cubit.close());

  test('starts in the initial state before any load', () {
    expect(cubit.state, const FeedInitial());
  });

  test('load goes loading then loaded with the query it was asked for', () async {
    when(() => getFeed(query)).thenAnswer((_) async => DataSuccess(feed));
    final states = <FeedState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load(query);
    await flush();
    await sub.cancel();

    expect(states.first, const FeedLoading(query));
    final loaded = states.last as FeedLoaded;
    expect(loaded.feed, feed);
    expect(loaded.query, query);
    expect(loaded.isEmpty, isFalse);
  });

  test('an empty feed without failures counts as empty', () async {
    when(() => getFeed(any())).thenAnswer((_) async => const DataSuccess(FeedEntity.empty));
    await cubit.load(query);
    expect((cubit.state as FeedLoaded).isEmpty, isTrue);

    when(() => getFeed(any())).thenAnswer(
      (_) async => const DataSuccess(FeedEntity(articles: [], remoteFailure: Failure.network())),
    );
    await cubit.load(query);
    expect((cubit.state as FeedLoaded).isEmpty, isFalse);
  });

  test('a failure of both sources becomes FeedFailure', () async {
    when(() => getFeed(any())).thenAnswer((_) async => const DataFailed(Failure.server()));

    await cubit.load(query);

    expect(cubit.state, const FeedFailure(query, Failure.server()));
  });

  test('only the latest load wins when two overlap', () async {
    final slow = Completer<DataState<FeedEntity>>();
    when(() => getFeed(const NewsQuery())).thenAnswer((_) => slow.future);
    when(() => getFeed(query)).thenAnswer((_) async => DataSuccess(feed));

    final first = cubit.load(const NewsQuery());
    await cubit.load(query);
    slow.complete(const DataSuccess(FeedEntity.empty));
    await first;

    expect(cubit.state.query, query);
    expect((cubit.state as FeedLoaded).feed, feed);
  });

  test('refresh reuses the current query and does nothing before a load', () async {
    await cubit.refresh();
    verifyNever(() => getFeed(any()));

    when(() => getFeed(query)).thenAnswer((_) async => DataSuccess(feed));
    await cubit.load(query);
    await cubit.refresh();

    verify(() => getFeed(query)).called(2);
  });
}
