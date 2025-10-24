import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'logger.dart';

/// Comprehensive API Test matching the Go backend verification
/// This tests the exact same workflow as the backend verification script
class ComprehensiveApiTest {
  final ApiService _apiService;

  ComprehensiveApiTest(this._apiService);

  /// Run the complete verification workflow
  Future<Map<String, dynamic>> runComprehensiveTest() async {
    final results = <String, dynamic>{};

    AppLogger.info('🎯 Starting Comprehensive API Verification');
    AppLogger.info('=========================================');

    try {
      // Step 0: Test Authentication
      results['authentication'] = await _testAuthentication();

      // Step 1: Find test data
      results['testData'] = await _findTestData();

      if (!results['testData']['success']) {
        return results;
      }

      final testData = results['testData']['data'];

      // Step 2: Test Get Active Stations by Route
      results['activeStationsByRoute'] =
          await _testActiveStationsByRoute(testData['route']['id']);

      // Step 3: Test Calculate Fare
      results['calculateFare'] = await _testCalculateFare(testData);

      // Step 4: Test Book Ticket
      results['bookTicket'] = await _testBookTicket(testData);

      // Step 5: Test Get My Tickets
      results['getMyTickets'] = await _testGetMyTickets();

      // Step 6: Test Ticket Status (if we have tickets)
      if (results['getMyTickets']['success'] &&
          results['getMyTickets']['tickets'].isNotEmpty) {
        final latestTicketId = results['getMyTickets']['tickets'][0]['id'];
        results['checkTicketStatus'] =
            await _testCheckTicketStatus(latestTicketId);
      }

      // Generate summary
      results['summary'] = _generateTestSummary(results);

      AppLogger.info('🎉 Comprehensive test completed!');
      return results;
    } catch (e) {
      AppLogger.error('❌ Comprehensive test failed: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Test Authentication with user/user123 credentials
  Future<Map<String, dynamic>> _testAuthentication() async {
    try {
      AppLogger.info('🔐 Testing Authentication...');

      final loginData = {
        'username': 'user',
        'password': 'user123',
      };

      final response =
          await _apiService.post(ApiConstants.login, data: loginData);

      if (response.statusCode == 200 &&
          response.data['data']?['token'] != null) {
        AppLogger.info('✅ Authentication successful');
        AppLogger.info('   User: ${response.data['data']['user']['username']}');

        return {
          'success': true,
          'token': response.data['data']['token'],
          'user': response.data['data']['user'],
        };
      } else {
        AppLogger.error('❌ Authentication failed: Invalid response');
        return {
          'success': false,
          'error': 'Invalid response from login endpoint',
        };
      }
    } catch (e) {
      AppLogger.error('❌ Authentication failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Find test data (user, bus, route)
  Future<Map<String, dynamic>> _findTestData() async {
    try {
      AppLogger.info('🔍 Finding test data...');

      // Get active routes
      final routesResponse = await _apiService.get(ApiConstants.activeRoutes);
      final routes = routesResponse.data['data'] as List;

      if (routes.isEmpty) {
        return {
          'success': false,
          'error': 'No active routes found',
        };
      }

      // Find a route with stations
      Map<String, dynamic>? testRoute;
      for (final route in routes) {
        if (route['distance'] != null && route['distance'] > 0) {
          testRoute = route;
          break;
        }
      }

      if (testRoute == null) {
        return {
          'success': false,
          'error': 'No suitable route found',
        };
      }

      // Get active buses
      final busesResponse = await _apiService.get(ApiConstants.activeBuses);
      final buses = busesResponse.data['data'] as List;

      if (buses.isEmpty) {
        return {
          'success': false,
          'error': 'No active buses found',
        };
      }

      final testBus = buses.first;

      AppLogger.info('✅ Test Data Found:');
      AppLogger.info(
          '   Route: ${testRoute['route_name']} (ID: ${testRoute['id']})');
      AppLogger.info('   Bus: ${testBus['bus_number']} (ID: ${testBus['id']})');

      return {
        'success': true,
        'data': {
          'route': testRoute,
          'bus': testBus,
        },
      };
    } catch (e) {
      AppLogger.error('❌ Failed to find test data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test 1: Get Active Stations by Route
  Future<Map<String, dynamic>> _testActiveStationsByRoute(
      String routeId) async {
    try {
      AppLogger.info('📍 Test 1: Get Active Stations by Route');

      final response =
          await _apiService.get('/routes/$routeId/stations/active');
      final stations = response.data['data'] as List;

      AppLogger.info('✅ Success: Found ${stations.length} active stations');

      final stationDetails = <Map<String, dynamic>>[];
      for (int i = 0; i < stations.length && i < 5; i++) {
        final stationData = stations[i];
        stationDetails.add({
          'name': stationData['station']['station_name'],
          'distance': stationData['distance_from_start'],
          'sequence': i + 1,
        });
        AppLogger.info(
            '   ${i + 1}. ${stationData['station']['station_name']} - Distance: ${stationData['distance_from_start']} km');
      }

      return {
        'success': true,
        'stationCount': stations.length,
        'stations': stationDetails,
        'allStations': stations,
      };
    } catch (e) {
      AppLogger.error('❌ Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test 2: Calculate Fare
  Future<Map<String, dynamic>> _testCalculateFare(
      Map<String, dynamic> testData) async {
    try {
      AppLogger.info('💰 Test 2: Calculate Fare');

      // Get stations for the route first
      final routeId = testData['route']['id'];
      final stationsResponse =
          await _apiService.get('/routes/$routeId/stations/active');
      final stations = stationsResponse.data['data'] as List;

      if (stations.length < 2) {
        return {
          'success': false,
          'error': 'Not enough stations for fare calculation',
        };
      }

      final fareRequest = {
        'bus_id': testData['bus']['id'],
        'route_id': routeId,
        'boarding_station_id': stations.first['station']['id'],
        'destination_station_id': stations.last['station']['id'],
        'ticket_type': 'single',
        'travel_date':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };

      final response =
          await _apiService.post(ApiConstants.calculateFare, data: fareRequest);
      final fareData = response.data['data'];

      AppLogger.info('✅ Success: Fare calculated');
      AppLogger.info('   Base Fare: ₹${fareData['base_fare']}');
      AppLogger.info('   Distance: ${fareData['distance']} km');
      AppLogger.info('   Final Amount: ₹${fareData['final_amount']}');

      return {
        'success': true,
        'baseFare': fareData['base_fare'],
        'distance': fareData['distance'],
        'finalAmount': fareData['final_amount'],
        'fareData': fareData,
      };
    } catch (e) {
      AppLogger.error('❌ Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test 3: Book Ticket
  Future<Map<String, dynamic>> _testBookTicket(
      Map<String, dynamic> testData) async {
    try {
      AppLogger.info('🎫 Test 3: Book Ticket');

      // Get stations for the route first
      final routeId = testData['route']['id'];
      final stationsResponse =
          await _apiService.get('/routes/$routeId/stations/active');
      final stations = stationsResponse.data['data'] as List;

      if (stations.length < 2) {
        return {
          'success': false,
          'error': 'Not enough stations for ticket booking',
        };
      }

      final bookingRequest = {
        'bus_id': testData['bus']['id'],
        'route_id': routeId,
        'boarding_station_id': stations.first['station']['id'],
        'destination_station_id': stations.last['station']['id'],
        'ticket_type': 'single',
        'travel_date':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'payment_mode': 'upi',
        'payment_method': 'test_payment',
      };

      final response =
          await _apiService.post(ApiConstants.bookTicket, data: bookingRequest);
      final ticketData = response.data['data'];

      AppLogger.info('✅ Success: Ticket booked and stored');
      AppLogger.info('   Ticket ID: ${ticketData['id']}');
      AppLogger.info('   Ticket Number: ${ticketData['ticket_number']}');
      AppLogger.info('   Fare: ₹${ticketData['fare_details']['final_amount']}');

      return {
        'success': true,
        'ticketId': ticketData['id'],
        'ticketNumber': ticketData['ticket_number'],
        'fare': ticketData['fare_details']['final_amount'],
        'ticketData': ticketData,
      };
    } catch (e) {
      AppLogger.error('❌ Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test 4: Get My Tickets
  Future<Map<String, dynamic>> _testGetMyTickets() async {
    try {
      AppLogger.info('📋 Test 4: Get My Tickets');

      final response = await _apiService.get(ApiConstants.myTickets);
      final tickets = response.data['data'] as List;

      AppLogger.info('✅ Success: Retrieved ${tickets.length} tickets');

      final recentTickets = <Map<String, dynamic>>[];
      for (int i = 0; i < tickets.length && i < 3; i++) {
        final ticket = tickets[i];
        recentTickets.add({
          'id': ticket['id'],
          'ticketNumber': ticket['ticket_number'],
          'status': ticket['status'],
          'fare': ticket['fare_details']['final_amount'],
        });
        AppLogger.info(
            '   ${i + 1}. ${ticket['ticket_number']} - ${ticket['status']} - ₹${ticket['fare_details']['final_amount']}');
      }

      return {
        'success': true,
        'ticketCount': tickets.length,
        'tickets': recentTickets,
        'allTickets': tickets,
      };
    } catch (e) {
      AppLogger.error('❌ Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test 5: Check Ticket Status
  Future<Map<String, dynamic>> _testCheckTicketStatus(String ticketId) async {
    try {
      AppLogger.info('🔍 Test 5: Check Ticket Status');

      final response =
          await _apiService.get('/tickets/passenger/$ticketId/status');
      final statusData = response.data['data'];

      AppLogger.info('✅ Success: Status checked');
      AppLogger.info('   Status: ${statusData['current_status']}');
      AppLogger.info('   Is Active: ${statusData['is_active']}');
      AppLogger.info('   Message: ${statusData['status_message']}');

      return {
        'success': true,
        'currentStatus': statusData['current_status'],
        'isActive': statusData['is_active'],
        'statusMessage': statusData['status_message'],
        'statusData': statusData,
      };
    } catch (e) {
      AppLogger.error('❌ Failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate test summary
  Map<String, dynamic> _generateTestSummary(Map<String, dynamic> results) {
    final tests = [
      'authentication',
      'testData',
      'activeStationsByRoute',
      'calculateFare',
      'bookTicket',
      'getMyTickets',
      'checkTicketStatus',
    ];

    int passedTests = 0;
    final issues = <String>[];
    final successes = <String>[];

    for (final test in tests) {
      if (results[test]?['success'] == true) {
        passedTests++;
        switch (test) {
          case 'authentication':
            successes
                .add('✅ Authentication working with user/user123 credentials');
            break;
          case 'activeStationsByRoute':
            successes.add('✅ Route stations endpoint working correctly');
            break;
          case 'calculateFare':
            successes.add('✅ Fare calculation working with proper distances');
            break;
          case 'bookTicket':
            successes.add('✅ Ticket booking and database storage working');
            break;
          case 'getMyTickets':
            successes.add('✅ Ticket retrieval from database working');
            break;
          case 'checkTicketStatus':
            successes.add('✅ Ticket status checking working');
            break;
        }
      } else if (results[test] != null) {
        switch (test) {
          case 'authentication':
            issues.add(
                '❌ Authentication failing - Cannot login with user/user123 credentials');
            break;
          case 'activeStationsByRoute':
            issues.add(
                '❌ Route stations endpoint failing - Active stations not showing according to route');
            break;
          case 'calculateFare':
            issues.add(
                '❌ Fare calculation failing - Unable to calculate ticket fare');
            break;
          case 'bookTicket':
            issues.add(
                '❌ Ticket booking failing - Tickets not being stored properly');
            break;
          case 'getMyTickets':
            issues.add(
                '❌ Ticket retrieval failing - Tickets not showing in my-tickets');
            break;
        }
      }
    }

    return {
      'totalTests': tests.length,
      'passedTests': passedTests,
      'issues': issues,
      'successes': successes,
      'overallSuccess': issues.isEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
