import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// One choice in an [OptionPickerList].
class PickerOption<T> {
  final T value;
  final String label;

  const PickerOption({required this.value, required this.label});
}

/// Full-screen radio list: one row per option, a check mark on the current
/// one, 56dp rows so nothing is fiddly to tap.
class OptionPickerList<T> extends StatelessWidget {
  final List<PickerOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  const OptionPickerList({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: options.length,
      separatorBuilder: (_, _) => const Divider(indent: AppSpacing.xxl, endIndent: AppSpacing.xxl),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.value == selected;
        return Semantics(
          selected: isSelected,
          inMutuallyExclusiveGroup: true,
          child: ListTile(
            minTileHeight: AppSizes.button,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            title: Text(
              option.label,
              style: AppTypography.body.copyWith(
                color: palette.ink,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: palette.primary)
                : null,
            onTap: () => onSelected(option.value),
          ),
        );
      },
    );
  }
}
