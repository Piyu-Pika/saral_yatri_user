import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class ApiClient {
  static final Dio _dio = Dio();

  static void init() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = ApiConstants.connectTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;

    // Add Pretty Dio Logger (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        logPrint: (object) => AppLogger.info('[API] $object'),
      ));
    }

    // Add authentication and error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        AppLogger.debug('[API] → ${options.method} ${options.path}');

        // Add auth token if available
        final token = StorageService.getString('user_token');
        if (token != null) {
          options.headers[ApiConstants.authHeader] =
              '${ApiConstants.bearerPrefix} $token';
          AppLogger.debug('[API] Added auth token');
        }

        // Add common headers
        options.headers[ApiConstants.contentType] =
            ApiConstants.applicationJson;
        options.headers['Accept'] = ApiConstants.applicationJson;

        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info(
            '[API] ← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        final statusCode = error.response?.statusCode ?? 'Unknown';
        AppLogger.error('[API] ✗ Error $statusCode: ${error.message}');

        // Log additional error details
        if (error.response != null) {
          AppLogger.error('[API] Response data: ${error.response?.data}');
          AppLogger.error('[API] Request path: ${error.requestOptions.path}');
        }

        handler.next(error);
      },
    ));
  }

  static Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      AppLogger.debug(
          '[API] GET $path ${queryParameters != null ? 'with params: $queryParameters' : ''}');
      final response = await _dio.get(path, queryParameters: queryParameters);
      AppLogger.info('[API] GET $path completed successfully');
      return response;
    } catch (e) {
      AppLogger.error('[API] GET $path failed: $e');
      rethrow;
    }
  }

  static Future<Response> post(String path, {dynamic data}) async {
    try {
      AppLogger.debug(
          '[API] POST $path ${data != null ? 'with data' : 'without data'}');
      final response = await _dio.post(path, data: data);
      AppLogger.info('[API] POST $path completed successfully');
      return response;
    } catch (e) {
      AppLogger.error('[API] POST $path failed: $e');
      rethrow;
    }
  }

  static Future<Response> put(String path, {dynamic data}) async {
    try {
      AppLogger.debug(
          '[API] PUT $path ${data != null ? 'with data' : 'without data'}');
      final response = await _dio.put(path, data: data);
      AppLogger.info('[API] PUT $path completed successfully');
      return response;
    } catch (e) {
      AppLogger.error('[API] PUT $path failed: $e');
      rethrow;
    }
  }

  static Future<Response> delete(String path) async {
    try {
      AppLogger.debug('[API] DELETE $path');
      final response = await _dio.delete(path);
      AppLogger.info('[API] DELETE $path completed successfully');
      return response;
    } catch (e) {
      AppLogger.error('[API] DELETE $path failed: $e');
      rethrow;
    }
  }

  // Get the Dio instance for advanced usage
  static Dio get instance => _dio;
}
