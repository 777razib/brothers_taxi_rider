import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../choose_taxi/controler/choose_taxi_api_controller.dart';
import '../controler/confirm_pick_up_api_controller.dart';
import '../controler/confirm_pickup_controller.dart';
import '../controler/my_ride_pending_api_controller.dart';

class ExpandedBottomSheet1 extends StatefulWidget {
  ExpandedBottomSheet1({super.key});

  @override
  State<ExpandedBottomSheet1> createState() => _ExpandedBottomSheet1State();
}

class _ExpandedBottomSheet1State extends State<ExpandedBottomSheet1> {
  final ConfirmPickupController uiController = Get.put(ConfirmPickupController());
  final ConfirmPickUpApiController apiController = Get.put(ConfirmPickUpApiController());
  final ChooseTaxiApiController chooseTaxiApiController = Get.put(ChooseTaxiApiController());
  final MyRidePendingApiController myRidePendingApiController = Get.put(MyRidePendingApiController());

  String getCurrentDate() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  // Time in HH:MM format (e.g., 03:39)
  String getCurrentTime() {
    return DateTime.now().toString().substring(11, 16);
  }


  // Consolidated async method to fetch ID and call APIs in sequence
  void _fetchAndLoadData() async {
    try {
      // 1. Call MyRidePendingApiController first
      debugPrint("📡 [API] Starting MyRidePendingApiController call...");
     //await myRidePendingApiController.myRidePendingApiController();
      debugPrint("✅ [API] MyRidePendingApiController call completed.");

      // 2. Get ID from AuthController after the first API call
      debugPrint("🔍 [Auth] Fetching user ID from AuthController...");

    } catch (e, stackTrace) {
      debugPrint("❌ [Error] Exception in _fetchAndLoadData: $e");
      debugPrint("📜 [StackTrace] $stackTrace");
      Get.snackbar("Error", "Failed to load data: $e");
    }
  }
@override
  void initState() {
    // TODO: implement initState
  uiController;
  _fetchAndLoadData();
    super.initState();
  }
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed to this bottom sheet
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    // Data for displaying in the UI
    final String pickupAddress = args['pickupAddress'] as String? ?? "No pickup address provided";

    // Data for the API call - Retrieve all necessary IDs
    final String ridePlanId = args['ridePlanId']?.toString() ?? "";
    final String selectedDriverId = args['selectedDriverId']?.toString() ?? ""; // Added back
    //final String selectedRiderId = args['ridePlanId']?.toString() ?? ""; // Added back
    final String selectedVehicleId = args['selectedVehicleId']?.toString() ?? "";




    // Note: actualPickupTime/Date from args are ignored in this implementation
    // as we rely on the current time due to the arguments being empty.

    return DraggableScrollableSheet(
      initialChildSize: 0.26,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (BuildContext scrollSheetContext, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Confirm Pick-up Location",
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: Theme.of(scrollSheetContext).primaryColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text("${chooseTaxiApiController.rideDataList[0].pickup}",
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Obx(() {
                  if (apiController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return CustomButton(
                    backgroundColor: Colors.amberAccent,
                    title: "Confirm Pick-up",
                    onPress: () async {
                      // --- Get Current Date and Time for the API Call ---
                      final String pickupDate = getCurrentDate(); // Now correctly derived
                      final String pickupTime = getCurrentTime();
                      //await myRidePendingApiController.myRidePendingApiController();// Now correctly derived
                      // ----------------------------------------------------
                      print("ExpandedBottomSheet1: 'Confirm Pick-up' button pressed.");
                      print("ExpandedBottomSheet1: Data for API call -> ridePlanId: '$ridePlanId', selectedDriverId: '$selectedDriverId', pickupTime: '$pickupTime', pickupDate: '$pickupDate', selectedVehicleId: '$selectedVehicleId'");

                      // Client-side validation for critical fields
                      if (ridePlanId.isEmpty || selectedDriverId.isEmpty || selectedVehicleId.isEmpty) {
                        Get.snackbar(
                            "Input Error",
                            "Required ride details are missing (Ride ID, Driver ID, or Vehicle ID).",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade600,
                            colorText: Colors.white);
                        return;
                      }

                      // Call the API method with the CURRENT date and time
                      final isSuccess = await apiController.confirmPickUpApiCallMethod(
                          ridePlanId,
                          selectedVehicleId
                      );

                      if (isSuccess) {
                        await myRidePendingApiController.myRidePendingApiController();
                        Get.snackbar("Success", "Ride confirmed successfully!",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white);
                        uiController.changeSheet(2,);
                        // Navigate away or close sheet
                      } else {
                        Get.snackbar(
                            "Confirmation Failed",
                            apiController.errorMessage.value.isNotEmpty
                                ? apiController.errorMessage.value
                                : "Could not confirm the ride. Please try again.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade600,
                            colorText: Colors.white);
                      }
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}