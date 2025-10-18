import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../models/bus_model.dart';

final busProvider = StateNotifierProvider<BusNotifier, BusState>((ref) {
  return BusNotifier(
    ref.watch(apiServiceProvider),
  );
});

class BusState {
  final List<BusModel> buses;
  final BusModel? selectedBus;
  final bool isLoading;
  final String? error;

  BusState({
    this.buses = const [],
    this.selectedBus,
    this.isLoading = false,
    this.error,
  });

  BusState copyWith({
    List<BusModel>? buses,
    BusModel? selectedBus,
    bool? isLoading,
    String? error,
  }) {
    return BusState(
      buses: buses ?? this.buses,
      selectedBus: selectedBus ?? this.selectedBus,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BusNotifier extends StateNotifier<BusState> {
  final ApiService _apiService;

  BusNotifier(this._apiService) : super(BusState());

  Future<void> loadActiveBuses() async {
    state = state.copyWith(isLoading: true);

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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchBusByNumber(String busNumber) async {
    state = state.copyWith(isLoading: true);

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
    state = state.copyWith(isLoading: true);

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
        return bus;
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}
