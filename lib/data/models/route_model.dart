class Route {
  final String id;
  final String routeName;
  final String routeNumber;
  final String routeCode;
  final String startStationId;
  final String endStationId;
  final List<RouteStation> stations;
  final double distance;
  final int estimatedDuration; // in minutes
  final OperatingHours operatingHours;
  final int frequency; // minutes between buses
  final bool isActive;
  final RouteType routeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Government specific fields
  final RoutePermit routePermit;
  final List<FareSegment> fareStructure;
  final SafetyMeasures safetyMeasures;

  const Route({
    required this.id,
    required this.routeName,
    required this.routeNumber,
    required this.routeCode,
    required this.startStationId,
    required this.endStationId,
    required this.stations,
    required this.distance,
    required this.estimatedDuration,
    required this.operatingHours,
    required this.frequency,
    required this.isActive,
    required this.routeType,
    required this.createdAt,
    required this.updatedAt,
    required this.routePermit,
    required this.fareStructure,
    required this.safetyMeasures,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] ?? json['_id'] ?? '',
      routeName: json['route_name'] ?? '',
      routeNumber: json['route_number'] ?? '',
      routeCode: json['route_code'] ?? '',
      startStationId: json['start_station_id'] ?? '',
      endStationId: json['end_station_id'] ?? '',
      stations: (json['stations'] as List<dynamic>?)
              ?.map((e) => RouteStation.fromJson(e))
              .toList() ??
          [],
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedDuration: json['estimated_duration'] ?? 0,
      operatingHours: OperatingHours.fromJson(json['operating_hours'] ?? {}),
      frequency: json['frequency'] ?? 0,
      isActive: json['is_active'] ?? false,
      routeType: _parseRouteType(json['route_type']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      routePermit: RoutePermit.fromJson(json['route_permit'] ?? {}),
      fareStructure: (json['fare_structure'] as List<dynamic>?)
              ?.map((e) => FareSegment.fromJson(e))
              .toList() ??
          [],
      safetyMeasures: SafetyMeasures.fromJson(json['safety_measures'] ?? {}),
    );
  }

  static RouteType _parseRouteType(String? type) {
    switch (type) {
      case 'city':
        return RouteType.city;
      case 'intercity':
        return RouteType.intercity;
      case 'express':
        return RouteType.express;
      case 'local':
        return RouteType.local;
      case 'shuttle':
        return RouteType.shuttle;
      case 'special':
        return RouteType.special;
      default:
        return RouteType.local;
    }
  }
}

enum RouteType {
  city,
  intercity,
  express,
  local,
  shuttle,
  special,
}

class RouteStation {
  final String stationId;
  final String stationName;
  final int sequenceNumber;
  final double distanceFromStart;
  final int estimatedArrival; // minutes from start
  final String? platformNumber;
  final bool isAccessible;

  const RouteStation({
    required this.stationId,
    required this.stationName,
    required this.sequenceNumber,
    required this.distanceFromStart,
    required this.estimatedArrival,
    this.platformNumber,
    required this.isAccessible,
  });

  factory RouteStation.fromJson(Map<String, dynamic> json) {
    return RouteStation(
      stationId: json['station_id'] ?? '',
      stationName: json['station_name'] ?? '',
      sequenceNumber: json['sequence_number'] ?? 0,
      distanceFromStart: (json['distance_from_start'] ?? 0).toDouble(),
      estimatedArrival: json['estimated_arrival'] ?? 0,
      platformNumber: json['platform_number'],
      isAccessible: json['is_accessible'] ?? false,
    );
  }
}

class OperatingHours {
  final String startTime; // HH:MM format
  final String endTime; // HH:MM format
  final List<String> operatingDays; // ["monday", "tuesday", ...]
  final List<SpecialHour>? specialHours;

  const OperatingHours({
    required this.startTime,
    required this.endTime,
    required this.operatingDays,
    this.specialHours,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      operatingDays: List<String>.from(json['operating_days'] ?? []),
      specialHours: (json['special_hours'] as List<dynamic>?)
          ?.map((e) => SpecialHour.fromJson(e))
          .toList(),
    );
  }
}

class SpecialHour {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String reason;

  const SpecialHour({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  factory SpecialHour.fromJson(Map<String, dynamic> json) {
    return SpecialHour(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class RoutePermit {
  final String permitNumber;
  final String issuingAuthority;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String permitType;
  final int authorizedCapacity;
  final bool isValid;

  const RoutePermit({
    required this.permitNumber,
    required this.issuingAuthority,
    required this.issueDate,
    required this.expiryDate,
    required this.permitType,
    required this.authorizedCapacity,
    required this.isValid,
  });

  factory RoutePermit.fromJson(Map<String, dynamic> json) {
    return RoutePermit(
      permitNumber: json['permit_number'] ?? '',
      issuingAuthority: json['issuing_authority'] ?? '',
      issueDate: DateTime.tryParse(json['issue_date'] ?? '') ?? DateTime.now(),
      expiryDate:
          DateTime.tryParse(json['expiry_date'] ?? '') ?? DateTime.now(),
      permitType: json['permit_type'] ?? '',
      authorizedCapacity: json['authorized_capacity'] ?? 0,
      isValid: json['is_valid'] ?? false,
    );
  }
}

class FareSegment {
  final String fromStationId;
  final String toStationId;
  final double distance;
  final double baseFare;
  final double? acFare;

  const FareSegment({
    required this.fromStationId,
    required this.toStationId,
    required this.distance,
    required this.baseFare,
    this.acFare,
  });

  factory FareSegment.fromJson(Map<String, dynamic> json) {
    return FareSegment(
      fromStationId: json['from_station_id'] ?? '',
      toStationId: json['to_station_id'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      baseFare: (json['base_fare'] ?? 0).toDouble(),
      acFare: json['ac_fare']?.toDouble(),
    );
  }
}

class SafetyMeasures {
  final int emergencyExits;
  final bool firstAidKit;
  final bool fireExtinguisher;
  final bool gpsTracking;
  final bool panicButton;
  final int cctvCameras;
  final List<String> emergencyContactNums;

  const SafetyMeasures({
    required this.emergencyExits,
    required this.firstAidKit,
    required this.fireExtinguisher,
    required this.gpsTracking,
    required this.panicButton,
    required this.cctvCameras,
    required this.emergencyContactNums,
  });

  factory SafetyMeasures.fromJson(Map<String, dynamic> json) {
    return SafetyMeasures(
      emergencyExits: json['emergency_exits'] ?? 0,
      firstAidKit: json['first_aid_kit'] ?? false,
      fireExtinguisher: json['fire_extinguisher'] ?? false,
      gpsTracking: json['gps_tracking'] ?? false,
      panicButton: json['panic_button'] ?? false,
      cctvCameras: json['cctv_cameras'] ?? 0,
      emergencyContactNums:
          List<String>.from(json['emergency_contact_nums'] ?? []),
    );
  }
} // minutes from start
