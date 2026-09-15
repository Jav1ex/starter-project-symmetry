import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_lens.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/skeleton/skeleton_box.dart';

/// The article body as the active lens shows it: the original text, a
/// loading skeleton, three bullets, or a rewritten text, crossfading
/// between them.
class ReaderLensBody extends StatelessWidget {
  final String original;
  final ArticleLensResult? result;
  final bool isLoading;

  const ReaderLensBody({super.key, required this.original, required this.result, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.durationFor(context, AppMotion.medium),
      child: KeyedSubtree(
        key: ValueKey(isLoading ? 'loading' : (result?.lens.name ?? 'original')),
        child: isLoading
            ? const _Skeleton()
            : result == null
                ? _Body(original)
                : _LensView(result: result!),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;

  const _Body(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.body.copyWith(color: context.palette.inkBody));
}

class _LensView extends StatelessWidget {
  final ArticleLensResult result;

  const _LensView({required this.result});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.bullets.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: palette.tint,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final bullet in result.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: palette.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(bullet, style: AppTypography.body.copyWith(color: palette.ink))),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else
          _Body(result.text),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 16, color: palette.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Written by AI from the original · tap ${result.lens.label} again to go back',
                style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonArea(
      child: Column(
        children: [
          SkeletonBox(height: 18),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 18),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 220, height: 18),
        ],
      ),
    );
  }
}
