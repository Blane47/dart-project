import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// The app's text input: a label above a filled, rounded field tuned for the
/// dark canvas. Focus is signalled by an accent ring (the one interactive
/// colour shift), and password fields get a built-in show/hide toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.prefixIcon,
    this.enabled = true,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;

  /// When true the field starts obscured and shows a reveal toggle.
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xs,
          ),
          child: Text(widget.label, style: AppTextStyles.caption),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: _obscured,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          enabled: widget.enabled,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.body,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: _obscured ? 'Show' : 'Hide',
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: _border(AppColors.glassBorder, 1),
            focusedBorder: _border(AppColors.accent, 1.6),
            errorBorder: _border(AppColors.error, 1),
            focusedErrorBorder: _border(AppColors.error, 1.6),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}
