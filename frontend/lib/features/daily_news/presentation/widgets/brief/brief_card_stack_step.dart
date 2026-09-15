import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_story_card.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B1A1F),
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
                        color: i <= widget.index ? palette.accent : Colors.white.withValues(alpha: 0.35),
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
