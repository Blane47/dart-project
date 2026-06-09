import '../strings.dart';

/// Formats a XAF amount.
///
/// XAF (Central African CFA franc) has no minor unit, so amounts are rounded to
/// whole numbers and grouped in thousands, e.g. `1234567 -> "1,234,567"`. Done
/// here without the `intl` package since the format is fixed.
///
/// Pass [withCode] to append the currency code: `"1,234,567 XAF"`.
/// Pass [signed] to prefix a `+`/`-` (useful in ledger rows).
String formatXaf(num amount, {bool withCode = false, bool signed = false}) {
  final rounded = amount.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  final sign = isNegative
      ? '-'
      : signed
      ? '+'
      : '';
  final grouped = '$sign$buffer';
  return withCode ? '$grouped ${AppStrings.currencyCode}' : grouped;
}
