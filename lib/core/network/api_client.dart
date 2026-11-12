import 'package:dio/dio.dart';

import '../config/app_environment.dart';
import '../security/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required this.secureStorage, Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio() {
    final rawBase = (baseUrl ?? AppEnvironment.apiBaseUrl).trim();
    final normalizedBase = rawBase.endsWith('/') ? rawBase : '$rawBase/';
    _dio.options = BaseOptions(
      baseUrl: normalizedBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-App-Name': AppEnvironment.appName,
        'X-App-Version': AppEnvironment.appVersion,
        'X-App-Build': AppEnvironment.buildNumber,
      },
    );
  }

  static const tokenKey = 'customer_auth_token';
  static const customerDataKey = 'customer_profile_cache';

  final SecureStorageService secureStorage;
  final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _request('GET', path, queryParameters: queryParameters, headers: headers);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => _request(
    'POST',
    path,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) => _request('PUT', path, data: data, headers: headers);

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? headers,
  }) => _request('DELETE', path, headers: headers);

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
    void Function(int sent, int total)? onSendProgress,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final token = await secureStorage.read(tokenKey);
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final response = await _dio.post<dynamic>(
        cleanPath,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            ...?headers,
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      final rawData = response.data;
      if (rawData is! Map) {
        return const <String, dynamic>{};
      }

      final envelope = Map<String, dynamic>.from(rawData);
      if (envelope['success'] == false) {
        final error = envelope['error'];
        throw ApiException(
          code: error is Map
              ? error['code']?.toString() ?? 'API_ERROR'
              : 'API_ERROR',
          message: error is Map
              ? error['message']?.toString() ?? 'Request failed'
              : 'Request failed',
          statusCode: response.statusCode,
          details: error is Map ? error['details'] : null,
        );
      }

      final payload = envelope['data'];
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
      return envelope;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final token = await secureStorage.read(tokenKey);
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final response = await _dio.request<dynamic>(
        cleanPath,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: {
            ...?headers,
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final rawData = response.data;
      if (rawData is! Map) {
        return const <String, dynamic>{};
      }

      final envelope = Map<String, dynamic>.from(rawData);
      if (envelope['success'] == false) {
        final error = envelope['error'];
        throw ApiException(
          code: error is Map
              ? error['code']?.toString() ?? 'API_ERROR'
              : 'API_ERROR',
          message: error is Map
              ? error['message']?.toString() ?? 'Request failed'
              : 'Request failed',
          statusCode: response.statusCode,
          details: error is Map ? error['details'] : null,
        );
      }

      final payload = envelope['data'];
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
      return envelope;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
