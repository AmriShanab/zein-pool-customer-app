import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
    this.isNetworkFailure = false,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Object? details;
  final bool isNetworkFailure;

  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED';
  bool get isConflict =>
      statusCode == 409 ||
      code == 'BOOKING_OVERLAP' ||
      code == 'VERSION_CONFLICT';

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final body = response?.data;
    final errorBody = body is Map ? body['error'] : null;

    if (errorBody is Map) {
      return ApiException(
        code: errorBody['code']?.toString() ?? 'API_ERROR',
        message:
            errorBody['message']?.toString() ??
            'The request could not be completed.',
        statusCode: response?.statusCode,
        details: errorBody['details'],
      );
    }

    final networkFailure =
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;

    final statusCode = response?.statusCode;
    final fallbackCode = statusCode == 404
        ? 'API_NOT_FOUND'
        : (statusCode != null && statusCode >= 500
              ? 'SERVER_ERROR'
              : 'API_ERROR');

    final fallbackMessage = networkFailure
        ? "Could not connect to Zein's Pool server. Please check your internet connection."
        : (statusCode == 404
              ? 'The requested resort resource was not found.'
              : 'An unexpected error occurred. Please try again.');

    return ApiException(
      code: networkFailure ? 'NETWORK_UNAVAILABLE' : fallbackCode,
      message: fallbackMessage,
      statusCode: statusCode,
      isNetworkFailure: networkFailure,
    );
  }

  @override
  String toString() => '$code: $message';
}
