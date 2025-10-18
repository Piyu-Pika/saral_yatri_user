import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';
import 'auth_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiService(authService);
});

class ApiService {
  late final Dio _dio;
  final AuthService _authService;

  ApiService(this._authService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        ApiConstants.contentType: ApiConstants.applicationJson,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers[ApiConstants.authHeader] = '${ApiConstants.bearerPrefix} $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final apiException = _handleError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: apiException,
        ));
      },
    ));
  }

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
        return ApiException(error.response?.data?['error'] ?? 'Server error occurred.');
      case DioExceptionType.connectionError:
        return ApiException('No internet connection. Please check your network.');
      default:
        return ApiException('An unexpected error occurred.');
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }
}
