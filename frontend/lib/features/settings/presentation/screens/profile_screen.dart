import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// The signed-in account: avatar, name, email, the two counters and the
/// links to My articles and Saved.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final myArticles = context.read<MyArticlesCubit>();
    if (myArticles.state.status == MyArticlesStatus.initial) myArticles.load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = context.select((SessionCubit cubit) => cubit.state.user);
    final savedCount = context.select((SavedArticlesCubit cubit) => cubit.state.articles.length);
    final publishedCount = context.select((MyArticlesCubit cubit) => cubit.state.articles.length);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(child: Text('Profile', style: AppTypography.headline.copyWith(color: palette.ink))),
                LabeledIconButton(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onPressed: context.pushSettings,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: UserAvatar(
                name: user.preferredName,
                photoUrl: user.photoUrl,
                size: 88,
                isCurrentUser: true,
                ringed: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              user.preferredName,
              textAlign: TextAlign.center,
              style: AppTypography.readerTitle.copyWith(color: palette.ink),
            ),
            if (user.email case final email?) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                email,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: palette.inkSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(child: _CounterCard(value: publishedCount, label: 'Published', hint: 'My articles')),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _CounterCard(value: savedCount, label: 'Saved', hint: 'For later')),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SettingsSection(
              title: 'Your writing',
              children: [
                SettingsRow(
                  label: 'My articles',
                  value: '$publishedCount',
                  icon: Icons.article_outlined,
                  onTap: context.pushMyArticles,
                ),
                SettingsRow(
                  label: 'Write an article',
                  icon: Icons.edit_outlined,
                  onTap: () => context.pushPublish(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  final int value;
  final String label;
  final String hint;

  const _CounterCard({required this.value, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: AppTypography.counter.copyWith(color: palette.primary)),
            Text(label, style: AppTypography.label.copyWith(color: palette.ink)),
            Text(hint, style: AppTypography.caption.copyWith(color: palette.inkSecondary)),
          ],
        ),
      ),
    );
  }
}
