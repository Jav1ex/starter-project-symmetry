import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_country.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/picker/option_picker_list.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/picker/option_picker_scaffold.dart';

/// Picks the country whose headlines fill the Home feed.
class CountryScreen extends StatelessWidget {
  const CountryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OptionPickerScaffold(
      title: 'Country',
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return OptionPickerList<NewsCountry>(
            options: [
              for (final country in NewsCountry.values)
                PickerOption(value: country, label: country.label),
            ],
            selected: NewsCountry.fromCode(state.settings.country),
            onSelected: (country) {
              context.read<SettingsCubit>().setCountry(country);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
