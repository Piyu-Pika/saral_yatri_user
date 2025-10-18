class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final DateTime createdAt;
  final bool isVerified;
  final List<String> subsidyEligibility;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.createdAt,
    required this.isVerified,
    required this.subsidyEligibility,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      subsidyEligibility: (json['subsidy_eligibility'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
      'subsidy_eligibility': subsidyEligibility,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    bool? isVerified,
    List<String>? subsidyEligibility,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      subsidyEligibility: subsidyEligibility ?? this.subsidyEligibility,
    );
  }
}