import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/hatched_plate.dart';

/// One story of the brief: the photo (or hatched plate) edge to edge under
/// a 2px paper frame, with the kicker, headline, teaser and the Read / Save
/// blocks over a dark scrim at the foot.
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
  static const Color _paper = Color(0xFFF3F2F2);
  static const Color _scrim = Color(0xFF0B0A0A);

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
      builder: (_, child) => Transform.translate(offset: Offset(0, _delta() * amount), child: child),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final frame = BorderSide(color: _paper.withValues(alpha: 0.9), width: AppRules.strong);
    return Container(
      decoration: BoxDecoration(border: Border.fromBorderSide(frame)),
      clipBehavior: Clip.hardEdge,
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
                      errorWidget: (_, _, _) => _Plate(article: article),
                    )
                  : _Plate(article: article),
            ),
            photoDrift,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.4, 1],
                colors: [
                  _scrim.withValues(alpha: 0.05),
                  _scrim.withValues(alpha: 0.25),
                  _scrim.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenMargin,
            right: AppSpacing.screenMargin,
            bottom: AppSpacing.screenMargin,
            child: _drifting(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: palette.primary,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    child: Text(
                      '${article.category.label} · ${article.author} · ${RelativeTimeFormatter.ago(article.publishedAt)}'
                          .toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.overline.copyWith(color: _paper),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.briefCardHeadline.copyWith(color: _paper),
                  ),
                  if (article.description case final teaser?) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      teaser,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(color: _paper.withValues(alpha: 0.85)),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onRead,
                          style: FilledButton.styleFrom(
                            backgroundColor: _paper,
                            foregroundColor: const Color(0xFF201E1D),
                            minimumSize: const Size(0, AppSizes.tertiaryButton),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text('Read'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (onListen != null)
                        IconButton.outlined(
                          onPressed: onListen,
                          tooltip: isListening ? 'Stop' : 'Listen',
                          style: IconButton.styleFrom(
                            foregroundColor: _paper,
                            shape: const RoundedRectangleBorder(),
                            side: BorderSide(color: _paper.withValues(alpha: 0.8), width: AppRules.strong),
                            minimumSize: const Size(AppSizes.tertiaryButton, AppSizes.tertiaryButton),
                          ),
                          icon: Icon(isListening ? Icons.stop_rounded : Icons.volume_up_outlined, size: 20),
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: onSave,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _paper,
                          side: BorderSide(color: _paper.withValues(alpha: 0.8), width: AppRules.strong),
                          minimumSize: const Size(0, AppSizes.tertiaryButton),
                        ),
                        icon: Icon(isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, size: 18),
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

class _Plate extends StatelessWidget {
  final ArticleEntity article;

  const _Plate({required this.article});

  @override
  Widget build(BuildContext context) {
    return HatchedPlate(
      pitch: 10,
      child: Text(
        article.category.label[0].toUpperCase(),
        style: AppTypography.glyph(220, weight: FontWeight.w900).copyWith(color: const Color(0xFF201E1D).withValues(alpha: 0.25)),
      ),
    );
  }
}
