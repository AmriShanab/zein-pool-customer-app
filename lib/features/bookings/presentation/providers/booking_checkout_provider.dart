import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/booking_option.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/service_availability.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../services/presentation/providers/availability_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/customer_booking.dart';
import 'customer_bookings_provider.dart';

import '../widgets/receipt_upload_card.dart';

class BookingDraftState {
  BookingDraftState({
    this.service,
    this.bookingType = BookingTypeEnum.hourly,
    required this.bookingDate,
    AvailableSlot? selectedSlot,
    List<AvailableSlot>? selectedSlots,
    this.membersCount = 1,
    this.additionalNote,
    this.paymentMethod = 'online',
    this.payNow = true,
    this.sendSms = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdBooking,
    this.receiptFile,
  }) : selectedSlots = _normalizeSlots(
         selectedSlots ?? (selectedSlot != null ? [selectedSlot] : const []),
       );

  final PoolService? service;
  final BookingTypeEnum bookingType;
  final DateTime bookingDate;
  final List<AvailableSlot> selectedSlots;
  final int membersCount;
  final String? additionalNote;
  final String paymentMethod;
  final bool payNow;
  final bool sendSms;
  final bool isSubmitting;
  final String? errorMessage;
  final CustomerBooking? createdBooking;
  final ReceiptFileInfo? receiptFile;

  static List<AvailableSlot> _normalizeSlots(List<AvailableSlot> slots) {
    final valid = slots
        .where((s) => s.isAvailable && !s.isBooked && !s.isPast)
        .toList();
    valid.sort((a, b) => a.startAt.compareTo(b.startAt));
    return List.unmodifiable(valid);
  }

  /// First selected slot (kept for backwards compatibility).
  AvailableSlot? get selectedSlot =>
      selectedSlots.isNotEmpty ? selectedSlots.first : null;

  int get selectedSlotCount => selectedSlots.length;

  DateTime? get selectedStartAt =>
      selectedSlots.isNotEmpty ? selectedSlots.first.startAt : null;

  DateTime? get selectedEndAt =>
      selectedSlots.isNotEmpty ? selectedSlots.last.endAt : null;

  String? get selectedTimeRange {
    if (selectedSlots.isEmpty) return null;
    return '${selectedSlots.first.startTime} – ${selectedSlots.last.endTime}';
  }

  String get selectedSlotsLabel {
    if (selectedSlots.isEmpty) return 'Select slots';
    if (selectedSlots.length == 1) {
      return '${selectedSlots.first.timeRange} (1 Slot)';
    }
    return '$selectedTimeRange (${selectedSlots.length} Slots)';
  }

  bool isSlotSelected(AvailableSlot slot) {
    return selectedSlots.any((s) => s.startAt.isAtSameMomentAs(slot.startAt));
  }

  bool get isComplete {
    if (service == null) return false;
    if (bookingType == BookingTypeEnum.hourly) {
      return selectedSlots.isNotEmpty;
    }
    return true;
  }

  double get totalPrice {
    if (service == null) return 0.0;
    if (bookingType == BookingTypeEnum.hourly) {
      if (selectedSlots.isNotEmpty) {
        return selectedSlots.fold(0.0, (sum, slot) => sum + slot.price);
      }
      final option = service!.hourlyOption;
      return option?.price ?? 0.0;
    }

    try {
      final option = service!.bookingOptions.firstWhere(
        (opt) => opt.type == bookingType && opt.isEnabled,
      );
      return option.price;
    } catch (_) {
      return service!.startingPrice;
    }
  }

  BookingDraftState copyWith({
    PoolService? service,
    BookingTypeEnum? bookingType,
    DateTime? bookingDate,
    AvailableSlot? selectedSlot,
    List<AvailableSlot>? selectedSlots,
    bool clearSelectedSlot = false,
    int? membersCount,
    String? additionalNote,
    String? paymentMethod,
    bool? payNow,
    bool? sendSms,
    bool? isSubmitting,
    String? errorMessage,
    CustomerBooking? createdBooking,
    ReceiptFileInfo? receiptFile,
    bool clearReceiptFile = false,
  }) {
    final List<AvailableSlot> nextSlots;
    if (clearSelectedSlot) {
      nextSlots = const [];
    } else if (selectedSlots != null) {
      nextSlots = selectedSlots;
    } else if (selectedSlot != null) {
      nextSlots = [selectedSlot];
    } else {
      nextSlots = this.selectedSlots;
    }

    return BookingDraftState(
      service: service ?? this.service,
      bookingType: bookingType ?? this.bookingType,
      bookingDate: bookingDate ?? this.bookingDate,
      selectedSlots: nextSlots,
      membersCount: membersCount ?? this.membersCount,
      additionalNote: additionalNote ?? this.additionalNote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payNow: payNow ?? this.payNow,
      sendSms: sendSms ?? this.sendSms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      createdBooking: createdBooking ?? this.createdBooking,
      receiptFile: clearReceiptFile ? null : (receiptFile ?? this.receiptFile),
    );
  }
}

class BookingCheckoutNotifier extends StateNotifier<BookingDraftState> {
  BookingCheckoutNotifier({required this.ref})
    : super(BookingDraftState(bookingDate: DateTime.now()));

  final Ref ref;

  void initForService(PoolService service, {BookingTypeEnum? initialType}) {
    state = BookingDraftState(
      service: service,
      bookingType: initialType ?? BookingTypeEnum.hourly,
      bookingDate: DateTime.now(),
      membersCount: 1,
      paymentMethod: 'online',
      payNow: true,
    );
  }

  void setDate(DateTime date) {
    state = state.copyWith(bookingDate: date, clearSelectedSlot: true);
  }

  void setBookingType(BookingTypeEnum type) {
    state = state.copyWith(bookingType: type, clearSelectedSlot: true);
  }

  /// Toggles or extends multi-slot hourly selection.
  /// Returns an optional informational message when selection resets across a booked gap.
  String? toggleSlot(AvailableSlot tapped, {List<AvailableSlot>? allSlots}) {
    if (!tapped.isAvailable || tapped.isBooked || tapped.isPast) {
      return 'This time slot is not available.';
    }

    final current = List<AvailableSlot>.from(state.selectedSlots);
    if (current.isEmpty) {
      state = state.copyWith(selectedSlots: [tapped]);
      return null;
    }

    final existingIndex = current.indexWhere(
      (s) => s.startAt.isAtSameMomentAs(tapped.startAt),
    );

    if (existingIndex >= 0) {
      if (current.length == 1) {
        state = state.copyWith(clearSelectedSlot: true);
      } else if (existingIndex == 0) {
        state = state.copyWith(selectedSlots: current.sublist(1));
      } else if (existingIndex == current.length - 1) {
        state = state.copyWith(
          selectedSlots: current.sublist(0, current.length - 1),
        );
      } else {
        // Tapped a middle slot: keep continuous prefix before tapped slot
        state = state.copyWith(
          selectedSlots: current.sublist(0, existingIndex),
        );
      }
      return null;
    }

    // Check if directly adjacent to current selection
    final isAdjacentBefore = tapped.endAt.isAtSameMomentAs(
      current.first.startAt,
    );
    final isAdjacentAfter = tapped.startAt.isAtSameMomentAs(
      current.last.endAt,
    );

    if (isAdjacentBefore || isAdjacentAfter) {
      final updated = [...current, tapped]
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
      state = state.copyWith(selectedSlots: updated);
      return null;
    }

    // If allSlots is provided, attempt to select the continuous range between current and tapped
    if (allSlots != null && allSlots.isNotEmpty) {
      final rangeStart = tapped.startAt.isBefore(current.first.startAt)
          ? tapped.startAt
          : current.first.startAt;
      final rangeEnd = tapped.endAt.isAfter(current.last.endAt)
          ? tapped.endAt
          : current.last.endAt;

      final rangeSlots = allSlots
          .where(
            (s) =>
                !s.startAt.isBefore(rangeStart) && !s.endAt.isAfter(rangeEnd),
          )
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));

      var isContiguousAndAvailable =
          rangeSlots.isNotEmpty &&
          rangeSlots.every((s) => s.isAvailable && !s.isBooked && !s.isPast);

      for (var i = 1; i < rangeSlots.length; i++) {
        if (!rangeSlots[i].startAt.isAtSameMomentAs(rangeSlots[i - 1].endAt)) {
          isContiguousAndAvailable = false;
          break;
        }
      }

      if (isContiguousAndAvailable) {
        state = state.copyWith(selectedSlots: rangeSlots);
        return null;
      }
    }

    // Non-contiguous across a booked/unavailable slot: start new selection at tapped slot
    state = state.copyWith(selectedSlots: [tapped]);
    return 'Multi-hour bookings require consecutive slots. Selection updated to ${tapped.timeRange}.';
  }

  void selectSlot(AvailableSlot slot, {List<AvailableSlot>? allSlots}) {
    toggleSlot(slot, allSlots: allSlots);
  }

  void clearSlot() {
    state = state.copyWith(clearSelectedSlot: true);
  }

  void setMembersCount(int count) {
    if (count >= 1 && count <= 50) {
      state = state.copyWith(membersCount: count);
    }
  }

  void setAdditionalNote(String note) {
    state = state.copyWith(additionalNote: note);
  }

  void setPaymentMethod(String method, {bool? payNow}) {
    state = state.copyWith(paymentMethod: method, payNow: false);
  }

  void setReceiptFile(ReceiptFileInfo? file) {
    if (file == null) {
      state = state.copyWith(clearReceiptFile: true);
    } else {
      state = state.copyWith(receiptFile: file);
    }
  }

  void setSendSms(bool send) {
    state = state.copyWith(sendSms: send);
  }

  /// Strictly validates whether the chosen slot or booking option is still available
  /// prior to initiating payment or creating a reservation.
  Future<bool> validateSlotAvailability() async {
    final service = state.service;
    if (service == null) return false;

    try {
      final repo = ref.read(serviceRepositoryProvider);
      final dateStr = DateFormatter.toIsoDate(state.bookingDate);
      final query = AvailabilityQuery(serviceId: service.id, date: dateStr);

      final availability = await repo.getAvailability(
        serviceId: service.id,
        date: dateStr,
      );

      // Invalidate cached query so provider reflects live backend data
      ref.invalidate(availabilityProvider(query));

      if (state.bookingType == BookingTypeEnum.hourly) {
        final chosenSlots = state.selectedSlots;
        if (chosenSlots.isEmpty) return false;

        // Verify contiguousness of chosen slots
        for (var i = 1; i < chosenSlots.length; i++) {
          if (!chosenSlots[i].startAt.isAtSameMomentAs(
            chosenSlots[i - 1].endAt,
          )) {
            clearSlot();
            return false;
          }
        }

        // Verify every chosen slot is still available in live backend data
        for (final chosen in chosenSlots) {
          AvailableSlot? match;
          for (final s in availability.slots) {
            if (s.startAt.isAtSameMomentAs(chosen.startAt) ||
                (s.startTime == chosen.startTime &&
                    s.endTime == chosen.endTime)) {
              match = s;
              break;
            }
          }
          if (match == null ||
              !match.isAvailable ||
              match.isBooked ||
              match.isPast) {
            clearSlot();
            return false;
          }
        }
        return true;
      } else {
        for (final opt in availability.options) {
          if (opt.bookingType == state.bookingType) {
            final isOk = opt.isAvailable && !opt.isBooked;
            return isOk;
          }
        }
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<CustomerBooking?> submitBooking() async {
    final service = state.service;
    if (service == null) {
      state = state.copyWith(errorMessage: 'No service selected');
      return null;
    }

    DateTime startAt;
    DateTime endAt;

    if (state.bookingType == BookingTypeEnum.hourly) {
      final chosenSlots = state.selectedSlots;
      if (chosenSlots.isEmpty) {
        state = state.copyWith(
          errorMessage: 'Please select at least one hourly slot',
        );
        return null;
      }
      startAt = chosenSlots.first.startAt;
      endAt = chosenSlots.last.endAt;
    } else {
      // Resolve start and end times based on the option
      BookingOption? opt;
      try {
        opt = service.bookingOptions.firstWhere(
          (o) => o.type == state.bookingType && o.isEnabled,
        );
      } catch (_) {}

      if (opt == null) {
        state = state.copyWith(
          errorMessage: 'Selected booking option is not available',
        );
        return null;
      }

      final date = state.bookingDate;
      final isoDate =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final avail = ref
          .read(
            availabilityProvider(
              AvailabilityQuery(serviceId: service.id, date: isoDate),
            ),
          )
          .valueOrNull;

      OptionAvailability? optAvail;
      try {
        optAvail = avail?.options.firstWhere(
          (o) => o.bookingType == state.bookingType,
        );
      } catch (_) {}

      if (optAvail != null &&
          optAvail.startAt != null &&
          optAvail.endAt != null) {
        startAt = optAvail.startAt!;
        endAt = optAvail.endAt!;
      } else {
        // Fallback: parse facility operating hours in Asia/Colombo (+05:30)
        final tzOffset = const Duration(hours: 5, minutes: 30);
        final startParts = opt.startTime.split(':');
        final endParts = opt.endTime.split(':');

        final startUtc = DateTime.utc(
          date.year,
          date.month,
          date.day,
          int.parse(startParts[0]),
          int.parse(startParts[1]),
        ).subtract(tzOffset);

        var endUtc = DateTime.utc(
          date.year,
          date.month,
          date.day,
          int.parse(endParts[0]),
          int.parse(endParts[1]),
        ).subtract(tzOffset);

        if (!endUtc.isAfter(startUtc)) {
          endUtc = endUtc.add(const Duration(days: 1));
        }

        startAt = startUtc;
        endAt = endUtc;
      }
    }

    final isoDate =
        "${state.bookingDate.year.toString().padLeft(4, '0')}-${state.bookingDate.month.toString().padLeft(2, '0')}-${state.bookingDate.day.toString().padLeft(2, '0')}";

    final request = CreateBookingRequest(
      serviceId: service.id,
      bookingType: state.bookingType,
      bookingDate: isoDate,
      startAt: startAt,
      endAt: endAt,
      membersCount: state.membersCount,
      additionalNote: state.additionalNote,
      paymentMethod: state.paymentMethod,
      payNow: state.payNow,
      sendConfirmationSms: state.sendSms,
    );

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final repo = ref.read(bookingRepositoryProvider);
      final booking = await repo.createBooking(request);

      CustomerBooking finalBooking = booking;
      if (state.paymentMethod == 'bank_transfer' && state.receiptFile != null) {
        try {
          finalBooking = await repo.uploadBankReceipt(
            bookingId: booking.id,
            filePath: state.receiptFile!.filePath,
          );
        } catch (_) {
          // Booking is created; receipt can be retried on details screen if failed
        }
      }

      state = state.copyWith(isSubmitting: false, createdBooking: finalBooking);
      // Refresh list of bookings
      ref.read(customerBookingsProvider.notifier).refresh();
      return finalBooking;
    } catch (e) {
      final dateStr = DateFormatter.toIsoDate(state.bookingDate);
      ref.invalidate(
        availabilityProvider(
          AvailabilityQuery(serviceId: service.id, date: dateStr),
        ),
      );
      final msg = e.toString().replaceFirst(RegExp(r'^[^:]*:\s*'), '');
      final isConflict =
          msg.toLowerCase().contains('no longer available') ||
          msg.toLowerCase().contains('reserved') ||
          msg.toLowerCase().contains('conflict');
      if (isConflict) {
        clearSlot();
      }
      state = state.copyWith(isSubmitting: false, errorMessage: msg);
      return null;
    }
  }
}

final bookingCheckoutProvider =
    StateNotifierProvider<BookingCheckoutNotifier, BookingDraftState>((ref) {
      return BookingCheckoutNotifier(ref: ref);
    });
