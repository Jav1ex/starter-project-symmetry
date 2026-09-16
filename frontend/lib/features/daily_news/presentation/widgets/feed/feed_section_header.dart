import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// "Latest" row with the last update time and the pull-to-refresh hint.
class FeedSectionHeader extends StatelessWidget {
  final String title;
  final DateTime? updatedAt;

  const FeedSectionHeader({super.key, required this.title, this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(title, style: AppTypography.title.copyWith(color: palette.ink))),
          if (updatedAt != null)
            Text(
              'Updated ${DateFormat.Hm().format(updatedAt!)}',
              style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
            ),
        ],
      ),
    );
  }
}
