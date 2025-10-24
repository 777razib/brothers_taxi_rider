import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/style/global_text_style.dart';
import '../../choose_taxi/screen/choose_taxi.dart';
import '../../confirm_pickup/controler/confirm_pickup_controller.dart';

class TripRequest extends StatelessWidget {
  final ConfirmPickupController controller = Get.put(ConfirmPickupController());

  TripRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.pickupPosition.value ?? const LatLng(23.749341, 90.437213),
                zoom: 15,
              ),
              markers: controller.markers.value,
              polylines: controller.polylines.value,
            );
          }),
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
          ExpandedBottomSheet(),
        ],
      ),
    );
  }
}