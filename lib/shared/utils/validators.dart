import '../strings.dart';

/// Form-field validators returning a user-facing error string, or null when the
/// value is valid (the contract Flutter's `validator` callbacks expect).
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errEmailRequired;
    if (!_email.hasMatch(v)) return AppStrings.errEmailInvalid;
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.errPasswordRequired;
    if (v.length < 6) return AppStrings.errPasswordShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '') != original) return AppStrings.errPasswordMismatch;
    return null;
  }

  static String? name(String? value) {
    if ((value?.trim() ?? '').isEmpty) return AppStrings.errNameRequired;
    return null;
  }

  /// Validates a XAF amount string: required, numeric, and positive.
  static String? amount(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errAmountRequired;
    final parsed = double.tryParse(v.replaceAll(',', ''));
    if (parsed == null) return AppStrings.errAmountInvalid;
    if (parsed <= 0) return AppStrings.errAmountPositive;
    return null;
  }
}
