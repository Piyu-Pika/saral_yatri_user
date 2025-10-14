class TicketModel {
  final String id;
  final String userId;
  final String busId;
  final String busNumber;
  final String routeId;
  final String routeName;
  final String boardingStop;
  final String droppingStop;
  final double originalFare;
  final double subsidyAmount;
  final double finalFare;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime bookingTime;
  final DateTime expiryTime;
  final String qrCode;
  final String status; // active, expired, used
  final bool isVerified;
  final DateTime? verificationTime;

  TicketModel({
    required this.id,
    required this.userId,
    required this.busId,
    required this.busNumber,
    required this.routeId,
    required this.routeName,
    required this.boardingStop,
    required this.droppingStop,
    required this.originalFare,
    required this.subsidyAmount,
    required this.finalFare,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.bookingTime,
    required this.expiryTime,
    required this.qrCode,
    required this.status,
    required this.isVerified,
    this.verificationTime,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      busId: json['bus_id'] ?? '',
      busNumber: json['bus_number'] ?? '',
      routeId: json['route_id'] ?? '',
      routeName: json['route_name'] ?? '',
      boardingStop: json['boarding_stop'] ?? '',
      droppingStop: json['dropping_stop'] ?? '',
      originalFare: (json['original_fare'] ?? 0.0).toDouble(),
      subsidyAmount: (json['subsidy_amount'] ?? 0.0).toDouble(),
      finalFare: (json['final_fare'] ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      bookingTime: DateTime.parse(json['booking_time'] ?? DateTime.now().toIso8601String()),
      expiryTime: DateTime.parse(json['expiry_time'] ?? DateTime.now().toIso8601String()),
      qrCode: json['qr_code'] ?? '',
      status: json['status'] ?? 'active',
      isVerified: json['is_verified'] ?? false,
      verificationTime: json['verification_time'] != null 
          ? DateTime.parse(json['verification_time']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bus_id': busId,
      'bus_number': busNumber,
      'route_id': routeId,
      'route_name': routeName,
      'boarding_stop': boardingStop,
      'dropping_stop': droppingStop,
      'original_fare': originalFare,
      'subsidy_amount': subsidyAmount,
      'final_fare': finalFare,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'booking_time': bookingTime.toIso8601String(),
      'expiry_time': expiryTime.toIso8601String(),
      'qr_code': qrCode,
      'status': status,
      'is_verified': isVerified,
      'verification_time': verificationTime?.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isActive => status == 'active' && !isExpired;

  TicketModel copyWith({
    String? id,
    String? userId,
    String? busId,
    String? busNumber,
    String? routeId,
    String? routeName,
    String? boardingStop,
    String? droppingStop,
    double? originalFare,
    double? subsidyAmount,
    double? finalFare,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? bookingTime,
    DateTime? expiryTime,
    String? qrCode,
    String? status,
    bool? isVerified,
    DateTime? verificationTime,
  }) {
    return TicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      busNumber: busNumber ?? this.busNumber,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      boardingStop: boardingStop ?? this.boardingStop,
      droppingStop: droppingStop ?? this.droppingStop,
      originalFare: originalFare ?? this.originalFare,
      subsidyAmount: subsidyAmount ?? this.subsidyAmount,
      finalFare: finalFare ?? this.finalFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingTime: bookingTime ?? this.bookingTime,
      expiryTime: expiryTime ?? this.expiryTime,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      verificationTime: verificationTime ?? this.verificationTime,
    );
  }
}