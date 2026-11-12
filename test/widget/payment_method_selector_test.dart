import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/features/bookings/presentation/widgets/payment_method_selector.dart';

void main() {
  Widget buildSubject({
    String selectedMethod = 'online',
    ValueChanged<String>? onMethodChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PaymentMethodSelector(
            selectedMethod: selectedMethod,
            onMethodChanged: onMethodChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('PaymentMethodSelector Online-Only Behavior', () {
    testWidgets('shows ONLY PayHere Online Payment and hides Cash & Bank Transfer', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      // PayHere Online Payment must be displayed
      expect(find.text('PayHere Online Payment'), findsOneWidget);
      expect(
        find.textContaining('Visa, MasterCard, FriMi, eZ Cash & Genie'),
        findsOneWidget,
      );

      // Pay at Resort Desk and Direct Bank Transfer must NOT be displayed
      expect(find.text('Pay at Resort Desk'), findsNothing);
      expect(find.text('Direct Bank Transfer'), findsNothing);
      expect(find.text('Attach Transfer Receipt'), findsNothing);
    });

    testWidgets('tapping PayHere Online Payment card invokes onMethodChanged', (
      tester,
    ) async {
      String? updatedMethod;

      await tester.pumpWidget(
        buildSubject(
          onMethodChanged: (val) => updatedMethod = val,
        ),
      );

      await tester.tap(find.text('PayHere Online Payment'));
      await tester.pump();

      expect(updatedMethod, equals('online'));
    });
  });
}
