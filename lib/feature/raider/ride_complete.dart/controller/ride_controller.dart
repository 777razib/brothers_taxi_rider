import 'package:get/get.dart';

class RideCompletedController extends GetxController {
  var rideDetails = RideDetails(
    riderName: "John Smith",
    tripDistance: "20.8km",
    tripDuration: "15 Min",
    pickupLocation: "Washing tone DC",
    rideCost: 18.00,
    paymentMethod: "Wallet",
    rideType: "MiniRide",
    bookingId: "FD14HF667",
    rideCompletedOn: "Today, 12:35 PM",
  ).obs;
}

class RideDetails {
  String riderName;
  String tripDistance;
  String tripDuration;
  String pickupLocation;
  double rideCost;
  String paymentMethod;
  String rideType;
  String bookingId;
  String rideCompletedOn;

  RideDetails({
    required this.riderName,
    required this.tripDistance,
    required this.tripDuration,
    required this.pickupLocation,
    required this.rideCost,
    required this.paymentMethod,
    required this.rideType,
    required this.bookingId,
    required this.rideCompletedOn,
  });
}
