import 'dart:convert';

/// Converts a JSON string into a CancelRideModel object.
CancelRideModel cancelRideModelFromJson(String str) =>
    CancelRideModel.fromJson(json.decode(str) as Map<String, dynamic>);

/// Converts a CancelRideModel object into a JSON string.
String cancelRideModelToJson(CancelRideModel data) => json.encode(data.toJson());

/// A model class representing the details of a cancelled ride.
class CancelRideModel {
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
  final List<dynamic>? beforePickupImages; // Using dynamic as the list is empty
  final List<dynamic>? afterPickupImages;  // Using dynamic as the list is empty
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ridePlanId;

  CancelRideModel({
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

  /// Factory constructor to create a new CancelRideModel instance from a map.
  factory CancelRideModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers of any type (int, double) to double?
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      return (value as num).toDouble();
    }

    return CancelRideModel(
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
      // Safely parse date strings into DateTime objects
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      ridePlanId: json['ridePlanId'] as String?,
    );
  }

  /// Converts the CancelRideModel instance to a JSON map.
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
      // Convert DateTime objects back to ISO 8601 string format for JSON
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ridePlanId': ridePlanId,
    };
  }
}
