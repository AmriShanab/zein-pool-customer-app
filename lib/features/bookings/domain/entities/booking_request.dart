import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';

class CreateBookingRequest {
  const CreateBookingRequest({
    required this.serviceId,
    required this.bookingType,
    required this.bookingDate,
    required this.startAt,
    required this.endAt,
    required this.membersCount,
    this.additionalNote,
    this.paymentMethod = 'cash',
    this.payNow = false,
    this.sendConfirmationSms = true,
  });

  final String serviceId;
  final BookingTypeEnum bookingType;
  final String bookingDate;
  final DateTime startAt;
  final DateTime endAt;
  final int membersCount;
  final String? additionalNote;
  final String paymentMethod;
  final bool payNow;
  final bool sendConfirmationSms;

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'booking_type': bookingType.wireValue,
    'booking_date': bookingDate,
    'start_at': startAt.toUtc().toIso8601String(),
    'end_at': endAt.toUtc().toIso8601String(),
    'members_count': membersCount,
    if (additionalNote != null && additionalNote!.trim().isNotEmpty)
      'additional_note': additionalNote!.trim(),
    'payment_method': paymentMethod,
    'pay_now': payNow,
    'send_confirmation_sms': sendConfirmationSms,
  };
}
