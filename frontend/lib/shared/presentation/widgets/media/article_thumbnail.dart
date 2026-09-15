import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/thumbnail_fallback.dart';

/// Square thumbnail for an article: the network image when it has one,
/// otherwise the typographic fallback. Wrapped in a [Hero] so the Reader can
/// grow it into its header.
class ArticleThumbnail extends StatelessWidget {
  final ArticleEntity article;
  final double size;
  final double borderRadius;

  const ArticleThumbnail({
    super.key,
    required this.article,
    this.size = AppSizes.thumb,
    this.borderRadius = AppRadius.thumb,
  });

  static String heroTag(ArticleEntity article) => 'thumb-${article.id}';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Widget child = article.hasImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              imageUrl: article.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(width: size, height: size, color: palette.skeletonBone),
              errorWidget: (_, _, _) => ThumbnailFallback(
                categoryLabel: article.category.label,
                size: size,
                borderRadius: borderRadius,
              ),
            ),
          )
        : ThumbnailFallback(
            categoryLabel: article.category.label,
            size: size,
            borderRadius: borderRadius,
          );

    return Hero(tag: heroTag(article), child: child);
  }
}
