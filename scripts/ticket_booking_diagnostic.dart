#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Focused diagnostic for ticket booking storage issues
/// This specifically tests why tickets booked through the app don't store in database
void main() async {
  print('🎫 Ticket Booking Storage Diagnostic');
  print('====================================');
  
  final diagnostic = TicketBookingStorageDiagnostic();
  await diagnostic.runDiagnostic();
}

class TicketBookingStorageDiagnostic {
  static const String baseUrl = 'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1';
  late Dio dio;
  String? authToken;
  
  TicketBookingStorageDiagnostic() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<void> runDiagnostic() async {
    try {
      print('🔍 Starting focused ticket booking diagnostic...\n');
      
      // Step 1: Authenticate
      await _authenticate();
      if (authToken == null) {
        print('❌ Cannot proceed without authentication');
        return;
      }
      
      // Step 2: Get test data
      final testData = await _getTestData();
      if (testData == null) {
        print('❌ Cannot proceed without test data');
        return;
      }
      
      // Step 3: Count tickets before booking
      final ticketsBefore = await _countUserTickets();
      print('📊 Tickets before booking: $ticketsBefore');
      
      // Step 4: Test fare calculation
      final fareData = await _testFareCalculation(testData);
      if (fareData == null) {
        print('❌ Cannot proceed without fare calculation');
        return;
      }
      
      // Step 5: Attempt booking
      print('\n🎫 ATTEMPTING TICKET BOOKING...');
      print('=' * 40);
      
      final bookingResult = await _attemptBooking(testData);
      
      // Step 6: Count tickets after booking
      await Future.delayed(const Duration(seconds: 2)); // Wait for DB sync
      final ticketsAfter = await _countUserTickets();
      print('📊 Tickets after booking: $ticketsAfter');
      
      // Step 7: Analyze results
      _analyzeResults(ticketsBefore, ticketsAfter, bookingResult);
      
    } catch (e) {
      print('❌ Diagnostic failed: $e');
    }
  }

  Future<void> _authenticate() async {
    try {
      print('🔐 Authenticating with user/user123...');
      
      final loginData = {
        'username': 'user',
        'password': 'user123',
      };
      
      final response = await dio.post('/auth/login', data: loginData);
      
      if (response.statusCode == 200 && response.data['data']?['token'] != null) {
        authToken = response.data['data']['token'];
        dio.options.headers['Authorization'] = 'Bearer $authToken';
        print('✅ Authentication successful');
        print('   User: ${response.data['data']['user']['username']}');
      } else {
        print('❌ Authentication failed');
      }
    } catch (e) {
      print('❌ Authentication error: $e');
    }
  }

  Future<Map<String, dynamic>?> _getTestData() async {
    try {
      print('\n📋 Getting test data...');
      
      // Get routes and buses
      final routesResponse = await dio.get('/routes/active');
      final routes = routesResponse.data['data'] as List;
      
      final busesResponse = await dio.get('/buses/active');
      final buses = busesResponse.data['data'] as List;
      
      if (routes.isEmpty || buses.isEmpty) {
        print('❌ No active routes or buses found');
        return null;
      }
      
      final testRoute = routes.first;
      final testBus = buses.first;
      
      // Get route stations
      final stationsResponse = await dio.get('/routes/${testRoute['id']}/stations/active');
      final stations = stationsResponse.data['data'] as List;
      
      if (stations.length < 2) {
        print('❌ Not enough stations for booking');
        return null;
      }
      
      print('✅ Test data ready:');
      print('   Route: ${testRoute['route_name']}');
      print('   Bus: ${testBus['bus_number']}');
      print('   Stations: ${stations.length} available');
      
      return {
        'route': testRoute,
        'bus': testBus,
        'stations': stations,
      };
      
    } catch (e) {
      print('❌ Failed to get test data: $e');
      return null;
    }
  }

  Future<int> _countUserTickets() async {
    try {
      final response = await dio.get('/tickets/passenger/my-tickets');
      final tickets = response.data['data'] as List;
      return tickets.length;
    } catch (e) {
      print('⚠️ Could not count tickets: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> _testFareCalculation(Map<String, dynamic> testData) async {
    try {
      print('\n💰 Testing fare calculation...');
      
      final stations = testData['stations'] as List;
      final fareRequest = {
        'bus_id': testData['bus']['id'],
        'route_id': testData['route']['id'],
        'boarding_station_id': stations.first['station']['id'],
        'destination_station_id': stations.last['station']['id'],
        'ticket_type': 'single',
        'travel_date': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };
      
      final response = await dio.post('/tickets/calculate-fare', data: fareRequest);
      final fareData = response.data['data'];
      
      print('✅ Fare calculated: ₹${fareData['final_amount']}');
      return fareData;
      
    } catch (e) {
      print('❌ Fare calculation failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _attemptBooking(Map<String, dynamic> testData) async {
    try {
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
      
      print('📤 Sending booking request...');
      print('   From: ${stations.first['station']['station_name']}');
      print('   To: ${stations.last['station']['station_name']}');
      print('   Bus: ${testData['bus']['bus_number']}');
      print('   Payment: UPI (app_booking)');
      
      final response = await dio.post('/tickets/passenger/book', data: bookingRequest);
      
      print('\n📥 Booking response:');
      print('   Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final ticketData = response.data['data'];
        
        print('✅ BOOKING API SUCCESSFUL');
        print('   Ticket ID: ${ticketData['id']}');
        print('   Ticket Number: ${ticketData['ticket_number']}');
        print('   Status: ${ticketData['status']}');
        print('   Fare: ₹${ticketData['fare_details']['final_amount']}');
        
        return {
          'success': true,
          'ticketId': ticketData['id'],
          'ticketNumber': ticketData['ticket_number'],
          'ticketData': ticketData,
        };
      } else {
        print('❌ BOOKING API FAILED');
        print('   Status: ${response.statusCode}');
        print('   Response: ${response.data}');
        
        return {
          'success': false,
          'error': 'API returned status ${response.statusCode}',
          'response': response.data,
        };
      }
      
    } catch (e) {
      print('❌ BOOKING REQUEST FAILED');
      print('   Error: $e');
      
      if (e is DioException) {
        print('   Status: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
      }
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  void _analyzeResults(int ticketsBefore, int ticketsAfter, Map<String, dynamic> bookingResult) {
    print('\n🔍 ANALYSIS RESULTS');
    print('=' * 40);
    
    final bookingSuccess = bookingResult['success'] ?? false;
    final ticketsAdded = ticketsAfter - ticketsBefore;
    
    print('📊 Ticket Count Analysis:');
    print('   Before booking: $ticketsBefore');
    print('   After booking: $ticketsAfter');
    print('   Difference: $ticketsAdded');
    print('   Booking API success: $bookingSuccess');
    
    print('\n🎯 DIAGNOSIS:');
    
    if (bookingSuccess && ticketsAdded > 0) {
      print('✅ SUCCESS: Booking works correctly!');
      print('   - API booking successful');
      print('   - Ticket stored in database');
      print('   - Ticket appears in my-tickets');
      print('\n💡 The ticket booking system is working properly.');
      
    } else if (bookingSuccess && ticketsAdded == 0) {
      print('❌ CRITICAL ISSUE FOUND: Booking API succeeds but ticket not stored!');
      print('   - API returns success response');
      print('   - Ticket ID and number generated');
      print('   - BUT ticket not saved to database');
      print('   - OR not associated with user');
      print('\n🔧 BACKEND ISSUE IDENTIFIED:');
      print('   1. Check database transaction in booking endpoint');
      print('   2. Verify user-ticket association logic');
      print('   3. Check for database connection issues');
      print('   4. Verify ticket save operation completes');
      
    } else if (!bookingSuccess) {
      print('❌ BOOKING API FAILURE:');
      print('   - Booking request failed');
      print('   - Error: ${bookingResult['error']}');
      print('\n🔧 FIX BOOKING API FIRST:');
      print('   1. Check API endpoint implementation');
      print('   2. Verify request data format');
      print('   3. Check authentication and permissions');
      
    } else {
      print('⚠️ UNEXPECTED STATE:');
      print('   - Booking failed but tickets increased');
      print('   - This suggests a race condition or timing issue');
    }
    
    print('\n📋 RECOMMENDATIONS:');
    if (bookingSuccess && ticketsAdded == 0) {
      print('   🎯 PRIMARY ISSUE: Database storage problem');
      print('   1. Add logging to backend booking endpoint');
      print('   2. Check database transaction rollback');
      print('   3. Verify user ID in booking request');
      print('   4. Test booking endpoint directly with curl/Postman');
    } else if (!bookingSuccess) {
      print('   🎯 PRIMARY ISSUE: API endpoint problem');
      print('   1. Fix booking API endpoint first');
      print('   2. Then re-run this diagnostic');
    } else {
      print('   🎯 System appears to be working correctly');
      print('   1. Test with Flutter app to confirm');
    }
  }
}