class UserDataModel {
  final String id;
  final String fullName;
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
  final String? role;
  final String? status;
  final bool? isPhoneNumberVerify;
  final String? profileImage;
  final bool? isNotificationOn;
  final bool? isUserOnline;
  final bool? onBoarding;
  final String? stripeCustomerId;
  final String? licenseFrontSide;
  final String? licenseBackSide;
  final String? adminApprovedStatus;
  final double? walletBalance;
  final double? rating;
  final double? totalDistance;
  final int? totalRides;
  final int? totalTrips;
  final double? averageRating;
  final int? reviewCount;
  final String? createdAt;
  final String? updatedAt;

  UserDataModel({
    required this.id,
    required this.fullName,
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
    this.role,
    this.status,
    this.isPhoneNumberVerify,
    this.profileImage,
    this.isNotificationOn,
    this.isUserOnline,
    this.onBoarding,
    this.stripeCustomerId,
    this.licenseFrontSide,
    this.licenseBackSide,
    this.adminApprovedStatus,
    this.walletBalance,
    this.rating,
    this.totalDistance,
    this.totalRides,
    this.totalTrips,
    this.averageRating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json["id"] ?? "",
      fullName: json["fullName"] ?? "",
      dob: json["dob"],
      gender: json["gender"],
      nidNumber: json["nidNumber"],
      referralCode: json["referralCode"],
      documents: json["documents"],
      address: json["address"],
      phoneNumber: json["phoneNumber"],
      email: json["email"],
      city: json["city"],
      location: json["location"],
      lat: (json["lat"] != null) ? json["lat"].toDouble() : null,
      lng: (json["lng"] != null) ? json["lng"].toDouble() : null,
      role: json["role"],
      status: json["status"],
      isPhoneNumberVerify: json["isPhoneNumberVerify"],
      profileImage: json["profileImage"],
      isNotificationOn: json["isNotificationOn"],
      isUserOnline: json["isUserOnline"],
      onBoarding: json["onBoarding"],
      stripeCustomerId: json["stripeCustomerId"],
      licenseFrontSide: json["licenseFrontSide"],
      licenseBackSide: json["licenseBackSide"],
      adminApprovedStatus: json["adminApprovedStatus"],
      walletBalance: (json["walletBalance"] != null) ? json["walletBalance"].toDouble() : null,
      rating: (json["rating"] != null) ? json["rating"].toDouble() : null,
      totalDistance: (json["totalDistance"] != null) ? json["totalDistance"].toDouble() : null,
      totalRides: json["totalRides"],
      totalTrips: json["totalTrips"],
      averageRating: (json["averageRating"] != null) ? json["averageRating"].toDouble() : null,
      reviewCount: json["reviewCount"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
    );
  }
}
