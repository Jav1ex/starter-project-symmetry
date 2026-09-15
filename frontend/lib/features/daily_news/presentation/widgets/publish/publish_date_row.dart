import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';

/// "Publish date" 56dp row. Tapping opens the date picker and then the time
/// picker; a future date marks the article as scheduled.
class PublishDateRow extends StatelessWidget {
  final DateTime value;
  final DateTime now;
  final ValueChanged<DateTime> onChanged;

  const PublishDateRow({super.key, required this.value, required this.now, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value.isBefore(now) ? now : value,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(value));
    if (time == null) return;
    onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isScheduled = value.isAfter(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publish date', style: AppTypography.label.copyWith(color: palette.ink)),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(AppRadius.field),
          child: Container(
            height: AppSizes.button,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadius.field),
              border: Border.all(color: palette.outlineStrong, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.event_outlined, color: palette.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    RelativeTimeFormatter.publishDateValue(value, now: now),
                    style: AppTypography.valueLine.copyWith(color: palette.ink),
                  ),
                ),
                if (isScheduled)
                  Text('Scheduled', style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary)),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded, color: palette.inkSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
