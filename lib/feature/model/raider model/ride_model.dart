import '../recommended driver/recommended_driver.dart';
import '../user model/user_model.dart';
import '../vehicle model/vehicle_model.dart';

class Ride {
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
  final double? totalAmount;
  final double? distance;
  final double? platformFee;
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
  final User? user;
  final Vehicle? vehicle;
  final List<RecommendedDriver>? recommendedDrivers;

  Ride({
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
    this.user,
    this.vehicle,
    this.recommendedDrivers,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json["id"],
      userId: json["userId"],
      vehicleId: json["vehicleId"],
      pickupLocation: json["pickupLocation"],
      dropOffLocation: json["dropOffLocation"],
      pickupLat: (json["pickupLat"] as num?)?.toDouble(),
      pickupLng: (json["pickupLng"] as num?)?.toDouble(),
      dropOffLat: (json["dropOffLat"] as num?)?.toDouble(),
      dropOffLng: (json["dropOffLng"] as num?)?.toDouble(),
      driverLat: (json["driverLat"] as num?)?.toDouble(),
      driverLng: (json["driverLng"] as num?)?.toDouble(),
      totalAmount: (json["totalAmount"] as num?)?.toDouble(),
      distance: (json["distance"] as num?)?.toDouble(),
      platformFee: (json["platformFee"] as num?)?.toDouble(),
      platformFeeType: json["platformFeeType"],
      paymentMethod: json["paymentMethod"],
      paymentStatus: json["paymentStatus"],
      isPayment: json["isPayment"],
      pickupDate: json["pickupDate"],
      pickupTime: json["pickupTime"],
      rideTime: json["rideTime"],
      waitingTime: json["waitingTime"],
      status: json["status"],
      assignedDriver: json["assignedDriver"],
      assignedDriverReqStatus: json["assignedDriverReqStatus"],
      isDriverReqCancel: json["isDriverReqCancel"],
      arrivalConfirmation: json["arrivalConfirmation"],
      journeyStarted: json["journeyStarted"],
      journeyCompleted: json["journeyCompleted"],
      serviceType: json["serviceType"],
      specialNotes: json["specialNotes"],
      beforePickupImages: json["beforePickupImages"] != null
          ? List<String>.from(json["beforePickupImages"])
          : [],
      afterPickupImages: json["afterPickupImages"] != null
          ? List<String>.from(json["afterPickupImages"])
          : [],
      cancelReason: json["cancelReason"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      user: json["user"] != null ? User.fromJson(json["user"]) : null,
      vehicle:
      json["vehicle"] != null ? Vehicle.fromJson(json["vehicle"]) : null,
      recommendedDrivers: json["recommendedDrivers"] != null
          ? List<RecommendedDriver>.from(
          json["recommendedDrivers"].map((x) => RecommendedDriver.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "vehicleId": vehicleId,
      "pickupLocation": pickupLocation,
      "dropOffLocation": dropOffLocation,
      "pickupLat": pickupLat,
      "pickupLng": pickupLng,
      "dropOffLat": dropOffLat,
      "dropOffLng": dropOffLng,
      "driverLat": driverLat,
      "driverLng": driverLng,
      "totalAmount": totalAmount,
      "distance": distance,
      "platformFee": platformFee,
      "platformFeeType": platformFeeType,
      "paymentMethod": paymentMethod,
      "paymentStatus": paymentStatus,
      "isPayment": isPayment,
      "pickupDate": pickupDate,
      "pickupTime": pickupTime,
      "rideTime": rideTime,
      "waitingTime": waitingTime,
      "status": status,
      "assignedDriver": assignedDriver,
      "assignedDriverReqStatus": assignedDriverReqStatus,
      "isDriverReqCancel": isDriverReqCancel,
      "arrivalConfirmation": arrivalConfirmation,
      "journeyStarted": journeyStarted,
      "journeyCompleted": journeyCompleted,
      "serviceType": serviceType,
      "specialNotes": specialNotes,
      "beforePickupImages": beforePickupImages,
      "afterPickupImages": afterPickupImages,
      "cancelReason": cancelReason,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "user": user?.toJson(),
      "vehicle": vehicle?.toJson(),
      "recommendedDrivers":
      recommendedDrivers?.map((x) => x.toJson()).toList(),
    };
  }
}
