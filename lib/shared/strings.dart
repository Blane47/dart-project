/// All user-facing copy lives here so it can be proofread in one place and,
/// later, localised. Group by feature. Never hard-code display strings in
/// widgets — add them here and reference [AppStrings].
abstract final class AppStrings {
  // ---- App ----
  static const String appName = 'Vault';
  static const String tagline = 'Banking, beautifully simple.';

  /// XAF (Central African CFA franc) has no minor unit — amounts are whole
  /// numbers. The code is shown as a small suffix; there is no currency symbol.
  static const String currencyCode = 'XAF';

  // ---- Common actions ----
  static const String continueLabel = 'Continue';
  static const String cancel = 'Cancel';
  static const String done = 'Done';
  static const String retry = 'Try again';
  static const String close = 'Close';

  // ---- Onboarding ----
  static const String onboardTitle1 = 'Your money, in focus';
  static const String onboardBody1 =
      'A calm, clear view of your balance and every transaction — no clutter.';
  static const String onboardTitle2 = 'Deposit in seconds';
  static const String onboardBody2 =
      'Top up your account instantly and watch your balance update live.';
  static const String onboardTitle3 = 'Learn as you bank';
  static const String onboardBody3 =
      'Play a quick quiz and pick up fun facts about staying safe with money.';
  static const String getStarted = 'Get started';
  static const String skip = 'Skip';

  // ---- Auth ----
  static const String signIn = 'Sign in';
  static const String signUp = 'Create account';
  static const String signOut = 'Sign out';
  static const String welcomeBack = 'Welcome back';
  static const String signInSubtitle = 'Sign in to continue to your account.';
  static const String createAccountTitle = 'Create your account';
  static const String createAccountSubtitle =
      'It only takes a moment to get started.';
  static const String emailLabel = 'Email';
  static const String emailHint = 'you@example.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'At least 6 characters';
  static const String confirmPasswordLabel = 'Confirm password';
  static const String nameLabel = 'Full name';
  static const String nameHint = 'Jane Doe';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccountPrompt = "Don't have an account? ";
  static const String haveAccountPrompt = 'Already have an account? ';
  static const String resetPasswordTitle = 'Reset your password';
  static const String resetPasswordSubtitle =
      'Enter your email and we\'ll send you a link to reset your password.';
  static const String sendResetLink = 'Send reset link';
  static const String resetLinkSent =
      'Check your inbox — we\'ve sent you a reset link.';

  // ---- Validation ----
  static const String errEmailRequired = 'Enter your email.';
  static const String errEmailInvalid = 'Enter a valid email address.';
  static const String errPasswordRequired = 'Enter a password.';
  static const String errPasswordShort = 'Use at least 6 characters.';
  static const String errPasswordMismatch = 'Passwords don\'t match.';
  static const String errNameRequired = 'Enter your name.';
  static const String errAmountRequired = 'Enter an amount.';
  static const String errAmountInvalid = 'Enter a valid amount.';
  static const String errAmountPositive = 'Amount must be greater than zero.';

  // ---- Dashboard ----
  static const String greetingMorning = 'Good morning';
  static const String greetingAfternoon = 'Good afternoon';
  static const String greetingEvening = 'Good evening';
  static const String availableBalance = 'Available balance';
  static const String hideBalance = 'Hide balance';
  static const String showBalance = 'Show balance';
  static const String quickActions = 'Quick actions';
  static const String recentActivity = 'Recent activity';
  static const String seeAll = 'See all';
  static const String noActivityTitle = 'No activity yet';
  static const String noActivityBody =
      'Your deposits and transfers will show up here.';

  // ---- Deposit ----
  static const String deposit = 'Deposit';
  static const String depositTitle = 'Add money';
  static const String depositSubtitle = 'How much would you like to deposit?';
  static const String amountLabel = 'Amount';
  static const String confirmDeposit = 'Confirm deposit';
  static const String depositSuccessTitle = 'Deposit successful';
  static String depositSuccessBody(String amount) =>
      '$amount has been added to your balance.';
  static const String backToDashboard = 'Back to home';

  // ---- Transactions ----
  static const String transactions = 'Transactions';
  static const String filterAll = 'All';
  static const String filterDeposits = 'Deposits';
  static const String filterWithdrawals = 'Withdrawals';
  static const String noTransactionsTitle = 'Nothing here yet';
  static const String noTransactionsBody =
      'Once you make a deposit, it\'ll appear in your history.';

  // ---- Quiz ----
  static const String quiz = 'Quiz';
  static const String quizIntroTitle = 'Money smarts quiz';
  static const String quizIntroBody =
      'Five quick questions about banking and staying safe. Ready?';
  static const String startQuiz = 'Start quiz';
  static const String funFact = 'Fun fact';
  static const String nextQuestion = 'Next';
  static const String seeResults = 'See results';
  static const String quizCompleteTitle = 'Quiz complete!';
  static String quizScore(int score, int total) => '$score / $total correct';
  static const String playAgain = 'Play again';
  static const String quizEmptyTitle = 'No questions yet';
  static const String quizEmptyBody =
      'Quiz questions haven\'t been added to the database yet.';
  static String questionProgress(int current, int total) =>
      'Question $current of $total';

  // ---- Settings ----
  static const String settings = 'Settings';
  static const String preferences = 'Preferences';
  static const String account = 'Account';
  static const String hideBalanceByDefault = 'Hide balance by default';
  static const String signOutConfirmTitle = 'Sign out?';
  static const String signOutConfirmBody =
      'You\'ll need to sign in again to access your account.';

  // ---- Insights ----
  static const String insights = 'Insights';
  static const String insightsTitle = 'Spending insights';
  static const String balanceOverTime = 'Balance over time';
  static const String totalIn = 'Total in';
  static const String totalOut = 'Total out';
  static const String netFlow = 'Net';
  static const String movements = 'Movements';
  static const String insightsEmptyTitle = 'Nothing to chart yet';
  static const String insightsEmptyBody =
      'Make a deposit or transfer to start seeing your trends.';

  // ---- Transfer ----
  static const String transfer = 'Transfer';
  static const String transferTitle = 'Send money';
  static const String transferSubtitle =
      'Send instantly to another Vault user by their email.';
  static const String recipientEmailLabel = 'Recipient email';
  static const String sendMoney = 'Send money';
  static const String transferSuccessTitle = 'Transfer sent';
  static String transferSuccessBody(String amount, String email) =>
      '$amount sent to $email.';

  // ---- Goals ----
  static const String goals = 'Goals';
  static const String savingsGoals = 'Savings goals';
  static const String goalsSubtitle = 'Set money aside for what matters.';
  static const String newGoal = 'New goal';
  static const String goalNameLabel = 'Goal name';
  static const String goalNameHint = 'e.g. New laptop';
  static const String targetAmountLabel = 'Target amount';
  static const String createGoal = 'Create goal';
  static const String addFunds = 'Add funds';
  static const String withdraw = 'Withdraw';
  static const String deleteGoal = 'Delete goal';
  static const String goalsEmptyTitle = 'No goals yet';
  static const String goalsEmptyBody =
      'Create a savings goal and watch it grow.';
  static String savedOfTarget(String saved, String target) =>
      '$saved of $target';

  // ---- Generic errors ----
  static const String genericError = 'Something went wrong. Please try again.';
}
