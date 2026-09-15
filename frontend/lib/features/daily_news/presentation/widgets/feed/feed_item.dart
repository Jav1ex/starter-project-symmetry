import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/search/highlighted_text.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';

/// One row of the feed. Renders every variant from the design: the thumb
/// slot appears only when there is an image, the teaser only when there is a
/// summary, so no row ever shows an empty box.
class FeedItem extends StatelessWidget {
  final ArticleEntity article;
  final bool isOwn;
  final VoidCallback onTap;

  /// Saved list puts the thumb on the left as a stable scan column and
  /// always shows a tile (fallback when there is no image).
  final bool thumbnailLeft;
  final String? metaOverride;

  /// Search query whose matches are marked in the title and teaser.
  final String highlight;

  const FeedItem({
    super.key,
    required this.article,
    required this.onTap,
    this.isOwn = false,
    this.thumbnailLeft = false,
    this.metaOverride,
    this.highlight = '',
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showThumb = thumbnailLeft || article.hasImage;
    final thumb = showThumb ? ArticleThumbnail(article: article) : null;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CategoryLabel(category: article.category),
            if (isOwn) ...[const SizedBox(width: AppSpacing.sm), const YouBadge()],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        HighlightedText(text: article.title, query: highlight, style: AppTypography.title.copyWith(color: palette.ink)),
        if (article.description case final teaser?) ...[
          const SizedBox(height: AppSpacing.xs),
          HighlightedText(
            text: teaser,
            query: highlight,
            maxLines: 2,
            style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          metaOverride ?? '${article.author} · ${RelativeTimeFormatter.ago(article.publishedAt)}',
          style: AppTypography.caption.copyWith(color: palette.inkSecondary),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.rowHorizontal,
          vertical: AppSpacing.rowVertical,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumb != null && thumbnailLeft) ...[thumb, const SizedBox(width: AppSpacing.lg)],
            Expanded(child: text),
            if (thumb != null && !thumbnailLeft) ...[const SizedBox(width: AppSpacing.lg), thumb],
          ],
        ),
      ),
    );
  }
}
