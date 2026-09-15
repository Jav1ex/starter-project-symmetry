import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/welcome/app_logo.dart';

/// Shown for the instant it takes the identity provider to report whether
/// somebody is signed in. The router leaves as soon as it knows.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: AppLogo(size: 96)),
    );
  }
}
