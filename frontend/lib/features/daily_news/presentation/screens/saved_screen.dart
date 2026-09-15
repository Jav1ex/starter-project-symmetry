import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Bookmarks kept on this device. Swipe a row left to remove it; the
/// snackbar offers Undo for five seconds.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<SavedArticlesCubit>();
    if (cubit.state.status == SavedStatus.initial) cubit.load();
  }

  Future<void> _remove(ArticleEntity article) async {
    final cubit = context.read<SavedArticlesCubit>();
    await cubit.remove(article);
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Removed from Saved',
      actionLabel: 'Undo',
      onAction: cubit.undoRemove,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SavedArticlesCubit, SavedArticlesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Saved', style: AppTypography.headline.copyWith(color: palette.ink)),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '${state.articles.length}',
                        style: AppTypography.title.copyWith(color: palette.inkSecondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.articles.isEmpty
                      ? const Center(
                          child: EmptyState(
                            icon: Icons.bookmark_rounded,
                            title: 'Keep stories for later',
                            message: "When you're reading an article, tap Save at the bottom "
                                'of the screen. It will appear here.',
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.articles.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final article = state.articles[index];
                            return Dismissible(
                              key: ValueKey('saved-${article.id}'),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _remove(article),
                              background: Container(
                                color: palette.error,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.xxl),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bookmark_remove_rounded, color: Colors.white),
                                    Text('Remove', style: AppTypography.navLabel.copyWith(color: Colors.white)),
                                  ],
                                ),
                              ),
                              child: FeedItem(
                                article: article,
                                isOwn: article.isOwnedBy(userId),
                                thumbnailLeft: true,
                                onTap: () => context.pushReader(article),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
