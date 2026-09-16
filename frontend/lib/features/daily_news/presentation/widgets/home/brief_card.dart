import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// The teal card at the top of Home that opens Today's Brief. Once the brief
/// was read today it invites to the summary instead.
class BriefCard extends StatelessWidget {
  final bool completedToday;
  final int storyCount;
  final VoidCallback onPressed;

  const BriefCard({
    super.key,
    required this.completedToday,
    required this.onPressed,
    this.storyCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: palette.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completedToday ? 'BRIEF DONE' : "TODAY'S BRIEF",
                  style: AppTypography.overline.copyWith(color: palette.accent),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  completedToday ? 'See what you read' : 'Five stories picked for you',
                  style: AppTypography.cardTitle.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  completedToday ? 'Come back tomorrow for five more' : 'About 4 minutes',
                  style: AppTypography.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: palette.primaryDeep,
                    minimumSize: const Size(0, AppSizes.inCardButton),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    textStyle: AppTypography.buttonSecondary,
                  ),
                  child: Text(completedToday ? 'Open summary' : 'Start reading →'),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          _TileStack(count: storyCount),
        ],
      ),
    );
  }
}

class _TileStack extends StatelessWidget {
  final int count;

  const _TileStack({required this.count});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget tile(double angle, double opacity) => Transform.rotate(
          angle: angle * math.pi / 180,
          child: Container(
            width: 72,
            height: 96,
            decoration: BoxDecoration(
              color: palette.primaryContainer.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(AppRadius.thumb),
            ),
          ),
        );
    return SizedBox(
      width: 96,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          tile(10, 0.35),
          tile(3, 0.6),
          tile(-4, 1),
          Text(
            '$count',
            style: AppTypography.counter.copyWith(color: palette.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
