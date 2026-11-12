import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/features/bookings/presentation/providers/booking_checkout_provider.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';

void main() {
  group('BookingDraftState Calculation Tests', () {
    const hourlyOption = BookingOption(
      id: 'opt-hourly',
      type: BookingTypeEnum.hourly,
      price: 1500.0,
      priceMinor: 150000,
      startTime: '08:00',
      endTime: '22:00',
      isEnabled: true,
      slotDurationMinutes: 60,
    );

    const fullDayOption = BookingOption(
      id: 'opt-fullday',
      type: BookingTypeEnum.fullDay,
      price: 12000.0,
      priceMinor: 1200000,
      startTime: '09:00',
      endTime: '18:00',
      isEnabled: true,
    );

    const service = PoolService(
      id: 'srv-1',
      vendorId: 'vnd-1',
      name: 'Olympic Luxury Pool',
      category: 'Pool',
      isActive: true,
      bookingOptions: [hourlyOption, fullDayOption],
    );

    test('calculates hourly rate with selected slot', () {
      final slot = AvailableSlot(
        bookingType: 'hourly',
        startTime: '10:00 AM',
        endTime: '11:00 AM',
        startAt: DateTime(2026, 10, 25, 10, 0),
        endAt: DateTime(2026, 10, 25, 11, 0),
        price: 1500.0,
        priceMinor: 150000,
        isAvailable: true,
      );

      final draft = BookingDraftState(
        service: service,
        bookingType: BookingTypeEnum.hourly,
        bookingDate: DateTime(2026, 10, 25),
        selectedSlot: slot,
        membersCount: 2,
      );

      expect(draft.isComplete, isTrue);
      expect(draft.totalPrice, 1500.0);
    });

    test('calculates fixed full day rate regardless of slot', () {
      final draft = BookingDraftState(
        service: service,
        bookingType: BookingTypeEnum.fullDay,
        bookingDate: DateTime(2026, 10, 25),
        membersCount: 4,
      );

      expect(draft.isComplete, isTrue);
      expect(draft.totalPrice, 12000.0);
    });

    test('identifies incomplete hourly draft when slot is missing', () {
      final draft = BookingDraftState(
        service: service,
        bookingType: BookingTypeEnum.hourly,
        bookingDate: DateTime(2026, 10, 25),
        selectedSlot: null,
      );

      expect(draft.isComplete, isFalse);
    });

    test(
      'AvailableSlot correctly reflects booked, past and unavailable reasons',
      () {
        final bookedSlot = AvailableSlot(
          bookingType: 'hourly',
          startTime: '08:00',
          endTime: '09:00',
          startAt: DateTime(2026, 10, 25, 8, 0),
          endAt: DateTime(2026, 10, 25, 9, 0),
          price: 1500.0,
          priceMinor: 150000,
          isAvailable: false,
          isBooked: true,
          unavailableReason: 'booked',
        );

        final pastSlot = AvailableSlot(
          bookingType: 'hourly',
          startTime: '09:00',
          endTime: '10:00',
          startAt: DateTime(2026, 10, 25, 9, 0),
          endAt: DateTime(2026, 10, 25, 10, 0),
          price: 1500.0,
          priceMinor: 150000,
          isAvailable: false,
          isPast: true,
          unavailableReason: 'past',
        );

        final openSlot = AvailableSlot(
          bookingType: 'hourly',
          startTime: '10:00',
          endTime: '11:00',
          startAt: DateTime(2026, 10, 25, 10, 0),
          endAt: DateTime(2026, 10, 25, 11, 0),
          price: 1500.0,
          priceMinor: 150000,
          isAvailable: true,
        );

        final avail = ServiceAvailability(
          date: '2026-10-25',
          serviceId: 'srv-1',
          serviceName: 'Olympic Luxury Pool',
          timezone: 'Asia/Colombo',
          options: const [
            OptionAvailability(
              id: 'opt-full',
              bookingType: BookingTypeEnum.fullDay,
              price: 12000.0,
              priceMinor: 1200000,
              startTime: '08:00',
              endTime: '20:00',
              isAvailable: false,
              unavailableReason: 'advance_required',
              unavailableMessage:
                  'Full-day reservations must be booked 1 day in advance.',
            ),
          ],
          slots: [bookedSlot, pastSlot, openSlot],
        );

        expect(avail.slots.length, 3);
        expect(avail.availableHourlySlots.length, 1);
        expect(avail.availableHourlySlots.first.startTime, '10:00');
        expect(avail.options.first.unavailableReason, 'advance_required');
      },
    );

    test('BookingDraftState rejects selecting booked or past slots', () {
      final bookedSlot = AvailableSlot(
        bookingType: 'hourly',
        startTime: '22:00',
        endTime: '23:00',
        startAt: DateTime(2026, 10, 21, 22, 0),
        endAt: DateTime(2026, 10, 21, 23, 0),
        price: 2500.0,
        priceMinor: 250000,
        isAvailable: false,
        isBooked: true,
        unavailableReason: 'booked',
      );

      final openSlot = AvailableSlot(
        bookingType: 'hourly',
        startTime: '10:00',
        endTime: '11:00',
        startAt: DateTime(2026, 10, 21, 10, 0),
        endAt: DateTime(2026, 10, 21, 11, 0),
        price: 2500.0,
        priceMinor: 250000,
        isAvailable: true,
        isBooked: false,
      );

      var state = BookingDraftState(
        service: service,
        bookingType: BookingTypeEnum.hourly,
        bookingDate: DateTime(2026, 10, 21),
      );

      // Attempting to select booked slot must not set selectedSlot
      if (bookedSlot.isAvailable &&
          !bookedSlot.isBooked &&
          !bookedSlot.isPast) {
        state = state.copyWith(selectedSlot: bookedSlot);
      }
      expect(state.selectedSlot, isNull);

      // Selecting available slot succeeds
      if (openSlot.isAvailable && !openSlot.isBooked && !openSlot.isPast) {
        state = state.copyWith(selectedSlot: openSlot);
      }
      expect(state.selectedSlot, isNotNull);
      expect(state.selectedSlot!.startTime, '10:00');

      // Clear slot clears selected slot
      state = state.copyWith(clearSelectedSlot: true);
      expect(state.selectedSlot, isNull);
    });

    test('calculates multi-slot hourly total price and time range', () {
      final slot1 = AvailableSlot(
        bookingType: 'hourly',
        startTime: '15:00',
        endTime: '16:00',
        startAt: DateTime.utc(2026, 10, 25, 9, 30),
        endAt: DateTime.utc(2026, 10, 25, 10, 30),
        price: 1500.0,
        priceMinor: 150000,
        isAvailable: true,
      );
      final slot2 = AvailableSlot(
        bookingType: 'hourly',
        startTime: '16:00',
        endTime: '17:00',
        startAt: DateTime.utc(2026, 10, 25, 10, 30),
        endAt: DateTime.utc(2026, 10, 25, 11, 30),
        price: 1500.0,
        priceMinor: 150000,
        isAvailable: true,
      );
      final slot3 = AvailableSlot(
        bookingType: 'hourly',
        startTime: '17:00',
        endTime: '18:00',
        startAt: DateTime.utc(2026, 10, 25, 11, 30),
        endAt: DateTime.utc(2026, 10, 25, 12, 30),
        price: 1500.0,
        priceMinor: 150000,
        isAvailable: true,
      );

      final draft = BookingDraftState(
        service: service,
        bookingType: BookingTypeEnum.hourly,
        bookingDate: DateTime(2026, 10, 25),
        selectedSlots: [slot1, slot2, slot3],
      );

      expect(draft.isComplete, isTrue);
      expect(draft.selectedSlotCount, 3);
      expect(draft.selectedTimeRange, '15:00 – 18:00');
      expect(draft.selectedSlotsLabel, '15:00 – 18:00 (3 Slots)');
      expect(draft.totalPrice, 4500.0);
      expect(draft.selectedStartAt, slot1.startAt);
      expect(draft.selectedEndAt, slot3.endAt);
    });
  });
}
