import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

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
                child: _BarAction(
                  icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  label: isSaved ? 'Saved' : 'Save',
                  color: isSaved ? palette.primary : palette.ink,
                  onPressed: onSave,
                ),
              ),
              Expanded(
                child: _BarAction(icon: Icons.share_outlined, label: 'Share', color: palette.ink, onPressed: onShare),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onSmallerText,
                      tooltip: 'Smaller text',
                      icon: const Text('A−', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                    Text(textSize.label, style: AppTypography.navLabel.copyWith(color: palette.inkSecondary)),
                    IconButton(
                      onPressed: onLargerText,
                      tooltip: 'Larger text',
                      icon: const Text('A+', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                    ),
                  ],
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
