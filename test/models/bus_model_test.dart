import 'package:flutter_test/flutter_test.dart';
import 'package:saral_yatri/data/models/bus_model.dart';

void main() {
  group('BusModel', () {
    test('should parse JSON from QR scan response correctly', () {
      // Sample JSON from QR scan response
      final json = {
        "id": "68e296d634860677dc476c85",
        "bus_number": "UP16AB1234",
        "fleet_number": "FLEET01",
        "bus_type": "ordinary",
        "route_id": "68e296d634860677dc476c83",
        "driver_id": "000000000000000000000000",
        "conductor_id": "68ea48334295f49fbb118065",
        "is_active": true,
        "created_at": "2025-10-05T16:03:34.233Z",
        "updated_at": "2025-10-11T12:06:11.373Z",
        "vehicle_compliance": {
          "registration_number": "",
          "emission_standard": "BS6",
          "fitness_expiry_date": "2026-10-05T16:03:34.232Z",
          "insurance_expiry_date": "2026-04-05T16:03:34.233Z",
          "permit_expiry_date": "2026-04-05T16:03:34.233Z",
          "pollution_cert_expiry": "2026-01-05T16:03:34.233Z",
          "tax_expiry_date": "0001-01-01T00:00:00Z",
          "is_compliant": false,
          "last_inspection_date": "0001-01-01T00:00:00Z",
          "next_inspection_date": "0001-01-01T00:00:00Z"
        },
        "specifications": {
          "seating_capacity": 50,
          "wheelchair_spaces": 0,
          "fuel_type": "",
          "fuel_capacity": 0,
          "manufacturer": "",
          "model": "",
          "year_of_manufacture": 0,
          "is_accessible": true,
          "has_air_conditioning": false,
          "has_wifi": false,
          "has_gps": false
        },
        "maintenance_record": null,
        "current_status": "parked"
      };

      final bus = BusModel.fromJson(json);

      expect(bus.id, equals("68e296d634860677dc476c85"));
      expect(bus.busNumber, equals("UP16AB1234"));
      expect(bus.fleetNumber, equals("FLEET01"));
      expect(bus.busType, equals("ordinary"));
      expect(bus.routeId, equals("68e296d634860677dc476c83"));
      expect(bus.isActive, equals(true));
      expect(bus.currentStatus, equals("parked"));
      expect(bus.seatingCapacity, equals(50));
      expect(bus.hasAirConditioning, equals(false));
      expect(bus.hasWifi, equals(false));
      expect(bus.hasGps, equals(false));
      expect(bus.isAccessible, equals(true));
      expect(bus.emissionStandard, equals("BS6"));
      expect(bus.isCompliant, equals(false));
      expect(bus.fitnessExpiryDate, isNotNull);
      expect(bus.insuranceExpiryDate, isNotNull);
    });

    test('should handle missing optional fields gracefully', () {
      final json = {
        "id": "test-id",
        "bus_number": "TEST123",
        "is_active": true,
        "updated_at": "2025-10-21T12:00:00.000Z",
        "current_status": "running"
      };

      final bus = BusModel.fromJson(json);

      expect(bus.id, equals("test-id"));
      expect(bus.busNumber, equals("TEST123"));
      expect(bus.fleetNumber, equals(""));
      expect(bus.busType, equals(""));
      expect(bus.seatingCapacity, equals(0));
      expect(bus.hasAirConditioning, equals(false));
      expect(bus.emissionStandard, equals(""));
      expect(bus.fitnessExpiryDate, isNull);
      expect(bus.insuranceExpiryDate, isNull);
    });
  });
}