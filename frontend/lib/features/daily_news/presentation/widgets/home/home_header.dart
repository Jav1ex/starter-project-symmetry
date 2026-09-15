import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// Greeting by time of day, today's date and the account avatar button.
class HomeHeader extends StatelessWidget {
  final UserEntity user;
  final DateTime now;
  final VoidCallback onAvatarTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.now,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${RelativeTimeFormatter.greeting(now)}, ${user.firstName}',
                  style: AppTypography.headline.copyWith(color: palette.ink),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  RelativeTimeFormatter.longDate(now),
                  style: AppTypography.bodySmall.copyWith(color: palette.inkSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Semantics(
            button: true,
            label: 'Account',
            child: InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: UserAvatar(
                name: user.preferredName,
                photoUrl: user.photoUrl,
                size: AppSizes.touchTarget,
                isCurrentUser: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
