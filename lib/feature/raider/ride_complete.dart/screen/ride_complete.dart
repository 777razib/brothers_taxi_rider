
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/global_widegts/custom_button.dart';
import '../../../../core/style/global_text_style.dart';
import '../../../bottom_nav_user/screen/bottom_nav_user.dart';
import '../controller/ride_complete_api_controller.dart';
import 'package:intl/intl.dart';

class RideCompletedScreen extends StatefulWidget {
  const RideCompletedScreen({super.key});

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  // We only need the API controller for this screen's data
  final RideCompleteApiController rideCompleteApiController = Get.put(RideCompleteApiController());

  @override
  void initState() {
    super.initState();

    // The most reliable way to get the ID is from the arguments passed to this screen.
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String transportId = args['transportId']?.toString() ?? '';

    if (transportId.isNotEmpty) {
      // Use a post-frame callback to ensure the widget is built before controller updates.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("RideCompletedScreen initState: Calling API with ID: $transportId");
        rideCompleteApiController.redeConpleteApiMethod(transportId);
      });
    } else {
      debugPrint("⚠️ RideCompletedScreen: No transport ID found in arguments - skipping API call.");
      // Optionally show an error immediately
      rideCompleteApiController.errorMessage.value = "Ride details could not be loaded. No ID provided.";
    }
  }

  // Helper function for creating a row of ride details
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: globalTextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: globalTextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Show a loading indicator while data is being fetched
          if (rideCompleteApiController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if the API call failed
          if (rideCompleteApiController.errorMessage.value.isNotEmpty && rideCompleteApiController.rideData.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      "Your Ride is Empty",
                      style: globalTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rideCompleteApiController.errorMessage.value,
                      style: globalTextStyle(fontSize: 16, color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      title: "Go to Home",
                      onPress: () => Get.offAll(() => BottomNavbarUser()), // Use offAll to clear nav stack
                    ),
                  ],
                ),
              ),
            );
          }

          // Main UI when data is available
          final rideData = rideCompleteApiController.rideData.value;
          final user = rideData?.user;
          final String profileImageUrl = rideData?.vehicle?.driver?.profileImage ?? ''; // Correct path to driver image
          final bool isProfileImageValid = profileImageUrl.isNotEmpty && profileImageUrl.startsWith('http');

          // Format date for display - THIS WILL NOW WORK
          final String completedDate = (rideData?.updatedAt != null && rideData!.updatedAt!.isNotEmpty)
              ? DateFormat('d MMMM yyyy').format(DateTime.parse(rideData!.updatedAt!))
              : 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Ride Completed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thank you for riding with us!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Driver info card (using driver from vehicle object)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: const Color(0xFFF0F0F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: isProfileImageValid
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: !isProfileImageValid
                            ? const Icon(Icons.person, size: 30, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        rideData?.vehicle?.driver?.fullName ?? "Driver",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Location Details section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: const Color(0xFFF0F0F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationRow(
                        icon: Icons.my_location,
                        title: 'Pickup Location',
                        location: rideData?.pickupLocation ?? 'Not specified',
                      ),
                      const SizedBox(height: 16),
                      _buildLocationRow(
                        icon: Icons.location_on,
                        title: 'Destination',
                        location: rideData?.dropOffLocation ?? 'Not specified',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ride details using helper
                _buildDetailRow("Ride Cost", "\$${rideData?.totalAmount?.toStringAsFixed(2) ?? '0.00'}"),
                _buildDetailRow("Payment method", rideData?.paymentMethod ?? 'N/A'),
                _buildDetailRow("Ride Type", rideData?.serviceType ?? 'N/A'),
                _buildDetailRow("Booking ID", rideData?.id?.substring(0, 10) ?? 'N/A'),
                _buildDetailRow("Ride Completed on", completedDate),

                const SizedBox(height: 24),
                CustomButton(
                  title: "Go to Home",
                  borderColor: Colors.transparent,
                  textStyle: globalTextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: const Color(0xFFFFDC71),
                  onPress: () {
                    Get.offAll(() => BottomNavbarUser());
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper widget for location rows to avoid code repetition
  Widget _buildLocationRow({required IconData icon, required String title, required String location}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: globalTextStyle(
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777F8B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
