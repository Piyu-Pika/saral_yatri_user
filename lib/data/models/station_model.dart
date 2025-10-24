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

  factory StationModel.fromJson(Map<String, dynamic> json,
      {String? routeId, int? sequence}) {
    // Handle different possible location formats
    LatLng location;
    if (json['location'] != null) {
      if (json['location'] is Map) {
        location = LatLng(
          (json['location']['latitude'] ?? 0.0).toDouble(),
          (json['location']['longitude'] ?? 0.0).toDouble(),
        );
      } else {
        location = const LatLng(0.0, 0.0);
      }
    } else if (json['latitude'] != null && json['longitude'] != null) {
      location = LatLng(
        (json['latitude'] ?? 0.0).toDouble(),
        (json['longitude'] ?? 0.0).toDouble(),
      );
    } else {
      location = const LatLng(0.0, 0.0);
    }

    return StationModel(
      id: (json['id'] ?? json['station_id'] ?? '').toString(),
      name: (json['name'] ?? json['station_name'] ?? '').toString(),
      code: (json['code'] ?? json['station_code'] ?? '').toString(),
      location: location,
      sequence: sequence ?? (json['sequence'] ?? json['order'] ?? 0).toInt(),
      routeId:
          routeId ?? (json['route_id'] ?? json['routeId'] ?? '').toString(),
      isActive: json['is_active'] ?? json['active'] ?? true,
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
