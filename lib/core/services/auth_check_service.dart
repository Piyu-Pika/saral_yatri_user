import 'package:dev_log/dev_log.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthCheckService {
  /// Check if user is authenticated by testing a simple API call
  static Future<bool> isAuthenticated() async {
    try {
      final token = StorageService.getString('user_token');
      if (token == null || token.isEmpty) {
        Log.w('No authentication token found');
        return false;
      }

      Log.i('Checking authentication status...');

      // Try to call a simple authenticated endpoint
      final response = await ApiClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        Log.i('✅ User is authenticated');
        return true;
      } else {
        Log.w(
            '❌ Authentication check failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Log.w('❌ Authentication check failed: $e');

      // Check if it's specifically a 401 error
      if (e.toString().contains('401')) {
        Log.w('Token appears to be expired or invalid');
      }

      return false;
    }
  }

  /// Get authentication status with detailed information
  static Future<Map<String, dynamic>> getAuthStatus() async {
    final token = StorageService.getString('user_token');

    if (token == null || token.isEmpty) {
      return {
        'isAuthenticated': false,
        'hasToken': false,
        'message': 'No authentication token found',
        'action': 'Please log in to access this feature',
      };
    }

    try {
      final response = await ApiClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return {
          'isAuthenticated': true,
          'hasToken': true,
          'message': 'User is authenticated',
          'userInfo': response.data,
        };
      } else {
        return {
          'isAuthenticated': false,
          'hasToken': true,
          'message': 'Authentication failed',
          'statusCode': response.statusCode,
          'action': 'Please log in again',
        };
      }
    } catch (e) {
      return {
        'isAuthenticated': false,
        'hasToken': true,
        'message': 'Authentication error: ${e.toString()}',
        'error': e.toString(),
        'action': e.toString().contains('401')
            ? 'Please log in again - your session has expired'
            : 'Please check your internet connection and try again',
      };
    }
  }

  /// Clear authentication data
  static Future<void> clearAuth() async {
    await StorageService.remove('user_token');
    Log.i('Authentication data cleared');
  }

  /// Test API connectivity without authentication
  static Future<bool> testApiConnectivity() async {
    try {
      Log.i('Testing API connectivity...');

      // Try to call a public endpoint (if available)
      // For now, we'll try the buses endpoint and expect a 401, which means API is reachable
      final response = await ApiClient.get(ApiConstants.activeBuses);

      // If we get any response (even 401), API is reachable
      Log.i('✅ API is reachable (status: ${response.statusCode})');
      return true;
    } catch (e) {
      // Check if it's a 401 error, which means API is reachable but auth is required
      if (e.toString().contains('401')) {
        Log.i('✅ API is reachable (authentication required)');
        return true;
      }

      Log.e('❌ API connectivity test failed: $e');
      return false;
    }
  }
}
