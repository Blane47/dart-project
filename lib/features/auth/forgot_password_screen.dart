import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/auth_layout.dart';

/// Password-recovery screen. Sends a Firebase reset email, then confirms and
/// returns to sign-in.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref
          .read(firebaseAuthServiceProvider)
          .sendPasswordResetEmail(_email.text);
      if (!mounted) return;
      showAppSnackBar(context, AppStrings.resetLinkSent);
      context.pop();
    } on AuthException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      title: AppStrings.resetPasswordTitle,
      subtitle: AppStrings.resetPasswordSubtitle,
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: AppStrings.sendResetLink,
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
