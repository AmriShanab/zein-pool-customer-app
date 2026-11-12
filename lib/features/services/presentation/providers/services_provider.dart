import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/entities/pool_service.dart';
import '../../domain/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ServiceRepositoryImpl(apiClient: client);
});

final servicesSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final servicesListProvider = FutureProvider<List<PoolService>>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  final search = ref.watch(servicesSearchQueryProvider);
  return repo.getServices(search: search.isEmpty ? null : search);
});

final singleServiceProvider = FutureProvider.family<PoolService, String>((
  ref,
  id,
) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getService(id);
});
