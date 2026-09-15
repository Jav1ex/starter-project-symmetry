import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// "Text size" row: a four-step slider between a small and a big "A", the
/// step's name, and a preview paragraph that re-renders at that size.
class TextSizeControl extends StatelessWidget {
  final TextSizePreference selected;
  final ValueChanged<TextSizePreference> onChanged;

  const TextSizeControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const String previewText =
      'The quick brown fox jumps over the lazy dog. Pick the size that reads '
      'best for you.';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final steps = TextSizePreference.values;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Text size', style: AppTypography.body.copyWith(color: palette.ink)),
              ),
              Text(
                selected.label,
                style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary),
              ),
            ],
          ),
          Row(
            children: [
              Text('A', style: TextStyle(fontFamily: AppTypography.sans, fontSize: 14, color: palette.inkSecondary)),
              Expanded(
                child: Slider(
                  value: selected.index.toDouble(),
                  min: 0,
                  max: (steps.length - 1).toDouble(),
                  divisions: steps.length - 1,
                  label: selected.label,
                  semanticFormatterCallback: (value) => steps[value.round()].label,
                  onChanged: (value) => onChanged(steps[value.round()]),
                ),
              ),
              Text('A', style: TextStyle(fontFamily: AppTypography.sans, fontSize: 24, color: palette.inkSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'PREVIEW',
            style: AppTypography.sectionOverline.copyWith(color: palette.inkSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(AppRadius.field),
              border: Border.all(color: palette.outline),
            ),
            child: Text(previewText, style: AppTypography.body.copyWith(color: palette.inkBody)),
          ),
        ],
      ),
    );
  }
}
