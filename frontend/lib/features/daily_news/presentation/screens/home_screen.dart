import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_error_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_section_header.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/brief_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/staggered_entrance.dart';

/// Home tab: greeting, then provider headlines and own articles in one
/// timeline. Reloads whenever the feed settings change.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static NewsQuery queryOf(AppSettings settings) =>
      NewsQuery(category: settings.defaultCategory, country: settings.country);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final feed = context.read<FeedCubit>();
    if (feed.state is FeedInitial) {
      feed.load(HomeScreen.queryOf(context.read<SettingsCubit>().state.settings));
    }
  }

  @override
  Widget build(BuildContext context) => const HomeView();
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.settings.defaultCategory != current.settings.defaultCategory ||
          previous.settings.country != current.settings.country,
      listener: (context, state) =>
          context.read<FeedCubit>().load(HomeScreen.queryOf(state.settings)),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushPublish(),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Write'),
          tooltip: 'Write an article',
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<FeedCubit>().refresh();
              if (context.mounted) showAppSnackBar(context, 'Feed updated');
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: BlocBuilder<SessionCubit, SessionState>(
                    builder: (context, state) => state.user == null
                        ? const SizedBox.shrink()
                        : HomeHeader(
                            user: state.user!,
                            now: DateTime.now(),
                            onAvatarTap: context.pushSettings,
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: BlocBuilder<BriefCubit, BriefState>(
                    builder: (context, state) => BriefCard(
                      completedToday: state.isCompletedOn(DateTime.now()),
                      onPressed: context.pushBrief,
                    ),
                  ),
                ),
                const _FeedBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody();

  @override
  Widget build(BuildContext context) {
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return switch (state) {
          FeedInitial() || FeedLoading() => const SliverToBoxAdapter(child: FeedSkeleton()),
          FeedFailure(:final failure) => SliverToBoxAdapter(
              child: FeedErrorCard(
                message: FailureMessageFormatter.of(failure),
                onRetry: () => context.read<FeedCubit>().load(state.query!),
              ),
            ),
          FeedLoaded() when state.isEmpty => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                glyph: 'n',
                title: 'Nothing new in ${state.query!.category.label} yet',
                message: 'Try another category or country, or write the first story yourself.',
                action: SecondaryButton(
                  label: 'Change category',
                  onPressed: context.pushDefaultCategoryPicker,
                ),
              ),
            ),
          FeedLoaded(:final feed, :final loadedAt) => SliverList.list(
              children: [
                if (feed.remoteFailure case final failure?)
                  FeedErrorCard(
                    message: '${FailureMessageFormatter.of(failure)} '
                        'Your own articles are still here below.',
                    onRetry: () => context.read<FeedCubit>().load(state.query!),
                  ),
                FeedSectionHeader(
                  title: feed.remoteFailure == null ? 'Latest' : 'Your articles',
                  updatedAt: loadedAt,
                ),
                for (final (index, article) in feed.articles.indexed)
                  StaggeredEntrance(
                    key: ValueKey('feed-${article.id}'),
                    index: index,
                    child: Column(
                      children: [
                        FeedItem(
                          article: article,
                          isOwn: article.isOwnedBy(userId),
                          onTap: () => context.pushReader(article),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
              ],
            ),
        };
      },
    );
  }
}
