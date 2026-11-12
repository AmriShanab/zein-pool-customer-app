import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/features/auth/data/models/customer_model.dart';
import 'package:zain_pool_customer_app/features/bookings/data/models/booking_model.dart';
import 'package:zain_pool_customer_app/features/resort_info/data/models/resort_config_model.dart';
import 'package:zain_pool_customer_app/features/services/data/models/pool_service_model.dart';
import 'package:zain_pool_customer_app/features/services/data/models/service_availability_model.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';

void main() {
  group('Model Serialization Tests', () {
    test('CustomerModel parses JSON and converts to Entity', () {
      final json = {
        'id': 'cust-123',
        'name': 'Asmi Mohamed',
        'mobile': '+94771234567',
        'email': 'asmi@example.com',
        'notes': 'VIP guest',
      };

      final model = CustomerModel.fromJson(json);
      expect(model.id, 'cust-123');
      expect(model.name, 'Asmi Mohamed');

      final entity = model.toEntity();
      expect(entity.name, 'Asmi Mohamed');
      expect(entity.mobile, '+94771234567');
      expect(entity.notes, 'VIP guest');
    });

    test('PoolServiceModel parses service and booking options', () {
      final json = {
        'id': 'srv-1',
        'vendor_id': 'vnd-1',
        'name': 'Main Heated Swimming Pool',
        'category': 'Pool',
        'is_active': true,
        'booking_options': [
          {
            'id': 'opt-1',
            'type': 'hourly',
            'price': '1500.00',
            'price_minor': 150000,
            'start_time': '08:00',
            'end_time': '22:00',
            'is_enabled': true,
            'slot_duration_minutes': 60,
          },
          {
            'id': 'opt-2',
            'type': 'full_day',
            'price': '15000.00',
            'price_minor': 1500000,
            'start_time': '09:00',
            'end_time': '18:00',
            'is_enabled': true,
          },
        ],
      };

      final model = PoolServiceModel.fromJson(json);
      expect(model.name, 'Main Heated Swimming Pool');
      expect(model.bookingTypes.length, 2);

      final entity = model.toEntity();
      expect(entity.startingPrice, 1500.0);
      expect(entity.hourlyOption?.type, BookingTypeEnum.hourly);
    });

    test('CustomerBookingModel parses backend booking payload', () {
      final json = {
        'id': 'bk-999',
        'vendor_id': 'vnd-1',
        'service_id': 'srv-1',
        'service_name': 'Main Heated Swimming Pool',
        'customer_id': 'cust-123',
        'booking_type': 'hourly',
        'booking_date': '2026-10-25',
        'start_at': '2026-10-25T10:00:00.000000Z',
        'end_at': '2026-10-25T11:00:00.000000Z',
        'members_count': 3,
        'total_amount': '1500.00',
        'total_minor': 150000,
        'status': 'confirmed',
        'payments': [
          {
            'id': 'pay-1',
            'amount': '1500.00',
            'amount_minor': 150000,
            'method': 'cash',
            'status': 'valid',
            'paid_at': '2026-10-25T10:00:00.000000Z',
          },
        ],
      };

      final model = CustomerBookingModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.id, 'bk-999');
      expect(entity.isConfirmed, isTrue);
      expect(entity.isCancelled, isFalse);
      expect(entity.paidAmount, 1500.0);
      expect(entity.balanceAmount, 0.0);
    });

    test('ResortConfigModel parses resort settings and bank details', () {
      final json = {
        'resort_name': "Zein's Pool",
        'currency': 'LKR',
        'timezone': 'Asia/Colombo',
        'business_mobile': '+94 78 923 8808',
        'business_email': 'contact@zeinspool.com',
        'business_address': 'Kattankudy, Batticaloa, Sri Lanka',
        'operating_hours': '07:00 AM – 11:00 PM Daily',
        'bank_info': {
          'bank_name': 'Commercial Bank',
          'account_name': "Zein's Pool Resort",
          'account_number': '8001234567',
          'branch': 'Kattankudy',
        },
        'guidelines': ['Wear proper swimwear', 'No glass items'],
      };

      final model = ResortConfigModel.fromJson(json);
      final entity = model.toEntity();
      expect(entity.resortName, "Zein's Pool");
      expect(entity.bankInfo.bankName, 'Commercial Bank');
      expect(entity.rules.length, 2);
    });

    test(
      'MonthAvailabilityModel parses day by day availability mapping correctly',
      () {
        final json = {
          'month': '2026-10',
          'service_id': 'srv-1',
          'timezone': 'Asia/Colombo',
          'days': {
            '2026-10-20': {
              'date': '2026-10-20',
              'status': 'partial',
              'available_slots': 15,
              'total_slots': 16,
              'booked_slots': 1,
            },
            '2026-10-21': {
              'date': '2026-10-21',
              'status': 'booked',
              'available_slots': 0,
              'total_slots': 16,
              'booked_slots': 16,
            },
            '2026-10-22': {
              'date': '2026-10-22',
              'status': 'available',
              'available_slots': 16,
              'total_slots': 16,
              'booked_slots': 0,
            },
          },
        };

        final model = MonthAvailabilityModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity.month, '2026-10');
        expect(
          entity.statusForDate('2026-10-20'),
          DayAvailabilityStatus.partial,
        );
        expect(
          entity.statusForDate('2026-10-21'),
          DayAvailabilityStatus.booked,
        );
        expect(
          entity.statusForDate('2026-10-22'),
          DayAvailabilityStatus.available,
        );
        expect(
          entity.statusForDate('2026-10-23'),
          DayAvailabilityStatus.available,
        );
      },
    );
  });
}
