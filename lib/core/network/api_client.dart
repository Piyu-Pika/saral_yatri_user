import 'package:dio/dio.dart';
import 'package:dev_log/dev_log.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = AppConstants.baseUrl + AppConstants.apiVersion;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => Log.i(object.toString()),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = StorageService.getString(AppConstants.userTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        Log.e('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      Log.e('GET request failed: $e');
      rethrow;
    }
  }
  
  static Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      Log.e('POST request failed: $e');
      rethrow;
    }
  }
  
  static Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      Log.e('PUT request failed: $e');
      rethrow;
    }
  }
  
  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      Log.e('DELETE request failed: $e');
      rethrow;
    }
  }
}