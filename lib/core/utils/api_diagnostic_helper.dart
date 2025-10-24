import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../../data/models/station_model.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/ticket_model.dart';
import 'logger.dart';

/// API Diagnostic Helper for Flutter App
/// Helps identify and fix issues with:
/// 1. Active stations not showing according to route
/// 2. Fare calculation problems
/// 3. Ticket booking and storage issues
class ApiDiagnosticHelper {
  final ApiService _apiService;

  ApiDiagnosticHelper(this._apiService);

  /// Run comprehensive API diagnostics
  Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    AppLogger.info('🔍 Starting API Diagnostics...');

    try {
      // Test 1: Station APIs
      results['stations'] = await _testStationAPIs();

      // Test 2: Route APIs (Critical for station-route issue)
      results['routes'] = await _testRouteAPIs();

      // Test 3: Bus APIs
      results['buses'] = await _testBusAPIs();

      // Test 4: Fare Calculation (Critical for fare issue)
      results['fareCalculation'] = await _testFareCalculation();

      // Test 5: Ticket Operations (Critical for storage issue)
      results['tickets'] = await _testTicketOperations();

      // Generate summary
      results['summary'] = _generateSummary(results);

      AppLogger.info('✅ API Diagnostics completed');
      return results;
    } catch (e) {
      AppLogger.error('❌ API Diagnostics failed: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Test station-related APIs
  Future<Map<String, dynamic>> _testStationAPIs() async {
    final result = <String, dynamic>{};

    try {
      AppLogger.info('🚏 Testing Station APIs...');

      // Test active stations
      final activeStationsResponse =
          await _apiService.get(ApiConstants.activeStations);
      final stations = activeStationsResponse.data['data'] as List;

      result['activeStations'] = {
        'success': true,
        'count': stations.length,
        'data': stations.take(3).toList(), // Sample data
      };

      AppLogger.info('✅ Active stations: ${stations.length} found');

      if (stations.isNotEmpty) {
        // Test station by ID
        final stationId = stations.first['id'];
        try {
          final stationResponse =
              await _apiService.get('${ApiConstants.stationById}/$stationId');
          result['stationById'] = {
            'success': true,
            'stationId': stationId,
            'data': stationResponse.data['data'],
          };
          AppLogger.info('✅ Station by ID working');
        } catch (e) {
          result['stationById'] = {'success': false, 'error': e.toString()};
          AppLogger.error('❌ Station by ID failed: $e');
        }

        // Test station search
        try {
          final searchResponse =
              await _apiService.get('${ApiConstants.searchStations}?q=bus');
          final searchResults = searchResponse.data['data'] as List;
          result['stationSearch'] = {
            'success': true,
            'count': searchResults.length,
          };
          AppLogger.info('✅ Station search: ${searchResults.length} results');
        } catch (e) {
          result['stationSearch'] = {'success': false, 'error': e.toString()};
          AppLogger.error('❌ Station search failed: $e');
        }
      }
    } catch (e) {
      result['error'] = e.toString();
      AppLogger.error('❌ Station APIs failed: $e');
    }

    return result;
  }

  /// Test route-related APIs (Critical for station-route issue)
  Future<Map<String, dynamic>> _testRouteAPIs() async {
    final result = <String, dynamic>{};

    try {
      AppLogger.info(
          '🛣️ Testing Route APIs (Critical for station-route issue)...');

      // Test active routes
      final activeRoutesResponse =
          await _apiService.get(ApiConstants.activeRoutes);
      final routes = activeRoutesResponse.data['data'] as List;

      result['activeRoutes'] = {
        'success': true,
        'count': routes.length,
        'data': routes.take(3).toList(),
      };

      AppLogger.info('✅ Active routes: ${routes.length} found');

      if (routes.isNotEmpty) {
        final routeId = routes.first['id'];

        // Test route stations - THIS IS CRITICAL
        try {
          AppLogger.info('🔍 Testing route stations for route: $routeId');
          final routeStationsResponse = await _apiService.get(
              '${ApiConstants.routeActiveStations}/$routeId/stations/active');
          final routeStations = routeStationsResponse.data['data'] as List;

          result['routeStations'] = {
            'success': true,
            'routeId': routeId,
            'stationCount': routeStations.length,
            'stations': routeStations
                .map((s) => {
                      'id': s['id'],
                      'name': s['name'],
                      'sequence': s['sequence'],
                      'routeId': s['route_id'],
                    })
                .toList(),
          };

          AppLogger.info(
              '✅ Route stations: ${routeStations.length} stations found');

          // Analyze station-route relationships
          final stationsWithoutRoute =
              routeStations.where((s) => s['route_id'] != routeId).toList();
          if (stationsWithoutRoute.isNotEmpty) {
            result['routeStations']['warning'] =
                'Some stations have mismatched route_id';
            AppLogger.warning(
                '⚠️ Found ${stationsWithoutRoute.length} stations with mismatched route_id');
          }
        } catch (e) {
          result['routeStations'] = {'success': false, 'error': e.toString()};
          AppLogger.error(
              '❌ Route stations failed: $e - THIS IS LIKELY THE STATION-ROUTE ISSUE!');
        }

        // Test route fare
        try {
          final routeFareResponse = await _apiService
              .get('${ApiConstants.routeFare}?route_id=$routeId');
          result['routeFare'] = {
            'success': true,
            'data': routeFareResponse.data['data'],
          };
          AppLogger.info('✅ Route fare endpoint working');
        } catch (e) {
          result['routeFare'] = {'success': false, 'error': e.toString()};
          AppLogger.error('❌ Route fare failed: $e');
        }
      }
    } catch (e) {
      result['error'] = e.toString();
      AppLogger.error('❌ Route APIs failed: $e');
    }

    return result;
  }

  /// Test bus-related APIs
  Future<Map<String, dynamic>> _testBusAPIs() async {
    final result = <String, dynamic>{};

    try {
      AppLogger.info('🚌 Testing Bus APIs...');

      // Test active buses
      final activeBusesResponse =
          await _apiService.get(ApiConstants.activeBuses);
      final buses = activeBusesResponse.data['data'] as List;

      result['activeBuses'] = {
        'success': true,
        'count': buses.length,
        'data': buses.take(3).toList(),
      };

      AppLogger.info('✅ Active buses: ${buses.length} found');

      if (buses.isNotEmpty) {
        final bus = buses.first;
        final busNumber = bus['bus_number'];
        final routeId = bus['route_id'];

        // Test bus by number
        try {
          final busResponse = await _apiService
              .get('${ApiConstants.busById}?bus_number=$busNumber');
          result['busByNumber'] = {
            'success': true,
            'busNumber': busNumber,
            'data': busResponse.data['data'],
          };
          AppLogger.info('✅ Bus by number working');
        } catch (e) {
          result['busByNumber'] = {'success': false, 'error': e.toString()};
          AppLogger.error('❌ Bus by number failed: $e');
        }

        // Test buses by route
        try {
          final routeBusesResponse = await _apiService
              .get('${ApiConstants.busByRoute}?route_id=$routeId');
          final routeBuses = routeBusesResponse.data['data'] as List;
          result['busByRoute'] = {
            'success': true,
            'routeId': routeId,
            'busCount': routeBuses.length,
          };
          AppLogger.info('✅ Buses by route: ${routeBuses.length} buses');
        } catch (e) {
          result['busByRoute'] = {'success': false, 'error': e.toString()};
          AppLogger.error('❌ Buses by route failed: $e');
        }
      }
    } catch (e) {
      result['error'] = e.toString();
      AppLogger.error('❌ Bus APIs failed: $e');
    }

    return result;
  }

  /// Test fare calculation (Critical for fare issue)
  Future<Map<String, dynamic>> _testFareCalculation() async {
    final result = <String, dynamic>{};

    try {
      AppLogger.info(
          '💰 Testing Fare Calculation (Critical for fare issue)...');

      // Get sample stations
      final stationsResponse =
          await _apiService.get(ApiConstants.activeStations);
      final stations = stationsResponse.data['data'] as List;

      if (stations.length >= 2) {
        final fromStationId = stations[0]['id'];
        final toStationId = stations[1]['id'];

        final fareData = {
          'from_station_id': fromStationId,
          'to_station_id': toStationId,
          'passenger_type': 'general',
          'journey_date': DateTime.now().toIso8601String(),
        };

        try {
          final fareResponse = await _apiService
              .post(ApiConstants.calculateFare, data: fareData);
          final fareInfo = fareResponse.data['data'];

          result['fareCalculation'] = {
            'success': true,
            'fromStation': stations[0]['name'],
            'toStation': stations[1]['name'],
            'baseFare': fareInfo['base_fare'],
            'finalFare': fareInfo['final_fare'],
            'distance': fareInfo['distance'],
            'data': fareInfo,
          };

          AppLogger.info(
              '✅ Fare calculation successful: ₹${fareInfo['final_fare']}');
        } catch (e) {
          result['fareCalculation'] = {
            'success': false,
            'error': e.toString(),
            'fromStation': stations[0]['name'],
            'toStation': stations[1]['name'],
          };
          AppLogger.error(
              '❌ Fare calculation failed: $e - THIS IS THE FARE ISSUE!');
        }
      } else {
        result['fareCalculation'] = {
          'success': false,
          'error': 'Not enough stations for fare calculation',
        };
      }
    } catch (e) {
      result['error'] = e.toString();
      AppLogger.error('❌ Fare calculation test failed: $e');
    }

    return result;
  }

  /// Test ticket operations (Critical for storage issue)
  Future<Map<String, dynamic>> _testTicketOperations() async {
    final result = <String, dynamic>{};

    try {
      AppLogger.info(
          '🎫 Testing Ticket Operations (Critical for storage issue)...');

      // Test my tickets retrieval
      try {
        final myTicketsResponse = await _apiService.get(ApiConstants.myTickets);
        final tickets = myTicketsResponse.data['data'] as List;

        result['myTickets'] = {
          'success': true,
          'count': tickets.length,
          'tickets': tickets
              .take(3)
              .map((t) => {
                    'id': t['id'],
                    'status': t['status'],
                    'finalFare': t['final_fare'],
                    'createdAt': t['created_at'],
                  })
              .toList(),
        };

        AppLogger.info('✅ My tickets: ${tickets.length} found');

        // Test individual ticket details if tickets exist
        if (tickets.isNotEmpty) {
          final ticketId = tickets.first['id'];
          try {
            final ticketResponse = await _apiService
                .get('${ApiConstants.ticketDetails}/$ticketId');
            result['ticketDetails'] = {
              'success': true,
              'ticketId': ticketId,
              'data': ticketResponse.data['data'],
            };
            AppLogger.info('✅ Ticket details working');
          } catch (e) {
            result['ticketDetails'] = {'success': false, 'error': e.toString()};
            AppLogger.error('❌ Ticket details failed: $e');
          }
        }
      } catch (e) {
        result['myTickets'] = {'success': false, 'error': e.toString()};
        AppLogger.error(
            '❌ My tickets failed: $e - THIS COULD BE THE STORAGE ISSUE!');
      }

      // Note: We don't test actual booking here to avoid creating test tickets
      result['bookingNote'] =
          'Booking test skipped to avoid creating test data';
    } catch (e) {
      result['error'] = e.toString();
      AppLogger.error('❌ Ticket operations test failed: $e');
    }

    return result;
  }

  /// Generate diagnostic summary
  Map<String, dynamic> _generateSummary(Map<String, dynamic> results) {
    final issues = <String>[];
    final recommendations = <String>[];

    // Check for station-route issues
    if (results['routes']?['routeStations']?['success'] != true) {
      issues.add(
          'Route stations endpoint failing - Active stations not showing according to route');
      recommendations.add(
          'Fix /routes/{id}/stations endpoint and verify station-route relationships');
    }

    // Check for fare calculation issues
    if (results['fareCalculation']?['fareCalculation']?['success'] != true) {
      issues.add('Fare calculation failing - Unable to calculate ticket fare');
      recommendations.add(
          'Fix /tickets/calculate-fare endpoint and verify station distance data');
    }

    // Check for ticket storage issues
    if (results['tickets']?['myTickets']?['success'] != true) {
      issues.add(
          'Ticket retrieval failing - Tickets not stored/retrieved properly');
      recommendations.add(
          'Fix ticket booking flow and verify user-ticket associations in database');
    }

    return {
      'totalTests': _countTests(results),
      'passedTests': _countPassedTests(results),
      'issues': issues,
      'recommendations': recommendations,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  int _countTests(Map<String, dynamic> results) {
    int count = 0;
    for (final category in results.values) {
      if (category is Map<String, dynamic>) {
        count += category.keys.where((k) => k != 'error').length;
      }
    }
    return count;
  }

  int _countPassedTests(Map<String, dynamic> results) {
    int count = 0;
    for (final category in results.values) {
      if (category is Map<String, dynamic>) {
        for (final test in category.values) {
          if (test is Map<String, dynamic> && test['success'] == true) {
            count++;
          }
        }
      }
    }
    return count;
  }

  /// Quick fix attempts for common issues
  Future<Map<String, dynamic>> attemptQuickFixes() async {
    final fixes = <String, dynamic>{};

    AppLogger.info('🔧 Attempting quick fixes...');

    // Fix 1: Refresh station cache
    try {
      await _apiService.get(ApiConstants.activeStations);
      fixes['stationCacheRefresh'] = {'success': true};
      AppLogger.info('✅ Station cache refreshed');
    } catch (e) {
      fixes['stationCacheRefresh'] = {'success': false, 'error': e.toString()};
    }

    // Fix 2: Verify route-station relationships
    try {
      final routesResponse = await _apiService.get(ApiConstants.activeRoutes);
      final routes = routesResponse.data['data'] as List;

      int validRoutes = 0;
      for (final route in routes.take(3)) {
        // Test first 3 routes
        try {
          await _apiService
              .get('${ApiConstants.routeStations}/${route['id']}/stations');
          validRoutes++;
        } catch (e) {
          // Route station endpoint failed
        }
      }

      fixes['routeStationValidation'] = {
        'success': validRoutes > 0,
        'validRoutes': validRoutes,
        'totalTested': routes.length.clamp(0, 3),
      };
    } catch (e) {
      fixes['routeStationValidation'] = {
        'success': false,
        'error': e.toString()
      };
    }

    return fixes;
  }
}
