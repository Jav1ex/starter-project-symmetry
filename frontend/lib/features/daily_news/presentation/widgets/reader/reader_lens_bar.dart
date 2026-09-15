import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';

/// Two chips under the author row: Brief it · Plain words.
/// The active one shows a check; tapping it again returns to the original.
class ReaderLensBar extends StatelessWidget {
  final ArticleLens? active;
  final ArticleLens? loading;
  final ValueChanged<ArticleLens> onToggle;

  const ReaderLensBar({super.key, required this.active, required this.loading, required this.onToggle});

  static IconData iconFor(ArticleLens lens) => switch (lens) {
        ArticleLens.brief => Icons.bolt_rounded,
        ArticleLens.plain => Icons.spa_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final lens in ArticleLens.values)
          ChoiceChip(
            avatar: loading == lens
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(iconFor(lens), size: 18),
            label: Text(lens.label),
            selected: active == lens,
            onSelected: loading == null ? (_) => onToggle(lens) : null,
          ),
      ],
    );
  }
}
