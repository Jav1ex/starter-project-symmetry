import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Small lilac pill that marks an article written by the signed-in user.
class YouBadge extends StatelessWidget {
  const YouBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: palette.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_rounded, size: 14, color: palette.onPrimaryContainer),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'You',
            style: AppTypography.overline.copyWith(
              color: palette.onPrimaryContainer,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
