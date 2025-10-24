
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../bottom_nav_user/screen/bottom_nav_user.dart';
import '../controler/confirm_pickup_controller.dart';
import '../controler/my_ride_pending_api_controller.dart';
import '../controler/ride_cancel_api_controller.dart';

class ExpandedBottomSheet4 extends StatefulWidget {
  ExpandedBottomSheet4({super.key});

  @override
  State<ExpandedBottomSheet4> createState() => _ExpandedBottomSheet4State();
}

class _ExpandedBottomSheet4State extends State<ExpandedBottomSheet4> {
  String transportId = '';

  final ConfirmPickupController controller = Get.put(ConfirmPickupController());
  final RideCancelApiController rideCancelApiController = Get.put(RideCancelApiController());
  final MyRidePendingApiController apiController = Get.put(MyRidePendingApiController());

  @override
  void initState() {
    super.initState();
    // Trigger API call and log execution
    Future.microtask(() async {
      debugPrint("-----ExpandedBottomSheet4 initState: Triggering myRidePendingApiController");
      await apiController.myRidePendingApiController();
      debugPrint("-----ExpandedBottomSheet4 initState: myRidePendingApiController completed, carTransportModel length: ${apiController.carTransportModel.length}");
    });

    // 1. PRIORITY: Get ID from ConfirmPickupController (post-ride creation)
    if (controller.carTransportId.value != null && controller.carTransportId.value!.isNotEmpty) {
      transportId = controller.carTransportId.value!;
      debugPrint("-----ExpandedBottomSheet4 initState: Using ID from ConfirmPickupController: $transportId");
    } else {
      // Fallback: Try MyRidePendingApiController
      if (apiController.carTransportModel.isNotEmpty) {
        transportId = apiController.carTransportModel[0].id ?? '';
        debugPrint("--+++--ExpandedBottomSheet4 initState: Fallback to MyRidePendingApiController ID: $transportId");
      } else {
        // Final fallback: Get.arguments
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        transportId = args['transportId']?.toString() ?? '';
        debugPrint("--**-ExpandedBottomSheet4 initState: Fallback to arguments ID: $transportId");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.1,
      maxChildSize: 0.6,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => controller.changeSheet(3),
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    Text(
                      "Cancel trip?",
                      style: globalTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.changeSheet(5),
                      child: Text(
                        "Skip",
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                // Add reactivity to show loading or error state
                Obx(() => apiController.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : apiController.errorMessage.value.isNotEmpty
                    ? Text(
                  "Error: ${apiController.errorMessage.value}",
                  style: globalTextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                )
                    : Text(
                  "Why do you want to cancel? ",
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
                SizedBox(height: 10),

                // --- Cancellation Reasons List (using a helper function) ---
                _buildReasonItem(1, "Selected wrong pick-up", "assets/icons/icon5.png"),
                Divider(),
                _buildReasonItem(2, "Selected wrong drop-off ", "assets/icons/icon6.png"),
                Divider(),
                _buildReasonItem(3, "Requested by accident", "assets/icons/icon4.png"),
                Divider(),
                _buildReasonItem(4, "Wait time was too long", "assets/icons/icon3.png"),
                Divider(),
                _buildReasonItem(5, "Requested wrong vehicle", "assets/icons/icon2.png"),
                Divider(),
                _buildReasonItem(6, "Other", "assets/icons/icon1.png"),

                SizedBox(height: 20),

                // Only the CustomButton needs to be reactive to the loading state.
                Obx(() => CustomButton(
                  title: rideCancelApiController.isLoading.value
                      ? 'Cancelling...'
                      : "Cancel Trip",
                  borderColor: Colors.transparent,
                  backgroundColor: const Color(0xFFFFDC71),
                  textStyle: globalTextStyle(fontWeight: FontWeight.bold),
                  onPress: rideCancelApiController.isLoading.value
                      ? null
                      : () => _rideCancelledMethod(),
                )),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to build each selectable row item
  Widget _buildReasonItem(int index, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        rideCancelApiController.selectContainerEffect(index);
      },
      child: Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: rideCancelApiController.selectedIndex.value == index
              ? Color(0xFFFFF4D4)
              : Colors.white,
        ),
        child: _buildRow(title: title, imagePath: imagePath), // Call the original _buildRow
      )),
    );
  }

  // Your original _buildRow for displaying the item content
  Widget _buildRow({required title, required imagePath}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Image.asset(imagePath, height: 25, width: 25),
          SizedBox(width: 10),
          Text(
            title,
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ⭐️ MODIFIED: Logic to get ID AND the selected REASON for the API call
  Future<void> _rideCancelledMethod() async {
    // ⭐️ Get the reason stored in the RideCancelApiController
    String reason = rideCancelApiController.selectedReasonTitle.value;

    if (reason.isEmpty) {
      Get.snackbar('Error', 'Please select a cancellation reason.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Logic to get transportId
    // PRIORITY: Get ID from ConfirmPickupController
    if (controller.carTransportId.value != null && controller.carTransportId.value!.isNotEmpty) {
      transportId = controller.carTransportId.value!;
      debugPrint("ExpandedBottomSheet4 _rideCancelledMethod: Using ID from ConfirmPickupController: $transportId");
    } else {
      // Retry API call if carTransportModel is empty
      if (apiController.carTransportModel.isEmpty) {
        debugPrint("ExpandedBottomSheet4 _rideCancelledMethod: carTransportModel empty, retrying API call");
        await apiController.myRidePendingApiController();
      }
      if (apiController.carTransportModel.isNotEmpty) {
        transportId = apiController.carTransportModel[0].id ?? '';
        debugPrint("ExpandedBottomSheet4 _rideCancelledMethod: Fallback to MyRidePendingApiController ID: $transportId");
      } else {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        transportId = args['transportId']?.toString() ?? '';
        debugPrint("ExpandedBottomSheet4 _rideCancelledMethod: Fallback to arguments ID: $transportId");
      }
    }

    if (transportId.isNotEmpty) {
      debugPrint("Calling Cancel API with ID: $transportId and Reason: $reason");
      // ⭐️ Pass both the ID and the Reason to the API controller
      bool isSuccess = await rideCancelApiController.rideCancelApiMethod(transportId, reason);

      if (isSuccess) {
        // Navigate to the main screen on success
        Get.offAll(() => BottomNavbarUser());
        Get.snackbar('Success', 'Trip cancelled successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      } else {
        // Show error message on failure
        Get.snackbar('Failed', rideCancelApiController.errorMessage ?? 'Cancellation failed.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } else {
      Get.snackbar('Error', "Could not find a valid trip ID.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }
}