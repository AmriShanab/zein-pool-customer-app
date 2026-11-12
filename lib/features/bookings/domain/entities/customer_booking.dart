import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';

import 'booking_payment.dart';

class CustomerBooking {
  const CustomerBooking({
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
  final BookingTypeEnum bookingType;
  final String bookingDate;
  final DateTime startAt;
  final DateTime endAt;
  final int membersCount;
  final double totalAmount;
  final int totalMinor;
  final String status; // 'confirmed', 'cancelled'
  final String? additionalNote;
  final String? conflictReason;
  final String? smsState;
  final int serverVersion;
  final bool allowOnlinePayment;
  final List<BookingPayment> payments;
  final DateTime? createdAt;

  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  int get paidMinor => payments
      .where(
        (p) =>
            p.status == 'valid' ||
            p.status == 'completed' ||
            p.status == 'successful',
      )
      .fold(0, (sum, p) => sum + p.amountMinor);

  double get paidAmount => paidMinor / 100.0;

  int get balanceMinor {
    final bal = totalMinor - paidMinor;
    return bal < 0 ? 0 : bal;
  }

  double get balanceAmount => balanceMinor / 100.0;

  bool get isFullyPaid => paidMinor >= totalMinor;
  bool get isPartiallyPaid => paidMinor > 0 && paidMinor < totalMinor;
  bool get isUnpaid => paidMinor == 0;
  bool get hasReceipt =>
      payments.any((p) => p.receiptUrl != null && p.receiptUrl!.isNotEmpty);
  BookingPayment? get receiptPayment => payments
      .where((p) => p.receiptUrl != null && p.receiptUrl!.isNotEmpty)
      .firstOrNull;
  bool get isUnderVerification => hasReceipt && !isFullyPaid;

  String get paymentStatusLabel {
    if (isFullyPaid) return 'paid';
    if (isUnderVerification) return 'under_verification';
    if (isPartiallyPaid) return 'partial';
    return 'unpaid';
  }

  bool get isUpcoming => isConfirmed && endAt.isAfter(DateTime.now());
  bool get isPast => endAt.isBefore(DateTime.now());
}
