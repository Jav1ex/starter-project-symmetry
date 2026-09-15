import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// What Search shows before typing: recent queries and topic chips.
class SearchIdleView extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;
  final ValueChanged<NewsCategory> onTopicTap;

  const SearchIdleView({
    super.key,
    required this.recent,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onTopicTap,
  });

  static IconData iconFor(NewsCategory category) => switch (category) {
        NewsCategory.business => Icons.work_outline_rounded,
        NewsCategory.sports => Icons.sports_soccer_rounded,
        NewsCategory.technology => Icons.memory_rounded,
        NewsCategory.health => Icons.favorite_outline_rounded,
        NewsCategory.science => Icons.science_outlined,
        NewsCategory.entertainment => Icons.theater_comedy_outlined,
        NewsCategory.general => Icons.newspaper_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text('Recent', style: AppTypography.title.copyWith(color: palette.ink))),
              TextButton(onPressed: onClearRecent, child: const Text('Clear all')),
            ],
          ),
          for (final query in recent)
            ListTile(
              minTileHeight: 52,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.history_rounded, color: palette.inkSecondary),
              title: Text(query, style: AppTypography.bodySmall.copyWith(color: palette.ink)),
              trailing: Icon(Icons.north_west_rounded, size: 18, color: palette.inkSecondary),
              onTap: () => onRecentTap(query),
            ),
          const SizedBox(height: AppSpacing.xl),
        ],
        Text('Browse a topic', style: AppTypography.title.copyWith(color: palette.ink)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final category in NewsCategory.values.where((c) => c != NewsCategory.general))
              ActionChip(
                avatar: Icon(iconFor(category), size: 20, color: palette.primary),
                label: Text(category.label),
                onPressed: () => onTopicTap(category),
              ),
          ],
        ),
      ],
    );
  }
}
