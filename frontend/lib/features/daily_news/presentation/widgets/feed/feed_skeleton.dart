import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// Bones that mirror the feed rows 1:1 while the first load runs.
class FeedSkeleton extends StatelessWidget {
  final int rows;

  const FeedSkeleton({super.key, this.rows = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonArea(
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.rowHorizontal,
                vertical: AppSpacing.rowVertical,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 72, height: 12),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(height: 20),
                        SizedBox(height: AppSpacing.xs),
                        SkeletonBox(width: 180, height: 20),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(width: 120, height: 14),
                      ],
                    ),
                  ),
                  if (i.isEven) ...[
                    const SizedBox(width: AppSpacing.lg),
                    const SkeletonBox(width: AppSizes.thumb, height: AppSizes.thumb, borderRadius: AppRadius.thumb),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
