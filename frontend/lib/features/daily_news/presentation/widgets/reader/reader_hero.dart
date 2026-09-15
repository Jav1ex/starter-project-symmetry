import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/article_thumbnail.dart';

/// 300dp header: the article image with a top scrim, or the typographic
/// hero (soft gradient with the huge category initial) when there is none.
/// Shares its Hero tag with the feed thumbnail.
class ReaderHero extends StatelessWidget {
  final ArticleEntity article;

  const ReaderHero({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Hero(
      tag: ArticleThumbnail.heroTag(article),
      child: SizedBox(
        height: AppSizes.heroHeight,
        width: double.infinity,
        child: article.hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => ColoredBox(color: palette.skeletonBone),
                    errorWidget: (_, _, _) => _TypographicHero(article: article),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.4],
                        colors: [palette.ink.withValues(alpha: 0.35), Colors.transparent],
                      ),
                    ),
                  ),
                ],
              )
            : _TypographicHero(article: article),
      ),
    );
  }
}

class _TypographicHero extends StatelessWidget {
  final ArticleEntity article;

  const _TypographicHero({required this.article});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.primaryContainer, palette.tint, palette.background],
          ),
        ),
        child: Align(
          alignment: const Alignment(1.1, 1.2),
          child: Text(
            article.category.label[0].toUpperCase(),
            style: AppTypography.serifGlyph(300).copyWith(color: palette.primary.withValues(alpha: 0.14)),
          ),
        ),
      ),
    );
  }
}
