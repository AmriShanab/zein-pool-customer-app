import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/service_availability.dart';
import 'services_provider.dart';

class AvailabilityQuery {
  const AvailabilityQuery({required this.serviceId, required this.date});

  final String serviceId;
  final String date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilityQuery &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          date == other.date;

  @override
  int get hashCode => serviceId.hashCode ^ date.hashCode;
}

final availabilityProvider = FutureProvider.autoDispose
    .family<ServiceAvailability, AvailabilityQuery>((ref, query) async {
      final repo = ref.watch(serviceRepositoryProvider);
      return repo.getAvailability(serviceId: query.serviceId, date: query.date);
    });

class MonthAvailabilityQuery {
  const MonthAvailabilityQuery({required this.serviceId, required this.month});

  final String serviceId;
  final String month;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthAvailabilityQuery &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          month == other.month;

  @override
  int get hashCode => serviceId.hashCode ^ month.hashCode;
}

final monthAvailabilityProvider = FutureProvider.autoDispose
    .family<MonthAvailability, MonthAvailabilityQuery>((ref, query) async {
      final repo = ref.watch(serviceRepositoryProvider);
      return repo.getMonthAvailability(
        serviceId: query.serviceId,
        month: query.month,
      );
    });
