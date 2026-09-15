import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('shows icons and fires its callback', (tester) async {
      var pressed = false;
      await pumpApp(
        tester,
        PrimaryButton(
          label: 'Start reading',
          icon: Icons.play_arrow_rounded,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.text('Start reading'));
      expect(pressed, isTrue);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('while loading it shows a spinner and cannot be pressed', (tester) async {
      var pressed = false;
      await pumpApp(
        tester,
        PrimaryButton(label: 'Publishing…', isLoading: true, onPressed: () => pressed = true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Publishing…'), warnIfMissed: false);
      expect(pressed, isFalse);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled, isFalse);
    });
  });

  testWidgets('SecondaryButton is outlined with an optional icon', (tester) async {
    await pumpApp(
      tester,
      SecondaryButton(label: 'Create account', icon: Icons.person_add, onPressed: () {}),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
  });

  group('DestructiveButton', () {
    testWidgets('is outlined by default and filled on request', (tester) async {
      await pumpApp(
        tester,
        Column(
          children: [
            DestructiveButton(label: 'Delete', onPressed: () {}),
            DestructiveButton(label: 'Yes, delete', filled: true, onPressed: () {}),
          ],
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Delete'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Yes, delete'), findsOneWidget);
    });
  });

  group('LabeledIconButton', () {
    testWidgets('named constructors carry their word', (tester) async {
      await pumpApp(
        tester,
        Column(
          children: [
            LabeledIconButton.back(onPressed: () {}),
            LabeledIconButton.close(onPressed: () {}),
            LabeledIconButton.cancel(onPressed: () {}),
            LabeledIconButton(icon: Icons.settings, label: 'Settings', onPressed: () {}),
          ],
        ),
      );

      for (final word in ['Back', 'Close', 'Cancel', 'Settings']) {
        expect(find.text(word), findsOneWidget);
      }
    });

    testWidgets('is at least 48dp tall', (tester) async {
      await pumpApp(tester, LabeledIconButton.back(onPressed: () {}, backgroundColor: Colors.white));

      expect(tester.getSize(find.byType(LabeledIconButton)).height, greaterThanOrEqualTo(48));
    });
  });
}
