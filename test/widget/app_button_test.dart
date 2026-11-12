import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/widgets/app_button.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders button text and triggers onPressed on tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Book Now',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Book Now'), findsOneWidget);
      await tester.tap(find.text('Book Now'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Confirming...',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders outline button variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.outline(
              text: 'Cancel Reservation',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cancel Reservation'), findsOneWidget);
    });
  });
}
