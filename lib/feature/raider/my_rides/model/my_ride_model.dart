// ride_response_model.dart

class MyRideModel {
  bool success;
  String message;
  List<RideData> data;

  MyRideModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MyRideModel.fromJson(Map<String, dynamic> json) => MyRideModel(
    success: json['success'],
    message: json['message'],
    data: List<RideData>.from(json['data'].map((x) => RideData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class RideData {
  String id;
  String userId;
  String vehicleId;
  String pickupLocation;
  String dropOffLocation;
  double pickupLat;
  double pickupLng;
  double dropOffLat;
  double dropOffLng;
  double driverLat;
  double driverLng;
  double totalAmount;
  double distance;
  double platformFee;
  String platformFeeType;
  String paymentMethod;
  String paymentStatus;
  bool isPayment;
  String pickupDate;
  String pickupTime;
  int rideTime;
  int waitingTime;
  String status;
  String assignedDriver;
  String assignedDriverReqStatus;
  bool isDriverReqCancel;
  bool arrivalConfirmation;
  bool journeyStarted;
  bool journeyCompleted;
  String serviceType;
  String specialNotes;
  List<String> beforePickupImages;
  List<String> afterPickupImages;
  String cancelReason;
  String createdAt;
  String updatedAt;
  String? ridePlanId;
  User user;
  Vehicle vehicle;
  List<NearbyDriver> nearbyDrivers;

  RideData({
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
    required this.nearbyDrivers,
  });

  factory RideData.fromJson(Map<String, dynamic> json) => RideData(
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
    platformFeeType: json['platformFeeType'],
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
    nearbyDrivers: List<NearbyDriver>.from(
        json['nearbyDrivers'].map((x) => NearbyDriver.fromJson(x))),
  );

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
    'beforePickupImages': List<dynamic>.from(beforePickupImages),
    'afterPickupImages': List<dynamic>.from(afterPickupImages),
    'cancelReason': cancelReason,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'ridePlanId': ridePlanId,
    'user': user.toJson(),
    'vehicle': vehicle.toJson(),
    'nearbyDrivers': List<dynamic>.from(nearbyDrivers.map((x) => x.toJson())),
  };
}

class User {
  String id;
  String fullName;
  String email;
  String profileImage;
  String location;
  double lat;
  double lng;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.location,
    required this.lat,
    required this.lng,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    profileImage: json['profileImage'],
    location: json['location'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

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
  String id;
  String manufacturer;
  String model;
  String licensePlateNumber;
  String bh;
  String image;
  String color;
  Driver driver;

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

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'],
    manufacturer: json['manufacturer'],
    model: json['model'],
    licensePlateNumber: json['licensePlateNumber'],
    bh: json['bh'],
    image: json['image'],
    color: json['color'],
    driver: Driver.fromJson(json['driver']),
  );

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
  String id;
  String fullName;
  String email;
  String phoneNumber;
  String profileImage;
  String location;

  Driver({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.location,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    profileImage: json['profileImage'],
    location: json['location'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'profileImage': profileImage,
    'location': location,
  };
}

class NearbyDriver {
  String id;
  String fullName;
  String phone;
  String profileImage;
  double lat;
  double lng;
  double distance;

  NearbyDriver({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.profileImage,
    required this.lat,
    required this.lng,
    required this.distance,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) => NearbyDriver(
    id: json['id'],
    fullName: json['fullName'],
    phone: json['phone'],
    profileImage: json['profileImage'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    distance: (json['distance'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'profileImage': profileImage,
    'lat': lat,
    'lng': lng,
    'distance': distance,
  };
}
