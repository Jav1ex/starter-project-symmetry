import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// "Theme" row with a three-way segmented control.
class ThemeModeSelector extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static String labelOf(AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => 'System',
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: AppTypography.body.copyWith(color: palette.ink)),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<AppThemeMode>(
            segments: [
              for (final mode in AppThemeMode.values)
                ButtonSegment(value: mode, label: Text(labelOf(mode))),
            ],
            selected: {selected},
            onSelectionChanged: (selection) => onChanged(selection.first),
          ),
        ],
      ),
    );
  }
}
