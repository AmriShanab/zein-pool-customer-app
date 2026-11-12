import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/resort_config_repository_impl.dart';
import '../../domain/entities/resort_config.dart';
import '../../domain/repositories/resort_config_repository.dart';

final resortConfigRepositoryProvider = Provider<ResortConfigRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ResortConfigRepositoryImpl(apiClient: client);
});

final resortConfigProvider = FutureProvider<ResortConfig>((ref) async {
  final repo = ref.watch(resortConfigRepositoryProvider);
  return repo.getConfig();
});
