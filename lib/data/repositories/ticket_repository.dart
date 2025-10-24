import 'package:dio/dio.dart';
import 'package:dev_log/dev_log.dart';
import '../models/ticket_model.dart';
import '../models/enhanced_ticket_model.dart';
import '../models/enhanced_ticket_display_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/mock_ticket_service.dart';
import '../../core/services/data_resolution_service.dart';

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
        'payment_mode':
            paymentMethod, // API expects 'payment_mode' not 'payment_method'
      };

      Log.i('🚀 Booking ticket with data: $requestData');
      print(
          '🚀 DEBUG: Booking API URL: ${ApiConstants.baseUrl}${ApiConstants.bookTicket}');
      print('🚀 DEBUG: Request data: $requestData');

      final response = await ApiClient.post(
        ApiConstants.bookTicket,
        data: requestData,
      );

      Log.i(
          '✅ Ticket booking response: ${response.statusCode} - ${response.data}');
      print('✅ DEBUG: Full response: ${response.toString()}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Handle different possible response structures
        final ticketData =
            response.data['data'] ?? response.data['ticket'] ?? response.data;
        return TicketModel.fromJson(ticketData);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to book ticket: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');

      // Extract and format error message for better user experience
      String errorMessage =
          extractErrorMessage(e.response?.data, 'Failed to book ticket');

      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') ||
          errorMessage.contains('AtlasError')) {
        errorMessage =
            'Server is temporarily unavailable due to maintenance. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage =
            'Invalid booking information. Please check your details and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage =
            'Bus or station information not found. Please refresh and try again.';
      } else if (errorMessage.contains('already booked')) {
        errorMessage =
            'This seat is already booked. Please select a different time or bus.';
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
      // Format date as expected by the API (YYYY-MM-DDTHH:mm:ssZ)
      final dateTime = (travelDate ?? DateTime.now()).toUtc();
      final formattedDate = dateTime.toIso8601String();

      // Map payment method to the expected format
      String paymentMode = paymentMethod;
      String paymentMethodValue = paymentMethod;

      // Convert payment method to expected API format
      switch (paymentMethod.toLowerCase()) {
        case 'digital':
          paymentMode = 'upi';
          paymentMethodValue = 'gpay'; // Default UPI method
          break;
        case 'cash':
          paymentMode = 'cash';
          paymentMethodValue = 'cash';
          break;
        case 'card':
          paymentMode = 'card';
          paymentMethodValue = 'debit_card'; // Default card method
          break;
        default:
          paymentMode = paymentMethod;
          paymentMethodValue = paymentMethod;
      }

      final requestData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': droppingStationId,
        'ticket_type': ticketType,
        'travel_date': formattedDate,
        'payment_mode': paymentMode,
        'payment_method': paymentMethodValue,
      };

      Log.i('🚀 Booking enhanced ticket with data: $requestData');

      final response = await ApiClient.post(
        ApiConstants.bookTicket,
        data: requestData,
      );

      Log.i(
          '✅ Enhanced ticket booking response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse the enhanced response structure
        final responseData = response.data;

        // The API returns the structure you specified
        if (responseData['data'] != null) {
          return EnhancedTicketModel.fromJson(responseData);
        } else {
          // Fallback for different response structure
          return EnhancedTicketModel.fromJson(responseData);
        }
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to book enhanced ticket: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');

      // Extract and format error message for better user experience
      String errorMessage =
          extractErrorMessage(e.response?.data, 'Failed to book ticket');

      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') ||
          errorMessage.contains('AtlasError')) {
        errorMessage =
            'Server is temporarily unavailable due to maintenance. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage =
            'Invalid booking information. Please check your details and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage =
            'Bus or station information not found. Please refresh and try again.';
      } else if (errorMessage.contains('already booked')) {
        errorMessage =
            'This seat is already booked. Please select a different time or bus.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error booking enhanced ticket: $e');

      // If API fails, fall back to mock service for demo purposes
      Log.w('API failed, creating mock enhanced ticket for demo: $e');
      try {
        final mockTicket = MockTicketService.createMockEnhancedTicket(
          busId: busId,
          routeId: routeId,
          boardingStationId: boardingStationId,
          destinationStationId: droppingStationId,
          paymentMethod: paymentMethod,
          ticketType: ticketType,
          travelDate: travelDate,
        );

        Log.i('Mock enhanced ticket created as fallback');
        return mockTicket;
      } catch (mockError) {
        Log.e('Failed to create mock ticket: $mockError');
        throw Exception('Failed to book ticket: ${e.toString()}');
      }
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      Log.i('Fetching user tickets from API...');
      final response = await ApiClient.get(ApiConstants.myTickets);

      Log.i('User tickets response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        // Handle different possible response structures
        final responseData = response.data;
        List<dynamic> ticketsData = [];

        if (responseData is Map<String, dynamic>) {
          // Try different possible keys for the tickets array
          ticketsData = responseData['tickets'] ??
              responseData['data'] ??
              responseData['results'] ??
              [];
        } else if (responseData is List) {
          // Direct array response
          ticketsData = responseData;
        }

        Log.i('Found ${ticketsData.length} tickets in response');

        final tickets = ticketsData
            .map((json) {
              try {
                return TicketModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                Log.w('Failed to parse ticket: $json, error: $e');
                return null;
              }
            })
            .where((ticket) => ticket != null)
            .cast<TicketModel>()
            .toList();

        Log.i('Successfully parsed ${tickets.length} tickets');
        return tickets;
      }

      Log.w('Unexpected response status: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      Log.e('Failed to fetch user tickets: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');

      // Extract and format error message for better user experience
      String errorMessage =
          extractErrorMessage(e.response?.data, 'Failed to fetch tickets');

      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') ||
          errorMessage.contains('AtlasError')) {
        errorMessage =
            'Server is temporarily unavailable. Please try again later.';
      } else if (errorMessage.contains('unauthorized') ||
          e.response?.statusCode == 401) {
        errorMessage = 'Please log in again to view your tickets.';
      } else if (errorMessage.contains('not found') ||
          e.response?.statusCode == 404) {
        errorMessage = 'No tickets found for your account.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error fetching user tickets: $e');
      throw Exception('An unexpected error occurred while fetching tickets');
    }
  }

  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response =
          await ApiClient.get('${ApiConstants.ticketDetails}/$ticketId');

      if (response.statusCode == 200) {
        return TicketModel.fromJson(response.data['ticket']);
      }
      return null;
    } on DioException catch (e) {
      Log.e('Failed to fetch ticket: ${e.message}');
      throw Exception(
          'Failed to fetch ticket: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      Log.e('Unexpected error fetching ticket: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<bool> verifyTicket(String ticketId) async {
    try {
      final response = await ApiClient.post(
          '${ApiConstants.ticketDetails}/$ticketId/verify');

      return response.statusCode == 200;
    } on DioException catch (e) {
      Log.e('Failed to verify ticket: ${e.message}');
      throw Exception(
          'Failed to verify ticket: ${e.response?.data['message'] ?? e.message}');
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

      Log.i(
          'Fare calculation response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      return {};
    } on DioException catch (e) {
      Log.e('Failed to calculate fare: ${e.message}');
      Log.e('Response status: ${e.response?.statusCode}');
      Log.e('Response data: ${e.response?.data}');

      // Extract and format error message for better user experience
      String errorMessage =
          extractErrorMessage(e.response?.data, 'Failed to calculate fare');

      // Handle specific server errors with user-friendly messages
      if (errorMessage.contains('space quota') ||
          errorMessage.contains('AtlasError')) {
        errorMessage =
            'Server is temporarily unavailable. Please try again later.';
      } else if (errorMessage.contains('validation')) {
        errorMessage =
            'Invalid route information. Please check your selection and try again.';
      } else if (errorMessage.contains('not found')) {
        errorMessage =
            'Route or station not found. Please refresh and try again.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      Log.e('Unexpected error calculating fare: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Get user tickets with resolved names (station names, bus numbers, route names)
  Future<List<EnhancedTicketDisplayModel>>
      getUserTicketsWithResolvedNames() async {
    try {
      Log.i('Fetching user tickets with resolved names...');

      // First get the raw tickets
      final tickets = await getUserTickets();

      if (tickets.isEmpty) {
        Log.i('No tickets found to resolve names for');
        return [];
      }

      Log.i('Resolving names for ${tickets.length} tickets...');

      // Resolve names for all tickets in parallel
      final enhancedTickets = await Future.wait(
        tickets.map((ticket) => _resolveTicketNames(ticket)).toList(),
      );

      Log.i(
          'Successfully resolved names for ${enhancedTickets.length} tickets');
      return enhancedTickets;
    } catch (e) {
      Log.e('Failed to get tickets with resolved names: $e');
      rethrow;
    }
  }

  /// Resolve names for a single ticket
  Future<EnhancedTicketDisplayModel> _resolveTicketNames(
      TicketModel ticket) async {
    try {
      // Use the data resolution service to get all names in parallel
      final resolvedData = await DataResolutionService.resolveTicketData(
        boardingStationId: ticket.boardingStationId ?? '',
        destinationStationId: ticket.destinationStationId ?? '',
        busId: ticket.busId,
        routeId: ticket.routeId,
      );

      return EnhancedTicketDisplayModel.withResolvedNames(
        ticket: ticket,
        boardingStationName: resolvedData['boardingStation']!,
        destinationStationName: resolvedData['destinationStation']!,
        busNumber: resolvedData['busNumber']!,
        routeName: resolvedData['routeName']!,
      );
    } catch (e) {
      Log.w('Failed to resolve names for ticket ${ticket.id}: $e');
      // Return with fallback names
      return EnhancedTicketDisplayModel.fromTicket(ticket);
    }
  }

  /// Get a single ticket by ID with resolved names
  Future<EnhancedTicketDisplayModel?> getTicketByIdWithResolvedNames(
      String ticketId) async {
    try {
      final ticket = await getTicketById(ticketId);
      if (ticket == null) return null;

      return await _resolveTicketNames(ticket);
    } catch (e) {
      Log.e('Failed to get ticket with resolved names: $e');
      rethrow;
    }
  }
}
