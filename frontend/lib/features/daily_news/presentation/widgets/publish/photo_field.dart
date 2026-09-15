import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';

/// "Photo (optional)": a dashed 72dp target until a picture is chosen, then
/// a 150dp preview with a labelled Remove pill. During upload a scrim and a
/// progress ring cover the preview.
class PhotoField extends StatelessWidget {
  final String? localPath;
  final String? remoteUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const PhotoField({
    super.key,
    required this.localPath,
    required this.remoteUrl,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  bool get hasPhoto => localPath != null || remoteUrl != null;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Photo',
            style: AppTypography.label.copyWith(color: palette.ink),
            children: [
              TextSpan(
                text: ' (optional)',
                style: AppTypography.label.copyWith(
                  color: palette.inkSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!hasPhoto)
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: Container(
              height: AppSizes.smallThumb,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.field),
                border: Border.all(color: palette.outlineStrong, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: palette.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Add a photo', style: AppTypography.buttonSecondary.copyWith(color: palette.primary)),
                ],
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (localPath != null)
                    Image.file(File(localPath!), fit: BoxFit.cover)
                  else
                    CachedNetworkImage(imageUrl: remoteUrl!, fit: BoxFit.cover),
                  if (isUploading)
                    ColoredBox(
                      color: palette.ink.withValues(alpha: 0.45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(color: palette.primaryContainer, strokeWidth: 4),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Uploading photo…', style: AppTypography.label.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: LabeledIconButton(
                        icon: Icons.close_rounded,
                        label: 'Remove',
                        color: palette.ink,
                        backgroundColor: palette.surface.withValues(alpha: 0.92),
                        onPressed: onRemove,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
