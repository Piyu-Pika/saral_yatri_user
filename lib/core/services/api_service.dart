import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/api_exceptions.dart';
import '../network/api_client.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService);
});

class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          _authService.logout();
          return ApiException('Unauthorized. Please login again.');
        }
        return ApiException(
            error.response?.data?['error'] ?? 'Server error occurred.');
      case DioExceptionType.connectionError:
        return ApiException(
            'No internet connection. Please check your network.');
      default:
        return ApiException('An unexpected error occurred.');
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      AppLogger.debug('[ApiService] GET request to: $path');
      return await ApiClient.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      AppLogger.error('[ApiService] GET request failed: ${e.message}');
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      AppLogger.debug('[ApiService] POST request to: $path');
      return await ApiClient.post(path, data: data);
    } on DioException catch (e) {
      AppLogger.error('[ApiService] POST request failed: ${e.message}');
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      AppLogger.debug('[ApiService] PUT request to: $path');
      return await ApiClient.put(path, data: data);
    } on DioException catch (e) {
      AppLogger.error('[ApiService] PUT request failed: ${e.message}');
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      AppLogger.debug('[ApiService] DELETE request to: $path');
      return await ApiClient.delete(path);
    } on DioException catch (e) {
      AppLogger.error('[ApiService] DELETE request failed: ${e.message}');
      throw _handleError(e);
    }
  }
}
