import 'package:latlong2/latlong.dart';

class BusStopModel {
  final String id;
  final String name;
  final LatLng location;
  final String address;
  final List<String> routeIds;
  final bool isActive;
  final String? amenities;

  BusStopModel({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.routeIds,
    required this.isActive,
    this.amenities,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: LatLng(
        json['location']?['latitude'] ?? 0.0,
        json['location']?['longitude'] ?? 0.0,
      ),
      address: json['address'] ?? '',
      routeIds: List<String>.from(json['route_ids'] ?? []),
      isActive: json['is_active'] ?? false,
      amenities: json['amenities'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'route_ids': routeIds,
      'is_active': isActive,
      'amenities': amenities,
    };
  }

  BusStopModel copyWith({
    String? id,
    String? name,
    LatLng? location,
    String? address,
    List<String>? routeIds,
    bool? isActive,
    String? amenities,
  }) {
    return BusStopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      routeIds: routeIds ?? this.routeIds,
      isActive: isActive ?? this.isActive,
      amenities: amenities ?? this.amenities,
    );
  }
}
