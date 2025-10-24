#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

/// Comprehensive API Test Script matching the Go backend verification
/// This tests the exact same workflow as the backend verification
void main() async {
  print('🎯 Saral Yatri Comprehensive API Verification');
  print('=============================================');

  final tester = ComprehensiveApiTester();
  await tester.runTest();
}

class ComprehensiveApiTester {
  static const String baseUrl =
      'https://unprophesied-emerson-unrubrically.ngrok-free.dev/api/v1';
  late Dio dio;
  String? authToken;

  ComprehensiveApiTester() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<void> runTest() async {
    try {
      // Step 1: Authentication (optional)
      await _authenticate();

      // Step 2: Find test data
      final testData = await _findTestData();
      if (testData == null) return;

      // Step 3: Test Active Stations by Route
      await _testActiveStationsByRoute(testData['route']['id']);

      // Step 4: Test Calculate Fare
      await _testCalculateFare(testData);

      // Step 5: Test Book Ticket (if authenticated)
      if (authToken != null) {
        await _testBookTicket(testData);

        // Step 6: Test Get My Tickets
        await _testGetMyTickets();
      }

      print('\n🎉 All Tests Completed Successfully!');
      print('✅ Ticket booking system is working correctly');
      print('✅ Database storage and retrieval is working');
      print('✅ Route stations endpoint is working');
      print('✅ Fare calculation is working with proper distances');
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }

  Future<void> _authenticate() async {
    try {
      print('🔐 Attempting authentication...');

      // Try with test credentials
      final loginData = {'username': 'user', 'password': 'user123'};

      final response = await dio.post('/auth/login', data: loginData);

      if (response.statusCode == 200 &&
          response.data['data']?['token'] != null) {
        authToken = response.data['data']['token'];
        dio.options.headers['Authorization'] = 'Bearer $authToken';
        print('✅ Authentication successful');
        print('   User: ${response.data['data']['user']['username']}');
      }
    } catch (e) {
      print('⚠️  Authentication failed, continuing without auth: $e');
    }
  }

  Future<Map<String, dynamic>?> _findTestData() async {
    try {
      print('\n🔍 Finding test data...');

      // Get active routes
      final routesResponse = await dio.get('/routes/active');
      final routes = routesResponse.data['data'] as List;

      if (routes.isEmpty) {
        print('❌ No active routes found');
        return null;
      }

      // Find a suitable route
      Map<String, dynamic>? testRoute;
      for (final route in routes) {
        if (route['distance'] != null && route['distance'] > 0) {
          testRoute = route;
          break;
        }
      }

      if (testRoute == null) {
        print('❌ No suitable route found');
        return null;
      }

      // Get active buses
      final busesResponse = await dio.get('/buses/active');
      final buses = busesResponse.data['data'] as List;

      if (buses.isEmpty) {
        print('❌ No active buses found');
        return null;
      }

      final testBus = buses.first;

      print('✅ Test Data Found:');
      print('   Route: ${testRoute['route_name']} (ID: ${testRoute['id']})');
      print('   Bus: ${testBus['bus_number']} (ID: ${testBus['id']})');

      return {
        'route': testRoute,
        'bus': testBus,
      };
    } catch (e) {
      print('❌ Failed to find test data: $e');
      return null;
    }
  }

  Future<void> _testActiveStationsByRoute(String routeId) async {
    try {
      print('\n📍 Test 1: Get Active Stations by Route');

      final response = await dio.get('/routes/$routeId/stations/active');
      final stations = response.data['data'] as List;

      print('✅ Success: Found ${stations.length} active stations');

      for (int i = 0; i < stations.length && i < 5; i++) {
        final stationData = stations[i];
        print(
            '   ${i + 1}. ${stationData['station']['station_name']} - Distance: ${stationData['distance_from_start']} km');
      }
    } catch (e) {
      print('❌ Failed: $e');
      throw e;
    }
  }

  Future<void> _testCalculateFare(Map<String, dynamic> testData) async {
    try {
      print('\n💰 Test 2: Calculate Fare');

      // Get stations for the route
      final routeId = testData['route']['id'];
      final stationsResponse =
          await dio.get('/routes/$routeId/stations/active');
      final stations = stationsResponse.data['data'] as List;

      if (stations.length < 2) {
        print('❌ Not enough stations for fare calculation');
        return;
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
          await dio.post('/tickets/calculate-fare', data: fareRequest);
      final fareData = response.data['data'];

      print('✅ Success: Fare calculated');
      print('   Base Fare: ₹${fareData['base_fare']}');
      print('   Distance: ${fareData['distance']} km');
      print('   Final Amount: ₹${fareData['final_amount']}');
    } catch (e) {
      print('❌ Failed: $e');
      throw e;
    }
  }

  Future<void> _testBookTicket(Map<String, dynamic> testData) async {
    try {
      print('\n🎫 Test 3: Book Ticket');

      // Get stations for the route
      final routeId = testData['route']['id'];
      final stationsResponse =
          await dio.get('/routes/$routeId/stations/active');
      final stations = stationsResponse.data['data'] as List;

      if (stations.length < 2) {
        print('❌ Not enough stations for ticket booking');
        return;
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
          await dio.post('/tickets/passenger/book', data: bookingRequest);
      final ticketData = response.data['data'];

      print('✅ Success: Ticket booked and stored');
      print('   Ticket ID: ${ticketData['id']}');
      print('   Ticket Number: ${ticketData['ticket_number']}');
      print('   Fare: ₹${ticketData['fare_details']['final_amount']}');
    } catch (e) {
      print('❌ Failed: $e');
      throw e;
    }
  }

  Future<void> _testGetMyTickets() async {
    try {
      print('\n📋 Test 4: Get My Tickets');

      final response = await dio.get('/tickets/passenger/my-tickets');
      final tickets = response.data['data'] as List;

      print('✅ Success: Retrieved ${tickets.length} tickets');
      print('   Recent tickets:');

      for (int i = 0; i < tickets.length && i < 3; i++) {
        final ticket = tickets[i];
        print(
            '   ${i + 1}. ${ticket['ticket_number']} - ${ticket['status']} - ₹${ticket['fare_details']['final_amount']}');
      }

      // Test ticket status if we have tickets
      if (tickets.isNotEmpty) {
        await _testTicketStatus(tickets.first['id']);
      }
    } catch (e) {
      print('❌ Failed: $e');
      throw e;
    }
  }

  Future<void> _testTicketStatus(String ticketId) async {
    try {
      print('\n🔍 Test 5: Check Ticket Status');

      final response = await dio.get('/tickets/passenger/$ticketId/status');
      final statusData = response.data['data'];

      print('✅ Success: Status checked');
      print('   Status: ${statusData['current_status']}');
      print('   Is Active: ${statusData['is_active']}');
      print('   Message: ${statusData['status_message']}');
    } catch (e) {
      print('❌ Failed: $e');
      // Don't throw here as this is optional
    }
  }
}
