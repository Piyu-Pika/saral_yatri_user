import 'package:dio/dio.dart';
import 'package:dev_log/dev_log.dart';
import '../models/bus_model.dart';
import '../models/bus_stop_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class BusRepository {
  Future<List<BusModel>> getAllBuses() async {
    try {
      final response = await ApiClient.get(AppConstants.busesEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['buses'] ?? [];
        return data.map((json) => BusModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch buses: ${e.message}');
      throw Exception('Failed to fetch buses: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching buses: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<BusModel>> getNearbyBuses(double latitude, double longitude, {double radius = 5.0}) async {
    try {
      final response = await ApiClient.get(
        '${AppConstants.busesEndpoint}/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['buses'] ?? [];
        return data.map((json) => BusModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch nearby buses: ${e.message}');
      throw Exception('Failed to fetch nearby buses: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching nearby buses: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<BusModel?> getBusByQrCode(String qrCode) async {
    try {
      final response = await ApiClient.get('${AppConstants.busesEndpoint}/qr/$qrCode');
      
      if (response.statusCode == 200) {
        return BusModel.fromJson(response.data['bus']);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to fetch bus by QR: ${e.message}');
      throw Exception('Failed to fetch bus by QR: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching bus by QR: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<BusModel?> getBusByNumber(String busNumber) async {
    try {
      final response = await ApiClient.get('${AppConstants.busesEndpoint}/number/$busNumber');
      
      if (response.statusCode == 200) {
        return BusModel.fromJson(response.data['bus']);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to fetch bus by number: ${e.message}');
      throw Exception('Failed to fetch bus by number: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching bus by number: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<BusStopModel>> getAllBusStops() async {
    try {
      final response = await ApiClient.get('/stations/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['bus_stops'] ?? [];
        return data.map((json) => BusStopModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch bus stops: ${e.message}');
      throw Exception('Failed to fetch bus stops: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching bus stops: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<BusStopModel>> getBusStopsByRoute(String routeId) async {
    try {
      final response = await ApiClient.get('/bus-stops/route/$routeId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['bus_stops'] ?? [];
        return data.map((json) => BusStopModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch bus stops by route: ${e.message}');
      throw Exception('Failed to fetch bus stops by route: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching bus stops by route: $e');
      throw Exception('An unexpected error occurred');
    }
  }
}