import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dev_log/dev_log.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/bus_stop_model.dart';
import '../../data/repositories/bus_repository.dart';

final busRepositoryProvider = Provider<BusRepository>((ref) => BusRepository());

final busProvider = StateNotifierProvider<BusNotifier, BusState>((ref) {
  return BusNotifier(ref.read(busRepositoryProvider));
});

class BusState {
  final List<BusModel> buses;
  final List<BusStopModel> busStops;
  final BusModel? selectedBus;
  final bool isLoading;
  final String? error;

  BusState({
    this.buses = const [],
    this.busStops = const [],
    this.selectedBus,
    this.isLoading = false,
    this.error,
  });

  BusState copyWith({
    List<BusModel>? buses,
    List<BusStopModel>? busStops,
    BusModel? selectedBus,
    bool? isLoading,
    String? error,
  }) {
    return BusState(
      buses: buses ?? this.buses,
      busStops: busStops ?? this.busStops,
      selectedBus: selectedBus ?? this.selectedBus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BusNotifier extends StateNotifier<BusState> {
  final BusRepository _busRepository;

  BusNotifier(this._busRepository) : super(BusState());

  Future<void> loadAllBuses() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final buses = await _busRepository.getAllBuses();
      state = state.copyWith(
        buses: buses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error loading buses: $e');
    }
  }

  Future<void> loadNearbyBuses(double latitude, double longitude) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final buses = await _busRepository.getNearbyBuses(latitude, longitude);
      state = state.copyWith(
        buses: buses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error loading nearby buses: $e');
    }
  }

  Future<void> loadBusStops() async {
    try {
      final busStops = await _busRepository.getAllBusStops();
      state = state.copyWith(busStops: busStops);
    } catch (e) {
      Log.e('Error loading bus stops: $e');
    }
  }

  Future<BusModel?> getBusByQrCode(String qrCode) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final bus = await _busRepository.getBusByQrCode(qrCode);
      state = state.copyWith(
        selectedBus: bus,
        isLoading: false,
      );
      return bus;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error getting bus by QR: $e');
      return null;
    }
  }

  Future<BusModel?> getBusByNumber(String busNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final bus = await _busRepository.getBusByNumber(busNumber);
      state = state.copyWith(
        selectedBus: bus,
        isLoading: false,
      );
      return bus;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error getting bus by number: $e');
      return null;
    }
  }

  void selectBus(BusModel bus) {
    state = state.copyWith(selectedBus: bus);
  }

  void clearSelectedBus() {
    state = state.copyWith(selectedBus: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}