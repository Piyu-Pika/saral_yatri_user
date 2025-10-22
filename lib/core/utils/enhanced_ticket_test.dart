import 'package:dev_log/dev_log.dart';
import '../../data/models/enhanced_ticket_model.dart';
import '../../data/models/enhanced_ticket_display_model.dart';
import '../services/data_resolution_service.dart';

class EnhancedTicketTest {
  /// Test the enhanced ticket display functionality
  static Future<void> testEnhancedTicketDisplay() async {
    try {
      Log.i('🧪 Testing Enhanced Ticket Display...');

      // Create a mock enhanced ticket
      final mockEnhancedTicket = _createMockEnhancedTicket();
      Log.i(
          '✅ Created mock enhanced ticket: ${mockEnhancedTicket.ticketNumber}');

      // Convert to regular ticket model
      final regularTicket = mockEnhancedTicket.toTicketModel();
      Log.i('✅ Converted to regular ticket model: ${regularTicket.id}');

      // Create enhanced display model from regular ticket
      final displayModel = EnhancedTicketDisplayModel.fromTicket(regularTicket);
      Log.i('✅ Created display model from ticket');
      Log.i('   Route Display: ${displayModel.routeDisplay}');
      Log.i('   Bus Display: ${displayModel.busDisplay}');
      Log.i('   Data Resolved: ${displayModel.isDataResolved}');

      // Test with resolved names
      if (regularTicket.boardingStationId != null &&
          regularTicket.destinationStationId != null) {
        Log.i('🔍 Testing name resolution...');

        final resolvedData = await DataResolutionService.resolveTicketData(
          boardingStationId: regularTicket.boardingStationId!,
          destinationStationId: regularTicket.destinationStationId!,
          busId: regularTicket.busId,
          routeId: regularTicket.routeId,
        );

        final resolvedDisplayModel =
            EnhancedTicketDisplayModel.withResolvedNames(
          ticket: regularTicket,
          boardingStationName: resolvedData['boardingStation']!,
          destinationStationName: resolvedData['destinationStation']!,
          busNumber: resolvedData['busNumber']!,
          routeName: resolvedData['routeName']!,
        );

        Log.i('✅ Created resolved display model');
        Log.i(
            '   Resolved Route Display: ${resolvedDisplayModel.routeDisplay}');
        Log.i('   Resolved Bus Display: ${resolvedDisplayModel.busDisplay}');
        Log.i('   Data Resolved: ${resolvedDisplayModel.isDataResolved}');
        Log.i(
            '   Full Route Description: ${resolvedDisplayModel.fullRouteDescription}');
      }

      Log.i('🎉 Enhanced ticket display test completed successfully!');
    } catch (e) {
      Log.e('❌ Enhanced ticket display test failed: $e');
    }
  }

  static EnhancedTicketModel _createMockEnhancedTicket() {
    final now = DateTime.now();

    return EnhancedTicketModel(
      id: 'test_ticket_001',
      ticketNumber: 'GOVT251022110001',
      ticketType: 'single',
      passengerId: 'test_passenger_001',
      busId: '68ea0d6cbbb53ea5402bd1b4',
      routeId: '68ea0d6cbbb53ea5402bd1b0',
      boardingStationId: '68ea0d6cbbb53ea5402bd1a8',
      destinationStationId: '68ea0d6cbbb53ea5402bd1aa',
      bookingTime: now,
      travelDate: now.add(const Duration(hours: 2)),
      validUntil: now.add(const Duration(hours: 8)),
      status: 'booked',
      fareDetails: FareDetails(
        baseFare: 50.0,
        grossFare: 50.0,
        totalSubsidyAmount: 5.0,
        netFare: 45.0,
        totalTaxAmount: 2.0,
        finalAmount: 47.0,
        governmentShare: 5.0,
        passengerShare: 42.0,
      ),
      qrToken: 'mock_qr_token',
      encryptedToken: 'mock_encrypted_token',
      isVerified: false,
      complianceData: ComplianceData(
        revenueDate: now,
        accountingCode: 'GOVT_BUS_REVENUE',
        revenueHead: 'Transport Department',
        isGovtFunded: false,
        auditTrailId: 'AUDIT_TEST_001',
        transactionRef: 'TXN_TEST_001',
      ),
      paymentDetails: PaymentDetails(
        paymentMode: 'upi',
        paymentMethod: 'test_payment',
        transactionId: 'PAY_TEST_001',
        paymentStatus: 'completed',
        paymentTime: now,
      ),
      createdAt: now,
      updatedAt: now,
      qrData: QrData(
        qrCodeBase64: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...',
        qrText: 'QR_test_ticket_001_encrypted',
        ticketId: 'test_ticket_001',
        ticketNumber: 'GOVT251022110001',
        passengerId: 'test_passenger_001',
        busId: '68ea0d6cbbb53ea5402bd1b4',
        routeId: '68ea0d6cbbb53ea5402bd1b0',
        boardingStationId: '68ea0d6cbbb53ea5402bd1a8',
        destinationStationId: '68ea0d6cbbb53ea5402bd1aa',
        travelDate:
            now.add(const Duration(hours: 2)).toIso8601String().split('T')[0],
        validUntil:
            now.add(const Duration(hours: 8)).toIso8601String().split('T')[0],
        fareAmount: 47.0,
        subsidyAmount: 5.0,
        governmentSignature: 'GOVT-SIG-TEST',
        validationCode: 'VAL_TEST_001',
        issuingAuthority: 'Transport Department',
        departmentCode: 'TRANS_DEPT',
        cityCode: 'SMART_CITY',
        timestamp: now.toIso8601String(),
      ),
    );
  }
}
