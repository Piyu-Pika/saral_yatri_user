import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'logger.dart';

/// Specific diagnostic for ticket booking storage issues
/// This focuses on identifying why tickets booked through the app don't store in database
class TicketBookingDiagnostic {
  final ApiService _apiService;
  
  TicketBookingDiagnostic(this._apiService);

  /// Run comprehensive ticket booking diagnostic
  Future<Map<String, dynamic>> diagnoseTicketBooking() async {
    final results = <String, dynamic>{};
    
    AppLogger.info('🎫 Starting Ticket Booking Diagnostic');
    AppLogger.info('=====================================');
    
    try {
      // Step 1: Test Authentication
      results['authentication'] = await _testAuthentication();
      
      if (!results['authentication']['success']) {
        AppLogger.error('❌ Cannot proceed without authentication');
        return results;
      }
      
      // Step 2: Get test data
      results['testData'] = await _getTestData();
      
      if (!results['testData']['success']) {
        AppLogger.error('❌ Cannot proceed without test data');
        return results;
      }
      
      final testData = results['testData']['data'];
      
      // Step 3: Test fare calculation (prerequisite for booking)
      results['fareCalculation'] = await _testFareCalculation(testData);
      
      // Step 4: Count tickets before booking
      results['ticketsBeforeBooking'] = await _countUserTickets();
      
      // Step 5: Attempt ticket booking
      results['ticketBooking'] = await _testTicketBooking(testData);
      
      // Step 6: Count tickets after booking
      results['ticketsAfterBooking'] = await _countUserTickets();
      
      // Step 7: Verify ticket was stored
      results['ticketVerification'] = await _verifyTicketStorage(results);
      
      // Step 8: Test ticket retrieval
      results['ticketRetrieval'] = await _testTicketRetrieval();
      
      // Generate diagnostic summary
      results['summary'] = _generateDiagnosticSummary(results);
      
      AppLogger.info('🎉 Ticket booking diagnostic completed');
      return results;
      
    } catch (e) {
      AppLogger.error('❌ Ticket booking diagnostic failed: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Test authentication
  Future<Map<String, dynamic>> _testAuthentication() async {
    try {
      AppLogger.info('🔐 Testing authentication...');
      
      final loginData = {
        'username': 'user',
        'password': 'user123',
      };
      
      final response = await _apiService.post(ApiConstants.login, data: loginData);
      
      if (response.statusCode == 200 && response.data['data']?['token'] != null) {
        AppLogger.info('✅ Authentication successful');
        return {
          'success': true,
          'token': response.data['data']['token'],
          'userId': response.data['data']['user']['id'],
        };
      } else {
        AppLogger.error('❌ Authentication failed');
        return {
          'success': false,
          'error': 'Authentication failed',
        };
      }
    } catch (e) {
      AppLogger.error('❌ Authentication error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get test data for booking
  Future<Map<String, dynamic>> _getTestData() async {
    try {
      AppLogger.info('📋 Getting test data...');
      
      // Get active routes
      final routesResponse = await _apiService.get(ApiConstants.activeRoutes);
      final routes = routesResponse.data['data'] as List;
      
      if (routes.isEmpty) {
        return {
          'success': false,
          'error': 'No active routes found',
        };
      }
      
      final testRoute = routes.first;
      
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
      
      // Get route stations
      final stationsResponse = await _apiService.get('/routes/${testRoute['id']}/stations/active');
      final stations = stationsResponse.data['data'] as List;
      
      if (stations.length < 2) {
        return {
          'success': false,
          'error': 'Not enough stations for booking',
        };
      }
      
      AppLogger.info('✅ Test data retrieved');
      AppLogger.info('   Route: ${testRoute['route_name']}');
      AppLogger.info('   Bus: ${testBus['bus_number']}');
      AppLogger.info('   Stations: ${stations.length} available');
      
      return {
        'success': true,
        'data': {
          'route': testRoute,
          'bus': testBus,
          'stations': stations,
        },
      };
      
    } catch (e) {
      AppLogger.error('❌ Failed to get test data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test fare calculation
  Future<Map<String, dynamic>> _testFareCalculation(Map<String, dynamic> testData) async {
    try {
      AppLogger.info('💰 Testing fare calculation...');
      
      final stations = testData['stations'] as List;
      final fareRequest = {
        'bus_id': testData['bus']['id'],
        'route_id': testData['route']['id'],
        'boarding_station_id': stations.first['station']['id'],
        'destination_station_id': stations.last['station']['id'],
        'ticket_type': 'single',
        'travel_date': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };
      
      final response = await _apiService.post(ApiConstants.calculateFare, data: fareRequest);
      final fareData = response.data['data'];
      
      AppLogger.info('✅ Fare calculation successful');
      AppLogger.info('   Final amount: ₹${fareData['final_amount']}');
      
      return {
        'success': true,
        'fareData': fareData,
        'fareRequest': fareRequest,
      };
      
    } catch (e) {
      AppLogger.error('❌ Fare calculation failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Count user tickets
  Future<Map<String, dynamic>> _countUserTickets() async {
    try {
      final response = await _apiService.get(ApiConstants.myTickets);
      final tickets = response.data['data'] as List;
      
      return {
        'success': true,
        'count': tickets.length,
        'tickets': tickets,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'count': 0,
      };
    }
  }

  /// Test ticket booking
  Future<Map<String, dynamic>> _testTicketBooking(Map<String, dynamic> testData) async {
    try {
      AppLogger.info('🎫 Testing ticket booking...');
      
      final stations = testData['stations'] as List;
      final bookingRequest = {
        'bus_id': testData['bus']['id'],
        'route_id': testData['route']['id'],
        'boarding_station_id': stations.first['station']['id'],
        'destination_station_id': stations.last['station']['id'],
        'ticket_type': 'single',
        'travel_date': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'payment_mode': 'upi',
        'payment_method': 'app_booking',
      };
      
      AppLogger.info('📤 Sending booking request...');
      AppLogger.info('   Request data: $bookingRequest');
      
      final response = await _apiService.post(ApiConstants.bookTicket, data: bookingRequest);
      
      AppLogger.info('📥 Booking response received');
      AppLogger.info('   Status: ${response.statusCode}');
      AppLogger.info('   Response: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ticketData = response.data['data'];
        
        AppLogger.info('✅ Ticket booking successful');
        AppLogger.info('   Ticket ID: ${ticketData['id']}');
        AppLogger.info('   Ticket Number: ${ticketData['ticket_number']}');
        AppLogger.info('   Status: ${ticketData['status']}');
        
        return {
          'success': true,
          'ticketData': ticketData,
          'ticketId': ticketData['id'],
          'ticketNumber': ticketData['ticket_number'],
        };
      } else {
        AppLogger.error('❌ Booking failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Booking failed with status ${response.statusCode}',
          'response': response.data,
        };
      }
      
    } catch (e) {
      AppLogger.error('❌ Ticket booking failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify ticket was stored in database
  Future<Map<String, dynamic>> _verifyTicketStorage(Map<String, dynamic> results) async {
    try {
      AppLogger.info('🔍 Verifying ticket storage...');
      
      final beforeCount = results['ticketsBeforeBooking']['count'] ?? 0;
      final afterCount = results['ticketsAfterBooking']['count'] ?? 0;
      final bookingSuccess = results['ticketBooking']['success'] ?? false;
      
      AppLogger.info('   Tickets before: $beforeCount');
      AppLogger.info('   Tickets after: $afterCount');
      AppLogger.info('   Booking success: $bookingSuccess');
      
      if (bookingSuccess && afterCount > beforeCount) {
        AppLogger.info('✅ Ticket successfully stored in database');
        return {
          'success': true,
          'ticketsAdded': afterCount - beforeCount,
          'message': 'Ticket stored successfully',
        };
      } else if (bookingSuccess && afterCount == beforeCount) {
        AppLogger.error('❌ Booking succeeded but ticket not found in database');
        return {
          'success': false,
          'error': 'Ticket booking succeeded but not stored in database',
          'ticketsAdded': 0,
        };
      } else if (!bookingSuccess) {
        AppLogger.error('❌ Booking failed, no ticket to verify');
        return {
          'success': false,
          'error': 'Booking failed, cannot verify storage',
          'ticketsAdded': 0,
        };
      } else {
        AppLogger.warning('⚠️ Unexpected state in ticket verification');
        return {
          'success': false,
          'error': 'Unexpected verification state',
          'ticketsAdded': afterCount - beforeCount,
        };
      }
      
    } catch (e) {
      AppLogger.error('❌ Ticket verification failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test ticket retrieval
  Future<Map<String, dynamic>> _testTicketRetrieval() async {
    try {
      AppLogger.info('📋 Testing ticket retrieval...');
      
      final response = await _apiService.get(ApiConstants.myTickets);
      final tickets = response.data['data'] as List;
      
      AppLogger.info('✅ Ticket retrieval successful');
      AppLogger.info('   Total tickets: ${tickets.length}');
      
      if (tickets.isNotEmpty) {
        final latestTicket = tickets.first;
        AppLogger.info('   Latest ticket: ${latestTicket['ticket_number']} (${latestTicket['status']})');
      }
      
      return {
        'success': true,
        'ticketCount': tickets.length,
        'tickets': tickets.take(3).toList(), // Sample tickets
      };
      
    } catch (e) {
      AppLogger.error('❌ Ticket retrieval failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generate diagnostic summary
  Map<String, dynamic> _generateDiagnosticSummary(Map<String, dynamic> results) {
    final issues = <String>[];
    final successes = <String>[];
    
    // Check authentication
    if (results['authentication']?['success'] == true) {
      successes.add('✅ Authentication working');
    } else {
      issues.add('❌ Authentication failing');
    }
    
    // Check fare calculation
    if (results['fareCalculation']?['success'] == true) {
      successes.add('✅ Fare calculation working');
    } else {
      issues.add('❌ Fare calculation failing');
    }
    
    // Check booking
    if (results['ticketBooking']?['success'] == true) {
      successes.add('✅ Ticket booking API working');
    } else {
      issues.add('❌ Ticket booking API failing');
    }
    
    // Check storage
    if (results['ticketVerification']?['success'] == true) {
      successes.add('✅ Ticket storage working');
    } else {
      issues.add('❌ Ticket not being stored in database - THIS IS THE MAIN ISSUE');
    }
    
    // Check retrieval
    if (results['ticketRetrieval']?['success'] == true) {
      successes.add('✅ Ticket retrieval working');
    } else {
      issues.add('❌ Ticket retrieval failing');
    }
    
    final mainIssueFound = results['ticketBooking']?['success'] == true && 
                          results['ticketVerification']?['success'] != true;
    
    return {
      'issues': issues,
      'successes': successes,
      'mainIssueFound': mainIssueFound,
      'diagnosis': mainIssueFound 
          ? 'Ticket booking API works but tickets are not being stored in database'
          : 'Multiple issues found, check individual test results',
      'recommendation': mainIssueFound
          ? 'Check backend ticket booking logic - API returns success but database transaction may be failing'
          : 'Fix the failing components first',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}