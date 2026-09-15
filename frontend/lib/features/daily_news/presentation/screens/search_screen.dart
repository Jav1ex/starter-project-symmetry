import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Search tab. The idle state ships now; results arrive with the search
/// cubit in the next release.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.sm),
              child: Text('Search', style: AppTypography.headline.copyWith(color: palette.ink)),
            ),
            const Expanded(
              child: Center(
                child: EmptyState(
                  glyph: '?',
                  title: 'Search all news',
                  message: 'Look for a story across the provider and your own articles.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
