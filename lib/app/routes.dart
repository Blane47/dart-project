/// Centralised route paths. Use these constants everywhere instead of raw
/// strings so navigation targets are typo-proof and easy to refactor.
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  /// Home / dashboard is the root of the signed-in experience.
  static const String dashboard = '/';
  static const String deposit = '/deposit';
  static const String transactions = '/transactions';
  static const String quiz = '/quiz';
  static const String settings = '/settings';

  // Innovations
  static const String insights = '/insights';
  static const String transfer = '/transfer';
  static const String goals = '/goals';
  static const String card = '/card';
  static const String loan = '/loan';
}
