import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/logger.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationState {
  final Position? currentPosition;
  final bool isLoading;
  final String? error;
  final bool hasPermission;
  final bool isServiceEnabled;

  LocationState({
    this.currentPosition,
    this.isLoading = false,
    this.error,
    this.hasPermission = false,
    this.isServiceEnabled = false,
  });

  LocationState copyWith({
    Position? currentPosition,
    bool? isLoading,
    String? error,
    bool? hasPermission,
    bool? isServiceEnabled,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          isServiceEnabled: false,
          error: 'Location services are disabled. Please enable location services.',
        );
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            hasPermission: false,
            error: 'Location permissions are denied. Please grant location permission.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          hasPermission: false,
          error: 'Location permissions are permanently denied. Please enable them in settings.',
        );
        return;
      }

      // Get current position
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        state = state.copyWith(
          currentPosition: position,
          isLoading: false,
          hasPermission: true,
          isServiceEnabled: true,
        );
        AppLogger.info('Location updated: ${position.latitude}, ${position.longitude}');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get current location. Please try again.',
        );
      }
    } catch (e) {
      AppLogger.error('Error getting location: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Error getting location: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  double? calculateDistanceToStation(double stationLat, double stationLng) {
    if (state.currentPosition == null) return null;
    
    return LocationService.calculateDistance(
      state.currentPosition!.latitude,
      state.currentPosition!.longitude,
      stationLat,
      stationLng,
    );
  }
}