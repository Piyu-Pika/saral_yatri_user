import 'package:latlong2/latlong.dart';

class BusModel {
  final String id;
  final String busNumber;
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

  BusModel({
    required this.id,
    required this.busNumber,
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
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id'] ?? '',
      busNumber: json['bus_number'] ?? '',
      routeId: json['route_id'] ?? '',
      routeName: json['route_name'] ?? '',
      currentLocation: LatLng(
        json['current_location']?['latitude'] ?? 0.0,
        json['current_location']?['longitude'] ?? 0.0,
      ),
      driverName: json['driver_name'] ?? '',
      conductorName: json['conductor_name'] ?? '',
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      isActive: json['is_active'] ?? false,
      qrCode: json['qr_code'] ?? '',
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_number': busNumber,
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
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  BusModel copyWith({
    String? id,
    String? busNumber,
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
  }) {
    return BusModel(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
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
    );
  }
}