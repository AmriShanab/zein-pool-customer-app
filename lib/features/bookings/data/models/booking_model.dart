import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';

import '../../domain/entities/booking_payment.dart';
import '../../domain/entities/customer_booking.dart';

class BookingPaymentModel {
  const BookingPaymentModel({
    required this.id,
    required this.amount,
    required this.amountMinor,
    required this.method,
    required this.status,
    required this.paidAt,
    this.reference,
    this.receiptUrl,
    this.note,
  });

  final String id;
  final String amount;
  final int amountMinor;
  final String method;
  final String status;
  final String paidAt;
  final String? reference;
  final String? receiptUrl;
  final String? note;

  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingPaymentModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      amountMinor: (json['amount_minor'] as num?)?.toInt() ?? 0,
      method: json['method']?.toString() ?? 'cash',
      status: json['status']?.toString() ?? 'valid',
      paidAt: json['paid_at']?.toString() ?? DateTime.now().toIso8601String(),
      reference: json['reference']?.toString(),
      receiptUrl: json['receipt_url']?.toString(),
      note: json['note']?.toString(),
    );
  }

  BookingPayment toEntity() {
    return BookingPayment(
      id: id,
      amount: double.tryParse(amount) ?? 0.0,
      amountMinor: amountMinor,
      method: method,
      status: status,
      paidAt: DateTime.tryParse(paidAt) ?? DateTime.now(),
      reference: reference,
      receiptUrl: receiptUrl,
      note: note,
    );
  }
}

class CustomerBookingModel {
  const CustomerBookingModel({
    required this.id,
    required this.vendorId,
    required this.serviceId,
    required this.customerId,
    required this.bookingType,
    required this.bookingDate,
    required this.startAt,
    required this.endAt,
    required this.membersCount,
    required this.totalAmount,
    required this.totalMinor,
    required this.status,
    required this.payments,
    this.serviceName,
    this.serviceImageUrl,
    this.additionalNote,
    this.conflictReason,
    this.smsState,
    this.serverVersion = 1,
    this.allowOnlinePayment = false,
    this.createdAt,
  });

  final String id;
  final String vendorId;
  final String serviceId;
  final String? serviceName;
  final String? serviceImageUrl;
  final String customerId;
  final String bookingType;
  final String bookingDate;
  final String startAt;
  final String endAt;
  final int membersCount;
  final String totalAmount;
  final int totalMinor;
  final String status;
  final String? additionalNote;
  final String? conflictReason;
  final String? smsState;
  final int serverVersion;
  final bool allowOnlinePayment;
  final List<BookingPaymentModel> payments;
  final String? createdAt;

  factory CustomerBookingModel.fromJson(Map<String, dynamic> json) {
    final paymentsRaw = json['payments'] as List? ?? [];
    final payments = paymentsRaw
        .whereType<Map>()
        .map((p) => BookingPaymentModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    final service = json['service'] as Map?;

    return CustomerBookingModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: service?['name']?.toString(),
      serviceImageUrl: service?['image_url']?.toString(),
      customerId: json['customer_id']?.toString() ?? '',
      bookingType: json['booking_type']?.toString() ?? 'hourly',
      bookingDate: json['booking_date']?.toString() ?? '',
      startAt: json['start_at']?.toString() ?? '',
      endAt: json['end_at']?.toString() ?? '',
      membersCount: (json['members_count'] as num?)?.toInt() ?? 1,
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      totalMinor: (json['total_minor'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'confirmed',
      additionalNote: json['additional_note']?.toString(),
      conflictReason: json['conflict_reason']?.toString(),
      smsState: json['sms_state']?.toString(),
      serverVersion: (json['server_version'] as num?)?.toInt() ?? 1,
      allowOnlinePayment:
          (service?['allow_online_payment'] == true) ||
          (json['allow_online_payment'] == true),
      payments: payments,
      createdAt: json['created_at']?.toString(),
    );
  }

  CustomerBooking toEntity() {
    return CustomerBooking(
      id: id,
      vendorId: vendorId,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceImageUrl: serviceImageUrl,
      customerId: customerId,
      bookingType: BookingTypeExtension.fromWireValue(bookingType),
      bookingDate: bookingDate,
      startAt: DateTime.tryParse(startAt) ?? DateTime.now(),
      endAt: DateTime.tryParse(endAt) ?? DateTime.now(),
      membersCount: membersCount,
      totalAmount: double.tryParse(totalAmount) ?? 0.0,
      totalMinor: totalMinor,
      status: status,
      additionalNote: additionalNote,
      conflictReason: conflictReason,
      smsState: smsState,
      serverVersion: serverVersion,
      allowOnlinePayment: allowOnlinePayment,
      payments: payments.map((p) => p.toEntity()).toList(),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}
