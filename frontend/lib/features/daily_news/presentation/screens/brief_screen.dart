import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_card_stack_step.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_summary_step.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/interest_picker_step.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Today's Brief, full screen: topics → card stack → summary.
class BriefScreen extends StatelessWidget {
  const BriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BriefCubit>();
    final firstName = context.select((SessionCubit c) => c.state.user?.firstName ?? 'there');
    final savedIds = context.select((SavedArticlesCubit c) => c.state.savedIds);
    final country = context.select((SettingsCubit c) => c.state.settings.country);

    return BlocBuilder<BriefCubit, BriefState>(
      builder: (context, state) {
        return switch (state.step) {
          BriefStep.picking || BriefStep.loading => InterestPickerStep(
              selected: state.selectedTopics,
              isLoading: state.step == BriefStep.loading,
              onToggle: cubit.toggleTopic,
              onSurpriseMe: cubit.selectAllTopics,
              onStart: () => cubit.start(country: country),
              onClose: () => Navigator.of(context).pop(),
            ),
          BriefStep.failure => Scaffold(
              body: Center(
                child: EmptyState(
                  glyph: '!',
                  title: "Couldn't build your brief",
                  message: FailureMessageFormatter.of(state.failure!),
                  action: PrimaryButton(label: 'Pick other topics', onPressed: cubit.restart),
                ),
              ),
            ),
          BriefStep.reading => BriefCardStackStep(
              articles: state.articles,
              index: state.index,
              savedIds: savedIds,
              onPageChanged: cubit.cardShown,
              onRead: (article) {
                cubit.markRead(article);
                context.pushReader(article);
              },
              onSave: context.read<SavedArticlesCubit>().toggle,
              onFinish: () => cubit.finish(DateTime.now()),
              onClose: () => Navigator.of(context).pop(),
            ),
          BriefStep.summary => BriefSummaryStep(
              firstName: firstName,
              articles: state.articles,
              readIds: state.readIds,
              savedIds: savedIds,
              minutes: state.totalMinutes,
              onBackToFeed: context.goHome,
              onOpenSaved: () => context.goHome(tab: 2),
            ),
        };
      },
    );
  }
}
