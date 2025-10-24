import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/style/global_text_style.dart';
import '../controler/driver_is_on_goging_controller.dart';
import '../widget/bottom_sheet6.dart';

class PickupPointMapScreen extends StatefulWidget {
  PickupPointMapScreen({super.key});

  @override
  State<PickupPointMapScreen> createState() => _PickupPointMapScreenState();
}

class _PickupPointMapScreenState extends State<PickupPointMapScreen> {
  final DriverIsOnGoingController controller = Get.put(DriverIsOnGoingController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String pickupAddress = args['pickup'] as String? ?? "No pickup address";
    final pickupLatArg = args['pickupLat'];
    final pickupLngArg = args['pickupLng'];
    final String dropOffAddress = args['dropOff'] as String? ?? "No drop-off address";
    final dropOffLatArg = args['dropOffLat'];
    final dropOffLngArg = args['dropOffLng'];

    final double pLat = double.tryParse(pickupLatArg?.toString() ?? '0.0') ?? 0.0;
    final double pLng = double.tryParse(pickupLngArg?.toString() ?? '0.0') ?? 0.0;
    final double dLat = double.tryParse(dropOffLatArg?.toString() ?? '0.0') ?? 0.0;
    final double dLng = double.tryParse(dropOffLngArg?.toString() ?? '0.0') ?? 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pLat != 0.0 && pLng != 0.0 && dLat != 0.0 && dLng != 0.0) {
        debugPrint("PickupPointMapScreen: Loading ride data with coordinates: Pickup=($pLat, $pLng), Drop-off=($dLat, $dLng)");
        controller.loadAndDisplayRideData(
          initialPickupLat: pLat,
          initialPickupLng: pLng,
          initialDropOffLat: dLat,
          initialDropOffLng: dLng,
        );
      } else {
        debugPrint("PickupPointMapScreen: Invalid coordinates provided, using fallback");
        controller.loadAndDisplayRideData(
          initialPickupLat: 23.749341,
          initialPickupLng: 90.437213,
          initialDropOffLat: 23.749704,
          initialDropOffLng: 90.430164,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value || controller.isLoadingMap.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.driverInfoApiController.errorMessage.value.isNotEmpty) {
              return Center(
                child: Text(
                  "Error: ${controller.driverInfoApiController.errorMessage.value}",
                  style: globalTextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (controller.pickupPosition.value == null) {
              return Center(
                child: Text(
                  "Unable to load map data. Please try again.",
                  style: globalTextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.pickupPosition.value!,
                zoom: 15,
              ),
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
            );
          }),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              "Brothers Taxi Ride1111111",
              style: globalTextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() => controller.isBottomSheetOpen.value
                ? Container(
              height: MediaQuery.of(context).size.height * 0.4, // Constrain height
              child: ExpandedBottomSheet6(
                driverDistance: controller.driverDistance.value,
                etaMinutes: controller.etaMinutes.value,
              ),
            )
                : Container()),
          ),
        ],
      ),
    );
  }
}