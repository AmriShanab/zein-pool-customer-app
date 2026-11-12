import '../entities/resort_config.dart';

abstract interface class ResortConfigRepository {
  Future<ResortConfig> getConfig();
}
