import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/widgets/app_card.dart';

void main() {
  group('AppCard Widget Tests', () {
    testWidgets('renders child content properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard(child: Text('Card Content Inside'))),
        ),
      );

      expect(find.text('Card Content Inside'), findsOneWidget);
    });

    testWidgets('handles tap event when onTap is provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      expect(tapped, isTrue);
    });
  });
}
