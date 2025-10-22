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
  
  // Additional fields from API
  final String? ticketNumber;
  final String? ticketType;
  final DateTime? travelDate;
  final String? boardingStationId;
  final String? destinationStationId;
  final double? taxAmount;
  final String? transactionId;
  final String? encryptedToken;

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
    this.ticketNumber,
    this.ticketType,
    this.travelDate,
    this.boardingStationId,
    this.destinationStationId,
    this.taxAmount,
    this.transactionId,
    this.encryptedToken,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    // Handle the nested API response structure
    final ticketData = json['ticket'] ?? json;
    final qrData = json['qr_data'] ?? {};
    final fareDetails = ticketData['fare_details'] ?? {};
    final paymentDetails = ticketData['payment_details'] ?? {};
    
    // Extract basic ticket information
    final ticketId = ticketData['id'] ?? ticketData['ticket_id'] ?? qrData['ticket_id'] ?? '';
    final passengerId = ticketData['passenger_id'] ?? qrData['passenger_id'] ?? '';
    final busId = ticketData['bus_id'] ?? qrData['bus_id'] ?? '';
    final routeId = ticketData['route_id'] ?? qrData['route_id'] ?? '';
    final boardingStationId = ticketData['boarding_station_id'] ?? qrData['boarding_station_id'] ?? '';
    final destinationStationId = ticketData['destination_station_id'] ?? qrData['destination_station_id'] ?? '';
    
    // Extract fare information from fare_details or qr_data
    final baseFare = (fareDetails['base_fare'] ?? fareDetails['gross_fare'] ?? qrData['fare_amount'] ?? 0.0).toDouble();
    final subsidyAmount = (fareDetails['total_subsidy_amount'] ?? qrData['subsidy_amount'] ?? 0.0).toDouble();
    final finalAmount = (fareDetails['final_amount'] ?? qrData['fare_amount'] ?? baseFare).toDouble();
    
    // Extract payment information
    final paymentMode = paymentDetails['payment_mode'] ?? paymentDetails['payment_method'] ?? '';
    final paymentStatus = paymentDetails['payment_status'] ?? 'completed';
    
    // Extract dates
    final bookingTime = ticketData['booking_time'] ?? ticketData['created_at'] ?? DateTime.now().toIso8601String();
    final validUntil = ticketData['valid_until'] ?? qrData['valid_until'] ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String();
    
    // Extract QR code information
    final qrToken = ticketData['qr_token'] ?? ticketData['encrypted_token'] ?? '';
    
    // Extract status and verification
    final status = ticketData['status'] ?? 'booked';
    final isVerified = ticketData['is_verified'] ?? false;
    
    return TicketModel(
      id: ticketId,
      userId: passengerId,
      busId: busId,
      busNumber: ticketData['bus_number'] ?? busId, // Use bus_id as fallback for display
      routeId: routeId,
      routeName: ticketData['route_name'] ?? routeId, // Use route_id as fallback for display
      boardingStop: ticketData['boarding_stop'] ?? boardingStationId, // Use station_id as fallback
      droppingStop: ticketData['dropping_stop'] ?? destinationStationId, // Use station_id as fallback
      originalFare: baseFare,
      subsidyAmount: subsidyAmount,
      finalFare: finalAmount,
      paymentMethod: paymentMode,
      paymentStatus: paymentStatus,
      bookingTime: DateTime.parse(bookingTime),
      expiryTime: DateTime.parse(validUntil),
      qrCode: qrToken,
      status: _mapApiStatusToAppStatus(status),
      isVerified: isVerified,
      verificationTime: ticketData['verification_time'] != null 
          ? DateTime.parse(ticketData['verification_time']) 
          : null,
      // Additional fields
      ticketNumber: ticketData['ticket_number'] ?? qrData['ticket_number'],
      ticketType: ticketData['ticket_type'],
      travelDate: ticketData['travel_date'] != null 
          ? DateTime.parse(ticketData['travel_date']) 
          : null,
      boardingStationId: boardingStationId,
      destinationStationId: destinationStationId,
      taxAmount: (fareDetails['total_tax_amount'] ?? 0.0).toDouble(),
      transactionId: paymentDetails['transaction_id'],
      encryptedToken: ticketData['encrypted_token'],
    );
  }
  
  /// Map API status values to app status values
  static String _mapApiStatusToAppStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'booked':
      case 'confirmed':
        return 'active';
      case 'expired':
      case 'cancelled':
        return 'expired';
      case 'used':
      case 'verified':
        return 'used';
      default:
        return apiStatus;
    }
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
      'ticket_number': ticketNumber,
      'ticket_type': ticketType,
      'travel_date': travelDate?.toIso8601String(),
      'boarding_station_id': boardingStationId,
      'destination_station_id': destinationStationId,
      'tax_amount': taxAmount,
      'transaction_id': transactionId,
      'encrypted_token': encryptedToken,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isActive => (status == 'active' || status == 'booked') && !isExpired;
  
  /// Get a user-friendly display name for the ticket
  String get displayName => ticketNumber ?? 'Ticket $id';
  
  /// Get formatted fare with currency
  String get formattedFare => '₹${finalFare.toStringAsFixed(2)}';
  
  /// Get formatted original fare with currency
  String get formattedOriginalFare => '₹${originalFare.toStringAsFixed(2)}';
  
  /// Get formatted subsidy amount with currency
  String get formattedSubsidy => subsidyAmount > 0 ? '₹${subsidyAmount.toStringAsFixed(2)}' : '';
  
  /// Get route display text
  String get routeDisplay => '$boardingStop → $droppingStop';

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
    String? ticketNumber,
    String? ticketType,
    DateTime? travelDate,
    String? boardingStationId,
    String? destinationStationId,
    double? taxAmount,
    String? transactionId,
    String? encryptedToken,
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
      ticketNumber: ticketNumber ?? this.ticketNumber,
      ticketType: ticketType ?? this.ticketType,
      travelDate: travelDate ?? this.travelDate,
      boardingStationId: boardingStationId ?? this.boardingStationId,
      destinationStationId: destinationStationId ?? this.destinationStationId,
      taxAmount: taxAmount ?? this.taxAmount,
      transactionId: transactionId ?? this.transactionId,
      encryptedToken: encryptedToken ?? this.encryptedToken,
    );
  }
}