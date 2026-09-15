import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';

/// Red-tinted card at the very bottom of Settings holding the one action
/// that cannot be undone.
class DangerZoneCard extends StatelessWidget {
  final VoidCallback? onDeleteAccount;

  const DangerZoneCard({super.key, required this.onDeleteAccount});

  static const String body =
      "Deleting your account removes your profile and every article you've "
      "published. This can't be undone.";

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: palette.dangerFill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: palette.dangerBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: palette.error, size: AppSizes.icon),
              const SizedBox(width: AppSpacing.sm),
              Text('Danger zone', style: AppTypography.title.copyWith(color: palette.error)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(body, style: AppTypography.bodySmall.copyWith(color: palette.inkBody)),
          const SizedBox(height: AppSpacing.lg),
          DestructiveButton(
            label: 'Delete account',
            icon: Icons.delete_forever_rounded,
            onPressed: onDeleteAccount,
          ),
        ],
      ),
    );
  }
}
