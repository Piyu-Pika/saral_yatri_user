import 'package:dev_log/dev_log.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import 'auth_check_service.dart';

class DataResolutionService {
  // Cache to avoid repeated API calls
  static final Map<String, String> _stationCache = {};
  static final Map<String, String> _busCache = {};
  static final Map<String, String> _routeCache = {};

  /// Get station name by station ID
  static Future<String> getStationName(String stationId) async {
    if (stationId.isEmpty) return 'Unknown Station';

    // Check cache first
    if (_stationCache.containsKey(stationId)) {
      return _stationCache[stationId]!;
    }

    dynamic lastError;
    try {
      Log.i('Fetching station name for ID: $stationId');
      final response =
          await ApiClient.get('${ApiConstants.stationById}/$stationId');

      if (response.statusCode == 200) {
        final stationData =
            response.data['data'] ?? response.data['station'] ?? response.data;
        final stationName = stationData['name'] ??
            stationData['station_name'] ??
            'Station $stationId';

        // Cache the result
        _stationCache[stationId] = stationName;
        Log.i('Station name resolved: $stationId -> $stationName');
        return stationName;
      }
    } catch (e) {
      lastError = e;
      Log.w('Failed to fetch station name for $stationId: $e');
    }

    // Fallback to station ID with auth-aware message
    final fallback = _isAuthError(lastError?.toString() ?? '')
        ? _handleAuthError('Station', stationId)
        : 'Station $stationId';
    _stationCache[stationId] = fallback;
    return fallback;
  }

  /// Get bus number by bus ID
  static Future<String> getBusNumber(String busId) async {
    if (busId.isEmpty) return 'Unknown Bus';

    // Check cache first
    if (_busCache.containsKey(busId)) {
      return _busCache[busId]!;
    }

    try {
      Log.i('Fetching bus number for ID: $busId');

      // Try individual bus endpoint first
      try {
        final response = await ApiClient.get('${ApiConstants.busById}/$busId');

        if (response.statusCode == 200) {
          final busData =
              response.data['data'] ?? response.data['bus'] ?? response.data;
          final busNumber = busData['bus_number'] ??
              busData['number'] ??
              busData['registration_number'] ??
              'Bus $busId';

          // Cache the result
          _busCache[busId] = busNumber;
          Log.i('Bus number resolved: $busId -> $busNumber');
          return busNumber;
        }
      } catch (individualError) {
        Log.w(
            'Individual bus endpoint failed, trying active buses list: $individualError');

        // If individual endpoint fails (like 401), try to get from active buses list
        final activeBusesResponse =
            await ApiClient.get(ApiConstants.activeBuses);

        if (activeBusesResponse.statusCode == 200) {
          final responseData = activeBusesResponse.data;
          final busList = responseData['data'] ?? [];

          // Find the bus with matching ID
          for (final bus in busList) {
            if (bus['id'] == busId) {
              final busNumber = bus['bus_number'] ??
                  bus['registration_number'] ??
                  'Bus $busId';

              // Cache the result
              _busCache[busId] = busNumber;
              Log.i(
                  'Bus number resolved from active buses: $busId -> $busNumber');
              return busNumber;
            }
          }

          Log.w('Bus ID $busId not found in active buses list');
        }
      }
    } catch (e) {
      Log.w('Failed to fetch bus number for $busId: $e');

      // Handle authentication errors specifically
      if (e.toString().contains('401') ||
          e.toString().contains('unauthorized')) {
        Log.w(
            'Authentication error when fetching bus data - user may need to log in');
      }
    }

    // Fallback to bus ID
    final fallback = 'Bus $busId';
    _busCache[busId] = fallback;
    return fallback;
  }

  /// Get route name by route ID
  static Future<String> getRouteName(String routeId) async {
    if (routeId.isEmpty) return 'Unknown Route';

    // Check cache first
    if (_routeCache.containsKey(routeId)) {
      return _routeCache[routeId]!;
    }

    dynamic lastError;
    try {
      Log.i('Fetching route name for ID: $routeId');
      final response =
          await ApiClient.get('${ApiConstants.routeById}/$routeId');

      if (response.statusCode == 200) {
        final routeData =
            response.data['data'] ?? response.data['route'] ?? response.data;
        final routeName =
            routeData['name'] ?? routeData['route_name'] ?? 'Route $routeId';

        // Cache the result
        _routeCache[routeId] = routeName;
        Log.i('Route name resolved: $routeId -> $routeName');
        return routeName;
      }
    } catch (e) {
      lastError = e;
      Log.w('Failed to fetch route name for $routeId: $e');
    }

    // Fallback to route ID with auth-aware message
    final fallback = _isAuthError(lastError?.toString() ?? '')
        ? _handleAuthError('Route', routeId)
        : 'Route $routeId';
    _routeCache[routeId] = fallback;
    return fallback;
  }

  /// Resolve all ticket data (station names, bus number, route name) in parallel
  static Future<Map<String, String>> resolveTicketData({
    required String boardingStationId,
    required String destinationStationId,
    required String busId,
    required String routeId,
  }) async {
    try {
      Log.i(
          'Resolving ticket data for stations: $boardingStationId, $destinationStationId, bus: $busId, route: $routeId');

      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        getStationName(boardingStationId),
        getStationName(destinationStationId),
        getBusNumber(busId),
        getRouteName(routeId),
      ]);

      return {
        'boardingStation': results[0],
        'destinationStation': results[1],
        'busNumber': results[2],
        'routeName': results[3],
      };
    } catch (e) {
      Log.e('Failed to resolve ticket data: $e');
      return {
        'boardingStation': 'Station $boardingStationId',
        'destinationStation': 'Station $destinationStationId',
        'busNumber': 'Bus $busId',
        'routeName': 'Route $routeId',
      };
    }
  }

  /// Batch resolve multiple station IDs
  static Future<Map<String, String>> batchResolveStations(
      List<String> stationIds) async {
    final results = <String, String>{};

    // Filter out already cached stations
    final uncachedIds =
        stationIds.where((id) => !_stationCache.containsKey(id)).toList();

    if (uncachedIds.isEmpty) {
      // All stations are cached
      for (final id in stationIds) {
        results[id] = _stationCache[id]!;
      }
      return results;
    }

    try {
      // Fetch uncached stations in parallel
      final futures = uncachedIds.map((id) => getStationName(id)).toList();
      await Future.wait(futures);

      // Combine cached and newly fetched results
      for (final id in stationIds) {
        if (_stationCache.containsKey(id)) {
          results[id] = _stationCache[id]!;
        }
      }

      return results;
    } catch (e) {
      Log.e('Failed to batch resolve stations: $e');
      // Return fallback names
      for (final id in stationIds) {
        results[id] = _stationCache[id] ?? 'Station $id';
      }
      return results;
    }
  }

  /// Clear all caches (useful for testing or when data might be stale)
  static void clearCache() {
    _stationCache.clear();
    _busCache.clear();
    _routeCache.clear();
    Log.i('Data resolution cache cleared');
  }

  /// Get cache statistics
  static Map<String, int> getCacheStats() {
    return {
      'stations': _stationCache.length,
      'buses': _busCache.length,
      'routes': _routeCache.length,
    };
  }

  /// Check if the error is an authentication error
  static bool _isAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('authentication');
  }

  /// Handle authentication errors by providing user-friendly messages
  static String _handleAuthError(String resourceType, String resourceId) {
    Log.w('Authentication required to fetch $resourceType data');
    return '$resourceType $resourceId (Login Required)';
  }

  /// Batch resolve bus numbers from active buses list (fallback method)
  static Future<Map<String, String>> batchResolveBusesFromActiveList(
      List<String> busIds) async {
    final results = <String, String>{};

    try {
      Log.i(
          'Batch resolving ${busIds.length} bus numbers from active buses list');

      final response = await ApiClient.get(ApiConstants.activeBuses);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final busList = responseData['data'] ?? [];

        // Create a map for quick lookup
        final busMap = <String, String>{};
        for (final bus in busList) {
          final id = bus['id'] as String?;
          final number = bus['bus_number'] ?? bus['registration_number'];
          if (id != null && number != null) {
            busMap[id] = number;
          }
        }

        // Resolve requested bus IDs
        for (final busId in busIds) {
          if (busMap.containsKey(busId)) {
            results[busId] = busMap[busId]!;
            _busCache[busId] = busMap[busId]!; // Cache the result
          } else {
            results[busId] = 'Bus $busId';
          }
        }

        Log.i('Batch resolved ${results.length} bus numbers');
      }
    } catch (e) {
      Log.e('Failed to batch resolve buses from active list: $e');

      // Fallback to bus IDs
      for (final busId in busIds) {
        results[busId] =
            _isAuthError(e) ? _handleAuthError('Bus', busId) : 'Bus $busId';
      }
    }

    return results;
  }
}
