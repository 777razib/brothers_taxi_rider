import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../confirm_pickup/controler/confirm_pickup_controller.dart';
import '../../ride_canceled/screen/ride_canceled.dart';
import '../controler/end_ride_controller.dart';

class EndRideScreen extends StatelessWidget {
  final EndRideController controllerPickupAccept = Get.put(EndRideController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            return controllerPickupAccept.isLoading.value
                ? CircularProgressIndicator()
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: controllerPickupAccept.markerPosition.value,
                      zoom: 15,
                    ),
                    markers: controllerPickupAccept.markers.value,
                    polylines: {
                      controllerPickupAccept.polyline.value,
                    }, // Show polyline between markers
                  );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 60),
            child: Text(
              "Brothers Taxi",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          EndRideBottomSheet(),
        ],
      ),
    );
  }
}

class EndRideBottomSheet extends StatelessWidget {
  EndRideBottomSheet({super.key});

  final ConfirmPickupController controller = Get.put(ConfirmPickupController());

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.7,
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

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 0.4, color: Colors.black45),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ), // Location icon
                          SizedBox(width: 10), // Space between icon and text
                          Text(
                            'Meet at the pick-up point for \nRode No.12, North',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Icon(
                            Icons.share_location,
                            color: Colors.black,
                          ), // Location icon
                          SizedBox(width: 10), // Space between icon and text
                          Text(
                            'Washing tone DC',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  title: "End Ride",
                  borderColor: Colors.transparent,
                  textStyle: globalTextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Color(0xFFFFDC71),
                  onPress: () {
                    Get.to(() => RideCanceled());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
