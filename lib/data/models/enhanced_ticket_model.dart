import 'ticket_model.dart';

class EnhancedTicketModel {
  final String id;
  final String ticketNumber;
  final String ticketType;
  final String passengerId;
  final String busId;
  final String routeId;
  final String boardingStationId;
  final String destinationStationId;
  final DateTime bookingTime;
  final DateTime travelDate;
  final DateTime validUntil;
  final String status;
  final FareDetails fareDetails;
  final String qrToken;
  final String encryptedToken;
  final bool isVerified;
  final ComplianceData complianceData;
  final PaymentDetails paymentDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
  final QrData qrData;

  EnhancedTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.ticketType,
    required this.passengerId,
    required this.busId,
    required this.routeId,
    required this.boardingStationId,
    required this.destinationStationId,
    required this.bookingTime,
    required this.travelDate,
    required this.validUntil,
    required this.status,
    required this.fareDetails,
    required this.qrToken,
    required this.encryptedToken,
    required this.isVerified,
    required this.complianceData,
    required this.paymentDetails,
    required this.createdAt,
    required this.updatedAt,
    required this.qrData,
  });

  factory EnhancedTicketModel.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    final ticketData = json['data']?['ticket'] ?? json['ticket'] ?? json;
    final qrDataRaw = json['data']?['qr_data'] ?? json['qr_data'] ?? {};
    
    return EnhancedTicketModel(
      id: ticketData['id'] ?? '',
      ticketNumber: ticketData['ticket_number'] ?? '',
      ticketType: ticketData['ticket_type'] ?? '',
      passengerId: ticketData['passenger_id'] ?? '',
      busId: ticketData['bus_id'] ?? '',
      routeId: ticketData['route_id'] ?? '',
      boardingStationId: ticketData['boarding_station_id'] ?? '',
      destinationStationId: ticketData['destination_station_id'] ?? '',
      bookingTime: DateTime.parse(ticketData['booking_time'] ?? DateTime.now().toIso8601String()),
      travelDate: DateTime.parse(ticketData['travel_date'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(ticketData['valid_until'] ?? DateTime.now().toIso8601String()),
      status: ticketData['status'] ?? '',
      fareDetails: FareDetails.fromJson(ticketData['fare_details'] ?? {}),
      qrToken: ticketData['qr_token'] ?? '',
      encryptedToken: ticketData['encrypted_token'] ?? '',
      isVerified: ticketData['is_verified'] ?? false,
      complianceData: ComplianceData.fromJson(ticketData['compliance_data'] ?? {}),
      paymentDetails: PaymentDetails.fromJson(ticketData['payment_details'] ?? {}),
      createdAt: DateTime.parse(ticketData['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(ticketData['updated_at'] ?? DateTime.now().toIso8601String()),
      qrData: QrData.fromJson(qrDataRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'ticket_type': ticketType,
      'passenger_id': passengerId,
      'bus_id': busId,
      'route_id': routeId,
      'boarding_station_id': boardingStationId,
      'destination_station_id': destinationStationId,
      'booking_time': bookingTime.toIso8601String(),
      'travel_date': travelDate.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'status': status,
      'fare_details': fareDetails.toJson(),
      'qr_token': qrToken,
      'encrypted_token': encryptedToken,
      'is_verified': isVerified,
      'compliance_data': complianceData.toJson(),
      'payment_details': paymentDetails.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'qr_data': qrData.toJson(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isActive => status == 'booked' && !isExpired;
  bool get isUsed => status == 'used';

  /// Convert to TicketModel for compatibility
  TicketModel toTicketModel() {
    return TicketModel(
      id: id,
      userId: passengerId,
      busId: busId,
      busNumber: busId, // Will be resolved by data resolution service
      routeId: routeId,
      routeName: routeId, // Will be resolved by data resolution service
      boardingStop: boardingStationId, // Will be resolved by data resolution service
      droppingStop: destinationStationId, // Will be resolved by data resolution service
      originalFare: fareDetails.baseFare,
      subsidyAmount: fareDetails.totalSubsidyAmount,
      finalFare: fareDetails.finalAmount,
      paymentMethod: paymentDetails.paymentMode,
      paymentStatus: paymentDetails.paymentStatus,
      bookingTime: bookingTime,
      expiryTime: validUntil,
      qrCode: qrToken,
      status: status,
      isVerified: isVerified,
      ticketNumber: ticketNumber,
      ticketType: ticketType,
      travelDate: travelDate,
      boardingStationId: boardingStationId,
      destinationStationId: destinationStationId,
      taxAmount: fareDetails.totalTaxAmount,
      transactionId: paymentDetails.transactionId,
      encryptedToken: encryptedToken,
    );
  }
}

class FareDetails {
  final double baseFare;
  final double grossFare;
  final List<dynamic>? appliedSubsidies;
  final double totalSubsidyAmount;
  final double netFare;
  final List<dynamic>? taxes;
  final double totalTaxAmount;
  final double finalAmount;
  final double governmentShare;
  final double passengerShare;

  FareDetails({
    required this.baseFare,
    required this.grossFare,
    this.appliedSubsidies,
    required this.totalSubsidyAmount,
    required this.netFare,
    this.taxes,
    required this.totalTaxAmount,
    required this.finalAmount,
    required this.governmentShare,
    required this.passengerShare,
  });

  factory FareDetails.fromJson(Map<String, dynamic> json) {
    return FareDetails(
      baseFare: (json['base_fare'] ?? 0.0).toDouble(),
      grossFare: (json['gross_fare'] ?? 0.0).toDouble(),
      appliedSubsidies: json['applied_subsidies'],
      totalSubsidyAmount: (json['total_subsidy_amount'] ?? 0.0).toDouble(),
      netFare: (json['net_fare'] ?? 0.0).toDouble(),
      taxes: json['taxes'],
      totalTaxAmount: (json['total_tax_amount'] ?? 0.0).toDouble(),
      finalAmount: (json['final_amount'] ?? 0.0).toDouble(),
      governmentShare: (json['government_share'] ?? 0.0).toDouble(),
      passengerShare: (json['passenger_share'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'gross_fare': grossFare,
      'applied_subsidies': appliedSubsidies,
      'total_subsidy_amount': totalSubsidyAmount,
      'net_fare': netFare,
      'taxes': taxes,
      'total_tax_amount': totalTaxAmount,
      'final_amount': finalAmount,
      'government_share': governmentShare,
      'passenger_share': passengerShare,
    };
  }
}

class ComplianceData {
  final DateTime revenueDate;
  final String accountingCode;
  final String revenueHead;
  final bool isGovtFunded;
  final String auditTrailId;
  final String transactionRef;

  ComplianceData({
    required this.revenueDate,
    required this.accountingCode,
    required this.revenueHead,
    required this.isGovtFunded,
    required this.auditTrailId,
    required this.transactionRef,
  });

  factory ComplianceData.fromJson(Map<String, dynamic> json) {
    return ComplianceData(
      revenueDate: DateTime.parse(json['revenue_date'] ?? DateTime.now().toIso8601String()),
      accountingCode: json['accounting_code'] ?? '',
      revenueHead: json['revenue_head'] ?? '',
      isGovtFunded: json['is_govt_funded'] ?? false,
      auditTrailId: json['audit_trail_id'] ?? '',
      transactionRef: json['transaction_ref'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_date': revenueDate.toIso8601String(),
      'accounting_code': accountingCode,
      'revenue_head': revenueHead,
      'is_govt_funded': isGovtFunded,
      'audit_trail_id': auditTrailId,
      'transaction_ref': transactionRef,
    };
  }
}

class PaymentDetails {
  final String paymentMode;
  final String paymentMethod;
  final String transactionId;
  final String paymentStatus;
  final DateTime paymentTime;

  PaymentDetails({
    required this.paymentMode,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentStatus,
    required this.paymentTime,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      paymentMode: json['payment_mode'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentTime: DateTime.parse(json['payment_time'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_mode': paymentMode,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'payment_status': paymentStatus,
      'payment_time': paymentTime.toIso8601String(),
    };
  }
}

class QrData {
  final String qrCodeBase64;
  final String qrText;
  final String ticketId;
  final String ticketNumber;
  final String passengerId;
  final String busId;
  final String routeId;
  final String boardingStationId;
  final String destinationStationId;
  final String travelDate;
  final String validUntil;
  final double fareAmount;
  final double subsidyAmount;
  final String governmentSignature;
  final String validationCode;
  final String issuingAuthority;
  final String departmentCode;
  final String cityCode;
  final String timestamp;

  QrData({
    required this.qrCodeBase64,
    required this.qrText,
    required this.ticketId,
    required this.ticketNumber,
    required this.passengerId,
    required this.busId,
    required this.routeId,
    required this.boardingStationId,
    required this.destinationStationId,
    required this.travelDate,
    required this.validUntil,
    required this.fareAmount,
    required this.subsidyAmount,
    required this.governmentSignature,
    required this.validationCode,
    required this.issuingAuthority,
    required this.departmentCode,
    required this.cityCode,
    required this.timestamp,
  });

  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      qrCodeBase64: json['qr_code_base64'] ?? '',
      qrText: json['qr_text'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      ticketNumber: json['ticket_number'] ?? '',
      passengerId: json['passenger_id'] ?? '',
      busId: json['bus_id'] ?? '',
      routeId: json['route_id'] ?? '',
      boardingStationId: json['boarding_station_id'] ?? '',
      destinationStationId: json['destination_station_id'] ?? '',
      travelDate: json['travel_date'] ?? '',
      validUntil: json['valid_until'] ?? '',
      fareAmount: (json['fare_amount'] ?? 0.0).toDouble(),
      subsidyAmount: (json['subsidy_amount'] ?? 0.0).toDouble(),
      governmentSignature: json['government_signature'] ?? '',
      validationCode: json['validation_code'] ?? '',
      issuingAuthority: json['issuing_authority'] ?? '',
      departmentCode: json['department_code'] ?? '',
      cityCode: json['city_code'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code_base64': qrCodeBase64,
      'qr_text': qrText,
      'ticket_id': ticketId,
      'ticket_number': ticketNumber,
      'passenger_id': passengerId,
      'bus_id': busId,
      'route_id': routeId,
      'boarding_station_id': boardingStationId,
      'destination_station_id': destinationStationId,
      'travel_date': travelDate,
      'valid_until': validUntil,
      'fare_amount': fareAmount,
      'subsidy_amount': subsidyAmount,
      'government_signature': governmentSignature,
      'validation_code': validationCode,
      'issuing_authority': issuingAuthority,
      'department_code': departmentCode,
      'city_code': cityCode,
      'timestamp': timestamp,
    };
  }
}