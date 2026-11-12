import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats numeric amounts with LKR prefix', () {
      final formatted = CurrencyFormatter.formatLkr(1500.0);
      expect(formatted, contains('1,500'));
      expect(formatted, contains('LKR'));
    });

    test('formats minor units (cents)', () {
      final formatted = CurrencyFormatter.formatMinor(250000); // 2500.00
      expect(formatted, contains('2,500'));
      expect(formatted, contains('LKR'));
    });

    test('supports decimals option', () {
      final formatted = CurrencyFormatter.formatLkr(
        1500.50,
        showDecimals: true,
      );
      expect(formatted, 'LKR 1,500.50');
    });
  });
}
