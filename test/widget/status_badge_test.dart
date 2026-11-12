import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/widgets/status_badge.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('renders confirmed status badge correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge.fromBookingStatus('confirmed')),
        ),
      );

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders cancelled status badge correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge.fromBookingStatus('cancelled')),
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });

    testWidgets('renders pending / custom status badge correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge.fromBookingStatus('pending')),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
