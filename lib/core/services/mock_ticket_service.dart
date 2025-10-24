import 'dart:convert';
import '../../../data/models/enhanced_ticket_model.dart';

class MockTicketService {
  /// Mock API response data based on the provided ticket booking response
  static Map<String, dynamic> getMockTicketResponse() {
    return {
      "data": {
        "ticket": {
          "id": "68f76de8d91044e7edd4a958",
          "ticket_number": "GOVT251021165632",
          "ticket_type": "single",
          "passenger_id": "68f4f4af369f77442bb24394",
          "bus_id": "68ea0d6cbbb53ea5402bd1b4",
          "route_id": "68ea0d6cbbb53ea5402bd1b0",
          "boarding_station_id": "68ea0d6cbbb53ea5402bd1a8",
          "destination_station_id": "68ea0d6cbbb53ea5402bd1aa",
          "booking_time": "2025-10-21T16:56:32.44100679+05:30",
          "travel_date": "2024-01-15T10:00:00Z",
          "valid_until": "2024-01-16T10:00:00Z",
          "status": "booked",
          "fare_details": {
            "base_fare": 50,
            "gross_fare": 50,
            "applied_subsidies": null,
            "total_subsidy_amount": 0,
            "net_fare": 50,
            "taxes": null,
            "total_tax_amount": 0,
            "final_amount": 50,
            "government_share": 0,
            "passenger_share": 50
          },
          "qr_token":
              "{\"ticket_id\":\"68f76de8d91044e7edd4a958\",\"ticket_number\":\"GOVT251021165632\",\"passenger_id\":\"68f4f4af369f77442bb24394\",\"bus_id\":\"68ea0d6cbbb53ea5402bd1b4\",\"route_id\":\"68ea0d6cbbb53ea5402bd1b0\",\"boarding_station_id\":\"68ea0d6cbbb53ea5402bd1a8\",\"destination_station_id\":\"68ea0d6cbbb53ea5402bd1aa\",\"travel_date\":\"2024-01-15\",\"valid_until\":\"2024-01-16\",\"fare_amount\":50,\"subsidy_amount\":0,\"government_signature\":\"GOVT-SIG-3638663736646538643931303434653765646434613935382d474f56543235313032313136353633322d3638663466346166333639663737343432626232343339342d323032342d30312d3135\",\"validation_code\":\"VAL_457772\",\"issuing_authority\":\"Transport Department\",\"department_code\":\"TRANS_DEPT\",\"city_code\":\"SMART_CITY\",\"timestamp\":\"2025-10-21T16:56:32+05:30\"}",
          "encrypted_token":
              "fIAwhfB7baQ1ma63sbkmT8la5PvD47nwF9SgAAchhdabNAlHULKr91Jb4Pkh9q5x2Q3nCR4/UoRC5D0/2XBFGq8Q20RMVHtYVM3/b72lBq2dlmrkRN9eSlUw71hFGNnW3yRVMUPJCMMezu7niMBUqTOPtLmJl1G8Ffsh+Oh187TSseGdCuIbXgjehsxbUeakaumkva++EHPg+nBnTY+TnbVKReAtn2D41sX2mjb5HvWAANtpbv7NIhyW03509Pi929RozyxGZ7OYvWDVRYAa5f7gTbbNu6Bqxfl8rkqibqBzUYrzTEbB9iutMDahoT9szrZDueUwZPPuYlrOMT1EQs4k+VxMYXlHpiz9msqvMytuZ5XSJa/vbddnDOjaFvHe3y33yVcpZhNZ+0BawNgjlOzx8RK8UrrD6dZJ2AMiPz9MNVlKU2mhXpAJ9Q==",
          "is_verified": false,
          "compliance_data": {
            "revenue_date": "2025-10-21T16:56:32.44100742+05:30",
            "accounting_code": "GOVT_BUS_REVENUE",
            "revenue_head": "Transport Department",
            "is_govt_funded": false,
            "audit_trail_id": "AUDIT_1761045992441007490",
            "transaction_ref": "TXN_1761045992441009780"
          },
          "payment_details": {
            "payment_mode": "upi",
            "payment_method": "",
            "transaction_id": "PAY_1761045992441010340",
            "payment_status": "completed",
            "payment_time": "2025-10-21T16:56:32.4410108+05:30"
          },
          "created_at": "2025-10-21T16:56:32.44101185+05:30",
          "updated_at": "2025-10-21T16:56:32.504709192+05:30"
        },
        "qr_data": {
          "ticket_id": "68f76de8d91044e7edd4a958",
          "ticket_number": "GOVT251021165632",
          "passenger_id": "68f4f4af369f77442bb24394",
          "bus_id": "68ea0d6cbbb53ea5402bd1b4",
          "route_id": "68ea0d6cbbb53ea5402bd1b0",
          "boarding_station_id": "68ea0d6cbbb53ea5402bd1a8",
          "destination_station_id": "68ea0d6cbbb53ea5402bd1aa",
          "travel_date": "2024-01-15",
          "valid_until": "2024-01-16",
          "fare_amount": 50,
          "subsidy_amount": 0,
          "government_signature":
              "GOVT-SIG-3638663736646538643931303434653765646434613935382d474f56543235313032313136353633322d3638663466346166333639663737343432626232343339342d323032342d30312d3135",
          "validation_code": "VAL_457772",
          "issuing_authority": "Transport Department",
          "department_code": "TRANS_DEPT",
          "city_code": "SMART_CITY",
          "timestamp": "2025-10-21T16:56:32+05:30"
        }
      },
      "message":
          "Ticket booked successfully. Use QR data to generate QR code on frontend.",
      "instructions": {
        "qr_generation":
            "Use the qr_data object to generate QR code on frontend",
        "qr_libraries": [
          "qrcode.js",
          "react-qr-code",
          "vue-qrcode",
          "angular-qr"
        ]
      },
      "success": true
    };
  }

  /// Create a mock enhanced ticket for testing
  static EnhancedTicketModel createMockEnhancedTicket({
    String? busId,
    String? routeId,
    String? boardingStationId,
    String? destinationStationId,
    String? paymentMethod,
    String ticketType = 'single',
    DateTime? travelDate,
  }) {
    final mockResponse = getMockTicketResponse();

    // Update with provided parameters
    if (busId != null) {
      mockResponse['data']['ticket']['bus_id'] = busId;
      mockResponse['data']['qr_data']['bus_id'] = busId;
    }
    if (routeId != null) {
      mockResponse['data']['ticket']['route_id'] = routeId;
      mockResponse['data']['qr_data']['route_id'] = routeId;
    }
    if (boardingStationId != null) {
      mockResponse['data']['ticket']['boarding_station_id'] = boardingStationId;
      mockResponse['data']['qr_data']['boarding_station_id'] =
          boardingStationId;
    }
    if (destinationStationId != null) {
      mockResponse['data']['ticket']['destination_station_id'] =
          destinationStationId;
      mockResponse['data']['qr_data']['destination_station_id'] =
          destinationStationId;
    }
    if (paymentMethod != null) {
      mockResponse['data']['ticket']['payment_details']['payment_mode'] =
          paymentMethod;
    }
    if (travelDate != null) {
      final formattedDate = travelDate.toIso8601String();
      final dateOnly = travelDate.toIso8601String().split('T')[0];
      mockResponse['data']['ticket']['travel_date'] = formattedDate;
      mockResponse['data']['qr_data']['travel_date'] = dateOnly;

      // Set valid until to next day
      final validUntil = travelDate.add(const Duration(days: 1));
      mockResponse['data']['ticket']['valid_until'] =
          validUntil.toIso8601String();
      mockResponse['data']['qr_data']['valid_until'] =
          validUntil.toIso8601String().split('T')[0];
    }

    mockResponse['data']['ticket']['ticket_type'] = ticketType;

    // Update timestamps to current time
    final now = DateTime.now();
    final nowString = now.toIso8601String();
    mockResponse['data']['ticket']['booking_time'] = nowString;
    mockResponse['data']['ticket']['created_at'] = nowString;
    mockResponse['data']['ticket']['updated_at'] = nowString;
    mockResponse['data']['ticket']['payment_details']['payment_time'] =
        nowString;
    mockResponse['data']['ticket']['compliance_data']['revenue_date'] =
        nowString;
    mockResponse['data']['qr_data']['timestamp'] = nowString;

    // Generate new ticket number with current timestamp
    final ticketNumber =
        'GOVT${now.millisecondsSinceEpoch.toString().substring(7)}';
    mockResponse['data']['ticket']['ticket_number'] = ticketNumber;
    mockResponse['data']['qr_data']['ticket_number'] = ticketNumber;

    // Update QR token with new data - prioritize encrypted_token
    final qrDataJson = jsonEncode(mockResponse['data']['qr_data']);
    // Keep the encrypted_token as is (it's already properly encrypted)
    // Only update qr_token as fallback
    if (mockResponse['data']['ticket']['encrypted_token'] == null ||
        mockResponse['data']['ticket']['encrypted_token'].isEmpty) {
      mockResponse['data']['ticket']['qr_token'] = qrDataJson;
    }

    return EnhancedTicketModel.fromJson(mockResponse);
  }
}
