import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/auth_layout.dart';

/// Sign-in screen. On success the auth-state stream drives the router redirect
/// to the dashboard — no manual navigation needed here.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    // Capture before await (the router disposes this screen on success).
    final auth = ref.read(firebaseAuthServiceProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final email = _email.text.trim();
    try {
      final user = await auth.signIn(email: email, password: _password.text);
      // Self-heal: make sure a profile doc exists for this account (covers
      // accounts created before the profile write was fixed).
      await firestore.createProfileIfAbsent(
        uid: user.uid,
        email: user.email ?? email,
      );
      // Router redirect takes over on success.
    } on AuthException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.welcomeBack,
      subtitle: AppStrings.signInSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.passwordLabel,
              controller: _password,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.password,
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: AppStrings.signIn,
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthFooterLink(
              prompt: AppStrings.noAccountPrompt,
              actionLabel: AppStrings.signUp,
              onPressed: () => context.go(AppRoutes.signUp),
            ),
          ],
        ),
      ),
    );
  }
}
