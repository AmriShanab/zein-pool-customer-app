import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../domain/entities/customer_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/customer_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.apiClient, required this.secureStorage});

  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  @override
  Future<OtpChallenge> requestOtp(String mobile) async {
    final normalized = normalizeSriLankanMobile(mobile);
    final data = await apiClient.post(
      '/customer/auth/request-otp',
      data: {'mobile': normalized},
    );

    return OtpChallenge(
      expiresInSeconds: (data['expires_in_seconds'] as num?)?.toInt() ?? 300,
      resendAfterSeconds: (data['resend_after_seconds'] as num?)?.toInt() ?? 60,
      debugOtp: data['debug_otp']?.toString(),
    );
  }

  @override
  Future<CustomerProfile> verifyOtp({
    required String mobile,
    required String otp,
    String? name,
  }) async {
    final normalized = normalizeSriLankanMobile(mobile);
    final data = await apiClient.post(
      '/customer/auth/verify-otp',
      data: {
        'mobile': normalized,
        'otp': otp,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      },
    );

    final token = data['token']?.toString() ?? '';
    await secureStorage.write(ApiClient.tokenKey, token);

    final customerJson = data['customer'];
    if (customerJson is Map) {
      final model = CustomerModel.fromJson(
        Map<String, dynamic>.from(customerJson),
      );
      await secureStorage.write(
        ApiClient.customerDataKey,
        jsonEncode(model.toJson()),
      );
      return model.toEntity();
    }

    throw Exception('Malformed customer profile received from server.');
  }

  @override
  Future<CustomerProfile?> getProfile() async {
    try {
      final data = await apiClient.get('/customer/profile');
      final model = CustomerModel.fromJson(data);
      await secureStorage.write(
        ApiClient.customerDataKey,
        jsonEncode(model.toJson()),
      );
      return model.toEntity();
    } catch (_) {
      // Fallback to cache if network fails
      final cached = await secureStorage.read(ApiClient.customerDataKey);
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached) as Map<String, dynamic>;
          return CustomerModel.fromJson(decoded).toEntity();
        } catch (_) {}
      }
      return null;
    }
  }

  @override
  Future<CustomerProfile> updateProfile({
    required String name,
    String? notes,
  }) async {
    final data = await apiClient.put(
      '/customer/profile',
      data: {'name': name.trim(), if (notes != null) 'notes': notes.trim()},
    );
    final model = CustomerModel.fromJson(data);
    await secureStorage.write(
      ApiClient.customerDataKey,
      jsonEncode(model.toJson()),
    );
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/customer/auth/logout');
    } catch (_) {}
    await secureStorage.delete(ApiClient.tokenKey);
    await secureStorage.delete(ApiClient.customerDataKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.read(ApiClient.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
