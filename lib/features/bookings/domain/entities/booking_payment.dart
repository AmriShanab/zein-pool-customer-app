class BookingPayment {
  const BookingPayment({
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
  final double amount;
  final int amountMinor;
  final String method;
  final String status;
  final DateTime paidAt;
  final String? reference;
  final String? receiptUrl;
  final String? note;

  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;
}
