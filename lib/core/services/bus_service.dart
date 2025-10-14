import 'package:dio/dio.dart';
import '../../data/models/bus_model.dart';
// import '../models/bus_model.dart';
import 'api_client.dart';

class BusService {
  final ApiClient _apiClient;

  BusService(this._apiClient);

  Future<List<BusModel>> getActiveBuses() async {
    try {
      final response = await _apiClient.dio.get('/buses/active');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BusModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BusModel> getBusById(String id) async {
    try {
      final response = await _apiClient.dio.get('/buses/$id');
      return BusModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<BusModel>> getBusesByRoute(String routeId) async {
    try {
      final response = await _apiClient.dio.get(
        '/buses',
        queryParameters: {'route_id': routeId},
      );
      final List<dynamic> data = response.data['data'];
      return data.map((json) => BusModel.fromJson(json)).toList();
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
