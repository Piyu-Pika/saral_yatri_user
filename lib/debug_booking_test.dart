import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';
import 'core/constants/api_constants.dart';
import 'core/utils/logger.dart';

class BookingDebugTest {
  static Future<void> testBookingAPI() async {
    try {
      AppLogger.info('🧪 Starting booking API test...');

      // Test data - you should replace these with actual IDs from your database
      final testBookingData = {
        'bus_id': '671b8b8b8b8b8b8b8b8b8b8b', // Replace with actual bus ID
        'route_id': '671b8b8b8b8b8b8b8b8b8b8c', // Replace with actual route ID
        'boarding_station_id':
            '671b8b8b8b8b8b8b8b8b8b8d', // Replace with actual station ID
        'destination_station_id':
            '671b8b8b8b8b8b8b8b8b8b8e', // Replace with actual station ID
        'ticket_type': 'single',
        'travel_date':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        'payment_mode': 'upi',
      };

      AppLogger.info('📤 Sending booking request with data: $testBookingData');

      final response = await ApiClient.post(
        ApiConstants.bookTicket,
        data: testBookingData,
      );

      AppLogger.info('✅ Booking API Response:');
      AppLogger.info('Status Code: ${response.statusCode}');
      AppLogger.info('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('🎉 Booking API test PASSED!');
        return;
      } else {
        AppLogger.error('❌ Booking API test FAILED - Unexpected status code');
      }
    } catch (e) {
      AppLogger.error('❌ Booking API test FAILED with error: $e');

      // If it's a DioException, log more details
      if (e.toString().contains('DioException')) {
        AppLogger.error('This might be due to:');
        AppLogger.error('1. Invalid test data (bus_id, route_id, station_ids)');
        AppLogger.error('2. Authentication issues (missing or invalid token)');
        AppLogger.error('3. Server connectivity issues');
        AppLogger.error('4. API endpoint changes');
      }
    }
  }

  static Future<void> testGetTickets() async {
    try {
      AppLogger.info('🧪 Testing get tickets API...');

      final response = await ApiClient.get(ApiConstants.myTickets);

      AppLogger.info('✅ Get Tickets API Response:');
      AppLogger.info('Status Code: ${response.statusCode}');
      AppLogger.info('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final tickets = response.data['data'] ?? response.data['tickets'] ?? [];
        AppLogger.info('📋 Found ${tickets.length} tickets');
        AppLogger.info('🎉 Get Tickets API test PASSED!');
      } else {
        AppLogger.error(
            '❌ Get Tickets API test FAILED - Unexpected status code');
      }
    } catch (e) {
      AppLogger.error('❌ Get Tickets API test FAILED with error: $e');
    }
  }

  static Future<void> testCalculateFare() async {
    try {
      AppLogger.info('🧪 Testing calculate fare API...');

      final testFareData = {
        'bus_id': '671b8b8b8b8b8b8b8b8b8b8b', // Replace with actual bus ID
        'route_id': '671b8b8b8b8b8b8b8b8b8b8c', // Replace with actual route ID
        'boarding_station_id':
            '671b8b8b8b8b8b8b8b8b8b8d', // Replace with actual station ID
        'destination_station_id':
            '671b8b8b8b8b8b8b8b8b8b8e', // Replace with actual station ID
        'ticket_type': 'single',
        'travel_date':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      };

      final response = await ApiClient.post(
        ApiConstants.calculateFare,
        data: testFareData,
      );

      AppLogger.info('✅ Calculate Fare API Response:');
      AppLogger.info('Status Code: ${response.statusCode}');
      AppLogger.info('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        AppLogger.info('🎉 Calculate Fare API test PASSED!');
      } else {
        AppLogger.error(
            '❌ Calculate Fare API test FAILED - Unexpected status code');
      }
    } catch (e) {
      AppLogger.error('❌ Calculate Fare API test FAILED with error: $e');
    }
  }

  static Future<void> runAllTests() async {
    AppLogger.info('🚀 Starting comprehensive booking API tests...');
    AppLogger.info('================================================');

    await testCalculateFare();
    AppLogger.info('');

    await testGetTickets();
    AppLogger.info('');

    await testBookingAPI();
    AppLogger.info('');

    AppLogger.info('================================================');
    AppLogger.info('🏁 All booking API tests completed!');
  }
}

// Widget to trigger the tests
class BookingTestWidget extends ConsumerWidget {
  const BookingTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking API Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => BookingDebugTest.runAllTests(),
              child: const Text('Run All Booking Tests'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => BookingDebugTest.testCalculateFare(),
              child: const Text('Test Calculate Fare'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => BookingDebugTest.testGetTickets(),
              child: const Text('Test Get Tickets'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => BookingDebugTest.testBookingAPI(),
              child: const Text('Test Booking API'),
            ),
          ],
        ),
      ),
    );
  }
}
