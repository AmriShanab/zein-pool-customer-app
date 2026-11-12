import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/app/app.dart';

void main() {
  testWidgets('ZeinsPoolCustomerApp smoke test and render', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ZeinsPoolCustomerApp()));

    // Initial splash screen renders
    expect(
      find.text('Exclusive Pool & Sports Turf Reservations'),
      findsOneWidget,
    );

    // Settle splash timer
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
