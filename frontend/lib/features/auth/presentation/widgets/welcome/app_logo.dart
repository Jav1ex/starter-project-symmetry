import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Gradient squircle with the serif "D" used on Welcome and the splash.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        'D',
        style: AppTypography.serifGlyph(size * 0.61, weight: FontWeight.w600).copyWith(color: Colors.white),
      ),
    );
  }
}
