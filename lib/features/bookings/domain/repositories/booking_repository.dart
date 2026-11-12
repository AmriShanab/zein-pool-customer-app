import '../entities/customer_booking.dart';
import '../entities/booking_request.dart';

abstract interface class BookingRepository {
  Future<List<CustomerBooking>> getBookings();
  Future<CustomerBooking> getBooking(String id);
  Future<CustomerBooking> createBooking(CreateBookingRequest request);
  Future<CustomerBooking> cancelBooking(String id);
  Future<CustomerBooking> uploadBankReceipt({
    required String bookingId,
    required String filePath,
    double? amount,
    String? reference,
    String? note,
  });
  Future<Map<String, dynamic>> initiatePayHere(String bookingId);
  Future<Map<String, dynamic>> verifyPayHere({
    required String bookingId,
    required String orderId,
    String? paymentId,
  });
}
