import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/category_label.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('CategoryLabel upper-cases the category in the primary colour', (tester) async {
    await pumpApp(tester, const CategoryLabel(category: NewsCategory.technology));

    final text = tester.widget<Text>(find.text('TECHNOLOGY'));
    expect(text.style?.color, AppPalette.light.primary);
  });

  testWidgets('CategoryLabel accepts a colour override for dark surfaces', (tester) async {
    await pumpApp(tester, const CategoryLabel(category: NewsCategory.health, color: Colors.white));

    expect(tester.widget<Text>(find.text('HEALTH')).style?.color, Colors.white);
  });

  testWidgets('YouBadge shows the word and the edit icon', (tester) async {
    await pumpApp(tester, const YouBadge());

    expect(find.text('You'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
  });
}
