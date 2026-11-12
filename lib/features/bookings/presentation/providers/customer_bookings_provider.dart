import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/customer_booking.dart';
import '../../domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BookingRepositoryImpl(apiClient: client);
});

final customerBookingsProvider =
    AsyncNotifierProvider<CustomerBookingsNotifier, List<CustomerBooking>>(() {
      return CustomerBookingsNotifier();
    });

class CustomerBookingsNotifier extends AsyncNotifier<List<CustomerBooking>> {
  @override
  Future<List<CustomerBooking>> build() async {
    final repo = ref.watch(bookingRepositoryProvider);
    final authState = ref.watch(authStateProvider);
    if (!authState.isAuthenticated) return [];
    return repo.getBookings();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bookingRepositoryProvider);
      return repo.getBookings();
    });
  }

  Future<bool> cancelBooking(String id) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final updated = await repo.cancelBooking(id);
      state = state.whenData((list) {
        return list.map((b) => b.id == id ? updated : b).toList();
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
