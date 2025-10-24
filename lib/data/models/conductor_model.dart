class ConductorRegisterRequest {
  final String username;
  final String email;
  final String phone;
  final String employeeId;
  final String? licenseNumber;
  final String badgeNumber;
  final String depot;

  ConductorRegisterRequest({
    required this.username,
    required this.email,
    required this.phone,
    required this.employeeId,
    this.licenseNumber,
    required this.badgeNumber,
    required this.depot,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'phone': phone,
        'employee_id': employeeId,
        if (licenseNumber != null) 'license_number': licenseNumber,
        'badge_number': badgeNumber,
        'depot': depot,
      };
}

class ConductorLoginRequest {
  final String username;
  final String password;

  ConductorLoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}
