import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';

/// Step 2 of 3: the vertical card stack. Swipe up for the next story; the
/// last card's swipe ends the brief.
class BriefCardStackStep extends StatefulWidget {
  final List<ArticleEntity> articles;
  final int index;
  final Set<String> savedIds;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ArticleEntity> onRead;
  final ValueChanged<ArticleEntity> onSave;
  final VoidCallback onFinish;
  final VoidCallback onClose;

  const BriefCardStackStep({
    super.key,
    required this.articles,
    required this.index,
    required this.savedIds,
    required this.onPageChanged,
    required this.onRead,
    required this.onSave,
    required this.onFinish,
    required this.onClose,
  });

  @override
  State<BriefCardStackStep> createState() => _BriefCardStackStepState();
}

class _BriefCardStackStepState extends State<BriefCardStackStep> {
  late final PageController _controller = PageController(viewportFraction: 0.86, initialPage: widget.index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (widget.index >= widget.articles.length - 1) {
      widget.onFinish();
      return;
    }
    await _controller.nextPage(
      duration: AppMotion.durationFor(context, AppMotion.long),
      curve: AppMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const ink = Color(0xFF1E1A20);
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xxl, 0),
              child: Row(
                children: [
                  LabeledIconButton.close(
                    onPressed: widget.onClose,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  const Spacer(),
                  for (var i = 0; i < widget.articles.length; i++)
                    AnimatedContainer(
                      duration: AppMotion.durationFor(context, AppMotion.short),
                      margin: const EdgeInsets.only(left: AppSpacing.xs),
                      width: i <= widget.index ? 24 : 8,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= widget.index ? palette.primaryContainer : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                onPageChanged: widget.onPageChanged,
                itemCount: widget.articles.length,
                itemBuilder: (context, i) {
                  final article = widget.articles[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.sm),
                    child: BriefStoryCard(
                      article: article,
                      isSaved: widget.savedIds.contains(article.id),
                      onRead: () => widget.onRead(article),
                      onSave: () => widget.onSave(article),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: TextButton.icon(
                onPressed: _next,
                style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.8)),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
                label: Text(widget.index >= widget.articles.length - 1
                    ? 'Finish the brief'
                    : 'Swipe up for the next story'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
