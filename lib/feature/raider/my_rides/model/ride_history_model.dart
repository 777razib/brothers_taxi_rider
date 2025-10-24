class RideHistoryModel {
  final bool success;
  final String message;
  final List<Ride> data;

  RideHistoryModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) {
    return RideHistoryModel(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((rideJson) => Ride.fromJson(rideJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((ride) => ride.toJson()).toList(),
  };
}

class Ride {
  final String id;
  final String userId;
  final String vehicleId;
  final String pickupLocation;
  final String dropOffLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropOffLat;
  final double dropOffLng;
  final double driverLat;
  final double driverLng;
  final double totalAmount;
  final double distance;
  final double platformFee;
  final String platformFeeType;
  final String paymentMethod;
  final String paymentStatus;
  final bool isPayment;
  final String pickupDate;
  final String pickupTime;
  final int rideTime;
  final int waitingTime;
  final String status;
  final String assignedDriver;
  final String assignedDriverReqStatus;
  final bool isDriverReqCancel;
  final bool arrivalConfirmation;
  final bool journeyStarted;
  final bool journeyCompleted;
  final String serviceType;
  final String specialNotes;
  final List<String> beforePickupImages;
  final List<String> afterPickupImages;
  final String cancelReason;
  final String createdAt;
  final String updatedAt;
  final String? ridePlanId;
  final User user;
  final Vehicle vehicle;

  Ride({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropOffLat,
    required this.dropOffLng,
    required this.driverLat,
    required this.driverLng,
    required this.totalAmount,
    required this.distance,
    required this.platformFee,
    required this.platformFeeType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.isPayment,
    required this.pickupDate,
    required this.pickupTime,
    required this.rideTime,
    required this.waitingTime,
    required this.status,
    required this.assignedDriver,
    required this.assignedDriverReqStatus,
    required this.isDriverReqCancel,
    required this.arrivalConfirmation,
    required this.journeyStarted,
    required this.journeyCompleted,
    required this.serviceType,
    required this.specialNotes,
    required this.beforePickupImages,
    required this.afterPickupImages,
    required this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    this.ridePlanId,
    required this.user,
    required this.vehicle,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      pickupLocation: json['pickupLocation'],
      dropOffLocation: json['dropOffLocation'],
      pickupLat: (json['pickupLat'] as num).toDouble(),
      pickupLng: (json['pickupLng'] as num).toDouble(),
      dropOffLat: (json['dropOffLat'] as num).toDouble(),
      dropOffLng: (json['dropOffLng'] as num).toDouble(),
      driverLat: (json['driverLat'] as num).toDouble(),
      driverLng: (json['driverLng'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      platformFeeType: json['platformFeeType'] ?? '',
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      isPayment: json['isPayment'],
      pickupDate: json['pickupDate'],
      pickupTime: json['pickupTime'],
      rideTime: json['rideTime'],
      waitingTime: json['waitingTime'],
      status: json['status'],
      assignedDriver: json['assignedDriver'],
      assignedDriverReqStatus: json['assignedDriverReqStatus'],
      isDriverReqCancel: json['isDriverReqCancel'],
      arrivalConfirmation: json['arrivalConfirmation'],
      journeyStarted: json['journeyStarted'],
      journeyCompleted: json['journeyCompleted'],
      serviceType: json['serviceType'],
      specialNotes: json['specialNotes'],
      beforePickupImages: List<String>.from(json['beforePickupImages']),
      afterPickupImages: List<String>.from(json['afterPickupImages']),
      cancelReason: json['cancelReason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      ridePlanId: json['ridePlanId'],
      user: User.fromJson(json['user']),
      vehicle: Vehicle.fromJson(json['vehicle']),
    );
  }

  Map<String, dynamic> toJson() => {
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
    'user': user.toJson(),
    'vehicle': vehicle.toJson(),
  };
}

class User {
  final String id;
  final String fullName;
  final String email;
  final String profileImage;
  final String location;
  final double lat;
  final double lng;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.location,
    required this.lat,
    required this.lng,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
      location: json['location'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'profileImage': profileImage,
    'location': location,
    'lat': lat,
    'lng': lng,
  };
}

class Vehicle {
  final String id;
  final String manufacturer;
  final String model;
  final String licensePlateNumber;
  final String bh;
  final String image;
  final String color;
  final Driver driver;

  Vehicle({
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.licensePlateNumber,
    required this.bh,
    required this.image,
    required this.color,
    required this.driver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      licensePlateNumber: json['licensePlateNumber'],
      bh: json['bh'],
      image: json['image'],
      color: json['color'],
      driver: Driver.fromJson(json['driver']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'manufacturer': manufacturer,
    'model': model,
    'licensePlateNumber': licensePlateNumber,
    'bh': bh,
    'image': image,
    'color': color,
    'driver': driver.toJson(),
  };
}

class Driver {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final String location;

  Driver({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.location,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'profileImage': profileImage,
    'location': location,
  };
}
