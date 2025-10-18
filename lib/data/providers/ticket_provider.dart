import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/ticket_model.dart';

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
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
      final tickets = ticketsData.map((data) => TicketModel.fromJson(data)).toList();

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

  Future<void> bookTicket(Map<String, dynamic> bookingData) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.post(ApiConstants.bookTicket, data: bookingData);
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

  Future<void> loadTicketDetails(String ticketId) async {
    try {
      final response = await _apiService.get('${ApiConstants.ticketDetails}/$ticketId');
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
}
