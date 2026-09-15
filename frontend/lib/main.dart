import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/app.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(DailyNewsApp(sessionCubit: sl(), settingsCubit: sl(), savedArticlesCubit: sl()));
}
