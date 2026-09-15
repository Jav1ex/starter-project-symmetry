import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/pop_in.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/staggered_entrance.dart';

/// Full-screen confirmation after publishing, with a preview of the new feed
/// row and the two ways out.
class PublishSuccessView extends StatelessWidget {
  final ArticleEntity article;
  final bool wasEdit;
  final VoidCallback onRead;
  final VoidCallback onBackHome;

  const PublishSuccessView({
    super.key,
    required this.article,
    required this.wasEdit,
    required this.onRead,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheduled = article.isScheduledAt(DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              PopIn(
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: palette.successContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.check_circle_rounded, size: 56, color: palette.success),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              StaggeredEntrance(
                index: 3,
                child: Text(
                  wasEdit
                      ? 'Your changes are live'
                      : scheduled
                      ? 'Your article is scheduled'
                      : 'Your article is live',
                  textAlign: TextAlign.center,
                  style: AppTypography.briefSummaryTitle.copyWith(color: palette.ink),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '"${article.title}" now appears in the feed under your name.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: palette.inkBody),
              ),
              const SizedBox(height: AppSpacing.xxl),
              StaggeredEntrance(
                index: 6,
                child: Card(
                  child: FeedItem(
                    article: article,
                    isOwn: true,
                    metaOverride: '${article.author} · just now',
                    onTap: onRead,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(label: 'Read it', icon: Icons.menu_book_rounded, onPressed: onRead),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onBackHome,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.tertiaryButton),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
