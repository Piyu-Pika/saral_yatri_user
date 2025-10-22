import 'package:flutter_riverpod/legacy.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/logger.dart';
import '../models/bus_model.dart';
import '../models/bus_stop_model.dart';
import '../models/station_model.dart';

final busProvider = StateNotifierProvider<BusNotifier, BusState>((ref) {
  return BusNotifier(
    ref.watch(apiServiceProvider),
  );
});

class BusState {
  final List<BusModel> buses;
  final BusModel? selectedBus;
  final List<BusStopModel> busStops;
  final List<StationModel> routeStations;
  final bool isLoading;
  final bool isLoadingStations;
  final String? error;

  BusState({
    this.buses = const [],
    this.selectedBus,
    this.busStops = const [],
    this.routeStations = const [],
    this.isLoading = false,
    this.isLoadingStations = false,
    this.error,
  });

  BusState copyWith({
    List<BusModel>? buses,
    BusModel? selectedBus,
    List<BusStopModel>? busStops,
    List<StationModel>? routeStations,
    bool? isLoading,
    bool? isLoadingStations,
    String? error,
    bool clearError = false,
  }) {
    return BusState(
      buses: buses ?? this.buses,
      selectedBus: selectedBus ?? this.selectedBus,
      busStops: busStops ?? this.busStops,
      routeStations: routeStations ?? this.routeStations,
      isLoading: isLoading ?? this.isLoading,
      isLoadingStations: isLoadingStations ?? this.isLoadingStations,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BusNotifier extends StateNotifier<BusState> {
  final ApiService _apiService;

  BusNotifier(this._apiService) : super(BusState());

  Future<void> loadActiveBuses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await ApiClient.get(ApiConstants.activeBuses);
      final busesData = response.data['data'] as List;
      final buses = busesData.map((data) => BusModel.fromJson(data)).toList();

      state = state.copyWith(
        buses: buses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchBusByNumber(String busNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.get(
        '${ApiConstants.busById}?bus_number=$busNumber',
      );

      if (response.data['data'] != null) {
        final bus = BusModel.fromJson(response.data['data']);
        state = state.copyWith(
          selectedBus: bus,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          selectedBus: null,
          isLoading: false,
          error: 'Bus not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        selectedBus: null,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBusByRoute(String routeId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.get(
        '${ApiConstants.busByRoute}?route_id=$routeId',
      );
      final busesData = response.data['data'] as List;
      final buses = busesData.map((data) => BusModel.fromJson(data)).toList();

      state = state.copyWith(
        buses: buses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<BusModel?> getBusByQrCode(String qrCode) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.busByQrCode}?qr_code=$qrCode',
      );

      if (response.data['data'] != null) {
        final bus = BusModel.fromJson(response.data['data']);
        state = state.copyWith(selectedBus: bus);
        
        // Load route stations for the selected bus
        await loadRouteStations(bus.routeId);
        
        return bus;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> loadRouteStations(String routeId) async {
    if (routeId.isEmpty) {
      AppLogger.warning('Route ID is empty, cannot load stations');
      return;
    }

    state = state.copyWith(isLoadingStations: true, clearError: true);

    try {
      AppLogger.info('Loading stations for route: $routeId');
      
      final response = await _apiService.get(
        '${ApiConstants.routeActiveStations}/$routeId/stations/active',
      );

      AppLogger.info('Route stations API response: ${response.data}');

      if (response.data['data'] != null) {
        final stationsData = response.data['data'] as List;
        AppLogger.info('Raw stations data: $stationsData');
        
        final stations = <StationModel>[];
        for (var data in stationsData) {
          try {
            final station = StationModel.fromJson(data);
            stations.add(station);
            AppLogger.info('Parsed station: ID=${station.id}, Name="${station.name}", Code="${station.code}", Route="${station.routeId}"');
          } catch (e) {
            AppLogger.error('Failed to parse station data: $data, Error: $e');
          }
        }

        // Sort stations by sequence
        stations.sort((a, b) => a.sequence.compareTo(b.sequence));

        AppLogger.info('Successfully loaded ${stations.length} stations for route $routeId');

        state = state.copyWith(
          routeStations: stations,
          isLoadingStations: false,
        );
      } else {
        AppLogger.warning('No stations data found for route $routeId. Response: ${response.data}');
        state = state.copyWith(
          routeStations: [],
          isLoadingStations: false,
        );
      }
    } catch (e) {
      AppLogger.error('Failed to load route stations: $e');
      state = state.copyWith(
        isLoadingStations: false,
        error: 'Failed to load route stations: $e',
      );
    }
  }

  Future<BusModel?> getBusByNumber(String busNumber) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.busById}?bus_number=$busNumber',
      );

      if (response.data['data'] != null) {
        final bus = BusModel.fromJson(response.data['data']);
        state = state.copyWith(selectedBus: bus);
        
        // Load route stations for the selected bus
        await loadRouteStations(bus.routeId);
        
        return bus;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Alias for loadActiveBuses to maintain compatibility
  Future<void> loadAllBuses() async {
    await loadActiveBuses();
  }

  // Placeholder for bus stops - can be implemented later
  Future<void> loadBusStops() async {
    AppLogger.info('loadBusStops called - placeholder implementation');
    // TODO: Implement bus stops loading if needed
  }

  // Placeholder for nearby buses - can be implemented later
  Future<void> loadNearbyBuses(double latitude, double longitude) async {
    AppLogger.info('loadNearbyBuses called for location: $latitude, $longitude');
    // TODO: Implement nearby buses loading if needed
    // For now, just load all active buses
    await loadActiveBuses();
  }

  // Get station details by ID
  Future<StationModel?> getStationById(String stationId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.stationById}/$stationId',
      );

      if (response.data['data'] != null) {
        return StationModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Failed to get station by ID: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}
