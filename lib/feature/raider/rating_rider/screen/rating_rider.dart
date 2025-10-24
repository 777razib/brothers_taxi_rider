import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../choose_taxi/controler/choose_taxi_api_controller.dart';
import '../controller/rating_rider_api_controller.dart';
import '../controller/rating_rider_controller.dart';

class RatingScreen extends StatefulWidget {
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final RatingController controller = Get.put(
    RatingController(),
  );
  String transportId = '';

  // Initialize the controller
  final ChooseTaxiApiController apiController = Get.find<ChooseTaxiApiController>();

  final RatingRiderApiController riderApiMethod = Get.find<RatingRiderApiController>();

  @override
  void initState() {
    super.initState();

    if (apiController.rideDataList.isNotEmpty &&
        apiController.rideDataList[0].carTransport != null &&
        apiController.rideDataList[0].carTransport!.isNotEmpty) {
      transportId = apiController.rideDataList[0].carTransport![0].id ?? '';
    }

    // 2. Fallback: Try to get ID from Get.arguments
    if (transportId.isEmpty) {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      transportId = args['transportId']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/images/cross.png",
                  width: 50,
                  height: 50,
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => controller.setRating(
                          index + 1,
                        ), // Set rating when icon is tapped
                        child: Obx(() {
                          return Icon(
                            index < controller.rating.value
                                ? Icons.star
                                : Icons
                                      .star_border, // Filled or empty star based on the rating
                            color: Colors.amber,
                            size: 40,
                          );
                        }),
                      );
                    }),
                  ),
                  Text(
                    "How was your Trip",
                    style: globalTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF041023),
                    ),
                  ),
                  Text(
                    "We hope you enjoyed your ride",
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF777F8B),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Obx(
                () => TextField(
                  onChanged:
                      controller.setDetails, // Update the details as user types
                  decoration: InputDecoration(
                    hintText: "Add review here... ",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(
                    text: controller.details.value,
                  ), // Display current text
                ),
              ),
              Spacer(),
              CustomButton(
                title: "Submit",
                backgroundColor: Color(0xFFFFDC71),
                borderColor: Colors.transparent,
                onPress: _submitRating,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void>_submitRating() async {
    /*String transportId = '';

    // 1. Try to get ID from the primary controller (ChooseTaxiApiController)
    if (apiController.rideDataList.isNotEmpty &&
        apiController.rideDataList[0].carTransport != null &&
        apiController.rideDataList[0].carTransport!.isNotEmpty) {
      transportId = apiController.rideDataList[0].carTransport![0].id ?? '';
    }

    // 2. Fallback: Try to get ID from Get.arguments
    if (transportId.isEmpty) {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      transportId = args['transportId']?.toString() ?? '';
    }*/

    if (transportId.isNotEmpty) {
      debugPrint("ExpandedBottomSheet6 initState: Calling API with ID: $transportId");
      bool isSuccess=await riderApiMethod.ratingRiderApiMethod(transportId, controller.rating.value, controller.details.value);
      if(isSuccess){
        Get.to(() => RatingScreen());
      }
    } else {
      debugPrint("⚠️ ExpandedBottomSheet6: No transport ID found - skipping API call in initState");
    }

  }
}
