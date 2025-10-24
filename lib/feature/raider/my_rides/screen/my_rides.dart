import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/global_widegts/appBar.dart';
import '../../../../core/style/global_text_style.dart';
import '../controller/my_rides_controller.dart';


class MyRides extends StatelessWidget {
  MyRides({super.key});

  final RideControllers rideControllers = Get.put(RideControllers());

  @override
  Widget build(BuildContext context) {
    // Trigger fetch when screen loads
    rideControllers.fetchRides();
    rideControllers.fetchRideHistory();

    return Obx(() {
      return DefaultTabController(
        length: 2,
        initialIndex: rideControllers.currentTabIndex.value,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomAppBar(
                    title: "",
                    onLeadingTap: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My rides",
                      style: globalTextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212529),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tab Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFFF2F2F2),
                    ),
                    child: ButtonsTabBar(
                      backgroundColor: const Color(0xFFFFDC71),
                      unselectedBackgroundColor: Colors.white,
                      unselectedLabelStyle: const TextStyle(color: Color(0xFF4D5154)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                      buttonMargin: const EdgeInsets.symmetric(horizontal: 10),
                      radius: 30,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Tab(text: "My rides"),
                        Tab(text: "Ride History"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        /// -------- My Rides --------
                        rideControllers.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : rideControllers.errorMessage.isNotEmpty
                            ? Center(child: Text(rideControllers.errorMessage.value))
                            : ListView.builder(
                          itemCount: rideControllers.rides.length,
                          itemBuilder: (context, index) {
                            final ride = rideControllers.rides[index];
                            return RideHistoryTab(
                              imagePersion: "assets/icons/usericon.png",
                              textPersion: ride.vehicle.driver.fullName ?? "Unknown Driver",
                              imagelocation1: "assets/icons/Frame.png",
                              textlocation1: ride.pickupLocation ?? "Unknown Pickup",
                              imagelocation2: "assets/icons/location-08 (4).png",
                              textlocation2: ride.dropOffLocation ?? "Unknown Drop",
                              pricing: ride.totalAmount?.toString() ?? "0",
                            );
                          },
                        ),

                        /// -------- Ride History --------
                        rideControllers.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : rideControllers.errorMessage.isNotEmpty
                            ? Center(child: Text(rideControllers.errorMessage.value))
                            : ListView.builder(
                          itemCount: rideControllers.rideHistory.length,
                          itemBuilder: (context, index) {
                            final ride = rideControllers.rideHistory[index];
                            return RideHistoryTab2(
                              buttonColor: const Color(0xFFFFDC71),
                              buttonText: ride.status ?? '',
                              googleMapChild: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      ride.pickupLat ?? 23.8103,
                                      ride.pickupLng ?? 90.4125,
                                    ),
                                    zoom: 14,
                                  ),
                                  zoomControlsEnabled: false,
                                  scrollGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                ),
                              ),
                              widget: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: RideHistoryTab(
                                  imagePersion: "assets/icons/usericon.png",
                                  textPersion: ride.vehicle.driver.fullName ?? "Unknown Driver",
                                  imagelocation1: "assets/icons/Frame.png",
                                  textlocation1: ride.pickupLocation ?? "",
                                  imagelocation2: "assets/icons/location-08 (4).png",
                                  textlocation2: ride.dropOffLocation ?? "",
                                  pricing: ride.totalAmount.toString() ?? "0",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}



class RideHistoryTab extends StatelessWidget {
  final String imagePersion;
  final String imagelocation1;
  final String imagelocation2;
  final String textlocation1;
  final String textlocation2;
  final String textPersion;
  final String pricing;

  const RideHistoryTab({
    super.key,
    required this.imagePersion,
    required this.imagelocation1,
    required this.textPersion,
    required this.pricing,
    required this.imagelocation2,
    required this.textlocation1,
    required this.textlocation2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 96,
        width: 339, // keep fixed width or make responsive
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Icon + Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: Image.asset(imagePersion, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          textPersion,
                          style: globalTextStyle(
                            color: const Color(0xFF000000),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: Image.asset(imagelocation1, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          textlocation1,
                          style: globalTextStyle(
                            color: const Color(0xFF000000),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset(imagelocation2, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          textlocation2,
                          style: globalTextStyle(
                            color: const Color(0xFF000000),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Pricing
              Text(
                "\$$pricing",
                style: globalTextStyle(
                  color: const Color(0xFF4D5154),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RideHistoryTab2 extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Widget widget;
  final Widget? googleMapChild;

  const RideHistoryTab2({
    super.key,
    required this.buttonText,
    required this.buttonColor,
    required this.widget,
    this.googleMapChild,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// Main Ride Card
            Container(
              width: 339,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                children: [
                  /// Map + Button Overlay
                  SizedBox(
                    height: 144,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        /// Google Map (only if provided)
                        if (googleMapChild != null) googleMapChild!,
                        /// Button Positioned on Map
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: buttonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Ride Info Section
                  widget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

