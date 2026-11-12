import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/app/app.dart';
import 'package:zain_pool_customer_app/app/routes.dart';
import 'package:zain_pool_customer_app/features/auth/domain/entities/customer_profile.dart';
import 'package:zain_pool_customer_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:zain_pool_customer_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/entities/booking_payment.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/entities/booking_request.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/entities/customer_booking.dart';
import 'package:zain_pool_customer_app/features/bookings/domain/repositories/booking_repository.dart';
import 'package:zain_pool_customer_app/features/bookings/presentation/providers/customer_bookings_provider.dart';
import 'package:zain_pool_customer_app/features/bookings/presentation/services/payhere_native_service.dart';
import 'package:zain_pool_customer_app/features/resort_info/domain/entities/resort_config.dart';
import 'package:zain_pool_customer_app/features/resort_info/presentation/providers/resort_config_provider.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';
import 'package:zain_pool_customer_app/features/services/domain/repositories/service_repository.dart';
import 'package:zain_pool_customer_app/features/services/presentation/providers/services_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  static const testCustomer = CustomerProfile(
    id: 'cust-1',
    vendorId: 'vnd-1',
    name: 'Asmi Mohamed',
    mobile: '+94771234567',
    normalizedMobile: '+94771234567',
  );

  @override
  Future<bool> isAuthenticated() async => true;

  @override
  Future<CustomerProfile?> getProfile() async => testCustomer;

  @override
  Future<OtpChallenge> requestOtp(String mobile) async => const OtpChallenge(
    expiresInSeconds: 300,
    resendAfterSeconds: 60,
    debugOtp: '123456',
  );

  @override
  Future<CustomerProfile> verifyOtp({
    required String mobile,
    required String otp,
    String? name,
  }) async => testCustomer;

  @override
  Future<CustomerProfile> updateProfile({
    required String name,
    String? notes,
  }) async => CustomerProfile(
    id: testCustomer.id,
    vendorId: testCustomer.vendorId,
    name: name,
    mobile: testCustomer.mobile,
    normalizedMobile: testCustomer.normalizedMobile,
    notes: notes,
  );

  @override
  Future<void> logout() async {}
}

class _FakeServiceRepository implements ServiceRepository {
  static const onlinePoolService = PoolService(
    id: 'srv-online-1',
    vendorId: 'vnd-1',
    name: 'Main Luxury Pool',
    category: 'Swimming Pool',
    isActive: true,
    allowOnlineBooking: true,
    allowOnlinePayment: true,
    bookingOptions: [
      BookingOption(
        id: 'opt-hourly',
        type: BookingTypeEnum.hourly,
        price: 2500.0,
        priceMinor: 250000,
        startTime: '08:00',
        endTime: '20:00',
        isEnabled: true,
        slotDurationMinutes: 60,
      ),
    ],
  );

  static const offlineOnlyService = PoolService(
    id: 'srv-offline-2',
    vendorId: 'vnd-1',
    name: 'Walk-In Only Turf',
    category: 'Turf',
    isActive: true,
    allowOnlineBooking: false,
    allowOnlinePayment: false,
    bookingOptions: [],
  );

  @override
  Future<List<PoolService>> getServices({String? search}) async {
    return [onlinePoolService, offlineOnlyService]
        .where((s) => s.isActive && s.allowOnlineBooking)
        .toList();
  }

  @override
  Future<PoolService> getService(String id) async => onlinePoolService;

  @override
  Future<ServiceAvailability> getAvailability({
    required String serviceId,
    required String date,
  }) async {
    return ServiceAvailability(
      date: date,
      serviceId: serviceId,
      serviceName: onlinePoolService.name,
      timezone: 'Asia/Colombo',
      options: const [
        OptionAvailability(
          id: 'opt-hourly',
          bookingType: BookingTypeEnum.hourly,
          price: 2500.0,
          priceMinor: 250000,
          startTime: '08:00',
          endTime: '20:00',
          slotDurationMinutes: 60,
          isAvailable: true,
        ),
      ],
      slots: [
        AvailableSlot(
          bookingType: 'hourly',
          startTime: '10:00',
          endTime: '11:00',
          startAt: DateTime.utc(2026, 11, 15, 4, 30),
          endAt: DateTime.utc(2026, 11, 15, 5, 30),
          price: 2500.0,
          priceMinor: 250000,
          isAvailable: true,
        ),
        AvailableSlot(
          bookingType: 'hourly',
          startTime: '11:00',
          endTime: '12:00',
          startAt: DateTime.utc(2026, 11, 15, 5, 30),
          endAt: DateTime.utc(2026, 11, 15, 6, 30),
          price: 2500.0,
          priceMinor: 250000,
          isAvailable: true,
        ),
      ],
    );
  }

  @override
  Future<MonthAvailability> getMonthAvailability({
    required String serviceId,
    required String month,
  }) async {
    return MonthAvailability(
      month: month,
      serviceId: serviceId,
      timezone: 'Asia/Colombo',
      days: const {},
    );
  }
}

class _FakeBookingRepository implements BookingRepository {
  CustomerBooking _booking = CustomerBooking(
    id: 'bk-test-1001',
    vendorId: 'vnd-1',
    serviceId: 'srv-online-1',
    serviceName: 'Main Luxury Pool',
    customerId: 'cust-1',
    bookingType: BookingTypeEnum.hourly,
    bookingDate: '2026-11-15',
    startAt: DateTime.utc(2026, 11, 15, 4, 30),
    endAt: DateTime.utc(2026, 11, 15, 5, 30),
    membersCount: 1,
    totalAmount: 2500.0,
    totalMinor: 250000,
    status: 'confirmed',
    payments: const [],
    allowOnlinePayment: true,
  );

  @override
  Future<List<CustomerBooking>> getBookings() async => [_booking];

  @override
  Future<CustomerBooking> getBooking(String id) async => _booking;

  @override
  Future<CustomerBooking> createBooking(CreateBookingRequest request) async {
    return _booking;
  }

  @override
  Future<CustomerBooking> cancelBooking(String id) async => _booking;

  @override
  Future<CustomerBooking> uploadBankReceipt({
    required String bookingId,
    required String filePath,
    double? amount,
    String? reference,
    String? note,
  }) async => _booking;

  @override
  Future<Map<String, dynamic>> initiatePayHere(String bookingId) async {
    return {
      'sandbox': true,
      'merchant_id': '1211149',
      'merchant_secret': 'secret',
      'order_id': 'PAYHERE-BKTEST10-12345',
      'items': "Zein's Pool - Main Luxury Pool",
      'amount': '2500.00',
      'currency': 'LKR',
      'first_name': 'Asmi Mohamed',
      'last_name': 'Guest',
      'email': 'guest@zeinspool.com',
      'phone': '+94771234567',
      'address': "Zein's Pool",
      'city': 'Batticaloa',
      'country': 'Sri Lanka',
    };
  }

  @override
  Future<Map<String, dynamic>> verifyPayHere({
    required String bookingId,
    required String orderId,
    String? paymentId,
  }) async {
    _booking = CustomerBooking(
      id: _booking.id,
      vendorId: _booking.vendorId,
      serviceId: _booking.serviceId,
      serviceName: _booking.serviceName,
      customerId: _booking.customerId,
      bookingType: _booking.bookingType,
      bookingDate: _booking.bookingDate,
      startAt: _booking.startAt,
      endAt: _booking.endAt,
      membersCount: _booking.membersCount,
      totalAmount: _booking.totalAmount,
      totalMinor: _booking.totalMinor,
      status: 'confirmed',
      payments: [
        BookingPayment(
          id: 'pay-1',
          amount: 2500.0,
          amountMinor: 250000,
          method: 'online',
          status: 'valid',
          paidAt: DateTime.utc(2026, 11, 15, 4, 30),
          reference: paymentId ?? orderId,
        ),
      ],
      allowOnlinePayment: true,
    );
    return {
      'verified': true,
      'status': 'success',
      'message': 'Online payment verified!',
    };
  }
}

void main() {
  const dummyConfig = ResortConfig(
    resortName: "Zein's Pool",
    currency: 'LKR',
    timezone: 'Asia/Colombo',
    businessMobile: '+94 78 923 8808',
    businessEmail: 'info@zeinspool.com',
    businessAddress: 'Sammanthurai',
    operatingHours: '08:00 AM - 10:00 PM',
    bankInfo: BankInfo(
      bankName: 'Commercial Bank',
      accountName: "Zein's Pool",
      accountNumber: '8001234567',
    ),
    rules: [],
  );

  tearDown(() {
    PayHereNativeService.testPaymentHandler = null;
  });

  testWidgets(
    'Full Customer Flow: Splash -> Explore Services -> Select Slot -> Checkout -> Payment Cancelled -> Retry Payment -> Redirect to Home',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeBookingRepo = _FakeBookingRepository();
      appRouter.go('/');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
            serviceRepositoryProvider.overrideWithValue(
              _FakeServiceRepository(),
            ),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
            resortConfigProvider.overrideWith((ref) async => dummyConfig),
          ],
          child: const ZeinsPoolCustomerApp(),
        ),
      );

      // 1. Splash Screen -> Home Screen
      expect(
        find.text('Exclusive Pool & Sports Turf Reservations'),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // 2. Home Screen: Verify online-booking-enabled service is listed & offline service is hidden
      expect(find.text('Main Luxury Pool'), findsOneWidget);
      expect(find.text('Walk-In Only Turf'), findsNothing);

      // Verify location labels and specification tiles are removed from Home Screen
      expect(find.text('Kattankudy, Batticaloa'), findsNothing);
      expect(find.text('FIFA Grade Turf'), findsNothing);
      expect(find.text('Filtered Water'), findsNothing);

      // 3. Tap "Book Now" on Main Luxury Pool -> Reserve Facility (Availability Screen)
      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      expect(find.text('Reserve Facility'), findsOneWidget);
      // Verify "Number of Guests" is removed
      expect(find.text('Number of Guests'), findsNothing);

      // Select multiple preferred time slots "10:00 – 11:00" and "11:00 – 12:00"
      expect(find.text('10:00 – 11:00'), findsOneWidget);
      expect(find.text('11:00 – 12:00'), findsOneWidget);
      await tester.tap(find.text('10:00 – 11:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('11:00 – 12:00'));
      await tester.pumpAndSettle();

      // Verify both slots are selected (2 Slots = LKR 5,000)
      expect(find.textContaining('10:00 – 12:00 • 2 Slots'), findsOneWidget);
      expect(find.text('LKR 5,000'), findsOneWidget);

      // Tap "Review & Checkout"
      await tester.tap(find.text('Review & Checkout'));
      await tester.pumpAndSettle();

      // 4. Review & Confirm (Checkout Screen): Verify ONLY Online Payment & 2 Slots Subtotal
      expect(find.text('Review & Confirm'), findsOneWidget);
      expect(find.text('Session Subtotal (2 Slots)'), findsOneWidget);
      expect(find.text('PayHere Online Payment'), findsOneWidget);
      expect(find.text('Pay at Resort Desk'), findsNothing);
      expect(find.text('Direct Bank Transfer'), findsNothing);

      // 5. Simulate Payment Cancelled on first attempt
      PayHereNativeService.testPaymentHandler = ({
        required paymentObject,
        required onSuccess,
        required onError,
        required onDismissed,
      }) async {
        onDismissed();
      };

      final proceedBtn = find.text('Proceed to Online Payment');
      await tester.ensureVisible(proceedBtn);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      // 6. Verify Payment Cancelled Screen (BookingPaymentScreen) is shown
      expect(find.text('Payment Cancelled'), findsOneWidget);
      expect(
        find.textContaining('Your online payment was cancelled'),
        findsOneWidget,
      );
      expect(find.textContaining('Retry Payment'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // 7. Simulate Payment Completed when customer retries payment -> Redirects to Home
      PayHereNativeService.testPaymentHandler = ({
        required paymentObject,
        required onSuccess,
        required onError,
        required onDismissed,
      }) async {
        await onSuccess('PAY-SUCCESS-999', paymentObject['order_id'].toString());
      };

      final retryBtn = find.textContaining('Retry Payment');
      await tester.ensureVisible(retryBtn);
      await tester.tap(retryBtn);
      await tester.pumpAndSettle();

      // Verify redirected back to Home screen with service cards visible
      expect(find.text('Main Luxury Pool'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);

      // 8. Navigate to My Bookings tab and verify zero overflow & no "Pay at Resort"
      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();
      expect(find.text('Your games'), findsOneWidget);
      expect(find.text('Pay at Resort'), findsNothing);

      // 9. Navigate to Profile tab and verify Elite VIP & Membership Tier are completely removed
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Asmi Mohamed'), findsOneWidget);
      expect(find.text('Elite VIP'), findsNothing);
      expect(find.text('Membership Tier'), findsNothing);
    },
  );
}

