import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/motion/bounce_on_change.dart';

/// Sticky 72dp bar: Save, Listen and the A− / A+ text-size stepper. Every
/// control carries a visible word.
class ReaderBottomBar extends StatelessWidget {
  final bool isSaved;
  final bool isListening;
  final VoidCallback onSave;
  final VoidCallback onListen;
  final VoidCallback onSmallerText;
  final VoidCallback onLargerText;

  const ReaderBottomBar({
    super.key,
    required this.isSaved,
    required this.isListening,
    required this.onSave,
    required this.onListen,
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
                child: _BarAction(
                  icon: isListening ? Icons.pause_circle_outline_rounded : Icons.volume_up_outlined,
                  label: isListening ? 'Pause' : 'Listen',
                  color: isListening ? palette.primary : palette.ink,
                  onPressed: onListen,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TextSizeButton(label: 'A−', tooltip: 'Smaller text', onPressed: onSmallerText),
                    _TextSizeButton(label: 'A+', tooltip: 'Larger text', onPressed: onLargerText),
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

/// Both steps share one size: the words say which way they go.
class _TextSizeButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  const _TextSizeButton({required this.label, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: AppSizes.touchTarget, minHeight: AppSizes.touchTarget),
      icon: Text(label, style: AppTypography.sized(17, weight: FontWeight.w700).copyWith(color: context.palette.ink)),
    );
  }
}
