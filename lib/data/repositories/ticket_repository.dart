import 'package:dio/dio.dart';
import 'package:dev_log/dev_log.dart';
import '../models/ticket_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class TicketRepository {
  Future<TicketModel?> bookTicket({
    required String busId,
    required String boardingStop,
    required String droppingStop,
    required String paymentMethod,
  }) async {
    try {
      final response = await ApiClient.post(
        AppConstants.bookingEndpoint,
        data: {
          'bus_id': busId,
          'boarding_stop': boardingStop,
          'dropping_stop': droppingStop,
          'payment_method': paymentMethod,
        },
      );

      if (response.statusCode == 201) {
        return TicketModel.fromJson(response.data['ticket']);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to book ticket: ${e.message}');
      throw Exception('Failed to book ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error booking ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      final response = await ApiClient.get(AppConstants.ticketsEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['tickets'] ?? [];
        return data.map((json) => TicketModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch user tickets: ${e.message}');
      throw Exception('Failed to fetch user tickets: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching user tickets: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await ApiClient.get('${AppConstants.ticketsEndpoint}/$ticketId');
      
      if (response.statusCode == 200) {
        return TicketModel.fromJson(response.data['ticket']);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to fetch ticket: ${e.message}');
      throw Exception('Failed to fetch ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<bool> verifyTicket(String ticketId) async {
    try {
      final response = await ApiClient.post('${AppConstants.ticketsEndpoint}/$ticketId/verify');
      
      return response.statusCode == 200;
    } on DioException catch (e) {
      Log.e('Failed to verify ticket: ${e.message}');
      throw Exception('Failed to verify ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error verifying ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> calculateFare({
    required String busId,
    required String boardingStop,
    required String droppingStop,
  }) async {
    try {
      final response = await ApiClient.post(
        '/fare/calculate',
        data: {
          'bus_id': busId,
          'boarding_stop': boardingStop,
          'dropping_stop': droppingStop,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      Log.e('Failed to calculate fare: ${e.message}');
      throw Exception('Failed to calculate fare: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error calculating fare: $e');
      throw Exception('An unexpected error occurred');
    }
  }
}