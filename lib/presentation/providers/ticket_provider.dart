import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dev_log/dev_log.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) => TicketRepository());

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  return TicketNotifier(ref.read(ticketRepositoryProvider));
});

class TicketState {
  final List<TicketModel> tickets;
  final TicketModel? currentTicket;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? fareCalculation;

  TicketState({
    this.tickets = const [],
    this.currentTicket,
    this.isLoading = false,
    this.error,
    this.fareCalculation,
  });

  TicketState copyWith({
    List<TicketModel>? tickets,
    TicketModel? currentTicket,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? fareCalculation,
    bool clearError = false,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      currentTicket: currentTicket ?? this.currentTicket,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      fareCalculation: fareCalculation ?? this.fareCalculation,
    );
  }
}

class TicketNotifier extends StateNotifier<TicketState> {
  final TicketRepository _ticketRepository;

  TicketNotifier(this._ticketRepository) : super(TicketState());

  Future<void> loadUserTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final tickets = await _ticketRepository.getUserTickets();
      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error loading user tickets: $e');
    }
  }

  Future<bool> bookTicket({
    required String busId,
    required String boardingStop,
    required String droppingStop,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final ticket = await _ticketRepository.bookTicket(
        busId: busId,
        boardingStop: boardingStop,
        droppingStop: droppingStop,
        paymentMethod: paymentMethod,
      );
      
      if (ticket != null) {
        final updatedTickets = [ticket, ...state.tickets];
        state = state.copyWith(
          tickets: updatedTickets,
          currentTicket: ticket,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to book ticket',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error booking ticket: $e');
      return false;
    }
  }

  Future<void> calculateFare({
    required String busId,
    required String boardingStop,
    required String droppingStop,
  }) async {
    try {
      final fareData = await _ticketRepository.calculateFare(
        busId: busId,
        boardingStop: boardingStop,
        droppingStop: droppingStop,
      );
      
      state = state.copyWith(fareCalculation: fareData, clearError: true);
    } catch (e) {
      Log.e('Error calculating fare: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getTicketById(String ticketId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final ticket = await _ticketRepository.getTicketById(ticketId);
      state = state.copyWith(
        currentTicket: ticket,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      Log.e('Error getting ticket: $e');
    }
  }

  Future<bool> verifyTicket(String ticketId) async {
    try {
      return await _ticketRepository.verifyTicket(ticketId);
    } catch (e) {
      Log.e('Error verifying ticket: $e');
      return false;
    }
  }

  void setCurrentTicket(TicketModel ticket) {
    state = state.copyWith(currentTicket: ticket);
  }

  void clearCurrentTicket() {
    state = state.copyWith(currentTicket: null);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearFareCalculation() {
    state = state.copyWith(fareCalculation: null);
  }
}