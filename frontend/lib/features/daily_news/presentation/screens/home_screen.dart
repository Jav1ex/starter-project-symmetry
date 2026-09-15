import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_error_card.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_section_header.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Home tab: greeting, then provider headlines and own articles in one
/// timeline. Reloads whenever the feed settings change.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeedCubit>()..load(_queryOf(context.read<SettingsCubit>().state.settings)),
      child: const HomeView(),
    );
  }

  static NewsQuery _queryOf(AppSettings settings) =>
      NewsQuery(category: settings.defaultCategory, country: settings.country);
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
          context.read<FeedCubit>().load(HomeScreen._queryOf(state.settings)),
      child: Scaffold(
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
                for (final article in feed.articles) ...[
                  FeedItem(
                    article: article,
                    isOwn: article.isOwnedBy(userId),
                    onTap: () => context.pushReader(article),
                  ),
                  const Divider(),
                ],
              ],
            ),
        };
      },
    );
  }
}
