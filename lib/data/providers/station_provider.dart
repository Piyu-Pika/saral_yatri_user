import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final stationsData = response.data['data'] as List;
      final stations = stationsData.map((data) => StationModel.fromJson(data)).toList();

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
      final stationsData = response.data['data'] as List;
      final stations = stationsData.map((data) => StationModel.fromJson(data)).toList();

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
      final stationsData = response.data['data'] as List;
      final nearbyStations = stationsData
          .map((data) => StationModel.fromJson(data))
          .toList();

      state = state.copyWith(nearbyStations: nearbyStations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
