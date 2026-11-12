import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/features/bookings/presentation/screens/booking_availability_screen.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/availability_provider.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/services_provider.dart';

void main() {
  group('BookingAvailabilityScreen Widget Tests', () {
    const hourlyOption = BookingOption(
      id: 'opt-hourly',
      type: BookingTypeEnum.hourly,
      price: 2500.0,
      priceMinor: 250000,
      startTime: '08:00',
      endTime: '20:00',
      isEnabled: true,
      slotDurationMinutes: 60,
    );

    const fullDayOption = BookingOption(
      id: 'opt-fullday',
      type: BookingTypeEnum.fullDay,
      price: 25000.0,
      priceMinor: 2500000,
      startTime: '08:00',
      endTime: '20:00',
      isEnabled: true,
    );

    const testService = PoolService(
      id: 'srv-1',
      vendorId: 'vnd-1',
      name: "Zein's Luxury Pool",
      category: 'Swimming Pool',
      isActive: true,
      bookingOptions: [hourlyOption, fullDayOption],
    );

    final testSlot = AvailableSlot(
      bookingType: 'hourly',
      startTime: '08:00',
      endTime: '09:00',
      startAt: DateTime(2026, 10, 25, 8, 0),
      endAt: DateTime(2026, 10, 25, 9, 0),
      price: 2500.0,
      priceMinor: 250000,
      isAvailable: true,
    );

    final testAvailability = ServiceAvailability(
      date: '2026-10-25',
      serviceId: 'srv-1',
      serviceName: "Zein's Luxury Pool",
      timezone: 'Asia/Colombo',
      options: const [
        OptionAvailability(
          id: 'opt-fullday',
          bookingType: BookingTypeEnum.fullDay,
          price: 25000.0,
          priceMinor: 2500000,
          startTime: '08:00',
          endTime: '20:00',
          isAvailable: true,
        ),
      ],
      slots: [testSlot],
    );

    testWidgets(
      'renders BookingAvailabilityScreen cleanly without error widgets',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              singleServiceProvider('srv-1')
                  .overrideWith((ref) async => testService),
              availabilityProvider.overrideWith(
                (ref, query) async => testAvailability,
              ),
            ],
            child: const MaterialApp(
              home: BookingAvailabilityScreen(serviceId: 'srv-1'),
            ),
          ),
        );

        // Pump initial frame
        await tester.pump();
        // Pump async providers
        await tester.pump(const Duration(milliseconds: 200));

        // Verify that AppBar title is rendered
        expect(find.text('Reserve Facility'), findsOneWidget);

        // Verify that facility card rendered
        expect(find.text("Zein's Luxury Pool"), findsOneWidget);

        // Verify no ErrorWidget (which causes the grey screen in release builds)
        expect(find.byType(ErrorWidget), findsNothing);

        // Verify booking options rendered
        expect(find.text('Hourly Slot'), findsOneWidget);
        expect(find.text('Full Day VIP'), findsOneWidget);

        // Verify slots rendered
        expect(find.text('08:00 – 09:00'), findsOneWidget);
      },
    );

    testWidgets('renders booked slot with Booked badge and blocks selection', (
      WidgetTester tester,
    ) async {
      final bookedSlot = AvailableSlot(
        bookingType: 'hourly',
        startTime: '22:00',
        endTime: '23:00',
        startAt: DateTime(2026, 10, 25, 22, 0),
        endAt: DateTime(2026, 10, 25, 23, 0),
        price: 2500.0,
        priceMinor: 250000,
        isAvailable: false,
        isBooked: true,
        unavailableReason: 'booked',
      );

      final mixedAvailability = ServiceAvailability(
        date: '2026-10-25',
        serviceId: 'srv-1',
        serviceName: "Zein's Luxury Pool",
        timezone: 'Asia/Colombo',
        options: const [
          OptionAvailability(
            id: 'opt-fullday',
            bookingType: BookingTypeEnum.fullDay,
            price: 25000.0,
            priceMinor: 2500000,
            startTime: '08:00',
            endTime: '20:00',
            isAvailable: true,
          ),
        ],
        slots: [bookedSlot],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singleServiceProvider('srv-1')
                .overrideWith((ref) async => testService),
            availabilityProvider.overrideWith(
              (ref, query) async => mixedAvailability,
            ),
          ],
          child: const MaterialApp(
            home: BookingAvailabilityScreen(serviceId: 'srv-1'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify the slot is rendered with the Booked badge matching vendor app (1 in legend, 1 on card)
      expect(find.text('22:00 – 23:00'), findsOneWidget);
      expect(find.text('Booked'), findsNWidgets(2));

      // Verify "0 Available" badge is rendered
      expect(find.text('0 Available'), findsOneWidget);

      // Tapping on the booked slot should not select it
      await tester.tap(find.text('22:00 – 23:00'), warnIfMissed: false);
      await tester.pump();

      // Tap Review & Checkout
      await tester.tap(find.text('Review & Checkout'));
      await tester.pump();

      // SnackBar prompt should appear indicating no available slot is selected
      expect(
        find.text(
          'Please select an available hourly time slot above to proceed.',
        ),
        findsOneWidget,
      );
    });
  });
}
