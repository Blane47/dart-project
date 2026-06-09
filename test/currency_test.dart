import 'package:dart_project/shared/utils/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatXaf', () {
    test('groups thousands without decimals', () {
      expect(formatXaf(0), '0');
      expect(formatXaf(999), '999');
      expect(formatXaf(1000), '1,000');
      expect(formatXaf(1234567), '1,234,567');
    });

    test('rounds to whole XAF (no minor unit)', () {
      expect(formatXaf(1499.4), '1,499');
      expect(formatXaf(1499.6), '1,500');
    });

    test('appends the currency code when requested', () {
      expect(formatXaf(2500, withCode: true), '2,500 XAF');
    });

    test('prefixes a sign when requested', () {
      expect(formatXaf(2500, signed: true), '+2,500');
      expect(formatXaf(-2500), '-2,500');
    });
  });
}
