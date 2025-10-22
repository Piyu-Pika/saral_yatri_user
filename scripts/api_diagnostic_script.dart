import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Comprehensive API Diagnostic Script
/// Tests all endpoints and identifies issues with:
/// 1. Active stations not showing according to route
/// 2. Fare calculation problems
/// 3. Ticket booking and storage issues
class ApiDiagnosticScript {
  static const String baseUrl = 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1';
  late Dio dio;
  String? authToken;
  
  ApiDiagnosticScript() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Add interceptor for logging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  /// Main diagnostic function
  Future<void> runDiagnostics() async {
    print('🔍 Starting API Diagnostic Script...\n');
    
    try {
      // Step 1: Test Authentication
      await _testAuthentication();
      
      // Step 2: Test Station APIs
      await _testStationAPIs();
      
      // Step 3: Test Route APIs
      await _testRouteAPIs();
      
      // Step 4: Test Bus APIs
      await _testBusAPIs();
      
      // Step 5: Test Fare Calculation
      await _testFareCalculation();
      
      // Step 6: Test Ticket Booking
      await _testTicketBooking();
      
      // Step 7: Test Ticket Retrieval
      await _testTicketRetrieval();
      
      print('\n✅ Diagnostic completed successfully!');
      
    } catch (e) {
      print('❌ Diagnostic failed: $e');
    }
  }

  /// Test authentication endpoints
  Future<void> _testAuthentication() async {
    print('📱 Testing Authentication...');
    
    try {
      // Test login with sample credentials
      final loginData = {
        'username': 'user',
        'password': 'user123'
      };
      
      final response = await dio.post('/auth/login', data: loginData);
      
      if (response.statusCode == 200 && response.data['data']?['token'] != null) {
        authToken = response.data['data']['token'];
        dio.options.headers['Authorization'] = 'Bearer $authToken';
        print('✅ Authentication successful');
        print('   User: ${response.data['data']['user']['username']}');
        
        // Test profile endpoint
        final profileResponse = await dio.get('/auth/profile');
        if (profileResponse.statusCode == 200) {
          print('✅ Profile endpoint working');
          print('   User: ${profileResponse.data['data']['username']}');
        }
      } else {
        print('❌ Authentication failed: Invalid response');
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      print('⚠️  Continuing without authentication...');
    }
    print('');
  }

  /// Test station-related APIs
  Future<void> _testStationAPIs() async {
    print('🚏 Testing Station APIs...');
    
    try {
      // Test active stations
      final activeStationsResponse = await dio.get('/stations/active');
      if (activeStationsResponse.statusCode == 200) {
        final stations = activeStationsResponse.data['data'] as List;
        print('✅ Active stations: ${stations.length} found');
        
        if (stations.isNotEmpty) {
          final firstStation = stations.first;
          print('   Sample station: ${firstStation['name']} (ID: ${firstStation['id']})');
          
          // Test station by ID
          final stationId = firstStation['id'];
          final stationResponse = await dio.get('/stations/$stationId');
          if (stationResponse.statusCode == 200) {
            print('✅ Station by ID endpoint working');
          }
        }
      } else {
        print('❌ Active stations endpoint failed');
      }
      
      // Test station search
      final searchResponse = await dio.get('/stations/search?q=bus');
      if (searchResponse.statusCode == 200) {
        final searchResults = searchResponse.data['data'] as List;
        print('✅ Station search: ${searchResults.length} results for "bus"');
      }
      
      // Test nearby stations
      final nearbyResponse = await dio.get('/stations/nearby?lat=28.6139&lng=77.2090');
      if (nearbyResponse.statusCode == 200) {
        final nearbyStations = nearbyResponse.data['data'] as List;
        print('✅ Nearby stations: ${nearbyStations.length} found');
      }
      
    } catch (e) {
      print('❌ Station API error: $e');
    }
    print('');
  }

  /// Test route-related APIs
  Future<void> _testRouteAPIs() async {
    print('🛣️  Testing Route APIs...');
    
    try {
      // Test active routes
      final activeRoutesResponse = await dio.get('/routes/active');
      if (activeRoutesResponse.statusCode == 200) {
        final routes = activeRoutesResponse.data['data'] as List;
        print('✅ Active routes: ${routes.length} found');
        
        if (routes.isNotEmpty) {
          final firstRoute = routes.first;
          final routeId = firstRoute['id'];
          print('   Sample route: ${firstRoute['name']} (ID: $routeId)');
          
          // Test route by ID
          final routeResponse = await dio.get('/routes/$routeId');
          if (routeResponse.statusCode == 200) {
            print('✅ Route by ID endpoint working');
          }
          
          // Test route stations - THIS IS CRITICAL FOR THE ISSUE
          print('🔍 Testing route stations (Critical for active station issue)...');
          final routeStationsResponse = await dio.get('/routes/$routeId/stations');
          if (routeStationsResponse.statusCode == 200) {
            final routeStations = routeStationsResponse.data['data'] as List;
            print('✅ Route stations: ${routeStations.length} stations found for route $routeId');
            
            // Analyze station data structure
            if (routeStations.isNotEmpty) {
              final sampleStation = routeStations.first;
              print('   Sample station structure: ${sampleStation.keys.toList()}');
              print('   Station: ${sampleStation['name']} (Sequence: ${sampleStation['sequence'] ?? 'N/A'})');
            }
          } else {
            print('❌ Route stations endpoint failed - THIS COULD BE THE ISSUE!');
          }
        }
      } else {
        print('❌ Active routes endpoint failed');
      }
      
    } catch (e) {
      print('❌ Route API error: $e');
    }
    print('');
  }

  /// Test bus-related APIs
  Future<void> _testBusAPIs() async {
    print('🚌 Testing Bus APIs...');
    
    try {
      // Test active buses
      final activeBusesResponse = await dio.get('/buses/active');
      if (activeBusesResponse.statusCode == 200) {
        final buses = activeBusesResponse.data['data'] as List;
        print('✅ Active buses: ${buses.length} found');
        
        if (buses.isNotEmpty) {
          final firstBus = buses.first;
          print('   Sample bus: ${firstBus['bus_number']} (Route: ${firstBus['route_id']})');
          
          // Test bus by number
          final busNumber = firstBus['bus_number'];
          final busResponse = await dio.get('/buses?bus_number=$busNumber');
          if (busResponse.statusCode == 200) {
            print('✅ Bus by number endpoint working');
          }
          
          // Test buses by route
          final routeId = firstBus['route_id'];
          final routeBusesResponse = await dio.get('/buses?route_id=$routeId');
          if (routeBusesResponse.statusCode == 200) {
            final routeBuses = routeBusesResponse.data['data'] as List;
            print('✅ Buses by route: ${routeBuses.length} buses on route $routeId');
          }
        }
      } else {
        print('❌ Active buses endpoint failed');
      }
      
    } catch (e) {
      print('❌ Bus API error: $e');
    }
    print('');
  }

  /// Test fare calculation - CRITICAL FOR FARE ISSUE
  Future<void> _testFareCalculation() async {
    print('💰 Testing Fare Calculation (Critical for fare issue)...');
    
    try {
      // Get sample stations for fare calculation
      final stationsResponse = await dio.get('/stations/active');
      if (stationsResponse.statusCode == 200) {
        final stations = stationsResponse.data['data'] as List;
        
        if (stations.length >= 2) {
          final fromStation = stations[0]['id'];
          final toStation = stations[1]['id'];
          
          print('🔍 Testing fare calculation between stations...');
          print('   From: ${stations[0]['name']} (ID: $fromStation)');
          print('   To: ${stations[1]['name']} (ID: $toStation)');
          
          // Test fare calculation
          final fareData = {
            'from_station_id': fromStation,
            'to_station_id': toStation,
            'passenger_type': 'general',
            'journey_date': DateTime.now().toIso8601String(),
          };
          
          final fareResponse = await dio.post('/tickets/calculate-fare', data: fareData);
          if (fareResponse.statusCode == 200) {
            final fareInfo = fareResponse.data['data'];
            print('✅ Fare calculation successful');
            print('   Base fare: ₹${fareInfo['base_fare']}');
            print('   Final fare: ₹${fareInfo['final_fare']}');
            print('   Distance: ${fareInfo['distance']} km');
          } else {
            print('❌ Fare calculation failed - THIS IS THE FARE ISSUE!');
            print('   Response: ${fareResponse.data}');
          }
        } else {
          print('❌ Not enough stations for fare calculation test');
        }
      }
      
    } catch (e) {
      print('❌ Fare calculation error: $e');
      print('   This could be the root cause of fare calculation issues!');
    }
    print('');
  }

  /// Test ticket booking - CRITICAL FOR STORAGE ISSUE
  Future<void> _testTicketBooking() async {
    print('🎫 Testing Ticket Booking (Critical for storage issue)...');
    
    if (authToken == null) {
      print('⚠️  Skipping ticket booking test - no authentication token');
      return;
    }
    
    try {
      // Get sample data for booking
      final stationsResponse = await dio.get('/stations/active');
      final busesResponse = await dio.get('/buses/active');
      
      if (stationsResponse.statusCode == 200 && busesResponse.statusCode == 200) {
        final stations = stationsResponse.data['data'] as List;
        final buses = busesResponse.data['data'] as List;
        
        if (stations.length >= 2 && buses.isNotEmpty) {
          final bookingData = {
            'bus_id': buses.first['id'],
            'route_id': buses.first['route_id'],
            'from_station_id': stations[0]['id'],
            'to_station_id': stations[1]['id'],
            'passenger_type': 'general',
            'journey_date': DateTime.now().toIso8601String(),
            'passenger_count': 1,
          };
          
          print('🔍 Attempting ticket booking...');
          print('   Bus: ${buses.first['bus_number']}');
          print('   From: ${stations[0]['name']}');
          print('   To: ${stations[1]['name']}');
          
          final bookingResponse = await dio.post('/tickets/passenger/book', data: bookingData);
          if (bookingResponse.statusCode == 200 || bookingResponse.statusCode == 201) {
            final ticket = bookingResponse.data['data'];
            print('✅ Ticket booking successful');
            print('   Ticket ID: ${ticket['id']}');
            print('   Status: ${ticket['status']}');
            print('   Fare: ₹${ticket['final_fare']}');
            
            // Immediately test if ticket appears in my-tickets
            await Future.delayed(const Duration(seconds: 2));
            await _verifyTicketStorage(ticket['id']);
            
          } else {
            print('❌ Ticket booking failed - THIS IS THE STORAGE ISSUE!');
            print('   Response: ${bookingResponse.data}');
          }
        }
      }
      
    } catch (e) {
      print('❌ Ticket booking error: $e');
      print('   This could be the root cause of ticket storage issues!');
    }
    print('');
  }

  /// Verify ticket storage
  Future<void> _verifyTicketStorage(String ticketId) async {
    print('🔍 Verifying ticket storage...');
    
    try {
      // Test my-tickets endpoint
      final myTicketsResponse = await dio.get('/tickets/passenger/my-tickets');
      if (myTicketsResponse.statusCode == 200) {
        final tickets = myTicketsResponse.data['data'] as List;
        final foundTicket = tickets.any((ticket) => ticket['id'] == ticketId);
        
        if (foundTicket) {
          print('✅ Ticket found in my-tickets list');
        } else {
          print('❌ Ticket NOT found in my-tickets - STORAGE ISSUE CONFIRMED!');
          print('   Total tickets in list: ${tickets.length}');
        }
      }
      
      // Test individual ticket retrieval
      final ticketResponse = await dio.get('/tickets/passenger/$ticketId');
      if (ticketResponse.statusCode == 200) {
        print('✅ Individual ticket retrieval working');
      } else {
        print('❌ Individual ticket retrieval failed');
      }
      
    } catch (e) {
      print('❌ Ticket verification error: $e');
    }
  }

  /// Test ticket retrieval
  Future<void> _testTicketRetrieval() async {
    print('📋 Testing Ticket Retrieval...');
    
    if (authToken == null) {
      print('⚠️  Skipping ticket retrieval test - no authentication token');
      return;
    }
    
    try {
      final myTicketsResponse = await dio.get('/tickets/passenger/my-tickets');
      if (myTicketsResponse.statusCode == 200) {
        final tickets = myTicketsResponse.data['data'] as List;
        print('✅ My tickets endpoint working');
        print('   Total tickets: ${tickets.length}');
        
        if (tickets.isNotEmpty) {
          final sampleTicket = tickets.first;
          print('   Sample ticket: ${sampleTicket['id']} (Status: ${sampleTicket['status']})');
          
          // Test individual ticket details
          final ticketId = sampleTicket['id'];
          final ticketResponse = await dio.get('/tickets/passenger/$ticketId');
          if (ticketResponse.statusCode == 200) {
            print('✅ Individual ticket details working');
          }
        } else {
          print('⚠️  No tickets found - this might indicate the storage issue');
        }
      } else {
        print('❌ My tickets endpoint failed');
      }
      
    } catch (e) {
      print('❌ Ticket retrieval error: $e');
    }
    print('');
  }

  /// Generate diagnostic report
  void generateReport() {
    print('📊 DIAGNOSTIC REPORT');
    print('=' * 50);
    print('Issues Identified:');
    print('1. Route Stations: Check /routes/{id}/stations endpoint');
    print('2. Fare Calculation: Check /tickets/calculate-fare endpoint');
    print('3. Ticket Storage: Check ticket booking and retrieval flow');
    print('4. Authentication: Ensure proper token handling');
    print('');
    print('Recommended Actions:');
    print('- Verify route-station relationships in database');
    print('- Check fare calculation logic and station distance data');
    print('- Ensure ticket booking creates proper database entries');
    print('- Verify user-ticket associations');
  }
}

/// Main function to run the diagnostic
void main() async {
  final diagnostic = ApiDiagnosticScript();
  await diagnostic.runDiagnostics();
  diagnostic.generateReport();
}