import 'ticket_model.dart';

/// Enhanced ticket model with resolved display names
class EnhancedTicketDisplayModel {
  final TicketModel ticket;
  final String boardingStationName;
  final String destinationStationName;
  final String busNumber;
  final String routeName;
  final bool isDataResolved;

  EnhancedTicketDisplayModel({
    required this.ticket,
    required this.boardingStationName,
    required this.destinationStationName,
    required this.busNumber,
    required this.routeName,
    this.isDataResolved = true,
  });

  /// Create from ticket model with fallback names
  factory EnhancedTicketDisplayModel.fromTicket(TicketModel ticket) {
    return EnhancedTicketDisplayModel(
      ticket: ticket,
      boardingStationName: ticket.boardingStop,
      destinationStationName: ticket.droppingStop,
      busNumber: ticket.busNumber,
      routeName: ticket.routeName,
      isDataResolved: false,
    );
  }

  /// Create with resolved names
  factory EnhancedTicketDisplayModel.withResolvedNames({
    required TicketModel ticket,
    required String boardingStationName,
    required String destinationStationName,
    required String busNumber,
    required String routeName,
  }) {
    return EnhancedTicketDisplayModel(
      ticket: ticket,
      boardingStationName: boardingStationName,
      destinationStationName: destinationStationName,
      busNumber: busNumber,
      routeName: routeName,
      isDataResolved: true,
    );
  }

  /// Get route display text with resolved names
  String get routeDisplay => '$boardingStationName → $destinationStationName';

  /// Get full route description
  String get fullRouteDescription => '$routeName: $boardingStationName → $destinationStationName';

  /// Get bus display text
  String get busDisplay => '$busNumber';

  /// Get ticket title for display
  String get ticketTitle => ticket.displayName;

  /// Get formatted fare
  String get formattedFare => ticket.formattedFare;

  /// Get status display
  String get statusDisplay {
    if (ticket.isActive) return 'Active';
    if (ticket.isExpired) return 'Expired';
    return ticket.status.toUpperCase();
  }

  /// Get status color based on ticket status
  String get statusColor {
    if (ticket.isActive) return 'green';
    if (ticket.isExpired) return 'red';
    return 'orange';
  }

  /// Copy with updated resolved names
  EnhancedTicketDisplayModel copyWithResolvedNames({
    String? boardingStationName,
    String? destinationStationName,
    String? busNumber,
    String? routeName,
  }) {
    return EnhancedTicketDisplayModel(
      ticket: ticket,
      boardingStationName: boardingStationName ?? this.boardingStationName,
      destinationStationName: destinationStationName ?? this.destinationStationName,
      busNumber: busNumber ?? this.busNumber,
      routeName: routeName ?? this.routeName,
      isDataResolved: true,
    );
  }
}