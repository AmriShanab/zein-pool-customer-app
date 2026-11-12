import '../entities/customer_profile.dart';

class OtpChallenge {
  const OtpChallenge({
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.debugOtp,
  });

  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String? debugOtp;
}

abstract interface class AuthRepository {
  Future<OtpChallenge> requestOtp(String mobile);
  Future<CustomerProfile> verifyOtp({
    required String mobile,
    required String otp,
    String? name,
  });
  Future<CustomerProfile?> getProfile();
  Future<CustomerProfile> updateProfile({required String name, String? notes});
  Future<void> logout();
  Future<bool> isAuthenticated();
}
