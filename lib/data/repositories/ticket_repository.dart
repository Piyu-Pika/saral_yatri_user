import 'package:dio/dio.dart';
import 'package:dev_log/dev_log.dart';
import '../models/ticket_model.dart';
import '../models/enhanced_ticket_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/mock_ticket_service.dart';

class TicketRepository {
  
  /// Extract user-friendly error message from API response
  String extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData == null) return defaultMessage;
    
    if (responseData is Map<String, dynamic>) {
      // Check for different error message fields
      String? message = responseData['message'] ?? 
                       responseData['error'] ?? 
                       responseData['details'];
      
      if (message != null && message.isNotEmpty) {
        return message;
      }
      
      // Check for validation errors
      if (responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.join(', ');
        } else if (errors is Map && errors.isNotEmpty) {
          return errors.values.join(', ');
        }
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    
    return defaultMessage;
  }
  Future<TicketModel?> bookTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    try {
      // Format date as expected by the API (YYYY-MM-DDTHH:mm:ssZ)
      final dateTime = (travelDate ?? DateTime.now()).toUtc();
      final formattedDate = dateTime.toIso8601String();
      
      final requestData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': droppingStationId,
        'ticket_type': ticketType,
        'travel_date': formattedDate,
        'payment_mode': paymentMethod, // API expects 'payment_mode' not 'payment_method'
      };
      
      Log.i('Booking ticket with data: $requestData');
      
      final response = await ApiClient.post(
        ApiConstants.bookTicket,
        data: requestData,
      );

      Log.i('Ticket booking response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Handle different possible response structures
        final ticketData = response.data['data'] ?? response.data['ticket'] ?? response.data;
        return TicketModel.fromJson(ticketData);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to book ticket: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');
      
      // Extract and format error message for better user experience
      String errorMessage = extractErrorMessage(e.response?.data, 'Failed to book ticket');
      
      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') || errorMessage.contains('AtlasError')) {
        errorMessage = 'Server is temporarily unavailable due to maintenance. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage = 'Invalid booking information. Please check your details and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage = 'Bus or station information not found. Please refresh and try again.';
      } else if (errorMessage.contains('already booked')) {
        errorMessage = 'This seat is already booked. Please select a different time or bus.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error booking ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Book ticket with enhanced response (includes QR data)
  Future<EnhancedTicketModel?> bookEnhancedTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    try {
      // For demo purposes, use mock service to simulate the API response
      // In production, this would make the actual API call
      Log.i('Creating mock enhanced ticket for demo');
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      final mockTicket = MockTicketService.createMockEnhancedTicket(
        busId: busId,
        routeId: routeId,
        boardingStationId: boardingStationId,
        destinationStationId: droppingStationId,
        paymentMethod: paymentMethod,
        ticketType: ticketType,
        travelDate: travelDate,
      );
      
      Log.i('Mock enhanced ticket created successfully');
      return mockTicket;
      
      /* 
      // Uncomment this section for actual API integration:
      
      // Format date as expected by the API (YYYY-MM-DDTHH:mm:ssZ)
      final dateTime = (travelDate ?? DateTime.now()).toUtc();
      final formattedDate = dateTime.toIso8601String();
      
      final requestData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': droppingStationId,
        'ticket_type': ticketType,
        'travel_date': formattedDate,
        'payment_mode': paymentMethod,
      };
      
      Log.i('Booking enhanced ticket with data: $requestData');
      
      final response = await ApiClient.post(
        ApiConstants.bookTicket,
        data: requestData,
      );

      Log.i('Enhanced ticket booking response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return EnhancedTicketModel.fromJson(response.data);
      }
      return null;
      */
    } on DioException catch (e) {
      Log.e('Failed to book enhanced ticket: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');
      
      // Extract and format error message for better user experience
      String errorMessage = extractErrorMessage(e.response?.data, 'Failed to book ticket');
      
      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') || errorMessage.contains('AtlasError')) {
        errorMessage = 'Server is temporarily unavailable due to maintenance. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage = 'Invalid booking information. Please check your details and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage = 'Bus or station information not found. Please refresh and try again.';
      } else if (errorMessage.contains('already booked')) {
        errorMessage = 'This seat is already booked. Please select a different time or bus.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error booking enhanced ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      final response = await ApiClient.get(ApiConstants.myTickets);
      
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
      final response = await ApiClient.get('${ApiConstants.ticketDetails}/$ticketId');
      
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
      final response = await ApiClient.post('${ApiConstants.ticketDetails}/$ticketId/verify');
      
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
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    try {
      // Format date as expected by the API (YYYY-MM-DDTHH:mm:ss.sssZ)
      final dateTime = (travelDate ?? DateTime.now()).toUtc();
      final formattedDate = dateTime.toIso8601String();
      
      final requestData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': droppingStationId,
        'ticket_type': ticketType,
        'travel_date': formattedDate,
      };
      
      Log.i('Calculating fare with data: $requestData');
      
      final response = await ApiClient.post(
        ApiConstants.calculateFare,
        data: requestData,
      );

      Log.i('Fare calculation response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      return {};
    } on DioException catch (e) {
      Log.e('Failed to calculate fare: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');
      
      // Extract and format error message for better user experience
      String errorMessage = extractErrorMessage(e.response?.data, 'Failed to calculate fare');
      
      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') || errorMessage.contains('AtlasError')) {
        errorMessage = 'Server is temporarily unavailable. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage = 'Invalid route information. Please check your selection and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage = 'Route or station not found. Please refresh and try again.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error calculating fare: $e');
      throw Exception('An unexpected error occurred');
    }
  }


}