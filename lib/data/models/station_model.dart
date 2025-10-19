import 'package:latlong2/latlong.dart';

class StationModel {
  final String id;
  final String name;
  final String code;
  final LatLng location;
  final int sequence;
  final String routeId;
  final bool isActive;

  StationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.sequence,
    required this.routeId,
    required this.isActive,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      location: LatLng(
        json['location']?['latitude'] ?? 0.0,
        json['location']?['longitude'] ?? 0.0,
      ),
      sequence: json['sequence'] ?? 0,
      routeId: json['route_id'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'sequence': sequence,
      'route_id': routeId,
      'is_active': isActive,
    };
  }

  StationModel copyWith({
    String? id,
    String? name,
    String? code,
    LatLng? location,
    int? sequence,
    String? routeId,
    bool? isActive,
  }) {
    return StationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      sequence: sequence ?? this.sequence,
      routeId: routeId ?? this.routeId,
      isActive: isActive ?? this.isActive,
    );
  }
}