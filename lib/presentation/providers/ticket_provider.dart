import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dev_log/dev_log.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/enhanced_ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) => TicketRepository());

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  return TicketNotifier(ref.read(ticketRepositoryProvider));
});

class TicketState {
  final List<TicketModel> tickets;
  final TicketModel? currentTicket;
  final EnhancedTicketModel? currentEnhancedTicket;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? fareCalculation;

  TicketState({
    this.tickets = const [],
    this.currentTicket,
    this.currentEnhancedTicket,
    this.isLoading = false,
    this.error,
    this.fareCalculation,
  });

  TicketState copyWith({
    List<TicketModel>? tickets,
    TicketModel? currentTicket,
    EnhancedTicketModel? currentEnhancedTicket,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? fareCalculation,
    bool clearError = false,
  }) {
    return TicketState(
      tickets: tickets ?? this.tickets,
      currentTicket: currentTicket ?? this.currentTicket,
      currentEnhancedTicket: currentEnhancedTicket ?? this.currentEnhancedTicket,
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
      
      // If no tickets from API, add some mock tickets for demo
      if (tickets.isEmpty) {
        final mockTickets = _generateMockTickets();
        state = state.copyWith(
          tickets: mockTickets,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          tickets: tickets,
          isLoading: false,
        );
      }
    } catch (e) {
      // If API fails, show mock tickets for demo
      Log.w('API failed, showing mock tickets: $e');
      final mockTickets = _generateMockTickets();
      state = state.copyWith(
        tickets: mockTickets,
        isLoading: false,
        clearError: true,
      );
    }
  }

  List<TicketModel> _generateMockTickets() {
    final now = DateTime.now();
    return [
      TicketModel(
        id: 'TICKET001',
        userId: 'USER001',
        busId: 'BUS001',
        busNumber: 'MH12AB1234',
        routeId: 'ROUTE001',
        routeName: 'Mumbai Central - Andheri',
        boardingStop: 'Mumbai Central',
        droppingStop: 'Andheri Station',
        originalFare: 50.0,
        subsidyAmount: 5.0,
        finalFare: 45.0,
        paymentMethod: 'upi',
        paymentStatus: 'completed',
        bookingTime: now.subtract(const Duration(hours: 2)),
        expiryTime: now.add(const Duration(hours: 4)),
        qrCode: 'MOCK_QR_CODE_001',
        status: 'active',
        isVerified: false,
      ),
      TicketModel(
        id: 'TICKET002',
        userId: 'USER001',
        busId: 'BUS002',
        busNumber: 'MH14CD5678',
        routeId: 'ROUTE002',
        routeName: 'Pune Station - Hinjewadi',
        boardingStop: 'Pune Station',
        droppingStop: 'Hinjewadi IT Park',
        originalFare: 75.0,
        subsidyAmount: 10.0,
        finalFare: 65.0,
        paymentMethod: 'card',
        paymentStatus: 'completed',
        bookingTime: now.subtract(const Duration(days: 1)),
        expiryTime: now.subtract(const Duration(hours: 20)),
        qrCode: 'MOCK_QR_CODE_002',
        status: 'expired',
        isVerified: false,
      ),
      TicketModel(
        id: 'TICKET003',
        userId: 'USER001',
        busId: 'BUS003',
        busNumber: 'MH20EF9012',
        routeId: 'ROUTE003',
        routeName: 'Nashik Road - College Road',
        boardingStop: 'Nashik Road',
        droppingStop: 'College Road',
        originalFare: 30.0,
        subsidyAmount: 3.0,
        finalFare: 27.0,
        paymentMethod: 'cash',
        paymentStatus: 'completed',
        bookingTime: now.add(const Duration(hours: 1)),
        expiryTime: now.add(const Duration(hours: 8)),
        qrCode: 'MOCK_QR_CODE_003',
        status: 'active',
        isVerified: false,
      ),
    ];
  }

  Future<bool> bookTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final ticket = await _ticketRepository.bookTicket(
        busId: busId,
        routeId: routeId,
        boardingStationId: boardingStationId,
        droppingStationId: droppingStationId,
        paymentMethod: paymentMethod,
        ticketType: ticketType,
        travelDate: travelDate,
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

  /// Book ticket with enhanced response (includes QR data)
  Future<bool> bookEnhancedTicket({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    required String paymentMethod,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final enhancedTicket = await _ticketRepository.bookEnhancedTicket(
        busId: busId,
        routeId: routeId,
        boardingStationId: boardingStationId,
        droppingStationId: droppingStationId,
        paymentMethod: paymentMethod,
        ticketType: ticketType,
        travelDate: travelDate,
      );
      
      if (enhancedTicket != null) {
        state = state.copyWith(
          currentEnhancedTicket: enhancedTicket,
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
      Log.e('Error booking enhanced ticket: $e');
      return false;
    }
  }

  Future<void> calculateFare({
    required String busId,
    required String routeId,
    required String boardingStationId,
    required String droppingStationId,
    String ticketType = 'single',
    DateTime? travelDate,
  }) async {
    try {
      final fareData = await _ticketRepository.calculateFare(
        busId: busId,
        routeId: routeId,
        boardingStationId: boardingStationId,
        droppingStationId: droppingStationId,
        ticketType: ticketType,
        travelDate: travelDate,
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

  void setCurrentEnhancedTicket(EnhancedTicketModel ticket) {
    state = state.copyWith(currentEnhancedTicket: ticket);
  }

  void clearCurrentTicket() {
    state = state.copyWith(currentTicket: null);
  }

  void clearCurrentEnhancedTicket() {
    state = state.copyWith(currentEnhancedTicket: null);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearFareCalculation() {
    state = state.copyWith(fareCalculation: null);
  }
}