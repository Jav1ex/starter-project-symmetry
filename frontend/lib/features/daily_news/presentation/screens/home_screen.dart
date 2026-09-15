import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Landing screen for a signed-in journalist.
///
/// This release ships the header and the account entry point; the feed,
/// the Brief card and the bottom navigation follow in the next one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            final user = state.user;
            return Column(
              children: [
                if (user != null)
                  HomeHeader(
                    user: user,
                    now: DateTime.now(),
                    onAvatarTap: context.pushSettings,
                  ),
                Expanded(
                  child: Center(
                    child: EmptyState(
                      glyph: 'n',
                      title: 'Your feed is on its way',
                      message: 'Headlines and your own stories will appear here.',
                      action: SecondaryButton(
                        label: 'Open settings',
                        icon: Icons.settings_outlined,
                        onPressed: context.pushSettings,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
