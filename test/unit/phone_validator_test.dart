import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/utils/phone_validator.dart';

void main() {
  group('Sri Lankan Mobile Validator & Formatter Tests', () {
    test('validates correct Sri Lankan mobile numbers', () {
      expect(isValidSriLankanMobile('0771234567'), isTrue);
      expect(isValidSriLankanMobile('+94771234567'), isTrue);
      expect(isValidSriLankanMobile('94771234567'), isTrue);
      expect(isValidSriLankanMobile('771234567'), isTrue);
      expect(isValidSriLankanMobile('071 234 5678'), isTrue);
    });

    test('rejects invalid numbers', () {
      expect(isValidSriLankanMobile(''), isFalse);
      expect(isValidSriLankanMobile('12345'), isFalse);
      expect(isValidSriLankanMobile('0112345678'), isFalse); // Landline
      expect(isValidSriLankanMobile('abcdefghij'), isFalse);
    });

    test('normalizes numbers to E.164 (+94XXXXXXXXX)', () {
      expect(normalizeSriLankanMobile('0771234567'), '+94771234567');
      expect(normalizeSriLankanMobile('+94771234567'), '+94771234567');
      expect(normalizeSriLankanMobile('94771234567'), '+94771234567');
      expect(normalizeSriLankanMobile('771234567'), '+94771234567');
    });

    test('formats numbers for display', () {
      final formatted = formatDisplayPhone('0771234567');
      expect(formatted, contains('+94 77 123 4567'));
    });
  });
}
