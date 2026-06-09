import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/card/card_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/deposit/deposit_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/loan/loan_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transfer/transfer_screen.dart';
import '../shared/services/services.dart';
import 'routes.dart';

/// The app router. Redirect logic gates the signed-in routes behind auth and
/// shows onboarding once on first run. It refreshes whenever auth state changes
/// (sign-in / sign-out) so navigation follows the user automatically.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Mirror the auth stream into a Listenable GoRouter can refresh on.
  final authState = ValueNotifier<AsyncValue<User?>>(const AsyncLoading());
  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (_, next) {
    authState.value = next;
  }, fireImmediately: true);
  ref.onDispose(authState.dispose);

  final prefs = ref.read(prefsServiceProvider);

  final router = GoRouter(
    initialLocation: prefs.onboardingSeen
        ? AppRoutes.dashboard
        : AppRoutes.onboarding,
    refreshListenable: authState,
    redirect: (context, state) {
      final auth = authState.value;
      // Don't bounce anyone around until the first auth event arrives.
      if (auth.isLoading) return null;

      final loggedIn = auth.value != null;
      final needsOnboarding = !prefs.onboardingSeen;
      final loc = state.matchedLocation;
      final atOnboarding = loc == AppRoutes.onboarding;
      final atAuth =
          loc == AppRoutes.signIn ||
          loc == AppRoutes.signUp ||
          loc == AppRoutes.forgotPassword;

      if (needsOnboarding) {
        return atOnboarding ? null : AppRoutes.onboarding;
      }
      if (!loggedIn) {
        return atAuth ? null : AppRoutes.signIn;
      }
      // Signed in: keep them out of the public routes.
      if (atAuth || atOnboarding) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.deposit,
        builder: (_, _) => const DepositScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (_, _) => const TransactionsScreen(),
      ),
      GoRoute(path: AppRoutes.quiz, builder: (_, _) => const QuizScreen()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (_, _) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.transfer,
        builder: (_, _) => const TransferScreen(),
      ),
      GoRoute(path: AppRoutes.goals, builder: (_, _) => const GoalsScreen()),
      GoRoute(path: AppRoutes.card, builder: (_, _) => const CardScreen()),
      GoRoute(path: AppRoutes.loan, builder: (_, _) => const LoanScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
