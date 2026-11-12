enum BookingTypeEnum { hourly, day, night, fullDay }

extension BookingTypeExtension on BookingTypeEnum {
  String get wireValue => switch (this) {
    BookingTypeEnum.hourly => 'hourly',
    BookingTypeEnum.day => 'day',
    BookingTypeEnum.night => 'night',
    BookingTypeEnum.fullDay => 'full_day',
  };

  String get displayName => switch (this) {
    BookingTypeEnum.hourly => 'Hourly Slot',
    BookingTypeEnum.day => 'Day Pass',
    BookingTypeEnum.night => 'Night Session',
    BookingTypeEnum.fullDay => 'Full Day VIP',
  };

  static BookingTypeEnum fromWireValue(String value) => switch (value) {
    'hourly' => BookingTypeEnum.hourly,
    'day' => BookingTypeEnum.day,
    'night' => BookingTypeEnum.night,
    'full_day' => BookingTypeEnum.fullDay,
    _ => BookingTypeEnum.hourly,
  };
}

class BookingOption {
  const BookingOption({
    required this.id,
    required this.type,
    required this.price,
    required this.priceMinor,
    required this.startTime,
    required this.endTime,
    required this.isEnabled,
    this.slotDurationMinutes,
  });

  final String id;
  final BookingTypeEnum type;
  final double price;
  final int priceMinor;
  final String startTime;
  final String endTime;
  final bool isEnabled;
  final int? slotDurationMinutes;

  String get timeWindowDisplay => '$startTime – $endTime';
  String get timeRange => '$startTime – $endTime';
}
