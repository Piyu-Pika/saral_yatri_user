import 'package:dio/dio.dart';
import '../../data/models/station_model.dart';
// import '../models/station_model.dart';
import 'api_client.dart';

class StationService {
  final ApiClient _apiClient;

  StationService(this._apiClient);

  Future<List<StationModel>> getActiveStations() async {
    try {
      final response = await _apiClient.dio.get('/stations/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => StationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StationModel> getStationById(String id) async {
    try {
      final response = await _apiClient.dio.get('/stations/$id');
      return StationModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<StationModel>> searchStations(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '/stations/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => StationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<StationModel>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/stations/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => StationModel.fromJson(json)).toList();
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

// [GIN] 2025/10/19 - 15:44:38 | 404 |        3.12µs |    49.36.183.57 | GET      ""
