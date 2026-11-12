import '../../../../core/network/api_client.dart';
import '../../domain/entities/resort_config.dart';
import '../../domain/repositories/resort_config_repository.dart';
import '../models/resort_config_model.dart';

class ResortConfigRepositoryImpl implements ResortConfigRepository {
  ResortConfigRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<ResortConfig> getConfig() async {
    try {
      final data = await apiClient.get('/customer/config');
      return ResortConfigModel.fromJson(data).toEntity();
    } catch (_) {
      // Fallback configuration if offline
      return const ResortConfig(
        resortName: "Zein's Pool",
        currency: 'LKR',
        timezone: 'Asia/Colombo',
        businessMobile: '+94 78 923 8808',
        businessEmail: 'contact@zeinspool.com',
        businessAddress: 'Kattankudy, Batticaloa, Sri Lanka',
        operatingHours: '07:00 AM – 11:00 PM Daily',
        bankInfo: BankInfo(
          bankName: 'Commercial Bank',
          accountName: "Zein's Pool Resort",
          accountNumber: '8001234567',
        ),
        rules: [
          'Appropriate swimwear is strictly required in the swimming pool at all times.',
          'Sports turf players must wear suitable sports shoes/turf footwear (no metal studs).',
          'Children under 12 must be supervised by an adult at all times.',
          'No glass bottles, food, or alcoholic beverages allowed inside pool or playing pitch.',
          'Cancellations made 24 hours prior to scheduled booking are eligible for rescheduling.',
          'Private bookings guarantee exclusive facility access for your group during reserved hours.',
        ],
      );
    }
  }
}
