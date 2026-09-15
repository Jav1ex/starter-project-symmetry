import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Tile shown where an image is required but the article has none: a lilac
/// gradient with the category initial in the serif at ~46% of the tile.
class ThumbnailFallback extends StatelessWidget {
  final String categoryLabel;
  final double size;
  final double borderRadius;

  /// Optional override of the gradient (e.g. the Brief card's deeper tones).
  final Gradient? gradient;
  final Color? initialColor;

  const ThumbnailFallback({
    super.key,
    required this.categoryLabel,
    required this.size,
    required this.borderRadius,
    this.gradient,
    this.initialColor,
  });

  String get _initial => categoryLabel.isEmpty ? 'N' : categoryLabel[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient ?? AppPalette.thumbnailFallbackGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: AppTypography.serifGlyph(size * 0.46)
            .copyWith(color: initialColor ?? AppPalette.onThumbnailFallback),
      ),
    );
  }
}
