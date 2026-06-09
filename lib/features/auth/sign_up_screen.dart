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

/// Sign-up screen. Creates the Firebase Auth user, then seeds the Firestore
/// profile doc (balance 0) before the router redirect lands on the dashboard.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    // Capture services + field values BEFORE any await. The moment sign-up
    // succeeds, the auth stream fires and the router disposes this screen, so
    // touching `ref`/controllers afterwards would throw before the profile is
    // written. Locals keep the Firestore write alive past disposal.
    final auth = ref.read(firebaseAuthServiceProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final email = _email.text.trim();
    final displayName = _name.text.trim();
    try {
      final user = await auth.signUp(email: email, password: _password.text);
      await firestore.createProfileIfAbsent(
        uid: user.uid,
        email: user.email ?? email,
        displayName: displayName,
      );
      // Router redirect takes over on success.
    } on AuthException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppStrings.createAccountTitle,
      subtitle: AppStrings.createAccountSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AppStrings.nameLabel,
              hint: AppStrings.nameHint,
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              prefixIcon: Icons.person_outline_rounded,
              validator: Validators.name,
            ),
            const SizedBox(height: AppSpacing.md),
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
              hint: AppStrings.passwordHint,
              controller: _password,
              obscure: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              prefixIcon: Icons.lock_outline_rounded,
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.confirmPasswordLabel,
              controller: _confirm,
              obscure: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline_rounded,
              validator: (v) => Validators.confirmPassword(v, _password.text),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: AppStrings.signUp,
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthFooterLink(
              prompt: AppStrings.haveAccountPrompt,
              actionLabel: AppStrings.signIn,
              onPressed: () => context.go(AppRoutes.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
