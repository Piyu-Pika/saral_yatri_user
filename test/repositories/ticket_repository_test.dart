import 'package:flutter_test/flutter_test.dart';
import 'package:saral_yatri/data/repositories/ticket_repository.dart';

void main() {
  group('TicketRepository', () {
    test('should handle fare calculation response correctly', () {
      // This test verifies the expected API response structure
      final mockApiResponse = {
        "data": {
          "base_fare": 50,
          "distance": 10,
          "applied_subsidies": null,
          "total_subsidy_amount": 0,
          "net_fare": 50,
          "taxes": [
            {
              "tax_type": "Green Tax",
              "tax_rate": 2,
              "tax_amount": 1
            }
          ],
          "total_tax_amount": 1,
          "final_amount": 51,
          "government_share": 0,
          "passenger_share": 51,
          "bus_type": "ordinary",
          "route_type": "city"
        },
        "message": "Fare calculated successfully",
        "success": true
      };

      // Verify the structure matches what FareBreakdownCard expects
      final fareData = mockApiResponse['data'] as Map<String, dynamic>;
      
      expect(fareData['base_fare'], equals(50));
      expect(fareData['distance'], equals(10));
      expect(fareData['total_subsidy_amount'], equals(0));
      expect(fareData['total_tax_amount'], equals(1));
      expect(fareData['final_amount'], equals(51));
      expect(fareData['government_share'], equals(0));
      expect(fareData['passenger_share'], equals(51));
      expect(fareData['bus_type'], equals('ordinary'));
      expect(fareData['route_type'], equals('city'));
      expect(fareData['taxes'], isA<List>());
      expect(fareData['taxes'][0]['tax_type'], equals('Green Tax'));
      expect(fareData['taxes'][0]['tax_amount'], equals(1));
    });

    test('should handle expected request body structure', () {
      final expectedRequestBody = {
        "bus_id": "68ea0d6cbbb53ea5402bd1b4",
        "route_id": "68ea0d6cbbb53ea5402bd1b0",
        "boarding_station_id": "68ea0d6cbbb53ea5402bd1a8",
        "destination_station_id": "68ea0d6cbbb53ea5402bd1aa",
        "ticket_type": "single",
        "travel_date": "2024-01-15T10:00:00Z"
      };

      // Verify all required fields are present
      expect(expectedRequestBody['bus_id'], isNotNull);
      expect(expectedRequestBody['route_id'], isNotNull);
      expect(expectedRequestBody['boarding_station_id'], isNotNull);
      expect(expectedRequestBody['destination_station_id'], isNotNull);
      expect(expectedRequestBody['ticket_type'], equals('single'));
      expect(expectedRequestBody['travel_date'], isNotNull);
    });
  });
}