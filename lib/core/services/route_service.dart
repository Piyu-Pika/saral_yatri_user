import 'package:dio/dio.dart';
import '../../data/models/route_model.dart';
// import '../models/route_model.dart';
import 'api_client.dart';

class RouteService {
  final ApiClient _apiClient;

  RouteService(this._apiClient);

  Future<List<Route>> getActiveRoutes() async {
    try {
      final response = await _apiClient.dio.get('/routes/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Route.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Route> getRouteById(String id) async {
    try {
      final response = await _apiClient.dio.get('/routes/$id');
      return Route.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Route>> getRoutesByStations({
    required String startStationId,
    required String endStationId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/routes',
        queryParameters: {
          'start_station_id': startStationId,
          'end_station_id': endStationId,
        },
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Route.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getFareInformation({
    required String routeId,
    required String fromStationId,
    required String toStationId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/routes/fare',
        queryParameters: {
          'route_id': routeId,
          'from_station_id': fromStationId,
          'to_station_id': toStationId,
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'An error occurred';
    } else {
      return 'Network error. Please check your connection.';
    }
  }
}
