import '../../domain/entities/booking_option.dart';
import '../../domain/entities/pool_service.dart';

class BookingOptionModel {
  const BookingOptionModel({
    required this.id,
    required this.type,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.isEnabled,
    this.slotDurationMinutes,
  });

  final String id;
  final String type;
  final String price;
  final String startTime;
  final String endTime;
  final bool isEnabled;
  final int? slotDurationMinutes;

  factory BookingOptionModel.fromJson(Map<String, dynamic> json) {
    return BookingOptionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'hourly',
      price: json['price']?.toString() ?? '0.00',
      startTime: json['start_time']?.toString() ?? '08:00',
      endTime: json['end_time']?.toString() ?? '18:00',
      isEnabled: json['is_enabled'] as bool? ?? true,
      slotDurationMinutes: (json['slot_duration_minutes'] as num?)?.toInt(),
    );
  }

  BookingOption toEntity() {
    final parsedPrice = double.tryParse(price) ?? 0.0;
    return BookingOption(
      id: id,
      type: BookingTypeExtension.fromWireValue(type),
      price: parsedPrice,
      priceMinor: (parsedPrice * 100).round(),
      startTime: startTime,
      endTime: endTime,
      isEnabled: isEnabled,
      slotDurationMinutes: slotDurationMinutes,
    );
  }
}

class PoolServiceModel {
  const PoolServiceModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.isActive,
    required this.allowOnlineBooking,
    required this.allowOnlinePayment,
    required this.bookingTypes,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String vendorId;
  final String name;
  final String category;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final bool allowOnlineBooking;
  final bool allowOnlinePayment;
  final List<BookingOptionModel> bookingTypes;

  factory PoolServiceModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['booking_types'] ?? json['booking_options'];
    final options = <BookingOptionModel>[];
    if (optionsRaw is List) {
      for (final item in optionsRaw) {
        if (item is Map) {
          options.add(
            BookingOptionModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return PoolServiceModel(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Pool',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      allowOnlineBooking:
          json['allow_online_booking'] == true ||
          json['allow_online_booking'] == 1,
      allowOnlinePayment:
          json['allow_online_payment'] == true ||
          json['allow_online_payment'] == 1,
      bookingTypes: options,
    );
  }

  PoolService toEntity() {
    return PoolService(
      id: id,
      vendorId: vendorId,
      name: name,
      category: category,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      allowOnlineBooking: allowOnlineBooking,
      allowOnlinePayment: allowOnlinePayment,
      bookingOptions: bookingTypes.map((m) => m.toEntity()).toList(),
    );
  }
}
