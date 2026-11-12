import '../../../../core/constants/facility_assets.dart';
import 'booking_option.dart';

class PoolService {
  const PoolService({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.isActive,
    required this.bookingOptions,
    this.description,
    this.imageUrl,
    this.allowOnlineBooking = false,
    this.allowOnlinePayment = false,
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
  final List<BookingOption> bookingOptions;

  double get startingPrice {
    final enabled = bookingOptions.where((opt) => opt.isEnabled);
    if (enabled.isEmpty) return 0.0;
    return enabled
        .map((opt) => opt.price)
        .fold(double.infinity, (min, p) => p < min ? p : min);
  }

  BookingOption? get hourlyOption {
    try {
      return bookingOptions.firstWhere(
        (opt) => opt.isEnabled && opt.type == BookingTypeEnum.hourly,
      );
    } catch (_) {
      return null;
    }
  }

  bool get isTurf =>
      category.toLowerCase().contains('turf') ||
      name.toLowerCase().contains('turf');

  String get assetImage =>
      isTurf ? FacilityAssets.turfGround : FacilityAssets.swimmingPool;

  String get defaultDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    if (isTurf) {
      return 'Premier outdoor artificial turf sports ground designed for football, cricket, and tournament matches. Features high-lumen floodlights for evening games and spectator seating.';
    }
    return 'Enjoy an exclusive swimming experience at Zain Pool with crystal-clear filtered water, private changing suites, and relaxing poolside amenities for families and groups.';
  }

  List<String> get amenities {
    if (isTurf) {
      return [
        'High-Grade Artificial Turf Surface',
        'High-Lumen Floodlights for Night Matches',
        'Private Changing Rooms & Washrooms',
        'Football & Cricket Friendly Pitch Markings',
        'Spectator Seating & Rest Area',
      ];
    }
    return [
      'Crystal Clear Filtered Water',
      'Private Changing Cabins & Showers',
      'Poolside Loungers & Relaxation Area',
      'Evening & Underwater LED Lighting',
      'Exclusive Private Family Atmosphere',
    ];
  }
}
