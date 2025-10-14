import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? aadhaarNumber,
    DateTime? dateOfBirth,
    String? fullName,
    String? gender,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          if (aadhaarNumber != null) 'aadhaar_number': aadhaarNumber,
          if (dateOfBirth != null)
            'date_of_birth': dateOfBirth.toIso8601String(),
          if (fullName != null) 'full_name': fullName,
          if (gender != null) 'gender': gender,
        },
      );

      final token = response.data['token'];
      final user = UserModel.fromJson(response.data['user']);

      _apiClient.setToken(token);
      await StorageService.setString(AppConstants.userTokenKey, token);
      await StorageService.setObject(AppConstants.userDataKey, user.toJson());
      await StorageService.setBool(AppConstants.isLoggedInKey, true);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['token'];
      final user = UserModel.fromJson(response.data['user']);

      _apiClient.setToken(token);
      await StorageService.setString(AppConstants.userTokenKey, token);
      await StorageService.setObject(AppConstants.userDataKey, user.toJson());
      await StorageService.setBool(AppConstants.isLoggedInKey, true);

      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSubsidyEligibility() async {
    try {
      final response = await _apiClient.dio.get('/auth/subsidy-eligibility');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> getToken() async {
    return StorageService.getString(AppConstants.userTokenKey);
  }

  Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      _apiClient.setToken(token);
    }
  }

  bool get isLoggedIn {
    return StorageService.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  UserModel? get currentUser {
    final userData = StorageService.getObject(AppConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<void> saveAuthData(String token, UserModel user) async {
    _apiClient.setToken(token);
    await StorageService.setString(AppConstants.userTokenKey, token);
    await StorageService.setObject(AppConstants.userDataKey, user.toJson());
    await StorageService.setBool(AppConstants.isLoggedInKey, true);
  }

  Future<void> logout() async {
    _apiClient.clearToken();
    await StorageService.remove(AppConstants.userTokenKey);
    await StorageService.remove(AppConstants.userDataKey);
    await StorageService.setBool(AppConstants.isLoggedInKey, false);
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      // Check if the response data is a Map before trying to access it with a key
      if (e.response?.data is Map<String, dynamic>) {
        return e.response?.data['message'] ?? 'An error occurred';
      } else if (e.response?.data is String) {
        return e.response?.data as String;
      }
      return 'An error occurred';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
