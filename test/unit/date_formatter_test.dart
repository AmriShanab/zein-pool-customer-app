import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formats dates correctly', () {
      final date = DateTime(2026, 10, 25, 14, 30);
      final formatted = DateFormatter.formatShortDate(date);
      expect(formatted, contains('25'));
      expect(formatted, contains('Oct'));
      expect(formatted, contains('2026'));
    });

    test('formats time correctly', () {
      final date = DateTime(2026, 10, 25, 14, 30);
      final formattedTime = DateFormatter.formatTime(date);
      expect(formattedTime, contains('30'));
    });

    test('formats ISO dates correctly', () {
      final date = DateTime(2026, 10, 25);
      expect(DateFormatter.toIsoDate(date), '2026-10-25');
    });

    test('formats durations cleanly', () {
      expect(
        DateFormatter.formatDuration(const Duration(hours: 2)),
        contains('2 hr'),
      );
      expect(
        DateFormatter.formatDuration(const Duration(hours: 1, minutes: 30)),
        '1h 30m',
      );
      expect(
        DateFormatter.formatDuration(const Duration(minutes: 45)),
        '45 mins',
      );
    });
  });
}
