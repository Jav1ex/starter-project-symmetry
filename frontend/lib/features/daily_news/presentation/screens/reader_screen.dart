import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/my_articles/delete_article_dialog.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_bottom_bar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reader/reader_hero.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// Full article. Text size follows the Settings preference and the bar's
/// A− / A+ buttons change that same preference.
class ReaderScreen extends StatelessWidget {
  final ArticleEntity article;

  const ReaderScreen({super.key, required this.article});

  Future<void> _delete(BuildContext context) async {
    final myArticles = context.read<MyArticlesCubit>();
    final feed = context.read<FeedCubit>();
    final navigator = Navigator.of(context);
    final confirmed = await DeleteArticleDialog.show(context, title: article.title);
    if (!confirmed || !context.mounted) return;
    final deleted = await myArticles.delete(article);
    if (!context.mounted) return;
    if (deleted) {
      feed.refresh();
      navigator.pop();
    } else if (myArticles.state.failure case final failure?) {
      showAppSnackBar(context, FailureMessageFormatter.of(failure));
    }
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: article.url ?? article.title));
    if (context.mounted) showAppSnackBar(context, 'Link copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final userId = context.select((SessionCubit cubit) => cubit.state.user?.id);
    final isOwn = article.isOwnedBy(userId);
    final isSaved = context.select((SavedArticlesCubit cubit) => cubit.isSaved(article.id));
    final textSize = context.select((SettingsCubit cubit) => cubit.state.settings.textSize);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              ReaderHero(article: article),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CategoryLabel(category: article.category),
                        if (isOwn) const YouBadge(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(article.title, style: AppTypography.readerTitle.copyWith(color: palette.ink)),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        UserAvatar(name: article.author, size: 40, isCurrentUser: isOwn),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOwn ? '${article.author} (you)' : article.author,
                                style: AppTypography.label.copyWith(color: palette.ink),
                              ),
                              Text(
                                '${RelativeTimeFormatter.published(article.publishedAt)} · '
                                '${article.readingTimeMinutes} min read',
                                style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(article.content, style: AppTypography.body.copyWith(color: palette.inkBody)),
                    const SizedBox(height: AppSizes.readerBar + AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
          if (isOwn)
            Positioned(
              top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
              right: AppSpacing.lg,
              child: MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.pushPublish(article: article),
                    child: const Text('Edit article'),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.delete_outline_rounded, color: palette.error),
                    onPressed: () => _delete(context),
                    child: Text('Delete article', style: TextStyle(color: palette.error)),
                  ),
                ],
                builder: (context, controller, _) => LabeledIconButton(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  color: article.hasImage ? Colors.white : palette.primary,
                  backgroundColor: article.hasImage ? palette.ink.withValues(alpha: 0.35) : palette.surface,
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            left: AppSpacing.lg,
            child: LabeledIconButton.back(
              onPressed: () => Navigator.of(context).pop(),
              color: article.hasImage ? Colors.white : palette.primary,
              backgroundColor: article.hasImage ? palette.ink.withValues(alpha: 0.35) : palette.surface,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ReaderBottomBar(
        isSaved: isSaved,
        textSize: textSize,
        onSave: () {
          HapticFeedback.lightImpact();
          context.read<SavedArticlesCubit>().toggle(article);
        },
        onShare: () => _share(context),
        onSmallerText: context.read<SettingsCubit>().decreaseTextSize,
        onLargerText: context.read<SettingsCubit>().increaseTextSize,
      ),
    );
  }
}
