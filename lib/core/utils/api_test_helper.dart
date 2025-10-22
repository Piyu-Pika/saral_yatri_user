import 'package:dev_log/dev_log.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

class ApiTestHelper {
  /// Test the my-tickets API endpoint
  static Future<void> testMyTicketsApi() async {
    try {
      Log.i('Testing my-tickets API endpoint...');
      
      final response = await ApiClient.get(ApiConstants.myTickets);
      
      Log.i('API Response Status: ${response.statusCode}');
      Log.i('API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        Log.i('✅ My-tickets API is working correctly');
        
        // Check response structure
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final tickets = data['tickets'] ?? data['data'] ?? [];
          Log.i('Found ${tickets.length} tickets in response');
        }
      } else {
        Log.w('⚠️ Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('❌ My-tickets API test failed: $e');
    }
  }
  
  /// Test API connectivity
  static Future<bool> testApiConnectivity() async {
    try {
      Log.i('Testing API connectivity...');
      
      // Try a simple endpoint that doesn't require auth
      final response = await ApiClient.get('/health');
      
      if (response.statusCode == 200) {
        Log.i('✅ API is reachable');
        return true;
      } else {
        Log.w('⚠️ API returned status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Log.e('❌ API connectivity test failed: $e');
      return false;
    }
  }
}