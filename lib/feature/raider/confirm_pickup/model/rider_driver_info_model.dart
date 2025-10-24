// RiderDriverInfoModel.dart
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
  final List<String>? beforePickupImages;
  final List<String>? afterPickupImages;
  final String? cancelReason;
  final String? createdAt;
  final String? updatedAt;
  final String? ridePlanId;
  final User? user;
  final Vehicle? vehicle;
  final List<RecommendedDriver>? recommendedDrivers;
  final List<Driver>? drivers;

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
    this.recommendedDrivers,
    this.drivers,
  });

  factory RiderDriverInfoModel.fromJson(Map<String, dynamic> json) {
    return RiderDriverInfoModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      dropOffLocation: json['dropOffLocation'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropOffLat: (json['dropOffLat'] as num?)?.toDouble(),
      dropOffLng: (json['dropOffLng'] as num?)?.toDouble(),
      driverLat: (json['driverLat'] as num?)?.toDouble(),
      driverLng: (json['driverLng'] as num?)?.toDouble(),
      totalAmount: json['totalAmount'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
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
      beforePickupImages: (json['beforePickupImages'] as List<dynamic>?)?.map((e) => e as String).toList(),
      afterPickupImages: (json['afterPickupImages'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cancelReason: json['cancelReason'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      ridePlanId: json['ridePlanId'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>) : null,
      recommendedDrivers: (json['recommendedDrivers'] as List<dynamic>?)
          ?.map((i) => RecommendedDriver.fromJson(i as Map<String, dynamic>))
          .toList(),
      drivers: (json['drivers'] as List<dynamic>?)
          ?.map((i) => Driver.fromJson(i as Map<String, dynamic>))
          .toList(),
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'ridePlanId': ridePlanId,
      'user': user?.toJson(),
      'vehicle': vehicle?.toJson(),
      'recommendedDrivers': recommendedDrivers?.map((i) => i.toJson()).toList(),
      'drivers': drivers?.map((i) => i.toJson()).toList(),
    };
  }
}

class User {
  final String? id;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? profileImage;
  final String? location;
  final double? lat;
  final double? lng;

  User({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.profileImage,
    this.location,
    this.lat,
    this.lng,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      location: json['location'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'location': location,
      'lat': lat,
      'lng': lng,
    };
  }
}

class Vehicle {
  final String? id;
  final String? manufacturer;
  final String? model;
  final String? licensePlateNumber;
  final String? bh;
  final String? image;
  final String? color;
  final Driver? driver;

  Vehicle({
    this.id,
    this.manufacturer,
    this.model,
    this.licensePlateNumber,
    this.bh,
    this.image,
    this.color,
    this.driver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      licensePlateNumber: json['licensePlateNumber'] as String?,
      bh: json['bh'] as String?,
      image: json['image'] as String?,
      color: json['color'] as String?,
      driver: json['driver'] != null ? Driver.fromJson(json['driver'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manufacturer': manufacturer,
      'model': model,
      'licensePlateNumber': licensePlateNumber,
      'bh': bh,
      'image': image,
      'color': color,
      'driver': driver?.toJson(),
    };
  }
}

class Driver {
  final String? id;
  final String? fullName;
  final String? referralCode;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final String? location;
  final double? lat; // Changed to double? to match API
  final double? lng; // Changed to double? to match API
  final int? totalTrips; // Changed to int? to match API
  final double? averageRating;
  final int? reviewCount;

  Driver({
    this.id,
    this.fullName,
    this.referralCode,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.location,
    this.lat,
    this.lng,
    this.totalTrips,
    this.averageRating,
    this.reviewCount,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    try {
      return Driver(
        id: json['id'] as String?,
        fullName: json['fullName'] as String?,
        referralCode: json['referralCode'] as String?,
        email: json['email'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        profileImage: json['profileImage'] as String?,
        location: json['location'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        totalTrips: json['totalTrips'] as int?,
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        reviewCount: json['reviewCount'] as int?,
      );
    } catch (e, stackTrace) {
      print("❌ [Driver.fromJson] Error parsing JSON: $e");
      print("📜 [StackTrace] $stackTrace");
      print("🔍 [JSON Input] $json");
      return Driver(); // Return empty Driver object as fallback
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (fullName != null) 'fullName': fullName,
      if (referralCode != null) 'referralCode': referralCode,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (profileImage != null) 'profileImage': profileImage,
      if (location != null) 'location': location,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (totalTrips != null) 'totalTrips': totalTrips,
      if (averageRating != null) 'averageRating': averageRating,
      if (reviewCount != null) 'reviewCount': reviewCount,
    };
  }
}

class RecommendedDriver {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;
  final double? lat;
  final double? lng;
  final double? distanceFromPickup;

  RecommendedDriver({
    this.id,
    this.fullName,
    this.phone,
    this.profileImage,
    this.lat,
    this.lng,
    this.distanceFromPickup,
  });

  factory RecommendedDriver.fromJson(Map<String, dynamic> json) {
    return RecommendedDriver(
      id: json['id'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      distanceFromPickup: (json['distanceFromPickup'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'profileImage': profileImage,
      'lat': lat,
      'lng': lng,
      'distanceFromPickup': distanceFromPickup,
    };
  }
}