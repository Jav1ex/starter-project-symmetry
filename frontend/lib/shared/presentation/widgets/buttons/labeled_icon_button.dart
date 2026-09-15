import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Icon plus a visible word, 48dp tall: "← Back", "× Close", "⚙ Settings".
///
/// The design never uses a bare icon for navigation so the label is required.
class LabeledIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Overrides the primary foreground, e.g. white on dark scrims.
  final Color? color;

  /// Draws a translucent pill behind the button (Reader hero, Brief).
  final Color? backgroundColor;

  const LabeledIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.backgroundColor,
  });

  const LabeledIconButton.back({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.arrow_back_rounded,
        label = 'Back';

  const LabeledIconButton.close({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.close_rounded,
        label = 'Close';

  const LabeledIconButton.cancel({super.key, required this.onPressed, this.color, this.backgroundColor})
      : icon = Icons.close_rounded,
        label = 'Cancel';

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.palette.primary;
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: backgroundColor,
        minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
        padding: EdgeInsets.symmetric(
          horizontal: backgroundColor == null ? AppSpacing.sm : AppSpacing.lg,
        ),
        textStyle: AppTypography.button,
      ),
      icon: Icon(icon, size: AppSizes.icon),
      label: Text(label),
    );
  }
}
