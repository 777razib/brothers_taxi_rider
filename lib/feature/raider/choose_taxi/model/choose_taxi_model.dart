import 'dart:convert';
import 'location_searching_model.dart';

class RidePlan2 {
  final String? id;
  final String? userId;
  final String? pickup;
  final String? dropOff;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropOffLat;
  final double? dropOffLng;
  final int? rideTime;
  final int? waitingTime;
  final double? distance;
  final int? estimatedFare;
  final String? serviceType;
  final String? pickupDate;
  final String? pickupTime;
  final String? createdAt;
  final String? updatedAt;
  final List<CarTransport>? carTransport;
  final List<NearbyDriver>? nearbyDrivers;

  RidePlan2({
    this.id,
    this.userId,
    this.pickup,
    this.dropOff,
    this.pickupLat,
    this.pickupLng,
    this.dropOffLat,
    this.dropOffLng,
    this.rideTime,
    this.waitingTime,
    this.distance,
    this.estimatedFare,
    this.serviceType,
    this.pickupDate,
    this.pickupTime,
    this.createdAt,
    this.updatedAt,
    this.carTransport,
    this.nearbyDrivers,
  });

  factory RidePlan2.fromJson(Map<String, dynamic> json) {
    var driversFromJson = json['nearbyDrivers'] as List<dynamic>?;
    List<NearbyDriver>? driversList = driversFromJson
        ?.map((driver) => NearbyDriver.fromJson(driver as Map<String, dynamic>))
        .toList();

    return RidePlan2(
      id: json['id'],
      userId: json['userId'],
      pickup: json['pickup'],
      dropOff: json['dropOff'],
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropOffLat: (json['dropOffLat'] as num?)?.toDouble(),
      dropOffLng: (json['dropOffLng'] as num?)?.toDouble(),
      rideTime: json['rideTime'],
      waitingTime: json['waitingTime'],
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedFare: json['estimatedFare'],
      serviceType: json['serviceType'],
      pickupDate: json['pickupDate'],
      pickupTime: json['pickupTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      carTransport: (json['carTransport'] as List<dynamic>?)
          ?.map((e) => CarTransport.fromJson(e))
          .toList(),
      nearbyDrivers: driversList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "pickup": pickup,
      "dropOff": dropOff,
      "pickupLat": pickupLat,
      "pickupLng": pickupLng,
      "dropOffLat": dropOffLat,
      "dropOffLng": dropOffLng,
      "rideTime": rideTime,
      "waitingTime": waitingTime,
      "distance": distance,
      "estimatedFare": estimatedFare,
      "serviceType": serviceType,
      "pickupDate": pickupDate,
      "pickupTime": pickupTime,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "carTransport": carTransport?.map((e) => e.toJson()).toList(),
      "nearbyDrivers": nearbyDrivers?.map((e) => e.toJson()).toList(),
    };
  }

  static List<RidePlan2> listFromJson(String str) =>
      List<RidePlan2>.from(json.decode(str).map((x) => RidePlan2.fromJson(x)));

  static String listToJson(List<RidePlan2> data) =>
      json.encode(data.map((x) => x.toJson()).toList());
}

class CarTransport {
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
  final String? createdAt;
  final String? updatedAt;
  final String? ridePlanId;

  CarTransport({
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
  });

  factory CarTransport.fromJson(Map<String, dynamic> json) {
    return CarTransport(
      id: json['id'],
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      pickupLocation: json['pickupLocation'],
      dropOffLocation: json['dropOffLocation'],
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropOffLat: (json['dropOffLat'] as num?)?.toDouble(),
      dropOffLng: (json['dropOffLng'] as num?)?.toDouble(),
      driverLat: (json['driverLat'] as num?)?.toDouble(),
      driverLng: (json['driverLng'] as num?)?.toDouble(),
      totalAmount: json['totalAmount'],
      distance: (json['distance'] as num?)?.toDouble(),
      platformFee: json['platformFee'],
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
      beforePickupImages: json['beforePickupImages'],
      afterPickupImages: json['afterPickupImages'],
      cancelReason: json['cancelReason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      ridePlanId: json['ridePlanId'],
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
      "ridePlanId": ridePlanId,
    };
  }
}