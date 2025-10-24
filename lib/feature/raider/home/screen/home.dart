
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/style/global_text_style.dart';
import '../../location_picker/screen/location_picker.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key, double? lat, double? lng});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Google Map widget
          Obx(() {
            return GoogleMap(
              onMapCreated: controller.onMapCreated,

              // Camera target uses the live-updated position
              initialCameraPosition: CameraPosition(
                target: controller.markerPosition.value,
                zoom: 14,
              ),
              myLocationEnabled: false,
              onTap: (LatLng position) {}, // Disabled to maintain live tracking

              markers: {
                Marker(
                  markerId: const MarkerId('CurrentLocation'),
                  // Marker position uses the live-updated position
                  position: controller.markerPosition.value,
                  infoWindow: const InfoWindow(title: 'You are here'),
                  icon: controller.customMarkerIcon.value,
                ),
              },
            );
          }),

          // Custom Title Text
          Padding(
            padding: EdgeInsets.only(left: 20, top: 60),
            child: Text(
              "Brothers Taxi",
              style: globalTextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Draggable Bottom Sheet
          const ExpandedBottomSheetHome(),
        ],
      ),
    );
  }
}

class ExpandedBottomSheetHome extends StatelessWidget {
  const ExpandedBottomSheetHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 0.4,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
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
                // Search Container
                GestureDetector(
                  onTap: () => Get.to(() => LocationPicker()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        25,
                      ), // Rounded corners
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[700]),
                        const SizedBox(width: 10),
                        const Expanded(child: Text("Search...")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}