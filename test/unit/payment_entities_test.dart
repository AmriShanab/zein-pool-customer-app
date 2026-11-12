import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/entities/booking_payment.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/entities/customer_booking.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';

void main() {
  group('BookingPayment & CustomerBooking Verification Rules', () {
    test('BookingPayment hasReceipt correctly detects receipt existence', () {
      final withReceipt = BookingPayment(
        id: 'pay-1',
        amount: 5000,
        amountMinor: 500000,
        method: 'bank_transfer',
        status: 'pending',
        paidAt: DateTime.now(),
        receiptUrl: 'https://example.com/receipts/slip.jpg',
      );

      final withoutReceipt = BookingPayment(
        id: 'pay-2',
        amount: 5000,
        amountMinor: 500000,
        method: 'cash',
        status: 'completed',
        paidAt: DateTime.now(),
      );

      expect(withReceipt.hasReceipt, isTrue);
      expect(withoutReceipt.hasReceipt, isFalse);
    });

    test('CustomerBooking reflects under_verification status when slip is submitted', () {
      final payment = BookingPayment(
        id: 'pay-1',
        amount: 10000,
        amountMinor: 1000000,
        method: 'bank_transfer',
        status: 'pending',
        paidAt: DateTime.now(),
        receiptUrl: 'https://book.horixpro.com/storage/receipts/test.png',
      );

      final booking = CustomerBooking(
        id: 'bk-12345678',
        vendorId: 'vnd-1',
        serviceId: 'srv-1',
        customerId: 'cust-1',
        serviceName: 'Private Pool VIP',
        bookingType: BookingTypeEnum.hourly,
        bookingDate: '2026-10-20',
        startAt: DateTime(2026, 10, 20, 10, 0),
        endAt: DateTime(2026, 10, 20, 12, 0),
        membersCount: 4,
        totalAmount: 10000,
        totalMinor: 1000000,
        status: 'confirmed',
        payments: [payment],
        allowOnlinePayment: true,
      );

      expect(booking.hasReceipt, isTrue);
      expect(booking.receiptPayment, equals(payment));
      expect(booking.isUnderVerification, isTrue);
      expect(booking.paymentStatusLabel, equals('under_verification'));
    });

    test('CustomerBooking with completed payment reflects paid status', () {
      final payment = BookingPayment(
        id: 'pay-2',
        amount: 10000,
        amountMinor: 1000000,
        method: 'payhere',
        status: 'completed',
        paidAt: DateTime.now(),
      );

      final booking = CustomerBooking(
        id: 'bk-87654321',
        vendorId: 'vnd-1',
        serviceId: 'srv-1',
        customerId: 'cust-1',
        serviceName: 'Private Pool VIP',
        bookingType: BookingTypeEnum.hourly,
        bookingDate: '2026-10-20',
        startAt: DateTime(2026, 10, 20, 14, 0),
        endAt: DateTime(2026, 10, 20, 16, 0),
        membersCount: 2,
        totalAmount: 10000,
        totalMinor: 1000000,
        status: 'confirmed',
        payments: [payment],
        allowOnlinePayment: true,
      );

      expect(booking.isUnderVerification, isFalse);
      expect(booking.paymentStatusLabel, equals('paid'));
      expect(booking.isFullyPaid, isTrue);
    });
  });
}
