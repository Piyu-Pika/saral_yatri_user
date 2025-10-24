import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/ticket_model.dart';

final ticketProvider =
    StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TicketNotifier(apiService);
});

class TicketState {
  final List<TicketModel> tickets;
  final TicketModel? lastBookedTicket;
  final bool isLoading;
  final String? error;

  TicketState({
    this.tickets = const [],
    this.lastBookedTicket,
    this.isLoading = false,
    this.error,
  });

  TicketState copyWith({
    List<TicketModel>? tickets,
    TicketModel? lastBookedTicket,
    bool? isLoading,
    String? error,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      lastBookedTicket: lastBookedTicket ?? this.lastBookedTicket,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TicketNotifier extends StateNotifier<TicketState> {
  final ApiService _apiService;

  TicketNotifier(this._apiService) : super(TicketState());

  Future<void> loadMyTickets() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConstants.myTickets);
      final ticketsData = response.data['data'] as List;
      final tickets =
          ticketsData.map((data) => TicketModel.fromJson(data)).toList();

      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _bookTicketWithData(Map<String, dynamic> bookingData) async {
    state = state.copyWith(isLoading: true);

    try {
      final response =
          await _apiService.post(ApiConstants.bookTicket, data: bookingData);
      final ticketData = response.data['data'];
      final ticket = TicketModel.fromJson(ticketData);

      final updatedTickets = [ticket, ...state.tickets];

      state = state.copyWith(
        tickets: updatedTickets,
        lastBookedTicket: ticket,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Book ticket with named parameters (used by payment screen)
  Future<bool> bookTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    required String ticketType,
    required DateTime travelDate,
  }) async {
    try {
      final bookingData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': droppingStationId,
        'ticket_type': ticketType,
        'travel_date': travelDate.toIso8601String(),
        'payment_mode': paymentMethod,
        'payment_method': 'app_booking',
      };

      await _bookTicketWithData(bookingData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Book enhanced ticket with QR data (placeholder for now)
  Future<bool> bookEnhancedTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    required String ticketType,
    required DateTime travelDate,
  }) async {
    // For now, just call regular booking
    return await bookTicket(
      busId: busId,
      routeId: routeId,
      boardingStationId: boardingStationId,
      droppingStationId: droppingStationId,
      paymentMethod: paymentMethod,
      ticketType: ticketType,
      travelDate: travelDate,
    );
  }

  Future<void> loadTicketDetails(String ticketId) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.ticketDetails}/$ticketId');
      final ticketData = response.data['data'];
      final ticket = TicketModel.fromJson(ticketData);

      // Update ticket in the list if it exists
      final updatedTickets = state.tickets.map((t) {
        return t.id == ticket.id ? ticket : t;
      }).toList();

      state = state.copyWith(tickets: updatedTickets);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load only active tickets using the new endpoint
  Future<void> loadMyActiveTickets() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.get(ApiConstants.myActiveTickets);
      final ticketsData = response.data['data'] as List;
      final tickets =
          ticketsData.map((data) => TicketModel.fromJson(data)).toList();

      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Check ticket status using the new endpoint
  Future<Map<String, dynamic>?> checkTicketStatus(String ticketId) async {
    try {
      final response = await _apiService
          .get('${ApiConstants.ticketStatus}/$ticketId/status');
      return response.data['data'];
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Check if ticket is active using the new endpoint
  Future<bool> isTicketActive(String ticketId) async {
    try {
      final response = await _apiService
          .get('${ApiConstants.ticketIsActive}/$ticketId/is-active');
      return response.data['data']['is_active'] ?? false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Calculate fare using the working endpoint
  Future<Map<String, dynamic>?> calculateFare({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String destinationStationId,
    required String ticketType,
    required DateTime travelDate,
  }) async {
    try {
      final fareData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': destinationStationId,
        'ticket_type': ticketType,
        'travel_date': travelDate.toIso8601String(),
      };

      final response =
          await _apiService.post(ApiConstants.calculateFare, data: fareData);
      return response.data['data'];
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}
