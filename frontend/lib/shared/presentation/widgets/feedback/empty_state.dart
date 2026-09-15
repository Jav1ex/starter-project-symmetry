import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Empty state: a tint squircle holding one italic serif glyph or one icon,
/// a plain-words headline, one sentence and one call to action.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;

  /// A single italic serif character (e.g. "n", "?", "¶").
  final String? glyph;

  /// Used instead of [glyph].
  final IconData? icon;
  final Widget? action;

  /// Rich body replacing [message] when the copy needs inline widgets.
  final Widget? messageWidget;

  const EmptyState({
    super.key,
    required this.title,
    this.message = '',
    this.glyph,
    this.icon,
    this.action,
    this.messageWidget,
  }) : assert(glyph != null || icon != null, 'Provide a glyph or an icon');

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const size = 120.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.huge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: palette.tint,
              borderRadius: BorderRadius.circular(size * 0.31),
            ),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, size: 72, color: palette.primary)
                : Text(
                    glyph!,
                    style: AppTypography.serifGlyph(64, weight: FontWeight.w400, italic: true)
                        .copyWith(color: palette.primary),
                  ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(color: palette.ink),
          ),
          const SizedBox(height: AppSpacing.md),
          messageWidget ??
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: palette.inkBody),
              ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            action!,
          ],
        ],
      ),
    );
  }
}
