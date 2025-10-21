import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/route_model.dart';

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RouteNotifier(apiService);
});

class RouteState {
  final List<Route> routes;
  final Route? selectedRoute;
  final List<RouteStation> routeStations;
  final FareSegment? fareCalculation;
  final bool isLoading;
  final String? error;

  RouteState({
    this.routes = const [],
    this.selectedRoute,
    this.routeStations = const [],
    this.fareCalculation,
    this.isLoading = false,
    this.error,
  });

  RouteState copyWith({
    List<Route>? routes,
    Route? selectedRoute,
    List<RouteStation>? routeStations,
    FareSegment? fareCalculation,
    bool? isLoading,
    String? error,
  }) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedRoute: selectedRoute ?? this.selectedRoute,
      routeStations: routeStations ?? this.routeStations,
      fareCalculation: fareCalculation ?? this.fareCalculation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RouteNotifier extends StateNotifier<RouteState> {
  final ApiService _apiService;

  RouteNotifier(this._apiService) : super(RouteState());

  Future<void> loadActiveRoutes() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConstants.activeRoutes);
      final routesData = response.data['data'] as List;
      final routes = routesData.map((data) => Route.fromJson(data)).toList();

      state = state.copyWith(
        routes: routes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadRouteStations(String routeId) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.routeById}/$routeId');
      final routeData = response.data['data'];
      final route = Route.fromJson(routeData);

      state = state.copyWith(
        selectedRoute: route,
        routeStations: route.stations,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<double> calculateFare({
    required String fromStationId,
    required String toStationId,
    required String routeId,
  }) async {
    try {
      final response = await _apiService.post(ApiConstants.routeFare, data: {
        'from_station_id': fromStationId,
        'to_station_id': toStationId,
        'route_id': routeId,
      });

      final fareData = response.data['data'];
      final fare = FareSegment.fromJson(fareData);

      state = state.copyWith(fareCalculation: fare);

      return fare.baseFare;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
