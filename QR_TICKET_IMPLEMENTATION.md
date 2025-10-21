# QR Ticket Implementation

This document explains the QR ticket system implementation for the Saral Yatri bus booking app.

## Overview

The QR ticket system generates secure QR codes for bus tickets that can be scanned by conductors for verification. The implementation includes:

1. **Enhanced Ticket Model** - Comprehensive ticket data structure matching the API response
2. **QR Code Generation** - Secure QR codes with government signatures and validation codes
3. **QR Ticket Screen** - Beautiful ticket display with QR code
4. **Mock Service** - For testing and demonstration

## Key Features

### 🎫 Enhanced Ticket Model
- Complete ticket information including fare breakdown
- Government compliance data with audit trails
- Payment details and transaction tracking
- QR data with validation codes and signatures

### 🔒 Security Features
- Government digital signatures
- Validation codes for verification
- Encrypted tokens for additional security
- Audit trail tracking

### 📱 User Experience
- Beautiful animated ticket display
- Copy ticket number functionality
- Status indicators (Active, Expired, Used)
- Detailed fare breakdown
- Important usage instructions

## Implementation Details

### Files Created/Modified

1. **lib/data/models/enhanced_ticket_model.dart**
   - Complete ticket data structure
   - Fare details, compliance data, payment details
   - QR data structure for code generation

2. **lib/core/utils/qr_utils.dart**
   - QR code generation utilities
   - Data validation and parsing
   - Custom QR code painter

3. **lib/presentation/screens/ticket/qr_ticket_screen.dart**
   - Beautiful ticket display screen
   - Animated transitions
   - QR code display with validation

4. **lib/core/services/mock_ticket_service.dart**
   - Mock API response for testing
   - Configurable ticket generation
   - Based on real API response structure

5. **Updated Files:**
   - `lib/data/repositories/ticket_repository.dart` - Added enhanced booking
   - `lib/presentation/providers/ticket_provider.dart` - Enhanced state management
   - `lib/presentation/screens/booking/payment_screen.dart` - QR ticket navigation
   - `lib/app.dart` - Added demo route

### API Response Structure

The system expects this API response structure:

```json
{
  "data": {
    "ticket": {
      "id": "ticket_id",
      "ticket_number": "GOVT251021165632",
      "ticket_type": "single",
      "passenger_id": "passenger_id",
      "bus_id": "bus_id",
      "route_id": "route_id",
      "boarding_station_id": "station_id",
      "destination_station_id": "station_id",
      "booking_time": "2025-10-21T16:56:32+05:30",
      "travel_date": "2024-01-15T10:00:00Z",
      "valid_until": "2024-01-16T10:00:00Z",
      "status": "booked",
      "fare_details": {
        "base_fare": 50,
        "gross_fare": 50,
        "total_subsidy_amount": 0,
        "net_fare": 50,
        "total_tax_amount": 0,
        "final_amount": 50,
        "government_share": 0,
        "passenger_share": 50
      },
      "qr_token": "...",
      "encrypted_token": "...",
      "is_verified": false,
      "compliance_data": {
        "revenue_date": "2025-10-21T16:56:32+05:30",
        "accounting_code": "GOVT_BUS_REVENUE",
        "revenue_head": "Transport Department",
        "is_govt_funded": false,
        "audit_trail_id": "AUDIT_...",
        "transaction_ref": "TXN_..."
      },
      "payment_details": {
        "payment_mode": "upi",
        "transaction_id": "PAY_...",
        "payment_status": "completed",
        "payment_time": "2025-10-21T16:56:32+05:30"
      }
    },
    "qr_data": {
      "ticket_id": "ticket_id",
      "ticket_number": "GOVT251021165632",
      "passenger_id": "passenger_id",
      "bus_id": "bus_id",
      "route_id": "route_id",
      "boarding_station_id": "station_id",
      "destination_station_id": "station_id",
      "travel_date": "2024-01-15",
      "valid_until": "2024-01-16",
      "fare_amount": 50,
      "subsidy_amount": 0,
      "government_signature": "GOVT-SIG-...",
      "validation_code": "VAL_457772",
      "issuing_authority": "Transport Department",
      "department_code": "TRANS_DEPT",
      "city_code": "SMART_CITY",
      "timestamp": "2025-10-21T16:56:32+05:30"
    }
  },
  "message": "Ticket booked successfully",
  "success": true
}
```

## Usage

### 1. Booking Flow
```dart
// In payment screen, after successful payment:
final success = await ref.read(ticketProvider.notifier).bookEnhancedTicket(
  busId: busId,
  routeId: routeId,
  boardingStationId: boardingStationId,
  droppingStationId: droppingStationId,
  paymentMethod: paymentMethod,
  ticketType: ticketType,
  travelDate: travelDate,
);

if (success) {
  final enhancedTicket = ref.read(ticketProvider).currentEnhancedTicket;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => QrTicketScreen(ticket: enhancedTicket!),
    ),
  );
}
```

### 2. QR Code Generation
```dart
// Generate QR code widget
final qrWidget = QrUtils.generateQrWidget(
  ticket.qrData,
  size: 200,
  foregroundColor: Colors.black,
  backgroundColor: Colors.white,
);
```

### 3. QR Data Validation
```dart
// Validate scanned QR data
final isValid = QrUtils.isValidQrData(scannedData);
if (isValid) {
  final qrData = QrUtils.parseQrData(scannedData);
  // Process the ticket data
}
```

## Testing

### Demo Route
Navigate to `/qr-ticket-demo` to see a sample QR ticket with mock data.

### Mock Service
Use `MockTicketService.createMockEnhancedTicket()` to generate test tickets with custom parameters.

## Production Integration

To integrate with your actual API:

1. **Update Repository**: Uncomment the actual API call in `ticket_repository.dart`
2. **Remove Mock**: Remove the mock service call and use real API
3. **Error Handling**: Ensure proper error handling for network issues
4. **Validation**: Add server-side QR code validation

## Security Considerations

1. **Government Signatures**: Validate government signatures on the backend
2. **Validation Codes**: Use validation codes for conductor verification
3. **Encrypted Tokens**: Store sensitive data in encrypted format
4. **Audit Trails**: Maintain complete audit trails for compliance
5. **Expiry Checks**: Always validate ticket expiry before allowing usage

## Dependencies

- `qr: ^3.0.2` - QR code generation
- `flutter_riverpod: ^3.0.3` - State management
- `intl: ^0.19.0` - Date formatting

## Future Enhancements

1. **Offline Support**: Cache tickets for offline viewing
2. **Push Notifications**: Notify users of ticket status changes
3. **Conductor App**: Separate app for ticket verification
4. **Analytics**: Track ticket usage and patterns
5. **Multi-language**: Support for regional languages