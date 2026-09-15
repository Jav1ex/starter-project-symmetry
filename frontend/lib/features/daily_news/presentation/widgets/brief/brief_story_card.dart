import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';

/// One story of the brief: photo (or gradient initial) with the headline,
/// teaser and the Read / Save actions over a bottom gradient.
class BriefStoryCard extends StatelessWidget {
  final ArticleEntity article;
  final bool isSaved;
  final VoidCallback onRead;
  final VoidCallback onSave;

  const BriefStoryCard({
    super.key,
    required this.article,
    required this.isSaved,
    required this.onRead,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.briefCard),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (article.hasImage)
            CachedNetworkImage(
              imageUrl: article.imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _GradientInitial(article: article),
            )
          else
            _GradientInitial(article: article),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.35, 1],
                colors: [
                  const Color(0xFF140A19).withValues(alpha: 0.1),
                  const Color(0xFF140A19).withValues(alpha: 0.2),
                  const Color(0xFF140A19).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xxl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${article.category.label.toUpperCase()} · ${article.author} · '
                  '${RelativeTimeFormatter.ago(article.publishedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.overline.copyWith(color: palette.primaryContainer),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  article.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.briefCardHeadline.copyWith(color: Colors.white),
                ),
                if (article.description case final teaser?) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    teaser,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onRead,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: palette.primaryDeep,
                          minimumSize: const Size(0, AppSizes.tertiaryButton),
                        ),
                        icon: const Icon(Icons.menu_book_rounded, size: 20),
                        label: const Text('Read'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: onSave,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                        minimumSize: const Size(0, AppSizes.tertiaryButton),
                      ),
                      icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, size: 20),
                      label: Text(isSaved ? 'Saved' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientInitial extends StatelessWidget {
  final ArticleEntity article;

  const _GradientInitial({required this.article});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primaryDeep, palette.primary],
        ),
      ),
      alignment: Alignment.topRight,
      child: Text(
        article.category.label[0].toUpperCase(),
        style: TextStyle(
          fontFamily: AppTypography.serif,
          fontSize: 280,
          height: 1,
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}
