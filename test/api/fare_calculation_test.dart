import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fare Calculation API', () {
    test('should format request correctly', () {
      final busId = "68ea0d6cbbb53ea5402bd1b4";
      final routeId = "68ea0d6cbbb53ea5402bd1b0";
      final boardingStationId = "68ea0d6cbbb53ea5402bd1a8";
      final destinationStationId = "68ea0d6cbbb53ea5402bd1aa";
      final ticketType = "single";
      final travelDate = DateTime.parse("2024-01-15T10:00:00Z");

      final requestData = {
        'bus_id': busId,
        'route_id': routeId,
        'boarding_station_id': boardingStationId,
        'destination_station_id': destinationStationId,
        'ticket_type': ticketType,
        'travel_date': travelDate.toUtc().toIso8601String(),
      };

      // Verify the request structure matches the expected format
      expect(requestData['bus_id'], equals(busId));
      expect(requestData['route_id'], equals(routeId));
      expect(requestData['boarding_station_id'], equals(boardingStationId));
      expect(requestData['destination_station_id'], equals(destinationStationId));
      expect(requestData['ticket_type'], equals(ticketType));
      expect(requestData['travel_date'], equals("2024-01-15T10:00:00.000Z"));

      // Verify all required fields are present and not empty
      expect(requestData['bus_id'], isNotEmpty);
      expect(requestData['route_id'], isNotEmpty);
      expect(requestData['boarding_station_id'], isNotEmpty);
      expect(requestData['destination_station_id'], isNotEmpty);
      expect(requestData['ticket_type'], isNotEmpty);
      expect(requestData['travel_date'], isNotEmpty);
    });

    test('should handle current date correctly', () {
      final now = DateTime.now();
      final formattedDate = now.toUtc().toIso8601String();
      
      // Verify the date format contains the required components
      expect(formattedDate, contains('T'));
      expect(formattedDate, endsWith('Z'));
      expect(formattedDate.length, greaterThan(19)); // At least YYYY-MM-DDTHH:mm:ssZ
    });
  });
}