class RiderModel{
  final String? id;
  final String? phoneNumber;
  final String? role;
  final String? email;
  final int? otp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RiderModel({
    this.id,
    this.phoneNumber,
    this.role,
    this.email,
    this.otp,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a model from JSON
  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String?,
      email: json['email'] as String?,
      otp: json['otp'] is int ? json['otp'] : int.tryParse(json['otp']?.toString() ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'role': role,
      'email': email,
      'otp': otp,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}