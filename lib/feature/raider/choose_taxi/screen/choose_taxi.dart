import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../confirm_pickup/screen/confirm_pickup.dart';
import '../controler/choose_taxi_api_controller.dart';
import '../controler/choose_taxi_controller.dart';
import '../model/choose_taxi_model.dart';
import '../widget/widget_add_new_card.dart';

class ChooseTaxiScreen extends StatefulWidget {

  ChooseTaxiScreen({super.key});

  @override
  State<ChooseTaxiScreen> createState() => _ChooseTaxiScreenState();
}

class _ChooseTaxiScreenState extends State<ChooseTaxiScreen> {
  @override
  void initState() {
    fachData;
    // TODO: implement initState
    super.initState();
  }
  Future<void> fachData()async{
    await controller.loadAndDisplayRideData();
  }
  final ChooseTaxiController controller = Get.put(ChooseTaxiController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String pickupAddress = args['pickup'] as String? ?? "No pickup address";
    final pickupLatArg = args['pickupLat'];
    final pickupLngArg = args['pickupLng'];
    final String dropOffAddress = args['dropOff'] as String? ?? "No dropOff address";
    final dropOffLatArg = args['dropOffLat'];
    final dropOffLngArg = args['dropOffLng'];

    final double pLat = double.tryParse(pickupLatArg?.toString() ?? '0.0') ?? 0.0;
    final double pLng = double.tryParse(pickupLngArg?.toString() ?? '0.0') ?? 0.0;
    final double dLat = double.tryParse(dropOffLatArg?.toString() ?? '0.0') ?? 0.0;
    final double dLng = double.tryParse(dropOffLngArg?.toString() ?? '0.0') ?? 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pLat != 0.0 || pLng != 0.0 || dLat != 0.0 || dLng != 0.0) {
        print("ChooseTaxiScreen: Calling loadAndDisplayRideData with arguments from previous screen.");
        controller.loadAndDisplayRideData(
          initialPickupLat: pLat,
          initialPickupLng: pLng,
          initialDropOffLat: dLat,
          initialDropOffLng: dLng,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoadingMap.value || controller.isLoadingDirections.value && controller.markers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.apiController.errorMessage.value.isNotEmpty &&
                controller.markers.isEmpty) {
              return Center(
                  child: Text(
                      "Error: ${controller.apiController.errorMessage.value}"));
            }

            if (controller.pickupPosition.value == null &&
                controller.markers.isEmpty) {
              if (pLat != 0.0 || pLng != 0.0) {
                print("ChooseTaxiScreen: Displaying fallback map with arguments.");
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(pLat, pLng),
                    zoom: 15,
                  ),
                );
              }
              return const Center(
                  child: Text("Map data could not be loaded or no ride found."));
            }

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.pickupPosition.value ??
                    LatLng(pLat != 0.0 ? pLat : 23.7947536,
                        pLng != 0.0 ? pLng : 90.4143085),
                zoom: 15,
              ),
              markers: controller.markers.value,
              polylines: controller.polyline.value.points.isNotEmpty
                  ? {controller.polyline.value}
                  : <Polyline>{},
            );
          }),
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

class ExpandedBottomSheet extends StatelessWidget {
  final ChooseTaxiApiController apiController = Get.find<ChooseTaxiApiController>();
  final ChooseTaxiController mainMapController = Get.find<ChooseTaxiController>();

  ExpandedBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (apiController.isLoading.value && apiController.rideDataList.isEmpty) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            color: Colors.white.withOpacity(0.8),
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      }

      if (apiController.errorMessage.value.isNotEmpty && apiController.rideDataList.isEmpty) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error fetching ride options: ${apiController.errorMessage.value}", style: globalTextStyle(color: Colors.red)),
          ),
        );
      }

      if (apiController.rideDataList.isEmpty) {
        return Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Found your Rider", style: globalTextStyle()),
          ),
        );
      }

      final ridePlanFromApi = apiController.rideDataList.first;
      final selectedCarFromApi = ridePlanFromApi.carTransport != null && ridePlanFromApi.carTransport!.isNotEmpty
          ? ridePlanFromApi.carTransport!.first
          : (mainMapController.selectedDriver.value != null
          ? CarTransport(
        id: mainMapController.selectedDriver.value!.id,
        serviceType: mainMapController.selectedDriver.value!.vehicleName,
        totalAmount: ridePlanFromApi.estimatedFare,
        driverLat: mainMapController.selectedDriver.value!.lat,
        driverLng: mainMapController.selectedDriver.value!.lng,
        vehicleId: mainMapController.selectedDriver.value!.vehicleId,
        pickupLocation: ridePlanFromApi.pickup,
        dropOffLocation: ridePlanFromApi.dropOff,
        pickupLat: ridePlanFromApi.pickupLat,
        pickupLng: ridePlanFromApi.pickupLng,
        dropOffLat: ridePlanFromApi.dropOffLat,
        dropOffLng: ridePlanFromApi.dropOffLng,
        distance: mainMapController.selectedDriver.value!.distance,
      )
          : null);

      return DraggableScrollableSheet(
        initialChildSize: 0.30,
        minChildSize: 0.15,
        maxChildSize: 0.7,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, spreadRadius: 1),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Confirm Details",
                      style: globalTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  const SizedBox(height: 10),

                  if (selectedCarFromApi != null) ...[
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/car2.png",
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCarFromApi.serviceType ?? "Standard Taxi",
                          style: globalTextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedCarFromApi.totalAmount != null
                              ? "${selectedCarFromApi.totalAmount!.toStringAsFixed(2)}ل.ل"
                              : "N/A",
                          style: globalTextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pickup: In 3 min",
                      style: globalTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF777F8B),
                      ),
                    ),
                    if (selectedCarFromApi.specialNotes != null &&
                        selectedCarFromApi.specialNotes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          selectedCarFromApi.specialNotes!,
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF777F8B),
                          ),
                        ),
                      ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          "No car assigned yet. Please select a driver below.",
                          style: globalTextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),

                  Text(
                    "Nearby Drivers",
                    style: globalTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (ridePlanFromApi.nearbyDrivers != null &&
                      ridePlanFromApi.nearbyDrivers!.isNotEmpty) ...[
                    ...ridePlanFromApi.nearbyDrivers!.map((driver) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_car,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver.fullName ?? 'Driver ',
                                    style: globalTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    driver.vehicleName,
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF777F8B),
                                    ),
                                  ),
                                  Text(
                                    "Distance: ${driver.distance.toStringAsFixed(2)} km",
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF777F8B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final LatLng driverPos = LatLng(driver.lat, driver.lng);
                              mainMapController.addMapMarker(
                                driverPos,
                                driver.fullName ?? 'Driver ${driver.id}',
                                MarkerType.car,
                                idSuffix: driver.id,
                              );
                              mainMapController.selectDriver(driver);
                              Get.snackbar("Driver Selected", "Selected ${driver.fullName ?? 'Driver ${driver.id}'}");
                            },
                            child: Text(
                              "Select",
                              style: globalTextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFDC71),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "No nearby drivers available.",
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],

                  // --- END OF MODIFIED SECTION ---

                  const SizedBox(height: 15), // Spacing before Payment Method
                  Text(
                    "Payment Method",
                    style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Get.to(WidgetAddNewCard());
                      Get.snackbar("Payment", "Navigate to add/select card screen.");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/card.png", width: 40, height: 40,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.credit_card, size: 40, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Add New Card",
                            style: globalTextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Bottom padding
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  CustomButton(
                    title: "Choose This Taxi",
                    borderColor: Colors.transparent,
                    backgroundColor: selectedCarFromApi != null
                        ? const Color(0xFFFFDC71)
                        : Colors.grey,
                    onPress: selectedCarFromApi != null
                        ? () {
                      final selectedDriver = mainMapController.selectedDriver.value;
                      if (selectedDriver == null) {
                        Get.snackbar("Selection Error", "Please select a driver first.");
                        return;
                      }
                      if (ridePlanFromApi.id == null || ridePlanFromApi.pickup == null || ridePlanFromApi.dropOff == null) {
                        Get.snackbar("Error", "Incomplete ride data. Please try again.");
                        return;
                      }

                      Get.to(() => ConfirmPickUpScreen(), arguments: {
                        'ridePlanId': ridePlanFromApi.id!,
                        'totalAmount': selectedCarFromApi.totalAmount!,
                        'transportId': selectedCarFromApi.id!,
                        'selectedDriverId': selectedDriver.id,
                        'selectedVehicleId': selectedDriver.vehicleId,
                        'selectedVehicleName': selectedDriver.vehicleName,
                        'pickupAddress': ridePlanFromApi.pickup!,
                        'dropOffAddress': ridePlanFromApi.dropOff!,
                        'pickupDate': ridePlanFromApi.pickupDate ?? DateTime.now().toIso8601String(),
                        'pickupTime': ridePlanFromApi.pickupTime ?? TimeOfDay.now().format(context),
                        'driverLat': selectedDriver.lat,
                        'driverLng': selectedDriver.lng,
                        'estimatedFare': selectedCarFromApi.totalAmount ?? ridePlanFromApi.estimatedFare ?? 0,
                      });
                    }
                        : () {
                      Get.snackbar("Selection Error",
                          "No car option available to choose. Please select a driver first.");
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}