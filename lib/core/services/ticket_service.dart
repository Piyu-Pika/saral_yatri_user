import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ticket_model.dart';
import '../network/api_client.dart';

class TicketService {
  TicketService();

  Future<Map<String, dynamic>> bookTicket({
    required String busId,
    required String boardingStop,
    required String droppingStop,
    required String paymentMethod,
  }) async {
    try {
      final response = await ApiClient.post(
        '/tickets/passenger/book',
        data: {},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      final response = await ApiClient.get('/tickets/passenger/my-tickets');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => TicketModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TicketModel> getTicketById(String id) async {
    try {
      final response = await ApiClient.get('/tickets/$id');
      return TicketModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelTicket(String ticketId) async {
    try {
      final response = await ApiClient.post('/tickets/$ticketId/cancel');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TicketModel?> verifyTicket(String ticketId) async {
    try {
      final response = await ApiClient.post(
        '/tickets/$ticketId/verify',
        data: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (response.data['success'] == true) {
        return TicketModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> markTicketAsUsed(String ticketId) async {
    try {
      final response = await ApiClient.post(
        '/tickets/$ticketId/mark-used',
        data: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      return response.data['success'] == true;
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

final ticketServiceProvider = Provider<TicketService>((ref) {
  return TicketService();
});
