import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// 64dp row: label on the left, current value and a chevron on the right.
/// Tapping opens the picker for that setting.
class SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.settingsRow),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: palette.primary, size: AppSizes.icon),
                const SizedBox(width: AppSpacing.lg),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(color: palette.ink),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary),
                ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded, color: palette.inkSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
