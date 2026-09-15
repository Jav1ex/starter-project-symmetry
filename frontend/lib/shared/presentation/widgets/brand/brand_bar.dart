import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/constants/app_info.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

/// The newspaper's masthead: a slim strip with the mark and the name, shown
/// above every tab of the shell.
class BrandBar extends StatelessWidget {
  const BrandBar({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.outline))),
        child: Row(
          children: [
            const BrandMark(size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppInfo.name,
              style: AppTypography.serifGlyph(20, weight: FontWeight.w600).copyWith(
                color: palette.primary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
