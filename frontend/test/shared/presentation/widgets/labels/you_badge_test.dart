import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/labels/you_badge.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the word and the edit icon', (tester) async {
    await pumpApp(tester, const YouBadge());

    expect(find.text('You'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
  });
}
