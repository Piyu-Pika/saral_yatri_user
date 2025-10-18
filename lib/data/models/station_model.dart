class StationModel {
  final String? id;
  final String stationName;
  final String stationCode;
  final Location location;
  final String stationType;
  final Address address;
  final StationFacilities facilities;
  final Accessibility accessibility;
  final bool isActive;
  final OperatingHours operatingHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String stationAuthority;
  final List<ComplianceCert> complianceCerts;
  final List<EmergencyContact> emergencyContacts;

  StationModel({
    this.id,
    required this.stationName,
    required this.stationCode,
    required this.location,
    required this.stationType,
    required this.address,
    required this.facilities,
    required this.accessibility,
    required this.isActive,
    required this.operatingHours,
    required this.createdAt,
    required this.updatedAt,
    required this.stationAuthority,
    required this.complianceCerts,
    required this.emergencyContacts,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String?,
      stationName: json['station_name'] as String,
      stationCode: json['station_code'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      stationType: json['station_type'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      facilities: StationFacilities.fromJson(json['facilities'] as Map<String, dynamic>),
      accessibility: Accessibility.fromJson(json['accessibility'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      operatingHours: OperatingHours.fromJson(json['operating_hours'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stationAuthority: json['station_authority'] as String,
      complianceCerts: (json['compliance_certs'] as List)
          .map((e) => ComplianceCert.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyContacts: (json['emergency_contacts'] as List)
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'station_name': stationName,
      'station_code': stationCode,
      'location': location.toJson(),
      'station_type': stationType,
      'address': address.toJson(),
      'facilities': facilities.toJson(),
      'accessibility': accessibility.toJson(),
      'is_active': isActive,
      'operating_hours': operatingHours.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'station_authority': stationAuthority,
      'compliance_certs': complianceCerts.map((e) => e.toJson()).toList(),
      'emergency_contacts': emergencyContacts.map((e) => e.toJson()).toList(),
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final double? altitude;

  Location({required this.latitude, required this.longitude, this.altitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
  };
}

class Address {
  final String street;
  final String city;
  final String district;
  final String state;
  final String pincode;

  Address({
    required this.street,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'district': district,
    'state': state,
    'pincode': pincode,
  };
}

class StationFacilities {
  final bool waitingArea;
  final bool restrooms;
  final bool drinkingWater;
  final bool ticketCounter;
  final bool informationDesk;
  final bool payPhone;
  final bool wifi;
  final bool foodCourt;
  final bool atm;
  final bool pharmacy;
  final bool parkingFacility;
  final bool securityOffice;

  StationFacilities({
    required this.waitingArea,
    required this.restrooms,
    required this.drinkingWater,
    required this.ticketCounter,
    required this.informationDesk,
    required this.payPhone,
    required this.wifi,
    required this.foodCourt,
    required this.atm,
    required this.pharmacy,
    required this.parkingFacility,
    required this.securityOffice,
  });

  factory StationFacilities.fromJson(Map<String, dynamic> json) {
    return StationFacilities(
      waitingArea: json['waiting_area'] as bool,
      restrooms: json['restrooms'] as bool,
      drinkingWater: json['drinking_water'] as bool,
      ticketCounter: json['ticket_counter'] as bool,
      informationDesk: json['information_desk'] as bool,
      payPhone: json['pay_phone'] as bool,
      wifi: json['wifi'] as bool,
      foodCourt: json['food_court'] as bool,
      atm: json['atm'] as bool,
      pharmacy: json['pharmacy'] as bool,
      parkingFacility: json['parking_facility'] as bool,
      securityOffice: json['security_office'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'waiting_area': waitingArea,
    'restrooms': restrooms,
    'drinking_water': drinkingWater,
    'ticket_counter': ticketCounter,
    'information_desk': informationDesk,
    'pay_phone': payPhone,
    'wifi': wifi,
    'food_court': foodCourt,
    'atm': atm,
    'pharmacy': pharmacy,
    'parking_facility': parkingFacility,
    'security_office': securityOffice,
  };
}

class Accessibility {
  final bool wheelchairAccess;
  final bool elevatorAccess;
  final bool brailleSignage;
  final bool audioAnnouncement;
  final bool tactileFlooring;
  final bool rampAccess;

  Accessibility({
    required this.wheelchairAccess,
    required this.elevatorAccess,
    required this.brailleSignage,
    required this.audioAnnouncement,
    required this.tactileFlooring,
    required this.rampAccess,
  });

  factory Accessibility.fromJson(Map<String, dynamic> json) {
    return Accessibility(
      wheelchairAccess: json['wheelchair_access'] as bool,
      elevatorAccess: json['elevator_access'] as bool,
      brailleSignage: json['braille_signage'] as bool,
      audioAnnouncement: json['audio_announcement'] as bool,
      tactileFlooring: json['tactile_flooring'] as bool,
      rampAccess: json['ramp_access'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'wheelchair_access': wheelchairAccess,
    'elevator_access': elevatorAccess,
    'braille_signage': brailleSignage,
    'audio_announcement': audioAnnouncement,
    'tactile_flooring': tactileFlooring,
    'ramp_access': rampAccess,
  };
}

class OperatingHours {
  final String startTime;
  final String endTime;
  final List<String> operatingDays;

  OperatingHours({
    required this.startTime,
    required this.endTime,
    required this.operatingDays,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      operatingDays: List<String>.from(json['operating_days'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'end_time': endTime,
    'operating_days': operatingDays,
  };
}

class ComplianceCert {
  final String certType;
  final String certNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String issuedBy;
  final bool isValid;

  ComplianceCert({
    required this.certType,
    required this.certNumber,
    required this.issueDate,
    required this.expiryDate,
    required this.issuedBy,
    required this.isValid,
  });

  factory ComplianceCert.fromJson(Map<String, dynamic> json) {
    return ComplianceCert(
      certType: json['cert_type'] as String,
      certNumber: json['cert_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      issuedBy: json['issued_by'] as String,
      isValid: json['is_valid'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'cert_type': certType,
    'cert_number': certNumber,
    'issue_date': issueDate.toIso8601String(),
    'expiry_date': expiryDate.toIso8601String(),
    'issued_by': issuedBy,
    'is_valid': isValid,
  };
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}
