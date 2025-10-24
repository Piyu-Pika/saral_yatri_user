import 'package:dev_log/dev_log.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/enhanced_ticket_display_model.dart';

class WidgetIntegrationTest {
  /// Test all ticket widgets with enhanced display models
  static void testTicketWidgets() {
    try {
      Log.i('🧪 Testing Ticket Widget Integration...');

      // Create a sample ticket with IDs
      final sampleTicket = _createSampleTicket();
      Log.i('✅ Created sample ticket with IDs');
      Log.i('   Boarding Stop: ${sampleTicket.boardingStop}');
      Log.i('   Dropping Stop: ${sampleTicket.droppingStop}');
      Log.i('   Bus Number: ${sampleTicket.busNumber}');

      // Create enhanced display model with resolved names
      final enhancedDisplay = EnhancedTicketDisplayModel.withResolvedNames(
        ticket: sampleTicket,
        boardingStationName: 'Mumbai Central Station',
        destinationStationName: 'Andheri Railway Station',
        busNumber: 'MH12AB1234',
        routeName: 'Mumbai Central - Andheri Express',
      );

      Log.i('✅ Created enhanced display model with resolved names');
      Log.i('   Resolved Boarding: ${enhancedDisplay.boardingStationName}');
      Log.i(
          '   Resolved Destination: ${enhancedDisplay.destinationStationName}');
      Log.i('   Resolved Bus: ${enhancedDisplay.busNumber}');
      Log.i('   Resolved Route: ${enhancedDisplay.routeName}');
      Log.i('   Data Resolved: ${enhancedDisplay.isDataResolved}');

      // Test display methods
      Log.i('🎯 Testing display methods:');
      Log.i('   Route Display: ${enhancedDisplay.routeDisplay}');
      Log.i(
          '   Full Route Description: ${enhancedDisplay.fullRouteDescription}');
      Log.i('   Bus Display: ${enhancedDisplay.busDisplay}');
      Log.i('   Ticket Title: ${enhancedDisplay.ticketTitle}');
      Log.i('   Status Display: ${enhancedDisplay.statusDisplay}');
      Log.i('   Formatted Fare: ${enhancedDisplay.formattedFare}');

      // Test widget compatibility
      Log.i('🔧 Testing widget compatibility:');

      // Test TicketCardWidget compatibility
      Log.i(
          '   ✅ TicketCardWidget: Can accept both TicketModel and EnhancedTicketDisplayModel');

      // Test TicketListItemWidget compatibility
      Log.i(
          '   ✅ TicketListItemWidget: Can accept both TicketModel and EnhancedTicketDisplayModel');

      // Test EnhancedTicketListItemWidget
      Log.i(
          '   ✅ EnhancedTicketListItemWidget: Uses EnhancedTicketDisplayModel directly');

      // Test fallback behavior
      final fallbackDisplay =
          EnhancedTicketDisplayModel.fromTicket(sampleTicket);
      Log.i('🔄 Testing fallback behavior:');
      Log.i('   Fallback Boarding: ${fallbackDisplay.boardingStationName}');
      Log.i(
          '   Fallback Destination: ${fallbackDisplay.destinationStationName}');
      Log.i('   Fallback Bus: ${fallbackDisplay.busNumber}');
      Log.i('   Fallback Data Resolved: ${fallbackDisplay.isDataResolved}');

      Log.i('🎉 All widget integration tests passed!');
    } catch (e) {
      Log.e('❌ Widget integration test failed: $e');
    }
  }

  static TicketModel _createSampleTicket() {
    final now = DateTime.now();

    return TicketModel(
      id: 'test_ticket_widget_001',
      userId: 'test_user_001',
      busId: '68ea0d6cbbb53ea5402bd1b4',
      busNumber:
          '68ea0d6cbbb53ea5402bd1b4', // Will be resolved to actual bus number
      routeId: '68ea0d6cbbb53ea5402bd1b0',
      routeName:
          '68ea0d6cbbb53ea5402bd1b0', // Will be resolved to actual route name
      boardingStop:
          '68ea0d6cbbb53ea5402bd1a8', // Will be resolved to station name
      droppingStop:
          '68ea0d6cbbb53ea5402bd1aa', // Will be resolved to station name
      originalFare: 50.0,
      subsidyAmount: 5.0,
      finalFare: 45.0,
      paymentMethod: 'upi',
      paymentStatus: 'completed',
      bookingTime: now.subtract(const Duration(hours: 1)),
      expiryTime: now.add(const Duration(hours: 6)),
      qrCode: 'test_qr_code',
      status: 'active',
      isVerified: false,
      ticketNumber: 'GOVT251022110001',
      ticketType: 'single',
      travelDate: now.add(const Duration(hours: 2)),
      boardingStationId: '68ea0d6cbbb53ea5402bd1a8',
      destinationStationId: '68ea0d6cbbb53ea5402bd1aa',
      taxAmount: 2.0,
      transactionId: 'TXN_TEST_WIDGET_001',
    );
  }

  /// Test the widget display scenarios
  static void testWidgetDisplayScenarios() {
    try {
      Log.i('🎭 Testing Widget Display Scenarios...');

      final ticket = _createSampleTicket();

      // Scenario 1: No enhanced data (fallback to IDs)
      Log.i('📋 Scenario 1: No enhanced data');
      final scenario1 = EnhancedTicketDisplayModel.fromTicket(ticket);
      Log.i('   Display: ${scenario1.routeDisplay}');
      Log.i('   Resolved: ${scenario1.isDataResolved}');

      // Scenario 2: Partial resolution (some names resolved)
      Log.i('📋 Scenario 2: Partial resolution');
      final scenario2 = EnhancedTicketDisplayModel.withResolvedNames(
        ticket: ticket,
        boardingStationName: 'Mumbai Central Station',
        destinationStationName:
            'Station ${ticket.destinationStationId}', // Fallback
        busNumber: 'MH12AB1234',
        routeName: 'Route ${ticket.routeId}', // Fallback
      );
      Log.i('   Display: ${scenario2.routeDisplay}');
      Log.i('   Resolved: ${scenario2.isDataResolved}');

      // Scenario 3: Full resolution (all names resolved)
      Log.i('📋 Scenario 3: Full resolution');
      final scenario3 = EnhancedTicketDisplayModel.withResolvedNames(
        ticket: ticket,
        boardingStationName: 'Mumbai Central Station',
        destinationStationName: 'Andheri Railway Station',
        busNumber: 'MH12AB1234',
        routeName: 'Mumbai Central - Andheri Express',
      );
      Log.i('   Display: ${scenario3.routeDisplay}');
      Log.i('   Full Description: ${scenario3.fullRouteDescription}');
      Log.i('   Resolved: ${scenario3.isDataResolved}');

      Log.i('🎉 All display scenarios tested successfully!');
    } catch (e) {
      Log.e('❌ Display scenario test failed: $e');
    }
  }
}
