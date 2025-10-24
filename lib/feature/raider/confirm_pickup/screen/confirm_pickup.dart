import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/style/global_text_style.dart';
import '../controler/confirm_pickup_controller.dart';
import '../widget/bottom_sheet1.dart';
import '../widget/bottom_sheet2.dart';
import '../widget/bottom_sheet3.dart';
import '../widget/bottom_sheet4.dart';
import '../widget/bottom_sheet5.dart';



class ConfirmPickUpScreen extends StatefulWidget {

  ConfirmPickUpScreen({super.key});

  @override
  State<ConfirmPickUpScreen> createState() => _ConfirmPickUpScreenState();
}

class _ConfirmPickUpScreenState extends State<ConfirmPickUpScreen> {
  final ConfirmPickupController controller = Get.put(ConfirmPickupController());
  // final MyRidePendingApiController myRidePendingApiController=Get.find<MyRidePendingApiController>();



  @override
  Widget build(BuildContext context) {

   /* final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String pickupAddress = args['pickup'] as String? ?? "No pickup address";
    final pickupLatArg = args['pickupLat'];
    final pickupLngArg = args['pickupLng'];
    final String dropOffAddress = args['dropOff'] as String? ?? "No dropOff address";
    final dropOffLatArg = args['dropOffLat'];
    final dropOffLngArg = args['dropOffLng'];
    final ridePlanId = args['ridePlanId'];
    final selectedDriverId = args['selectedDriverId'];
    final pickupTime = args['pickupTime'];
    final pickupDate = args['pickupDate'];
    final selectedVehicleId = args['selectedVehicleId'];

    final double pLat = double.tryParse(pickupLatArg?.toString() ?? '0.0') ?? 0.0;
    final double pLng = double.tryParse(pickupLngArg?.toString() ?? '0.0') ?? 0.0;
    final double dLat = double.tryParse(dropOffLatArg?.toString() ?? '0.0') ?? 0.0;
    final double dLng = double.tryParse(dropOffLngArg?.toString() ?? '0.0') ?? 0.0;*/

   /* WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pLat != 0.0 || pLng != 0.0 || dLat != 0.0 || dLng != 0.0) {
        print("ChooseTaxiScreen: Calling loadAndDisplayRideData with arguments from previous screen.");
        chooseTaxiController.loadAndDisplayRideData(
          initialPickup: pickupAddress,
          initialDropOff: dropOffAddress,
          initialPickupLat: pLat,
          initialPickupLng: pLng,
          initialDropOffLat: dLat,
          initialDropOffLng: dLng,
        );
      }
    });*/



    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.pickupPosition.value ?? const LatLng(23.749341, 90.437213),
                zoom: 11,
              ),
              markers: controller.markers.value,
              polylines: controller.polylines.value, // Show multiple polylines
            );
          }),
          // Overlay for distance and ETA
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Obx(() => Text(
                    "Driver Distance: ${controller.driverDistance.value}",
                    style: globalTextStyle(fontSize: 14, color: Colors.black),
                  )),
                  Obx(() => Text(
                    "ETA: ${controller.etaMinutes.value}",
                    style: globalTextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 60),
            child: Text(
              "Brothers Taxi",
              style: globalTextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Obx(() => buildBottomSheet(controller.currentBottomSheet.value)),
        ],
      ),
    );
  }

  Widget buildBottomSheet(int value) {
    switch (value) {
      case 1:
        return ExpandedBottomSheet1();
      case 2:
        return ExpandedBottomSheet2();
      case 3:
        return ExpandedBottomSheet3();
      case 4:
        return ExpandedBottomSheet4();
      case 5:
        return ExpandedBottomSheet5();
      default:
        return Container();
    }
  }
}
