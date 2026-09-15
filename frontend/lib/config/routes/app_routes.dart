/// Every location the app can navigate to.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/';
  static const String settings = '/settings';
  static const String settingsCategory = '/settings/category';
  static const String settingsCountry = '/settings/country';

  /// Reachable without an account.
  static const Set<String> public = {welcome, signIn, signUp};
}
