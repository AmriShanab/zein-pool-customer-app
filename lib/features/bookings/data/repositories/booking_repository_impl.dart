import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/customer_booking.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<CustomerBooking>> getBookings() async {
    final data = await apiClient.get('/customer/bookings');
    final itemsRaw = data['items'];
    if (itemsRaw is List) {
      return itemsRaw
          .whereType<Map>()
          .map(
            (m) =>
                CustomerBookingModel.fromJson(Map<String, dynamic>.from(m))
                    .toEntity(),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<CustomerBooking> getBooking(String id) async {
    final data = await apiClient.get('/customer/bookings/$id');
    return CustomerBookingModel.fromJson(data).toEntity();
  }

  @override
  Future<CustomerBooking> createBooking(CreateBookingRequest request) async {
    final data = await apiClient.post(
      '/customer/bookings',
      data: request.toJson(),
    );
    return CustomerBookingModel.fromJson(data).toEntity();
  }

  @override
  Future<CustomerBooking> cancelBooking(String id) async {
    final data = await apiClient.post('/customer/bookings/$id/cancel');
    return CustomerBookingModel.fromJson(data).toEntity();
  }

  @override
  Future<CustomerBooking> uploadBankReceipt({
    required String bookingId,
    required String filePath,
    double? amount,
    String? reference,
    String? note,
  }) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'receipt': await MultipartFile.fromFile(filePath, filename: fileName),
      if (amount != null) 'amount': amount.toStringAsFixed(2),
      if (reference != null && reference.isNotEmpty) 'reference': reference,
      if (note != null && note.isNotEmpty) 'note': note,
    });

    final data = await apiClient.postMultipart(
      '/customer/bookings/$bookingId/receipt',
      formData: formData,
    );
    return CustomerBookingModel.fromJson(data).toEntity();
  }

  @override
  Future<Map<String, dynamic>> initiatePayHere(String bookingId) async {
    return apiClient.post('/customer/bookings/$bookingId/payhere/initiate');
  }

  @override
  Future<Map<String, dynamic>> verifyPayHere({
    required String bookingId,
    required String orderId,
    String? paymentId,
  }) async {
    return apiClient.post(
      '/customer/bookings/$bookingId/payhere/verify',
      data: {'order_id': orderId, 'payment_id': ?paymentId},
    );
  }
}
