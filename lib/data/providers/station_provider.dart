import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';

final stationProvider = StateNotifierProvider<StationNotifier, StationState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return StationNotifier(apiService);
});

class StationState {
  final List<StationModel> stations;
  final List<StationModel> nearbyStations;
  final bool isLoading;
  final String? error;

  StationState({
    this.stations = const [],
    this.nearbyStations = const [],
    this.isLoading = false,
    this.error,
  });

  StationState copyWith({
    List<StationModel>? stations,
    List<StationModel>? nearbyStations,
    bool? isLoading,
    String? error,
  }) {
    return StationState(
      stations: stations ?? this.stations,
      nearbyStations: nearbyStations ?? this.nearbyStations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StationNotifier extends StateNotifier<StationState> {
  final ApiService _apiService;

  StationNotifier(this._apiService) : super(StationState());

  Future<void> loadActiveStations() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConstants.activeStations);
      
      // Handle both single station and list of stations response
      List<dynamic> stationsData;
      if (response.data['data'] is List) {
        stationsData = response.data['data'] as List;
      } else if (response.data['data'] is Map) {
        // If it's a single station, wrap it in a list
        stationsData = [response.data['data']];
      } else {
        stationsData = [];
      }
      
      final stations = <StationModel>[];
      for (int i = 0; i < stationsData.length; i++) {
        try {
          final stationData = stationsData[i];
          final station = StationModel.fromJson(stationData, sequence: i + 1);
          stations.add(station);
        } catch (e) {
          print('Error parsing station at index $i: $e');
        }
      }

      state = state.copyWith(
        stations: stations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchStations(String query) async {
    if (query.isEmpty) {
      await loadActiveStations();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(
        '${ApiConstants.searchStations}?q=$query',
      );
      
      // Handle both single station and list of stations response
      List<dynamic> stationsData;
      if (response.data['data'] is List) {
        stationsData = response.data['data'] as List;
      } else if (response.data['data'] is Map) {
        stationsData = [response.data['data']];
      } else {
        stationsData = [];
      }
      
      final stations = <StationModel>[];
      for (int i = 0; i < stationsData.length; i++) {
        try {
          final stationData = stationsData[i];
          final station = StationModel.fromJson(stationData, sequence: i + 1);
          stations.add(station);
        } catch (e) {
          print('Error parsing station at index $i: $e');
        }
      }

      state = state.copyWith(
        stations: stations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNearbyStations(double latitude, double longitude) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.nearbyStations}?lat=$latitude&lng=$longitude',
      );
      
      // Handle both single station and list of stations response
      List<dynamic> stationsData;
      if (response.data['data'] is List) {
        stationsData = response.data['data'] as List;
      } else if (response.data['data'] is Map) {
        stationsData = [response.data['data']];
      } else {
        stationsData = [];
      }
      
      final nearbyStations = <StationModel>[];
      for (int i = 0; i < stationsData.length; i++) {
        try {
          final stationData = stationsData[i];
          final station = StationModel.fromJson(stationData, sequence: i + 1);
          nearbyStations.add(station);
        } catch (e) {
          print('Error parsing nearby station at index $i: $e');
        }
      }

      state = state.copyWith(nearbyStations: nearbyStations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
