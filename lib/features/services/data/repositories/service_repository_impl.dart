import '../../../../core/network/api_client.dart';
import '../../domain/entities/pool_service.dart';
import '../../domain/entities/service_availability.dart';
import '../../domain/repositories/service_repository.dart';
import '../models/pool_service_model.dart';
import '../models/service_availability_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<PoolService>> getServices({String? search}) async {
    final query = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final data = await apiClient.get(
      '/customer/services',
      queryParameters: query.isEmpty ? null : query,
    );

    final itemsRaw = data['items'];
    if (itemsRaw is List) {
      return itemsRaw
          .whereType<Map>()
          .map(
            (item) =>
                PoolServiceModel.fromJson(Map<String, dynamic>.from(item))
                    .toEntity(),
          )
          .where((service) => service.isActive && service.allowOnlineBooking)
          .toList();
    }
    return [];
  }

  @override
  Future<PoolService> getService(String id) async {
    final data = await apiClient.get('/customer/services/$id');
    return PoolServiceModel.fromJson(data).toEntity();
  }

  @override
  Future<ServiceAvailability> getAvailability({
    required String serviceId,
    required String date,
  }) async {
    final data = await apiClient.get(
      '/customer/services/$serviceId/availability',
      queryParameters: {'date': date},
    );
    return ServiceAvailabilityModel.fromJson(data).toEntity();
  }

  @override
  Future<MonthAvailability> getMonthAvailability({
    required String serviceId,
    required String month,
  }) async {
    final data = await apiClient.get(
      '/customer/services/$serviceId/month-availability',
      queryParameters: {'month': month},
    );
    return MonthAvailabilityModel.fromJson(data).toEntity();
  }
}
