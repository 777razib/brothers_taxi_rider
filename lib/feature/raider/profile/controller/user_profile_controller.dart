import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/network_caller/network_config.dart';
import '../../../../core/network_path/natwork_path.dart';
import '../../../../core/services_class/shared_preferences_data_helper.dart';
import '../../../../core/services_class/shared_preferences_helper.dart';

class UserProfileController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var userProfile = Rxn<UserProfileModel>();

  /// Fetch Logged-in User Profile
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    errorMessage.value = "";

    EasyLoading.show(status: "Fetching profile...");

    try {
      // Token
      final token = await AuthController.accessToken;
      debugPrint("🔑 Token: $token");

      if (token == null || token.isEmpty) {
        errorMessage.value = "Access token not found. Please login.";
        EasyLoading.showError(errorMessage.value);
        debugPrint("❌ $errorMessage");
        return;
      }

      // Headers
      Map<String, String> headers = {
        "Authorization": token,
        "Content-Type": "application/json",
      };
      debugPrint("📌 Headers: $headers");

      // Call API
      NetworkResponse response = await NetworkCall.getRequest(
        url: NetworkPath.getMe, // /users/get-me
      );

      debugPrint("🌍 Raw Response: ${response.responseData}");

      if (response.isSuccess) {
        final data = response.responseData?["data"];
        debugPrint("✅ Extracted data: $data");

        if (data != null && data is Map<String, dynamic>) {
          userProfile.value = UserProfileModel.fromJson(data);
          // debugPrint("👤 UserProfile Model: ${userProfile.value?.toJson()}");
        } else {
          userProfile.value = null;
          debugPrint("⚠️ Data is null or not a valid Map");
        }

        EasyLoading.showSuccess("Fetched successfully");
      } else {
        errorMessage.value =
            response.errorMessage ?? "Failed to load profile";
        EasyLoading.showError(errorMessage.value);
        debugPrint("❌ Error Message: ${errorMessage.value}");
      }
    } catch (e, stackTrace) {
      errorMessage.value = "Error: $e";
      EasyLoading.showError(errorMessage.value);
      debugPrint("💥 Exception: $e");
      debugPrint("📚 StackTrace: $stackTrace");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
      debugPrint("🔄 Loading finished, isLoading = ${isLoading.value}");
    }
  }
}


class UserProfileModel {
  String? id;
  String? fullName;
  String? dob;
  String? gender;
  String? nidNumber;
  String? referralCode;
  dynamic documents;
  String? address;
  String? phoneNumber;
  String? email;
  String? city;
  String? location;
  double? lat;
  double? lng;
  String? role;
  String? status;
  String? otp;
  String? otpExpiresAt;
  String? phoneVerificationToken;
  bool? isPhoneNumberVerify;
  String? profileImage;
  bool? isNotificationOn;
  bool? isUserOnline;
  bool? onBoarding;
  String? accountLink;
  String? stripeAccountUrl;
  String? stripeCustomerId;
  String? stripeAccountId;
  double? walletBalance;
  String? licensePlate;
  String? drivingLicense;
  String? licenseFrontSide;
  String? licenseBackSide;
  String? taxiManufacturer;
  String? bhNumber;
  String? adminApprovedStatus;
  double? rating;
  double? totalDistance;
  int? totalRides;
  int? totalTrips;
  double? averageRating;
  int? reviewCount;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfileModel({
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
    this.role,
    this.status,
    this.otp,
    this.otpExpiresAt,
    this.phoneVerificationToken,
    this.isPhoneNumberVerify,
    this.profileImage,
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      nidNumber: json['nidNumber'] as String?,
      referralCode: json['referralCode'] as String?,
      documents: json['documents'],
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      location: json['location'] as String?,
      lat: (json['lat'] is int) ? (json['lat'] as int).toDouble() : json['lat'],
      lng: (json['lng'] is int) ? (json['lng'] as int).toDouble() : json['lng'],
      role: json['role'] as String?,
      status: json['status'] as String?,
      otp: json['otp'] as String?,
      otpExpiresAt: json['otpExpiresAt'] as String?,
      phoneVerificationToken: json['phoneVerificationToken'] as String?,
      isPhoneNumberVerify: json['isPhoneNumberVerify'] as bool?,
      profileImage: json['profileImage'] as String?,
      isNotificationOn: json['isNotificationOn'] as bool?,
      isUserOnline: json['isUserOnline'] as bool?,
      onBoarding: json['onBoarding'] as bool?,
      accountLink: json['accountLink'] as String?,
      stripeAccountUrl: json['stripeAccountUrl'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeAccountId: json['stripeAccountId'] as String?,
      walletBalance: (json['walletBalance'] is int)
          ? (json['walletBalance'] as int).toDouble()
          : json['walletBalance'],
      licensePlate: json['licensePlate'] as String?,
      drivingLicense: json['drivingLicense'] as String?,
      licenseFrontSide: json['licenseFrontSide'] as String?,
      licenseBackSide: json['licenseBackSide'] as String?,
      taxiManufacturer: json['taxiManufacturer'] as String?,
      bhNumber: json['bhNumber'] as String?,
      adminApprovedStatus: json['adminApprovedStatus'] as String?,
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : json['rating'],
      totalDistance: (json['totalDistance'] is int)
          ? (json['totalDistance'] as int).toDouble()
          : json['totalDistance'],
      totalRides: json['totalRides'] as int?,
      totalTrips: json['totalTrips'] as int?,
      averageRating: (json['averageRating'] is int)
          ? (json['averageRating'] as int).toDouble()
          : json['averageRating'],
      reviewCount: json['reviewCount'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "dob": dob,
      "gender": gender,
      "nidNumber": nidNumber,
      "referralCode": referralCode,
      "documents": documents,
      "address": address,
      "phoneNumber": phoneNumber,
      "email": email,
      "city": city,
      "location": location,
      "lat": lat,
      "lng": lng,
      "role": role,
      "status": status,
      "otp": otp,
      "otpExpiresAt": otpExpiresAt,
      "phoneVerificationToken": phoneVerificationToken,
      "isPhoneNumberVerify": isPhoneNumberVerify,
      "profileImage": profileImage,
      "isNotificationOn": isNotificationOn,
      "isUserOnline": isUserOnline,
      "onBoarding": onBoarding,
      "accountLink": accountLink,
      "stripeAccountUrl": stripeAccountUrl,
      "stripeCustomerId": stripeAccountId,
      "stripeAccountId": stripeAccountId,
      "walletBalance": walletBalance,
      "licensePlate": licensePlate,
      "drivingLicense": drivingLicense,
      "licenseFrontSide": licenseFrontSide,
      "licenseBackSide": licenseBackSide,
      "taxiManufacturer": taxiManufacturer,
      "bhNumber": bhNumber,
      "adminApprovedStatus": adminApprovedStatus,
      "rating": rating,
      "totalDistance": totalDistance,
      "totalRides": totalRides,
      "totalTrips": totalTrips,
      "averageRating": averageRating,
      "reviewCount": reviewCount,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
