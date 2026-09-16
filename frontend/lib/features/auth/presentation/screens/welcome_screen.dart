import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';

/// First screen without a session: the mark, the wordmark and the two ways
/// in. No carousel, nothing to swipe.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: BrandMark(size: 96)),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Headline\nNews',
                textAlign: TextAlign.center,
                style: AppTypography.wordmark.copyWith(color: palette.ink),
              ),
              const Spacer(flex: 2),
              PrimaryButton(label: 'Sign in', onPressed: context.goToSignIn),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(label: 'Create account', onPressed: context.goToSignUp),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'By continuing you agree to our terms and privacy policy.',
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
