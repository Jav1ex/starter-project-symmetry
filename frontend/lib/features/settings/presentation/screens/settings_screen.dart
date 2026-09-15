import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/constants/app_info.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_country.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/danger_zone_card.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/delete_account_dialog.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/text_size_control.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/theme_mode_selector.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';

/// Appearance, feed defaults, about, and the account actions.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              current is SessionAuthenticated && current.failure != null,
          listener: (context, state) => showAppSnackBar(
            context,
            FailureMessageFormatter.of((state as SessionAuthenticated).failure!),
          ),
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) => current.saveFailure != null,
          listener: (context, state) => showAppSnackBar(
            context,
            FailureMessageFormatter.of(state.saveFailure!),
          ),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: LabeledIconButton.back(onPressed: () => Navigator.of(context).pop()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.xxl,
                ),
                child: Text('Settings', style: AppTypography.headline.copyWith(color: palette.ink)),
              ),
              const _AppearanceSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _FeedSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _AboutSection(),
              const SizedBox(height: AppSpacing.xxl),
              const _AccountSection(),
              const SizedBox(height: AppSpacing.lg),
              const _DangerZone(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSection(
          title: 'Appearance',
          children: [
            ThemeModeSelector(
              selected: state.settings.themeMode,
              onChanged: cubit.setThemeMode,
            ),
            TextSizeControl(
              selected: state.settings.textSize,
              onChanged: cubit.setTextSize,
            ),
          ],
        );
      },
    );
  }
}

class _FeedSection extends StatelessWidget {
  const _FeedSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSection(
          title: 'Feed',
          children: [
            SettingsRow(
              label: 'Default category',
              value: state.settings.defaultCategory.label,
              onTap: context.pushDefaultCategoryPicker,
            ),
            SettingsRow(
              label: 'Country',
              value: NewsCountry.fromCode(state.settings.country).label,
              onTap: context.pushCountryPicker,
            ),
          ],
        );
      },
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'About',
      children: [
        SettingsRow(
          label: 'About ${AppInfo.name}',
          value: 'v${AppInfo.version}',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: AppInfo.name,
            applicationVersion: AppInfo.version,
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final email = state.user?.email;
        return SettingsSection(
          title: email == null ? 'Account' : 'Account · $email',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: OutlinedButton.icon(
                onPressed: _isBusy(state) ? null : context.read<SessionCubit>().signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.ink,
                  side: BorderSide(color: palette.outlineStrong, width: 1.5),
                ),
                icon: const Icon(Icons.logout_rounded, size: AppSizes.buttonIcon),
                label: const Text('Sign out'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        return DangerZoneCard(
          onDeleteAccount: _isBusy(state) ? null : () => _confirmDelete(context),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<SessionCubit>();
    final confirmed = await DeleteAccountDialog.show(context);
    if (confirmed) await cubit.deleteAccount();
  }
}

bool _isBusy(SessionState state) => state is SessionAuthenticated && state.isBusy;
