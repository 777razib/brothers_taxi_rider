class UpdateProfileModel {
  final bool success;
  final String message;
  final UserData? data;

  UpdateProfileModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserData {
  final String? id;
  final String? fullName;
  final String? dob;
  final String? gender;
  final String? nidNumber;
  final String? referralCode;
  final String? documents;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? city;
  final String? location;
  final double? lat;
  final double? lng;
  final String? password;
  final String? role;
  final String? status;
  final String? otp;
  final String? otpExpiresAt;
  final String? phoneVerificationToken;
  final bool? isPhoneNumberVerify;
  final String? profileImage;
  final String? fcmToken;
  final bool? isNotificationOn;
  final bool? isUserOnline;
  final bool? onBoarding;
  final String? accountLink;
  final String? stripeAccountUrl;
  final String? stripeCustomerId;
  final String? stripeAccountId;
  final num? walletBalance;
  final String? licensePlate;
  final String? drivingLicense;
  final String? licenseFrontSide;
  final String? licenseBackSide;
  final String? taxiManufacturer;
  final String? bhNumber;
  final String? adminApprovedStatus;
  final num? rating;
  final num? totalDistance;
  final num? totalRides;
  final num? totalTrips;
  final num? averageRating;
  final num? reviewCount;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    this.id,
    this.fullName,
    this.dob,
    this.gender,
    this.nidNumber,
    this.referralCode,
    this.documents,
    this.address,
    this.phoneNumber,
    this.email,
    this.city,
    this.location,
    this.lat,
    this.lng,
    this.password,
    this.role,
    this.status,
    this.otp,
    this.otpExpiresAt,
    this.phoneVerificationToken,
    this.isPhoneNumberVerify,
    this.profileImage,
    this.fcmToken,
    this.isNotificationOn,
    this.isUserOnline,
    this.onBoarding,
    this.accountLink,
    this.stripeAccountUrl,
    this.stripeCustomerId,
    this.stripeAccountId,
    this.walletBalance,
    this.licensePlate,
    this.drivingLicense,
    this.licenseFrontSide,
    this.licenseBackSide,
    this.taxiManufacturer,
    this.bhNumber,
    this.adminApprovedStatus,
    this.rating,
    this.totalDistance,
    this.totalRides,
    this.totalTrips,
    this.averageRating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      fullName: json['fullName'],
      dob: json['dob'],
      gender: json['gender'],
      nidNumber: json['nidNumber'],
      referralCode: json['referralCode'],
      documents: json['documents'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      city: json['city'],
      location: json['location'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      password: json['password'],
      role: json['role'],
      status: json['status'],
      otp: json['otp'],
      otpExpiresAt: json['otpExpiresAt'],
      phoneVerificationToken: json['phoneVerificationToken'],
      isPhoneNumberVerify: json['isPhoneNumberVerify'],
      profileImage: json['profileImage'],
      fcmToken: json['fcmToken'],
      isNotificationOn: json['isNotificationOn'],
      isUserOnline: json['isUserOnline'],
      onBoarding: json['onBoarding'],
      accountLink: json['accountLink'],
      stripeAccountUrl: json['stripeAccountUrl'],
      stripeCustomerId: json['stripeCustomerId'],
      stripeAccountId: json['stripeAccountId'],
      walletBalance: json['walletBalance'],
      licensePlate: json['licensePlate'],
      drivingLicense: json['drivingLicense'],
      licenseFrontSide: json['licenseFrontSide'],
      licenseBackSide: json['licenseBackSide'],
      taxiManufacturer: json['taxiManufacturer'],
      bhNumber: json['bhNumber'],
      adminApprovedStatus: json['adminApprovedStatus'],
      rating: json['rating'],
      totalDistance: json['totalDistance'],
      totalRides: json['totalRides'],
      totalTrips: json['totalTrips'],
      averageRating: json['averageRating'],
      reviewCount: json['reviewCount'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dob': dob,
      'gender': gender,
      'nidNumber': nidNumber,
      'referralCode': referralCode,
      'documents': documents,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'city': city,
      'location': location,
      'lat': lat,
      'lng': lng,
      'password': password,
      'role': role,
      'status': status,
      'otp': otp,
      'otpExpiresAt': otpExpiresAt,
      'phoneVerificationToken': phoneVerificationToken,
      'isPhoneNumberVerify': isPhoneNumberVerify,
      'profileImage': profileImage,
      'fcmToken': fcmToken,
      'isNotificationOn': isNotificationOn,
      'isUserOnline': isUserOnline,
      'onBoarding': onBoarding,
      'accountLink': accountLink,
      'stripeAccountUrl': stripeAccountUrl,
      'stripeCustomerId': stripeCustomerId,
      'stripeAccountId': stripeAccountId,
      'walletBalance': walletBalance,
      'licensePlate': licensePlate,
      'drivingLicense': drivingLicense,
      'licenseFrontSide': licenseFrontSide,
      'licenseBackSide': licenseBackSide,
      'taxiManufacturer': taxiManufacturer,
      'bhNumber': bhNumber,
      'adminApprovedStatus': adminApprovedStatus,
      'rating': rating,
      'totalDistance': totalDistance,
      'totalRides': totalRides,
      'totalTrips': totalTrips,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
