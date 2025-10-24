import '../../data/models/ticket_model.dart';
import '../../data/models/enhanced_ticket_model.dart';

class TicketUtils {
  /// Convert enhanced ticket to regular ticket model for display compatibility
  static TicketModel enhancedToRegular(EnhancedTicketModel enhanced) {
    return TicketModel(
      id: enhanced.id,
      userId: enhanced.passengerId,
      busId: enhanced.busId,
      busNumber: 'Bus ${enhanced.busId}', // Fallback bus number
      routeId: enhanced.routeId,
      routeName: 'Route ${enhanced.routeId}', // Fallback route name
      boardingStop: 'Station ${enhanced.boardingStationId}',
      droppingStop: 'Station ${enhanced.destinationStationId}',
      originalFare: enhanced.fareDetails.baseFare,
      subsidyAmount: enhanced.fareDetails.totalSubsidyAmount,
      finalFare: enhanced.fareDetails.finalAmount,
      paymentMethod: enhanced.paymentDetails.paymentMode,
      paymentStatus: enhanced.paymentDetails.paymentStatus,
      bookingTime: enhanced.bookingTime,
      expiryTime: enhanced.validUntil,
      qrCode: enhanced.qrToken,
      status: enhanced.status,
      isVerified: enhanced.isVerified,
    );
  }

  /// Check if a ticket ID matches an enhanced ticket
  static bool isEnhancedTicket(
      String ticketId, EnhancedTicketModel? enhancedTicket) {
    return enhancedTicket != null && enhancedTicket.id == ticketId;
  }

  /// Get display ticket number (safe substring)
  static String getDisplayTicketNumber(String ticketId) {
    if (ticketId.length > 8) {
      return ticketId.substring(ticketId.length - 8);
    }
    return ticketId;
  }

  /// Format ticket status for display
  static String getStatusDisplay(String status, bool isExpired, bool isActive) {
    if (isExpired) return 'EXPIRED';
    if (isActive) return 'ACTIVE';
    return status.toUpperCase();
  }

  /// Get status color based on ticket state
  static String getStatusColorName(bool isExpired, bool isActive) {
    if (isExpired) return 'error';
    if (isActive) return 'success';
    return 'warning';
  }
}
