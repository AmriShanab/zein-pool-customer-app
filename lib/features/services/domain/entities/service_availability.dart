import 'booking_option.dart';

class AvailableSlot {
  const AvailableSlot({
    required this.bookingType,
    required this.startTime,
    required this.endTime,
    required this.startAt,
    required this.endAt,
    required this.price,
    required this.priceMinor,
    required this.isAvailable,
    this.isBooked = false,
    this.isPast = false,
    this.unavailableReason,
  });

  final String bookingType;
  final String startTime;
  final String endTime;
  final DateTime startAt;
  final DateTime endAt;
  final double price;
  final int priceMinor;
  final bool isAvailable;
  final bool isBooked;
  final bool isPast;
  final String? unavailableReason;

  String get timeRange => '$startTime – $endTime';
}

class OptionAvailability {
  const OptionAvailability({
    required this.id,
    required this.bookingType,
    required this.price,
    required this.priceMinor,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.slotDurationMinutes,
    this.startAt,
    this.endAt,
    this.isBooked = false,
    this.unavailableReason,
    this.unavailableMessage,
  });

  final String id;
  final BookingTypeEnum bookingType;
  final double price;
  final int priceMinor;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int? slotDurationMinutes;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isBooked;
  final String? unavailableReason;
  final String? unavailableMessage;

  String get timeRange => '$startTime – $endTime';
}

class ServiceAvailability {
  const ServiceAvailability({
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

  List<AvailableSlot> get availableHourlySlots =>
      slots.where((s) => s.isAvailable && !s.isBooked && !s.isPast).toList();
}

enum DayAvailabilityStatus {
  available,
  partial,
  booked,
  blocked,
  past;

  static DayAvailabilityStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'partial':
        return DayAvailabilityStatus.partial;
      case 'booked':
        return DayAvailabilityStatus.booked;
      case 'blocked':
        return DayAvailabilityStatus.blocked;
      case 'past':
        return DayAvailabilityStatus.past;
      case 'available':
      default:
        return DayAvailabilityStatus.available;
    }
  }
}

class MonthDayAvailability {
  const MonthDayAvailability({
    required this.date,
    required this.status,
    required this.availableSlots,
    required this.totalSlots,
    required this.bookedSlots,
  });

  final String date;
  final DayAvailabilityStatus status;
  final int availableSlots;
  final int totalSlots;
  final int bookedSlots;
}

class MonthAvailability {
  const MonthAvailability({
    required this.month,
    required this.serviceId,
    required this.timezone,
    required this.days,
  });

  final String month;
  final String serviceId;
  final String timezone;
  final Map<String, MonthDayAvailability> days;

  DayAvailabilityStatus statusForDate(String dateStr) {
    return days[dateStr]?.status ?? DayAvailabilityStatus.available;
  }

  MonthDayAvailability? forDate(String dateStr) => days[dateStr];
}
