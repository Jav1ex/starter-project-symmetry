import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';

/// Row of My Articles: status badge, title, date, 72dp tile and the visible
/// Edit / Delete actions (never hidden behind a swipe).
class MyArticleRow extends StatelessWidget {
  final ArticleEntity article;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyArticleRow({
    super.key,
    required this.article,
    required this.now,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scheduled = article.isScheduledAt(now);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.rowHorizontal, vertical: AppSpacing.rowVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(scheduled: scheduled, date: article.publishedAt),
                      const SizedBox(height: AppSpacing.sm),
                      Text(article.title, style: AppTypography.title.copyWith(color: palette.ink)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        DateFormat('d MMM yyyy · H:mm').format(article.publishedAt.toLocal()),
                        style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                ArticleThumbnail(article: article, size: AppSizes.smallThumb),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _ActionChip(label: 'Edit', icon: Icons.edit_outlined, color: palette.primary, onPressed: onEdit),
                const SizedBox(width: AppSpacing.sm),
                _ActionChip(label: 'Delete', icon: Icons.delete_outline_rounded, color: palette.error, onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool scheduled;
  final DateTime date;

  const _StatusBadge({required this.scheduled, required this.date});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: scheduled ? palette.tint : palette.successContainer,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scheduled ? Icons.schedule_rounded : Icons.check_circle_rounded,
            size: 14,
            color: scheduled ? palette.primaryDeep : palette.onSuccessContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            scheduled ? 'Scheduled · ${DateFormat('d MMM').format(date)}' : 'Published',
            style: AppTypography.overline.copyWith(
              letterSpacing: 0,
              color: scheduled ? palette.primaryDeep : palette.onSuccessContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionChip({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        minimumSize: const Size(0, AppSizes.inCardButton),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        textStyle: AppTypography.buttonSecondary,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
