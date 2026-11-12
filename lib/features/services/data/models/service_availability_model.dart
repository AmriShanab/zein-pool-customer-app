import '../../domain/entities/booking_option.dart';
import '../../domain/entities/service_availability.dart';

class ServiceAvailabilityModel {
  const ServiceAvailabilityModel({
    required this.date,
    required this.serviceId,
    required this.serviceName,
    required this.timezone,
    required this.options,
    required this.slots,
  });

  final String date;
  final String serviceId;
  final String serviceName;
  final String timezone;
  final List<OptionAvailability> options;
  final List<AvailableSlot> slots;

  factory ServiceAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'] as List? ?? [];
    final slotsRaw = json['slots'] as List? ?? [];

    final parsedOptions = optionsRaw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final price = double.tryParse(map['price']?.toString() ?? '0') ?? 0.0;
      return OptionAvailability(
        id: map['id']?.toString() ?? '',
        bookingType: BookingTypeExtension.fromWireValue(
          map['booking_type']?.toString() ?? 'hourly',
        ),
        price: price,
        priceMinor:
            (map['price_minor'] as num?)?.toInt() ?? (price * 100).round(),
        startTime: map['start_time']?.toString() ?? '',
        endTime: map['end_time']?.toString() ?? '',
        isAvailable: map['is_available'] as bool? ?? false,
        slotDurationMinutes: (map['slot_duration_minutes'] as num?)?.toInt(),
        startAt: DateTime.tryParse(map['start_at']?.toString() ?? ''),
        endAt: DateTime.tryParse(map['end_at']?.toString() ?? ''),
        isBooked: map['is_booked'] as bool? ?? false,
        unavailableReason: map['unavailable_reason']?.toString(),
        unavailableMessage: map['unavailable_message']?.toString(),
      );
    }).toList();

    final parsedSlots = slotsRaw.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final price = double.tryParse(map['price']?.toString() ?? '0') ?? 0.0;
      return AvailableSlot(
        bookingType: map['booking_type']?.toString() ?? 'hourly',
        startTime: map['start_time']?.toString() ?? '',
        endTime: map['end_time']?.toString() ?? '',
        startAt:
            DateTime.tryParse(map['start_at']?.toString() ?? '') ??
            DateTime.now(),
        endAt:
            DateTime.tryParse(map['end_at']?.toString() ?? '') ??
            DateTime.now(),
        price: price,
        priceMinor:
            (map['price_minor'] as num?)?.toInt() ?? (price * 100).round(),
        isAvailable: map['is_available'] as bool? ?? false,
        isBooked: map['is_booked'] as bool? ?? false,
        isPast: map['is_past'] as bool? ?? false,
        unavailableReason: map['unavailable_reason']?.toString(),
      );
    }).toList();

    return ServiceAvailabilityModel(
      date: json['date']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'Asia/Colombo',
      options: parsedOptions,
      slots: parsedSlots,
    );
  }

  ServiceAvailability toEntity() {
    return ServiceAvailability(
      date: date,
      serviceId: serviceId,
      serviceName: serviceName,
      timezone: timezone,
      options: options,
      slots: slots,
    );
  }
}

class MonthAvailabilityModel {
  const MonthAvailabilityModel({
    required this.month,
    required this.serviceId,
    required this.timezone,
    required this.days,
  });

  final String month;
  final String serviceId;
  final String timezone;
  final Map<String, MonthDayAvailability> days;

  factory MonthAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as Map? ?? {};
    final parsedDays = <String, MonthDayAvailability>{};

    rawDays.forEach((key, val) {
      if (val is Map) {
        final map = Map<String, dynamic>.from(val);
        parsedDays[key.toString()] = MonthDayAvailability(
          date: map['date']?.toString() ?? key.toString(),
          status: DayAvailabilityStatus.fromString(map['status']?.toString()),
          availableSlots: (map['available_slots'] as num?)?.toInt() ?? 0,
          totalSlots: (map['total_slots'] as num?)?.toInt() ?? 0,
          bookedSlots: (map['booked_slots'] as num?)?.toInt() ?? 0,
        );
      }
    });

    return MonthAvailabilityModel(
      month: json['month']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'Asia/Colombo',
      days: parsedDays,
    );
  }

  MonthAvailability toEntity() {
    return MonthAvailability(
      month: month,
      serviceId: serviceId,
      timezone: timezone,
      days: days,
    );
  }
}
