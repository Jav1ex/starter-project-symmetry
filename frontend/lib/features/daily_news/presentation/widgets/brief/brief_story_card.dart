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

  /// The stack's controller and this card's page, for the parallax: the
  /// photo drifts with the swipe while the text drifts slightly against it.
  final PageController? parallax;
  final int page;

  /// Reading aloud: whether this card's story is playing, and the toggle.
  final bool isListening;
  final VoidCallback? onListen;

  const BriefStoryCard({
    super.key,
    required this.article,
    required this.isSaved,
    required this.onRead,
    required this.onSave,
    this.parallax,
    this.page = 0,
    this.isListening = false,
    this.onListen,
  });

  static const double photoDrift = 40;
  static const double textDrift = -12;

  double _delta() {
    final controller = parallax;
    if (controller == null || !controller.hasClients || !controller.position.haveDimensions) {
      return 0;
    }
    return ((controller.page ?? page.toDouble()) - page).clamp(-1.0, 1.0);
  }

  Widget _drifting(BuildContext context, Widget child, double amount) {
    final controller = parallax;
    if (controller == null || MediaQuery.of(context).disableAnimations) return child;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _delta() * amount), child: child),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.briefCard),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _drifting(
            context,
            Transform.scale(
              scale: 1.15,
              child: article.hasImage
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _GradientInitial(article: article),
                    )
                  : _GradientInitial(article: article),
            ),
            photoDrift,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.35, 1],
                colors: [
                  const Color(0xFF07171B).withValues(alpha: 0.1),
                  const Color(0xFF07171B).withValues(alpha: 0.2),
                  const Color(0xFF07171B).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xxl,
            child: _drifting(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${article.category.label.toUpperCase()} · ${article.author} · '
                    '${RelativeTimeFormatter.ago(article.publishedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.overline.copyWith(color: palette.accent),
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
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
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
                        icon: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          size: 20,
                        ),
                        label: Text(isSaved ? 'Saved' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
              textDrift,
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
        style: AppTypography.serifGlyph(280).copyWith(color: Colors.white.withValues(alpha: 0.12)),
      ),
    );
  }
}
