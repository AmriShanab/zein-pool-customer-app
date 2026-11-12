import 'package:flutter_test/flutter_test.dart';
import 'package:zain_pool_customer_app/core/constants/facility_assets.dart';
import 'package:zain_pool_customer_app/features/services/domain/entities/pool_service.dart';

void main() {
  group('FacilityAssets Configuration Tests', () {
    test('swimmingPool path is defined correctly', () {
      expect(FacilityAssets.swimmingPool, 'assets/images/zein_pool_1.jpg');
    });

    test('turfGround path is defined correctly', () {
      expect(FacilityAssets.turfGround, 'assets/images/zein_turf.webp');
    });

    test('logo path is defined correctly', () {
      expect(FacilityAssets.logo, 'assets/images/zein_logo.png');
    });

    test('PoolService.assetImage routes correctly for turf and pool', () {
      const pool = PoolService(
        id: '1',
        vendorId: 'v1',
        name: 'Zain Pool',
        category: 'Pool',
        isActive: true,
        bookingOptions: [],
      );
      expect(pool.isTurf, isFalse);
      expect(pool.assetImage, FacilityAssets.swimmingPool);

      const turf = PoolService(
        id: '2',
        vendorId: 'v1',
        name: 'Zeins Turf Ground',
        category: 'Turf',
        isActive: true,
        bookingOptions: [],
      );
      expect(turf.isTurf, isTrue);
      expect(turf.assetImage, FacilityAssets.turfGround);
    });
  });
}
