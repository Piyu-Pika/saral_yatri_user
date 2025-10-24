class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dateOfBirth;
  final List<String>? subsidyEligible;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.dateOfBirth,
    this.subsidyEligible,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse DateTime
    DateTime? safeParseDateTime(String? dateString) {
      if (dateString == null || dateString == "0001-01-01T00:00:00Z") {
        return null;
      }
      return DateTime.tryParse(dateString);
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'passenger',
      profileImage: json['profile_image']?.toString(),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      dateOfBirth: safeParseDateTime(json['date_of_birth']?.toString()),
      subsidyEligible: (json['subsidy_eligible'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'subsidy_eligible': subsidyEligible,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
    List<String>? subsidyEligible,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      subsidyEligible: subsidyEligible ?? this.subsidyEligible,
    );
  }
}
