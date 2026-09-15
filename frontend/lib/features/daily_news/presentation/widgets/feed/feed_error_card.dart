import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';

/// Card shown where the Brief card would be when the provider cannot be
/// reached. Own articles keep rendering underneath.
class FeedErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FeedErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: palette.dangerBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Icon(Icons.cloud_off_rounded, color: palette.error),
          ),
          const SizedBox(height: AppSpacing.md),
          Text("Couldn't load the news", style: AppTypography.cardTitle.copyWith(color: palette.ink)),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: onRetry),
        ],
      ),
    );
  }
}
