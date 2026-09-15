import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Step 3 of 3: what was read and saved, then back to the feed.
class BriefSummaryStep extends StatelessWidget {
  final String firstName;
  final List<ArticleEntity> articles;
  final Set<String> readIds;
  final Set<String> savedIds;
  final int minutes;
  final VoidCallback onBackToFeed;
  final VoidCallback onOpenSaved;

  const BriefSummaryStep({
    super.key,
    required this.firstName,
    required this.articles,
    required this.readIds,
    required this.savedIds,
    required this.minutes,
    required this.onBackToFeed,
    required this.onOpenSaved,
  });

  @override
  Widget build(BuildContext context) {
    final savedCount = articles.where((a) => savedIds.contains(a.id)).length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5E3A7C), Color(0xFF7B4FA0), Color(0xFF9B6FB8)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('STEP 3 OF 3',
                      style: AppTypography.sectionOverline.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text("That's your brief, $firstName.",
                    style: AppTypography.briefSummaryTitle.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${articles.length} stories · $minutes min · $savedCount saved for later',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: ListView(
                      children: [
                        for (final article in articles)
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  savedIds.contains(article.id)
                                      ? Icons.bookmark_rounded
                                      : Icons.check_rounded,
                                  size: 20,
                                  color: savedIds.contains(article.id)
                                      ? const Color(0xFFE3BEE8)
                                      : Colors.white.withValues(alpha: readIds.contains(article.id) ? 0.55 : 0.25),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    article.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTypography.serif,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: onBackToFeed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5E3A7C),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Back to feed'),
                ),
                TextButton(
                  onPressed: onOpenSaved,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(AppSizes.tertiaryButton),
                  ),
                  child: const Text('Open Saved'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
