import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/splash_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/welcome/app_logo.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows only the logo while the session is resolved', (tester) async {
    await pumpApp(tester, const SplashScreen());

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });
}
