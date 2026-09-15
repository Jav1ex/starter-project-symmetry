import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/bounce_on_change.dart';

/// Sticky 72dp bar: Save, Share and the A− / A+ text-size stepper. Every
/// control carries a visible word.
class ReaderBottomBar extends StatelessWidget {
  final bool isSaved;
  final TextSizePreference textSize;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onSmallerText;
  final VoidCallback onLargerText;

  const ReaderBottomBar({
    super.key,
    required this.isSaved,
    required this.textSize,
    required this.onSave,
    required this.onShare,
    required this.onSmallerText,
    required this.onLargerText,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: AppSizes.readerBar,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.outline))),
          child: Row(
            children: [
              Expanded(
                child: BounceOnChange(
                  trigger: isSaved,
                  child: _BarAction(
                    icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    label: isSaved ? 'Saved' : 'Save',
                    color: isSaved ? palette.primary : palette.ink,
                    onPressed: onSave,
                  ),
                ),
              ),
              Expanded(
                child: _BarAction(icon: Icons.share_outlined, label: 'Share', color: palette.ink, onPressed: onShare),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TextSizeButton(label: 'A−', fontSize: 15, tooltip: 'Smaller text', onPressed: onSmallerText),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Text(textSize.label, style: AppTypography.navLabel.copyWith(color: palette.inkSecondary)),
                      ),
                      _TextSizeButton(label: 'A+', fontSize: 19, tooltip: 'Larger text', onPressed: onLargerText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BarAction({required this.icon, required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.navLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _TextSizeButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final String tooltip;
  final VoidCallback onPressed;

  const _TextSizeButton({required this.label, required this.fontSize, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppSizes.touchTarget, minHeight: AppSizes.touchTarget),
      icon: Text(label, style: AppTypography.sansSized(fontSize, weight: FontWeight.w700).copyWith(color: context.palette.ink)),
    );
  }
}
