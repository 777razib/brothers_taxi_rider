import 'dart:convert';

/// Helper function to decode the main JSON object.
RiderDriverInfoModel riderDriverInfoModelFromJson(String str) =>
    RiderDriverInfoModel.fromJson(json.decode(str) as Map<String, dynamic>);

/// Helper function to encode the main model object to a JSON string.
String riderDriverInfoModelToJson(RiderDriverInfoModel data) => json.encode(data.toJson());

/// Main model for the entire API response.
class RiderDriverInfoModel {
  final String? id;
  final String? userId;
  final String? vehicleId;
  final String? pickupLocation;
  final String? dropOffLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropOffLat;
  final double? dropOffLng;
  final double? driverLat;
  final double? driverLng;
  final int? totalAmount;
  final double? distance;
  final int? platformFee;
  final String? platformFeeType;
  final String? paymentMethod;
  final String? paymentStatus;
  final bool? isPayment;
  final String? pickupDate;
  final String? pickupTime;
  final int? rideTime;
  final int? waitingTime;
  final String? status;
  final String? assignedDriver;
  final String? assignedDriverReqStatus;
  final bool? isDriverReqCancel;
  final bool? arrivalConfirmation;
  final bool? journeyStarted;
  final bool? journeyCompleted;
  final String? serviceType;
  final String? specialNotes;
  final List<dynamic>? beforePickupImages;
  final List<dynamic>? afterPickupImages;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ridePlanId;
  final User? user;
  final Vehicle? vehicle;

  RiderDriverInfoModel({
    this.id,
    this.userId,
    this.vehicleId,
    this.pickupLocation,
    this.dropOffLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropOffLat,
    this.dropOffLng,
    this.driverLat,
    this.driverLng,
    this.totalAmount,
    this.distance,
    this.platformFee,
    this.platformFeeType,
    this.paymentMethod,
    this.paymentStatus,
    this.isPayment,
    this.pickupDate,
    this.pickupTime,
    this.rideTime,
    this.waitingTime,
    this.status,
    this.assignedDriver,
    this.assignedDriverReqStatus,
    this.isDriverReqCancel,
    this.arrivalConfirmation,
    this.journeyStarted,
    this.journeyCompleted,
    this.serviceType,
    this.specialNotes,
    this.beforePickupImages,
    this.afterPickupImages,
    this.cancelReason,
    this.createdAt,
    this.updatedAt,
    this.ridePlanId,
    this.user,
    this.vehicle,
  });

  factory RiderDriverInfoModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers of any type (int, double) to double?
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return RiderDriverInfoModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      dropOffLocation: json['dropOffLocation'] as String?,
      pickupLat: parseDouble(json['pickupLat']),
      pickupLng: parseDouble(json['pickupLng']),
      dropOffLat: parseDouble(json['dropOffLat']),
      dropOffLng: parseDouble(json['dropOffLng']),
      driverLat: parseDouble(json['driverLat']),
      driverLng: parseDouble(json['driverLng']),
      totalAmount: json['totalAmount'] as int?,
      distance: parseDouble(json['distance']),
      platformFee: json['platformFee'] as int?,
      platformFeeType: json['platformFeeType'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      isPayment: json['isPayment'] as bool?,
      pickupDate: json['pickupDate'] as String?,
      pickupTime: json['pickupTime'] as String?,
      rideTime: json['rideTime'] as int?,
      waitingTime: json['waitingTime'] as int?,
      status: json['status'] as String?,
      assignedDriver: json['assignedDriver'] as String?,
      assignedDriverReqStatus: json['assignedDriverReqStatus'] as String?,
      isDriverReqCancel: json['isDriverReqCancel'] as bool?,
      arrivalConfirmation: json['arrivalConfirmation'] as bool?,
      journeyStarted: json['journeyStarted'] as bool?,
      journeyCompleted: json['journeyCompleted'] as bool?,
      serviceType: json['serviceType'] as String?,
      specialNotes: json['specialNotes'] as String?,
      beforePickupImages: json['beforePickupImages'] != null ? List<dynamic>.from(json['beforePickupImages'] as List) : null,
      afterPickupImages: json['afterPickupImages'] != null ? List<dynamic>.from(json['afterPickupImages'] as List) : null,
      cancelReason: json['cancelReason'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      ridePlanId: json['ridePlanId'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropOffLat': dropOffLat,
      'dropOffLng': dropOffLng,
      'driverLat': driverLat,
      'driverLng': driverLng,
      'totalAmount': totalAmount,
      'distance': distance,
      'platformFee': platformFee,
      'platformFeeType': platformFeeType,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'isPayment': isPayment,
      'pickupDate': pickupDate,
      'pickupTime': pickupTime,
      'rideTime': rideTime,
      'waitingTime': waitingTime,
      'status': status,
      'assignedDriver': assignedDriver,
      'assignedDriverReqStatus': assignedDriverReqStatus,
      'isDriverReqCancel': isDriverReqCancel,
      'arrivalConfirmation': arrivalConfirmation,
      'journeyStarted': journeyStarted,
      'journeyCompleted': journeyCompleted,
      'serviceType': serviceType,
      'specialNotes': specialNotes,
      'beforePickupImages': beforePickupImages,
      'afterPickupImages': afterPickupImages,
      'cancelReason': cancelReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ridePlanId': ridePlanId,
      'user': user?.toJson(),
      'vehicle': vehicle?.toJson(),
    };
  }
}

// -----------------------------------------------------------------------------
// Sub-model for the 'user' object
// -----------------------------------------------------------------------------
class User {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  // Other fields from your JSON can be added here if needed

  User({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
    };
  }
}

// -----------------------------------------------------------------------------
// Sub-model for the 'vehicle' object
// -----------------------------------------------------------------------------
class Vehicle {
  final String? id;
  final String? manufacturer;
  final String? model;
  final String? color;
  final String? licensePlateNumber;
  final String? image;
  final Driver? driver;

  Vehicle({
    this.id,
    this.manufacturer,
    this.model,
    this.color,
    this.licensePlateNumber,
    this.image,
    this.driver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      licensePlateNumber: json['licensePlateNumber'] as String?,
      image: json['image'] as String?,
      driver: json['driver'] != null ? Driver.fromJson(json['driver'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'color': color,
      'licensePlateNumber': licensePlateNumber,
      'image': image,
      'driver': driver?.toJson(),
    };
  }
}

// -----------------------------------------------------------------------------
// Sub-model for the 'driver' object (nested inside 'vehicle')
// -----------------------------------------------------------------------------
class Driver {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  final int? totalTrips;
  final double? averageRating;
  final int? reviewCount;

  Driver({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.totalTrips,
    this.averageRating,
    this.reviewCount,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers that might be int or double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper to safely parse numbers that might be int or string
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Driver(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      totalTrips: parseInt(json['totalTrips']),
      averageRating: parseDouble(json['averageRating']),
      reviewCount: parseInt(json['reviewCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'totalTrips': totalTrips,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
    };
  }
}
