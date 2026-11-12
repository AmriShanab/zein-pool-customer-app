import '../entities/pool_service.dart';
import '../entities/service_availability.dart';

abstract interface class ServiceRepository {
  Future<List<PoolService>> getServices({String? search});
  Future<PoolService> getService(String id);
  Future<ServiceAvailability> getAvailability({
    required String serviceId,
    required String date,
  });
  Future<MonthAvailability> getMonthAvailability({
    required String serviceId,
    required String month,
  });
}
