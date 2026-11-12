import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/widgets/facility_image_view.dart';

void main() {
  group('FacilityImageView Widget Tests', () {
    testWidgets('renders pool placeholder gracefully when image is missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FacilityImageView(
              assetPath: 'assets/images/missing_pool.jpg',
              isTurf: false,
              height: 180,
              width: 320,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the attractive branded fallback rendered
      expect(find.byType(FacilityImageView), findsOneWidget);
      expect(find.text("Zein's Swimming Pool"), findsOneWidget);
      expect(find.text('PRIVATE LUXURY POOL'), findsOneWidget);
      expect(find.byIcon(Icons.pool_rounded), findsOneWidget);
    });

    testWidgets('renders turf placeholder gracefully when image is missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FacilityImageView(
              assetPath: 'assets/images/missing_turf.jpg',
              isTurf: true,
              height: 180,
              width: 320,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the attractive branded turf fallback rendered
      expect(find.byType(FacilityImageView), findsOneWidget);
      expect(find.text("Zein's Turf Ground"), findsOneWidget);
      expect(find.text('PREMIER SPORTS TURF'), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer_rounded), findsOneWidget);
    });
  });
}
