import 'package:latlong2/latlong.dart';

class BusModel {
  final String id;
  final String busNumber;
  final String fleetNumber;
  final String busType;
  final String routeId;
  final String routeName;
  final LatLng currentLocation;
  final String driverName;
  final String conductorName;
  final int totalSeats;
  final int availableSeats;
  final bool isActive;
  final String qrCode;
  final DateTime lastUpdated;
  final String currentStatus;

  // Vehicle specifications
  final int seatingCapacity;
  final bool hasAirConditioning;
  final bool hasWifi;
  final bool hasGps;
  final bool isAccessible;

  // Vehicle compliance
  final String emissionStandard;
  final DateTime? fitnessExpiryDate;
  final DateTime? insuranceExpiryDate;
  final bool isCompliant;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.fleetNumber,
    required this.busType,
    required this.routeId,
    required this.routeName,
    required this.currentLocation,
    required this.driverName,
    required this.conductorName,
    required this.totalSeats,
    required this.availableSeats,
    required this.isActive,
    required this.qrCode,
    required this.lastUpdated,
    required this.currentStatus,
    required this.seatingCapacity,
    required this.hasAirConditioning,
    required this.hasWifi,
    required this.hasGps,
    required this.isAccessible,
    required this.emissionStandard,
    this.fitnessExpiryDate,
    this.insuranceExpiryDate,
    required this.isCompliant,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    final specs = json['specifications'] ?? {};
    final compliance = json['vehicle_compliance'] ?? {};

    return BusModel(
      id: json['id'] ?? '',
      busNumber: json['bus_number'] ?? '',
      fleetNumber: json['fleet_number'] ?? '',
      busType: json['bus_type'] ?? '',
      routeId: json['route_id'] ?? '',
      routeName: json['route_name'] ?? '',
      currentLocation: LatLng(
        json['current_location']?['latitude'] ?? 0.0,
        json['current_location']?['longitude'] ?? 0.0,
      ),
      driverName: json['driver_name'] ?? '',
      conductorName: json['conductor_name'] ?? '',
      totalSeats: json['total_seats'] ?? specs['seating_capacity'] ?? 0,
      availableSeats: json['available_seats'] ?? specs['seating_capacity'] ?? 0,
      isActive: json['is_active'] ?? false,
      qrCode: json['qr_code'] ?? '',
      lastUpdated: DateTime.parse(json['updated_at'] ??
          json['last_updated'] ??
          DateTime.now().toIso8601String()),
      currentStatus: json['current_status'] ?? 'unknown',
      seatingCapacity: specs['seating_capacity'] ?? 0,
      hasAirConditioning: specs['has_air_conditioning'] ?? false,
      hasWifi: specs['has_wifi'] ?? false,
      hasGps: specs['has_gps'] ?? false,
      isAccessible: specs['is_accessible'] ?? false,
      emissionStandard: compliance['emission_standard'] ?? '',
      fitnessExpiryDate: compliance['fitness_expiry_date'] != null &&
              compliance['fitness_expiry_date'] != "0001-01-01T00:00:00Z"
          ? DateTime.tryParse(compliance['fitness_expiry_date'])
          : null,
      insuranceExpiryDate: compliance['insurance_expiry_date'] != null &&
              compliance['insurance_expiry_date'] != "0001-01-01T00:00:00Z"
          ? DateTime.tryParse(compliance['insurance_expiry_date'])
          : null,
      isCompliant: compliance['is_compliant'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_number': busNumber,
      'fleet_number': fleetNumber,
      'bus_type': busType,
      'route_id': routeId,
      'route_name': routeName,
      'current_location': {
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      },
      'driver_name': driverName,
      'conductor_name': conductorName,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'is_active': isActive,
      'qr_code': qrCode,
      'updated_at': lastUpdated.toIso8601String(),
      'current_status': currentStatus,
      'specifications': {
        'seating_capacity': seatingCapacity,
        'has_air_conditioning': hasAirConditioning,
        'has_wifi': hasWifi,
        'has_gps': hasGps,
        'is_accessible': isAccessible,
      },
      'vehicle_compliance': {
        'emission_standard': emissionStandard,
        'fitness_expiry_date': fitnessExpiryDate?.toIso8601String(),
        'insurance_expiry_date': insuranceExpiryDate?.toIso8601String(),
        'is_compliant': isCompliant,
      },
    };
  }

  BusModel copyWith({
    String? id,
    String? busNumber,
    String? fleetNumber,
    String? busType,
    String? routeId,
    String? routeName,
    LatLng? currentLocation,
    String? driverName,
    String? conductorName,
    int? totalSeats,
    int? availableSeats,
    bool? isActive,
    String? qrCode,
    DateTime? lastUpdated,
    String? currentStatus,
    int? seatingCapacity,
    bool? hasAirConditioning,
    bool? hasWifi,
    bool? hasGps,
    bool? isAccessible,
    String? emissionStandard,
    DateTime? fitnessExpiryDate,
    DateTime? insuranceExpiryDate,
    bool? isCompliant,
  }) {
    return BusModel(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      fleetNumber: fleetNumber ?? this.fleetNumber,
      busType: busType ?? this.busType,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      currentLocation: currentLocation ?? this.currentLocation,
      driverName: driverName ?? this.driverName,
      conductorName: conductorName ?? this.conductorName,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      isActive: isActive ?? this.isActive,
      qrCode: qrCode ?? this.qrCode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentStatus: currentStatus ?? this.currentStatus,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasWifi: hasWifi ?? this.hasWifi,
      hasGps: hasGps ?? this.hasGps,
      isAccessible: isAccessible ?? this.isAccessible,
      emissionStandard: emissionStandard ?? this.emissionStandard,
      fitnessExpiryDate: fitnessExpiryDate ?? this.fitnessExpiryDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      isCompliant: isCompliant ?? this.isCompliant,
    );
  }
}
